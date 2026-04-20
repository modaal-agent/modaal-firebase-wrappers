#!/bin/bash
set -eo pipefail

# Runs the Firebase Emulator-backed smoke + integration tests end-to-end:
# installs firebase-tools, starts the emulator, runs xcodebuild test against
# the concrete iOS Simulator, and tears the emulator down on exit.
#
# Idempotent and self-sufficient: `bash scripts/run-integration-tests.sh`
# works on a fresh macOS checkout as long as Homebrew is installed.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$GIT_ROOT/.build}"
CONFIGURATION="${CONFIGURATION:-Debug}"
FIREBASE_TOOLS_VERSION="${FIREBASE_TOOLS_VERSION:-14}"
EMULATOR_PROJECT="${EMULATOR_PROJECT:-demo-modaal}"
EMULATOR_HOST="${EMULATOR_HOST:-localhost}"
FIRESTORE_PORT="${FIRESTORE_PORT:-8080}"
AUTH_PORT="${AUTH_PORT:-9099}"
STORAGE_PORT="${STORAGE_PORT:-9199}"
EMULATOR_READY_TIMEOUT="${EMULATOR_READY_TIMEOUT:-60}"
EMU_LOG="${EMU_LOG:-$DERIVED_DATA_PATH/emulator.log}"

CURRENT_STEP="startup"

error_handler() {
  echo -e "\033[1;31mFailed at step: $CURRENT_STEP\033[0m"
  if [ -f "$EMU_LOG" ]; then
    echo "--- Emulator log tail ---"
    tail -40 "$EMU_LOG" || true
  fi
  exit 1
}
trap 'error_handler' ERR

cleanup() {
  if [ -n "${EMU_PID:-}" ] && kill -0 "$EMU_PID" 2>/dev/null; then
    echo "Stopping Firebase Emulator (PID $EMU_PID)..."
    kill "$EMU_PID" 2>/dev/null || true
    wait "$EMU_PID" 2>/dev/null || true
  fi
}
trap 'cleanup' EXIT

