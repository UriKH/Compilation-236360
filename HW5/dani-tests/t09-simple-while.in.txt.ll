@.str0 = constant [29 x i8] c"never gonna happen hopefully\00"

; =================================== Declarations of built-in functions ===================================
declare i32 @scanf(i8*, ...)
declare i32 @printf(i8*, ...)
declare void @exit(i32)
@.int_specifier_scan = constant [3 x i8] c"%d\00"
@.int_specifier = constant [4 x i8] c"%d\0A\00"
@.str_specifier = constant [4 x i8] c"%s\0A\00"

; =================================== Definitions of built-in functions ===================================
define i32 @readi(i32) {
	%ret_val = alloca i32
	%spec_ptr = getelementptr [3 x i8], [3 x i8]* @.int_specifier_scan, i32 0, i32 0
	call i32 (i8*, ...) @scanf(i8* %spec_ptr, i32* %ret_val)
	%val = load i32, i32* %ret_val
	ret i32 %val
}

define void @printi(i32) {
	%spec_ptr = getelementptr [4 x i8], [4 x i8]* @.int_specifier, i32 0, i32 0
	call i32 (i8*, ...) @printf(i8* %spec_ptr, i32 %0)
	ret void
}

define void @print(i8*) {
	%spec_ptr = getelementptr [4 x i8], [4 x i8]* @.str_specifier, i32 0, i32 0
	call i32 (i8*, ...) @printf(i8* %spec_ptr, i8* %0)
	ret void
}

; =================================== End of built-in functions ===================================

define void @main() {
	; >>> Begin while condition evaluation
	br label %label_1
label_1:
	%t0 = icmp ne i32 0, 0
	br i1 %t0, label %label_0, label %label_2
	; >>> Begin while code
label_0:
	%t1 = getelementptr [29 x i8], [29 x i8]* @.str0, i32 0, i32 0
	call void @print(i8* %t1)
	br label %label_1
	; >>> end while block
label_2:
	%t2 = alloca i32
	store i32 0, i32* %t2
	; >>> Begin while condition evaluation
	br label %label_4
label_4:
	%t3 = load i32, i32* %t2
	%t5 = icmp slt i32 %t3, 10
	%t6 = zext i1 %t5 to i32
	%t7 = icmp ne i32 %t6, 0
	br i1 %t7, label %label_3, label %label_5
	; >>> Begin while code
label_3:
	%t8 = load i32, i32* %t2
	call void @printi(i32 %t8)
	%t9 = load i32, i32* %t2
	%t10 = add i32 %t9, 1
	store i32 %t10, i32* %t2
	br label %label_4
	; >>> end while block
label_5:
	ret void
}

