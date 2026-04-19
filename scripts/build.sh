#!/bin/bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-$GIT_ROOT/.build}"
DESTINATION="${DESTINATION:-generic/platform=iOS Simulator}"
CONFIGURATION="${CONFIGURATION:-Debug}"

error_handler() {
  echo -e "\033[1;31mBuild failed at step: $CURRENT_STEP\033[0m"
  exit 1
}
trap 'error_handler' ERR

# ── Prerequisites ──────────────────────────────────────────────────
CURRENT_STEP="Install prerequisites (mint bootstrap)"
echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;33m$CURRENT_STEP\033[0m"
echo "──────────────────────────────────────────"

# Detect architecture and set Homebrew path accordingly
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

# Helper to install a brew package if missing
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

# Use absolute Homebrew path for mint to avoid shadowing by other binaries
# (e.g. npm's mint package)
MINT="$BREW_PREFIX/bin/mint"
"$MINT" bootstrap -m "$SCRIPT_DIR/.mintfile"

# Pipe xcodebuild output through xcbeautify (via function to avoid word-splitting)
run_xcbeautify() {
  "$MINT" run --silent cpisciotta/xcbeautify --disable-colored-output --is-ci --disable-logging -q
}

XCODEBUILD_COMMON=(
  -derivedDataPath "$DERIVED_DATA_PATH/DerivedData"
  -clonedSourcePackagesDirPath "$DERIVED_DATA_PATH/SourcePackages"
  -destination "$DESTINATION"
  -configuration "$CONFIGURATION"
  -sdk "iphonesimulator"
  -skipPackagePluginValidation
)

cd "$GIT_ROOT"

# ── Step 0: Validate generated mocks are up-to-date ──────────────
CURRENT_STEP="Validate generated mocks"
echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;33m$CURRENT_STEP\033[0m"
echo "──────────────────────────────────────────"

install_if_missing sourcery

"$SCRIPT_DIR/generate-mocks.sh"

if ! git diff --quiet Sources/ModaalFirebaseMocks/Generated/; then
  echo -e "\033[1;31mGenerated mocks are stale. Run scripts/generate-mocks.sh and commit the result.\033[0m"
  git diff --stat Sources/ModaalFirebaseMocks/Generated/
  exit 1
fi
echo -e "\033[0;32mMocks are up-to-date ✓\033[0m"

# ── Step 1: Build all library targets (SPM) ───────────────────────
CURRENT_STEP="Build library targets"
echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;33m$CURRENT_STEP\033[0m"
echo "──────────────────────────────────────────"

# Package name is "ModaalFirebase" → SPM auto-generates scheme "ModaalFirebase-Package"
PACKAGE_SCHEME="ModaalFirebase-Package"

xcodebuild build \
  -scheme "$PACKAGE_SCHEME" \
  "${XCODEBUILD_COMMON[@]}" \
  | run_xcbeautify

# ── Step 2: Generate + build the SampleApp (XcodeGen) ─────────────
CURRENT_STEP="Build SampleApp (API surface verification)"
echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;33m$CURRENT_STEP\033[0m"
echo "──────────────────────────────────────────"

SAMPLE_APP_DIR="$GIT_ROOT/Examples/SampleApp"

# Generate xcodeproj from xcodegen.yml
cd "$SAMPLE_APP_DIR"
"$MINT" run --silent yonaskolb/XcodeGen xcodegen generate --spec xcodegen.yml
cd "$GIT_ROOT"

xcodebuild build \
  -project "$SAMPLE_APP_DIR/SampleApp.xcodeproj" \
  -scheme "SampleApp" \
  "${XCODEBUILD_COMMON[@]}" \
  | run_xcbeautify

# ── Step 3: Run tests (if any test targets exist) ─────────────────
# Future-proof: when test targets are added, this step runs them.
CURRENT_STEP="Run tests (if present)"
echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;33m$CURRENT_STEP\033[0m"
echo "──────────────────────────────────────────"

TEST_EXIT=0
xcodebuild test \
  -scheme "$PACKAGE_SCHEME" \
  "${XCODEBUILD_COMMON[@]}" \
  | run_xcbeautify \
  || TEST_EXIT=$?

if [ $TEST_EXIT -ne 0 ]; then
  # xcodebuild exits 66 when scheme has no test action configured
  if [ $TEST_EXIT -eq 66 ]; then
    echo -e "\033[0;33m(No test targets configured — skipping)\033[0m"
  else
    echo -e "\033[1;31mTests failed (exit code $TEST_EXIT)\033[0m"
    exit $TEST_EXIT
  fi
fi

echo ""
echo "──────────────────────────────────────────"
echo -e "\033[1;32mAll steps passed ✓\033[0m"
echo "──────────────────────────────────────────"
