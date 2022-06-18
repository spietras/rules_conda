#!/usr/bin/env sh

ROOT_DIR="$(cd -- "$(dirname -- "$0")/.." >/dev/null 2>&1 && pwd 2>/dev/null)"
TESTS_DIR="${ROOT_DIR%/}/tests"

if ! cd "$TESTS_DIR"; then
    echo "Error: can't cd into $TESTS_DIR"
    exit 1
fi

tests=0
passed=0
failed=0

for d in */; do
    [ -L "${d%/}" ] && continue
    cd "$d" || continue

    echo
    echo "Testing ${d%/}..."
    echo

    if ../../scripts/bazelw test --test_output=all --test_arg=--verbose --test_arg=-rA ...; then
        passed=$((passed + 1))
    else
        failed=$((failed + 1))
    fi
    tests=$((tests + 1))
    
    cd ..
done

echo
echo "**********************************************"
echo
echo "Tests completed. All: $tests, Passed: $passed, Failed: $failed."
echo
echo "**********************************************"
echo

if [ "$failed" -ne 0 ]; then
    exit 2
fi
