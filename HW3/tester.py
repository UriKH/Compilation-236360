import os
import glob
import subprocess
import sys
import difflib

# --- CONFIGURATION ---
EXECUTABLE = "./hw3"   # Name of your compiled program
TEST_DIR = "./dani_tests"         # Directory containing the .in/.out files
# ---------------------

def normalize_output(text):
    """Normalizes line endings to prevent Windows/Linux mismatch."""
    return text.replace('\r\n', '\n')

def run_tests():
    # 1. Find all .in files
    in_files = glob.glob(os.path.join(TEST_DIR, "*.in"))
    in_files.sort()

    if not in_files:
        print(f"No .in files found in {TEST_DIR}")
        return

    # Check if executable exists
    if not os.path.exists(EXECUTABLE) and not os.path.exists(EXECUTABLE + ".exe"):
        print(f"Error: Executable '{EXECUTABLE}' not found. Did you run 'make'?")
        return

    print(f"{'Test Name':<30} | {'Result':<10}")
    print("-" * 45)

    passed_count = 0
    failed_count = 0

    for in_file in in_files:
        # 2. Determine corresponding .out filename
        # Replaces the last instance of .in with .out
        base_name = in_file[:-3] 
        expected_out_file = base_name + ".out"
        test_name = os.path.basename(base_name)

        if not os.path.exists(expected_out_file):
            print(f"{test_name:<30} | SKIP (Missing .out file)")
            continue

        # 3. Run the executable
        try:
            with open(in_file, 'r') as f_in:
                # Equivalent to: ./hw3 < test.in 2>&1
                result = subprocess.run(
                    [EXECUTABLE],
                    stdin=f_in,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.STDOUT, # Combine stderr into stdout (crucial for error tests)
                    text=True
                )
                actual_output = normalize_output(result.stdout)
        except Exception as e:
            print(f"{test_name:<30} | EXECUTION ERROR: {e}")
            failed_count += 1
            continue

        # 4. Read Expected Output
        try:
            with open(expected_out_file, 'r') as f_out:
                expected_output = normalize_output(f_out.read())
        except Exception as e:
            print(f"{test_name:<30} | FILE ERROR: {e}")
            failed_count += 1
            continue

        # 5. Compare
        # We strip trailing whitespace from both to be slightly forgiving of newline differences at EOF
        if actual_output.strip() == expected_output.strip():
            print(f"{test_name:<30} | PASS")
            passed_count += 1
        else:
            print(f"{test_name:<30} | FAIL")
            failed_count += 1
            
            # Optional: Print the first few lines of the diff to help debug
            print(f"   --- Diff for {test_name} ---")
            diff = difflib.unified_diff(
                expected_output.splitlines(), 
                actual_output.splitlines(), 
                fromfile='Expected', 
                tofile='Actual', 
                lineterm=''
            )
            for line in list(diff)[:10]: # Limit diff output
                print(f"   {line}")
            print("   ---------------------------")

    # 6. Summary
    print("-" * 45)
    total = passed_count + failed_count
    print(f"Summary: {passed_count}/{total} passed.")

    if failed_count > 0:
        sys.exit(1) # Exit with error code if any test failed

if __name__ == "__main__":
    run_tests()