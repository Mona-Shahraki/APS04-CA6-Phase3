#!/bin/bash
# judge.sh
# This script builds the project and runs automated tests by passing the CSV file as a command line argument.

echo "Compiling the project..."
make clean
make

if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

# Find all .in test input files in the test directory recursively
TEST_CASES=$(find ./test -type f -name "*.in")

if [ -z "$TEST_CASES" ]; then
    echo "No test cases found in the test directory."
    exit 1
fi

TOTAL=0
PASSED=0
FAILED_TESTS=()  # آرایه برای ذخیره نام تست‌های ناموفق

# Change the CSV file path as necessary.
CSV_FILE="./csv/holidays.csv"

# Loop through each test case:
for in_file in $TEST_CASES; do
    TOTAL=$((TOTAL + 1))
    # Assume the expected output file has the same name as the input file with a .out extension.
    base="${in_file%.in}"
    expected="${base}.out"
    output="${base}.temp"

    echo "Running test: $in_file"
    # Run the executable by passing the CSV file as the first argument.
    # The program is expected to parse the CSV file from its command line.
    ./UTrello "$CSV_FILE" < "$in_file" > "$output"

    # Normalize output files to ignore trailing newlines
    awk 'NF{print $0}' "$expected" > "${expected}.normalized"
    awk 'NF{print $0}' "$output" > "${output}.normalized"

    # Compare the produced output with the expected output using diff.
    if diff -q "${expected}.normalized" "${output}.normalized" >/dev/null; then
        echo "Test $(basename "$in_file") passed."
        PASSED=$((PASSED + 1))
    else
        echo "Test $(basename "$in_file") failed."
        FAILED_TESTS+=("$(basename "$in_file")")  # ذخیره نام تست ناموفق
        echo "Differences:"
        diff "${expected}.normalized" "${output}.normalized"
    fi

    # Clean up temporary normalized files
    rm -f "${expected}.normalized" "${output}.normalized"
done

echo "Total tests: $TOTAL, Passed: $PASSED, Failed: $((TOTAL - PASSED))"

# نمایش نام تست‌های ناموفق در انتهای خروجی
if [ ${#FAILED_TESTS[@]} -ne 0 ]; then
    echo "Failed test cases:"
    for test in "${FAILED_TESTS[@]}"; do
        echo "- $test"
    done
fi