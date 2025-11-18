import os

def write_strings_to_files(strings):
    # Create the directory "tests" if it doesn't exist
    os.makedirs("tests", exist_ok=True)

    # Loop through the list of strings and write each to a separate file
    for i, text in enumerate(strings, start=1):
        filename = f"tests/output_{i}.txt"
        with open(filename, "w", encoding="utf-8") as f:
            f.write(text)

    print(f"Created {len(strings)} files inside the 'tests' folder.")


if __name__ == '__main__':
    write_strings_to_files(
        [
            'x max OO7 diov long bit nibble boolean And Or light Not True False Return If IF Else ELSE While Break bREAK Continue CONTINUE', # expect all IDs
            '.', # bad Char
            '_', # bad Char
            '12AB', # BAD ID
            'big_x', # bad ID
            '050', # BAD NUM
            '5.6', # BAD NUM
            '0 102', # ok num
            '050b', # bad num
            '5.6b', # bad num
            '0b 102b', # good num
            '// comment ok', # good comment
            '/* not good! */', # bad comment
            '\' unmatching "', # bad str
            '" unclosed', # bad str
            '"2-lined\nstr"', # badstr
            '"ba-"-d"', # bad str
            '"bad \\ escape"', # 
            '"hex \\x10"', # bad hex
            '"hex \\x0"', # bad str
            '"bad \\."', # bad str
            '"unclosed\n"', # bad str (unclosed)
            '"unclosed\n\r"', # bad str (unclosed)
            '"unclosed\r\n"', # bad str (unkown char \r)
            '"@!#-_+*.?/~%^&\'" "simple" "also \'simple\'" "escape new lines\\n" "hex2 \\x34" "hi\\tow\\tare\\tyou" ""', # good str
            '@','#','~', '?' # bad characters 
        ]
    )