# ── Prerequisites ──────────────────────────────────────────────────
CURRENT_STEP="Install prerequisites (brew + mint + firebase-tools)"
echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;33m$CURRENT_STEP\033[0m"
echo "──────────────────────────────────────────"

ARCH="$(uname -m)"
if [ "$ARCH" = "arm64" ]; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi
BREW="$BREW_PREFIX/bin/brew"

if [ ! -x "$BREW" ]; then
  echo "Error: Homebrew not found at $BREW" >&2
  exit 1
fi

install_if_missing() {
  local cmd="$1"
  local pkg="${2:-$1}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    if "$BREW" list --formula "$pkg" >/dev/null 2>&1; then
      "$BREW" reinstall "$pkg"
    else
      "$BREW" install "$pkg"
    fi
  fi
}

install_if_missing mint
install_if_missing node

# Firebase Emulator Suite requires Java (>=21 for firebase-tools v15+). Use a
# keg-only brew formula (no sudo, no system-wide install) and prepend it to
# PATH just for this process.
JDK_FORMULA="${JDK_FORMULA:-openjdk@21}"
if ! "$BREW" list --formula "$JDK_FORMULA" >/dev/null 2>&1; then
  echo "Installing $JDK_FORMULA..."
  "$BREW" install "$JDK_FORMULA"
fi
if [ -d "$BREW_PREFIX/opt/$JDK_FORMULA/bin" ]; then
  export PATH="$BREW_PREFIX/opt/$JDK_FORMULA/bin:$PATH"
fi
if ! java -version >/dev/null 2>&1; then
  echo "Error: 'java' from $JDK_FORMULA not on PATH after install." >&2
  exit 1
fi

# firebase-tools is distributed via npm. Pin the major version to insulate
# against emulator protocol drift.
if ! command -v firebase >/dev/null 2>&1; then
  echo "Installing firebase-tools@${FIREBASE_TOOLS_VERSION}..."
  npm install -g "firebase-tools@${FIREBASE_TOOLS_VERSION}"
fi

MINT="$BREW_PREFIX/bin/mint"
"$MINT" bootstrap -m "$SCRIPT_DIR/.mintfile"

run_xcbeautify() {
  "$MINT" run --silent cpisciotta/xcbeautify --disable-colored-output --is-ci --disable-logging -q
}

XCODEBUILD_COMMON=(
  -derivedDataPath "$DERIVED_DATA_PATH/DerivedData"
  -clonedSourcePackagesDirPath "$DERIVED_DATA_PATH/SourcePackages"
  -configuration "$CONFIGURATION"
  -sdk "iphonesimulator"
  -skipPackagePluginValidation
)

cd "$GIT_ROOT"

# ── Start Firebase Emulator ────────────────────────────────────────
CURRENT_STEP="Start Firebase Emulator"
echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;33m$CURRENT_STEP\033[0m"
echo "──────────────────────────────────────────"

mkdir -p "$DERIVED_DATA_PATH"

# Free ports in case a previous run left a zombie.
for PORT in "$FIRESTORE_PORT" "$AUTH_PORT" "$STORAGE_PORT"; do
  if lsof -ti tcp:"$PORT" >/dev/null 2>&1; then
    echo "Port $PORT is in use; killing existing listener..."
    lsof -ti tcp:"$PORT" | xargs kill -9 2>/dev/null || true
  fi
done

firebase emulators:start \
  --only firestore,auth,storage \
  --project "$EMULATOR_PROJECT" \
  > "$EMU_LOG" 2>&1 &
EMU_PID=$!
echo "Emulator PID: $EMU_PID — log: $EMU_LOG"

# Wait for all three services to respond on their ports. We only need TCP to
# accept + server to answer any HTTP status code (emulator root routes return
# 200 or 404 depending on service; both mean "alive").
wait_for_port() {
  local port="$1"
  local name="$2"
  local deadline=$(( SECONDS + EMULATOR_READY_TIMEOUT ))
  until curl -s -o /dev/null "http://${EMULATOR_HOST}:${port}"; do
    if ! kill -0 "$EMU_PID" 2>/dev/null; then
      echo "Emulator process exited before ${name} was ready." >&2
      return 1
    fi
    if [ "$SECONDS" -ge "$deadline" ]; then
      echo "Timed out waiting for ${name} on port ${port}" >&2
      return 1
    fi
    sleep 1
  done
  echo "  ✓ ${name} ready on :${port}"
}

wait_for_port "$FIRESTORE_PORT" "Firestore emulator"
wait_for_port "$AUTH_PORT" "Auth emulator"
wait_for_port "$STORAGE_PORT" "Storage emulator"

# ── Discover iOS Simulator ─────────────────────────────────────────
CURRENT_STEP="Discover iOS Simulator"
echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;33m$CURRENT_STEP\033[0m"
echo "──────────────────────────────────────────"

TEST_UDID=$(xcrun simctl list devices available \
  | grep -E "^[[:space:]]*iPhone" \
  | grep -oE "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" \
  | head -1 || true)

if [ -z "$TEST_UDID" ]; then
  echo -e "\033[1;31mNo available iPhone Simulator found\033[0m"
  xcrun simctl list devices available
  exit 1
fi

TEST_DESTINATION="platform=iOS Simulator,id=$TEST_UDID"
echo "Using test destination: $TEST_DESTINATION"

# Make sure the simulator is booted before we set env on it.
xcrun simctl boot "$TEST_UDID" 2>/dev/null || true
xcrun simctl bootstatus "$TEST_UDID" -b

# Inject emulator coords into the simulator environment. Child processes
# launched on the sim (including the test host + xctest bundle) inherit these.
xcrun simctl spawn "$TEST_UDID" launchctl setenv MODAAL_EMULATOR_HOST "$EMULATOR_HOST"
xcrun simctl spawn "$TEST_UDID" launchctl setenv MODAAL_FIRESTORE_PORT "$FIRESTORE_PORT"
xcrun simctl spawn "$TEST_UDID" launchctl setenv MODAAL_AUTH_PORT "$AUTH_PORT"
xcrun simctl spawn "$TEST_UDID" launchctl setenv MODAAL_STORAGE_PORT "$STORAGE_PORT"

# ── Generate EmulatorTests project ─────────────────────────────────
CURRENT_STEP="Generate EmulatorTests Xcode project"
echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;33m$CURRENT_STEP\033[0m"
echo "──────────────────────────────────────────"

EMULATOR_TESTS_DIR="$GIT_ROOT/Tests/EmulatorTests"
(cd "$EMULATOR_TESTS_DIR" && "$MINT" run --silent yonaskolb/XcodeGen xcodegen generate --spec xcodegen.yml)

# ── Run integration + smoke tests ──────────────────────────────────
CURRENT_STEP="Run emulator-backed tests"
echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;33m$CURRENT_STEP\033[0m"
echo "──────────────────────────────────────────"

xcodebuild test \
  -project "$EMULATOR_TESTS_DIR/EmulatorTests.xcodeproj" \
  -scheme "EmulatorTests" \
  -destination "$TEST_DESTINATION" \
  "${XCODEBUILD_COMMON[@]}" \
  | run_xcbeautify

echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;32mIntegration tests passed ✓\033[0m"
echo "──────────────────────────────────────────"
