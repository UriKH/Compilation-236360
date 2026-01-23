import os
import subprocess
import sys
import glob

# ================= CONFIGURATION =================
# The folder where your tests are located
TESTS_DIR = "dani-tests" 

# The name of your compiler executable
COMPILER_EXEC = "./hw5"

# The command to run LLVM IR
LLI_EXEC = "lli"
# =================================================

# ANSI colors for terminal output
class Colors:
    HEADER = '\033[95m'
    OKGREEN = '\033[92m'
    FAIL = '\033[91m'
    WARNING = '\033[93m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

def get_test_files(directory):
    """Finds all input files ending in .in or .in.txt"""
    # Look for *.in
    files = glob.glob(os.path.join(directory, "*.in"))
    # Look for *.in.txt
    files += glob.glob(os.path.join(directory, "*.in.txt"))
    return sorted(files)

def get_expected_output_file(input_file):
    """Determines the expected output file path based on input name"""
    # Logic: replace .in.txt with .out, or .in with .out
    if input_file.endswith(".in.txt"):
        return input_file.replace(".in.txt", ".out")
    elif input_file.endswith(".in"):
        return input_file.replace(".in", ".out")
    return None

def run_tests():
    # 1. Compile the project first
    print(f"{Colors.HEADER}--- Compiling Project (make) ---{Colors.ENDC}")
    make_process = subprocess.run(["make"], capture_output=True, text=True)
    if make_process.returncode != 0:
        print(f"{Colors.FAIL}Build failed!{Colors.ENDC}")
        print(make_process.stderr)
        return

    # 2. Find tests
    test_files = get_test_files(TESTS_DIR)
    if not test_files:
        print(f"{Colors.WARNING}No test files found in folder '{TESTS_DIR}'{Colors.ENDC}")
        return

    print(f"{Colors.HEADER}--- Running {len(test_files)} Tests ---{Colors.ENDC}")
    
    passed = 0
    failed = 0

    for input_file in test_files:
        test_name = os.path.basename(input_file)
        expected_file = get_expected_output_file(input_file)
        
        # Check if expected output exists
        if not os.path.exists(expected_file):
            print(f"{Colors.WARNING}[SKIP] {test_name}: Missing .out file{Colors.ENDC}")
            continue

        # --- STEP A: Run Compiler (./hw5 < input) ---
        try:
            with open(input_file, 'r') as fin:
                # We capture stdout because your main.cpp prints the IR/Errors to cout
                compiler_process = subprocess.run(
                    [COMPILER_EXEC], 
                    stdin=fin, 
                    capture_output=True, 
                    text=True
                )
        except FileNotFoundError:
            print(f"{Colors.FAIL}Error: Executable {COMPILER_EXEC} not found.{Colors.ENDC}")
            return

        compiler_output = compiler_process.stdout
        
        # --- STEP B: Determine if we run lli or check for compile errors ---
        # Your error functions (errorUndef, errorSyn, etc.) print "line X:" to stdout.
        # If the output contains "line <number>:", it's a compilation error test.
        
        actual_output = ""
        
        is_compile_error = "line " in compiler_output and ":" in compiler_output
        
        if is_compile_error:
            # The test expects a compilation error (semantic/syntax)
            actual_output = compiler_output
        else:
            # The test expects valid execution. Run LLI.
            # Save IR to a temporary file
            ll_file_path = input_file + ".ll"
            with open(ll_file_path, "w") as fll:
                fll.write(compiler_output)
            
            # Run lli
            lli_process = subprocess.run(
                [LLI_EXEC, ll_file_path],
                capture_output=True,
                text=True
            )
            
            if lli_process.returncode != 0:
                # lli crashed (segfault or bad IR)
                actual_output = f"LLI ERROR:\n{lli_process.stderr}"
            else:
                actual_output = lli_process.stdout
            
            # Cleanup .ll file (optional)
            # os.remove(ll_file_path) 

        # --- STEP C: Compare Results ---
        with open(expected_file, 'r') as fexp:
            expected_content = fexp.read()

        # Normalize line endings and strip whitespace
        if actual_output.strip() == expected_content.strip():
            print(f"{Colors.OKGREEN}[PASS] {test_name}{Colors.ENDC}")
            passed += 1
        else:
            print(f"{Colors.FAIL}[FAIL] {test_name}{Colors.ENDC}")
            print(f"{Colors.BOLD}Expected:{Colors.ENDC}\n{expected_content.strip()}")
            print(f"{Colors.BOLD}Got:{Colors.ENDC}\n{actual_output.strip()}")
            print("-" * 30)
            failed += 1

    # --- Summary ---
    print(f"\n{Colors.HEADER}Summary:{Colors.ENDC}")
    print(f"Passed: {Colors.OKGREEN}{passed}{Colors.ENDC}")
    print(f"Failed: {Colors.FAIL}{failed}{Colors.ENDC}")

if __name__ == "__main__":
    run_tests()