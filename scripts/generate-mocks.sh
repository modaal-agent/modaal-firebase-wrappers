#!/bin/bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GIT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Configuration ─────────────────────────────────────────────────
TEMPLATES_REPO="https://github.com/ivanmisuno/swift-sourcery-templates.git"
TEMPLATES_TAG="0.2.12"
TEMPLATES_CACHE="$GIT_ROOT/.build/swift-sourcery-templates"

# Override TEMPLATES_DIR to point at a local checkout for iteration:
#   TEMPLATES_DIR=/path/to/swift-sourcery-templates/templates ./scripts/generate-mocks.sh
TEMPLATES_DIR="${TEMPLATES_DIR:-$TEMPLATES_CACHE/templates}"

OUTPUT_DIR="$GIT_ROOT/Sources/ModaalFirebaseMocks/Generated"
ANNOTATIONS_DIR="$GIT_ROOT/Sources/ModaalFirebaseMocks/Annotations"

# ── Prerequisites ─────────────────────────────────────────────────
if ! command -v sourcery &>/dev/null; then
  echo "Error: sourcery CLI not found."
  echo "Install with: brew install sourcery"
  exit 1
fi

echo "Using sourcery $(sourcery --version)"
echo "Templates: $TEMPLATES_DIR"
echo ""

# ── Fetch templates (if not using local override) ─────────────────
if [ "$TEMPLATES_DIR" = "$TEMPLATES_CACHE/templates" ]; then
  if [ ! -d "$TEMPLATES_CACHE" ]; then
    echo "Cloning swift-sourcery-templates@$TEMPLATES_TAG..."
    git clone --depth 1 --branch "$TEMPLATES_TAG" "$TEMPLATES_REPO" "$TEMPLATES_CACHE" 2>&1
    echo ""
  else
    # Verify we're on the expected tag
    CURRENT_TAG=$(cd "$TEMPLATES_CACHE" && git describe --tags --exact-match 2>/dev/null || echo "unknown")
    if [ "$CURRENT_TAG" != "$TEMPLATES_TAG" ]; then
      echo "Templates at $CURRENT_TAG, expected $TEMPLATES_TAG. Re-cloning..."
      rm -rf "$TEMPLATES_CACHE"
      git clone --depth 1 --branch "$TEMPLATES_TAG" "$TEMPLATES_REPO" "$TEMPLATES_CACHE" 2>&1
      echo ""
    fi
  fi
fi

if [ ! -f "$TEMPLATES_DIR/Mocks.swifttemplate" ]; then
  echo "Error: Mocks.swifttemplate not found at $TEMPLATES_DIR"
  exit 1
fi

# ── Prepare output directory ──────────────────────────────────────
mkdir -p "$OUTPUT_DIR"

# ── Generate mocks per module ─────────────────────────────────────
#
# Each module gets a separate sourcery run producing one output file.
# --args passes import= for regular imports, testable= for @testable imports.
# Only protocols annotated with `/// sourcery: CreateMock` are processed.

generate_module() {
  local module="$1"
  shift
  local sources_dir="$GIT_ROOT/Sources/$module"
  local output_file="$OUTPUT_DIR/${module}Mocks.swift"

  # Build --args: Foundation is always needed, module is @testable,
  # any extra args (e.g. import=UIKit) are passed through.
  local args=("--args" "import=Foundation,testable=$module")
  for extra in "$@"; do
    args+=("--args" "$extra")
  done

  echo "Generating mocks for $module..."
  sourcery \
    --sources "$sources_dir" \
    --sources "$ANNOTATIONS_DIR" \
    --templates "$TEMPLATES_DIR/Mocks.swifttemplate" \
    --output "$output_file" \
    "${args[@]}" \
    --quiet

  if [ -f "$output_file" ]; then
    local count
    count=$(grep -c "^class .*Mock" "$output_file" 2>/dev/null || echo "0")
    echo "  → $output_file ($count mocks)"
  else
    echo "  → No output generated"
  fi
}

generate_module "ModaalFirebaseAuth" "import=UIKit"
generate_module "ModaalFirebaseAnalytics"
generate_module "ModaalFirebaseCrashlytics"
generate_module "ModaalFirestore"
generate_module "ModaalCloudStorage"
generate_module "ModaalFirebaseMessaging"
generate_module "ModaalFirebaseRemoteConfig"

echo ""
echo "Done. Generated mocks in $OUTPUT_DIR"
