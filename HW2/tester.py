import os
import subprocess
import glob

def run_tests(test_dir="./tests", executable_path="./my_hw.exe"):
    """
    1. Runs the executable with input from a .in file, saving output to a .res file.
    2. Compares the .res file against the expected .out file using diff.
    """
    
    # 1. Find all input files
    input_files = glob.glob(os.path.join(test_dir, "*.in"))
    
    if not input_files:
        print(f"❌ No .in files found in directory: {test_dir}")
        return

    print(f"🔎 Found {len(input_files)} test cases.")
    print("-" * 40)

    all_passed = True

    for in_path in sorted(input_files):
        # 2. Derive paths for expected output (.out) and actual result (.res)
        test_base_name = os.path.splitext(os.path.basename(in_path))[0]
        out_path = os.path.join(test_dir, f"{test_base_name}.out")
        res_path = os.path.join(test_dir, f"{test_base_name}.res")
        
        print(f"Testing: **{test_base_name}**...")

        if not os.path.exists(out_path):
            print(f"   ⚠️ **WARNING:** Missing expected output file: {out_path}")
            all_passed = False
            continue

        # --- STEP 1: Execute Program and Capture Output to .res file ---
        try:
            # Open the input file for reading
            with open(in_path, 'r') as infile:
                # Execute the program. Input is taken from 'infile', output is captured.
                program_result = subprocess.run(
                    [executable_path],
                    stdin=infile,
                    capture_output=True,
                    text=True,
                    check=False # Do not raise an exception if the program itself fails
                )
            
            # Save the captured stdout (the result) to the .res file
            with open(res_path, 'w') as resfile:
                resfile.write(program_result.stdout)

        except FileNotFoundError:
            print(f"   🛑 **Error:** Executable not found at {executable_path}. Check the path.")
            all_passed = False
            continue
        except Exception as e:
            print(f"   🔥 **Execution Error:** {e}")
            all_passed = False
            continue

        # --- STEP 2: Compare .res with .out using diff ---
        
        # We use diff to compare the actual result (.res) against the expected output (.out)
        diff_command = [
            'diff',
            '--strip-trailing-cr', # Keep this to ignore Windows vs Unix line endings
            out_path,              # Expected output (file 1)
            res_path               # Actual result (file 2)
        ]

        try:
            # Run diff. We don't need shell=True here!
            diff_result = subprocess.run(
                diff_command,
                check=False, 
                capture_output=True,
                text=True
            )

            # Check the return code: 0=Pass, 1=Fail, 2=Error
            if diff_result.returncode == 0:
                print("   ✅ **Test Passed!** Output matches expected.")
            elif diff_result.returncode == 1:
                all_passed = False
                print("   ❌ **Test Failed!** Differences found:")
                print("   " + "=" * 40)
                # Print the diff output
                print(diff_result.stdout.strip())
                print("   " + "=" * 40)
            else: 
                all_passed = False
                print(f"   🛑 **Diff Error** (Exit Code {diff_result.returncode}):")
                print(diff_result.stderr.strip())

        except Exception as e:
            all_passed = False
            print(f"   🔥 An exception occurred during diff: {e}")
        
        print("-" * 40)

    if all_passed:
        print("🎉 **All tests completed successfully!**")
    else:
        print("⚠️ **One or more tests failed.** Check the output above and the generated .res files.")

if __name__ == "__main__":
    # Configure your paths here
    TEST_FOLDER = "./myTests" 
    EXECUTABLE = "./hw2"
    
    run_tests(TEST_FOLDER, EXECUTABLE)