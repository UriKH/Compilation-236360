#!/usr/bin/env bash
set -u

# 1. Setup paths relative to this script
# ROOT assumes this script is inside 'dani-tests', so root is one level up
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="${BIN:-$ROOT/hw5}"
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT/test_build}"
LLI_BIN="${LLI:-}"

mkdir -p "$BUILD_DIR"

# 2. Color helper functions
red() { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }

# 3. Ensure the compiler is built
ensure_built() {
    if [[ ! -x "$BIN" ]]; then
        yellow "[build] '$BIN' not found/executable. Running 'make'..."
        (cd "$ROOT" && make)
    fi
    if [[ ! -x "$BIN" ]]; then
        red "[build] Failed: '$BIN' still not executable."
        exit 2
    fi
}

# 4. Find the lli (LLVM interpreter) executable
find_lli() {
    if [[ -n "$LLI_BIN" ]]; then return; fi
    if command -v lli >/dev/null 2>&1; then
        LLI_BIN="$(command -v lli)"
    elif [ -f "/usr/lib/llvm-10/bin/lli" ]; then
         LLI_BIN="/usr/lib/llvm-10/bin/lli"
    else
        echo "lli not found. Please set LLI variable."
        exit 1
    fi
}

ensure_built
find_lli

# 5. Run the tests
PASS=0
FAIL=0
SKIP=0

echo "Running tests from: $TESTS_DIR"

# Loop over all .in.txt files (e.g., t01.in.txt)
for test_file in "$TESTS_DIR"/*.in.txt; do
    # Extract base name (e.g., "t01")
    filename=$(basename "$test_file")
    test_name="${filename%.in.txt}"

    # Define expected files
    expected_out="$TESTS_DIR/$test_name.out"
    generated_ll="$BUILD_DIR/$test_name.ll"
    generated_out="$BUILD_DIR/$test_name.res"

    # Skip if no corresponding .out file exists
    if [[ ! -f "$expected_out" ]]; then
        yellow "[SKIP] $test_name: No .out file found."
        SKIP=$((SKIP + 1))
        continue
    fi

    # Run your compiler (hw5) -> produces .ll
    "$BIN" < "$test_file" > "$generated_ll" 2>/dev/null
    if [[ $? -ne 0 ]]; then
        red "[FAIL] $test_name: Compiler crashed or returned error."
        FAIL=$((FAIL + 1))
        continue
    fi

    # Run lli on the generated .ll -> produces execution output
    "$LLI_BIN" "$generated_ll" > "$generated_out" 2>&1

    # Compare output
    # Modified here: Added --strip-trailing-cr
    if diff -q --strip-trailing-cr "$expected_out" "$generated_out" >/dev/null; then
        green "[PASS] $test_name"
        PASS=$((PASS + 1))
    else
        red "[FAIL] $test_name"
        # Optional: Show diff with the same flag
        # diff --strip-trailing-cr "$expected_out" "$generated_out" | head -n 5
        FAIL=$((FAIL + 1))
    fi
done

echo "--------------------------------"
echo "Summary: PASS=$PASS  FAIL=$FAIL  SKIP=$SKIP"
if [[ $FAIL -gt 0 ]]; then
    exit 1
fi