@.str0 = constant [5 x i8] c"foo!\00"

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

define void @foo() {
	%t0 = getelementptr [5 x i8], [5 x i8]* @.str0, i32 0, i32 0
	call void @print(i8* %t0)
	ret void
}

define void @bar(i32) {
	%t1 = alloca i32
	store i32 %0, i32* %t1
	%t2 = load i32, i32* %t1
	call void @printi(i32 %t2)
	ret void
}

define void @moo(i32) {
	%t3 = alloca i32
	store i32 %0, i32* %t3
	; >>> evaluating if condition
	%t4 = load i32, i32* %t3
	%t5 = icmp ne i32 %t4, 0
	br i1 %t5, label %label_0, label %label_2
	; >>> then block
label_0:
	call void @foo()
	br label %label_1
	; >>> else block
label_2:
	call void @bar(i32 110)
	br label %label_1
	; >>> end if
label_1:
	ret void
}

define void @main() {
	call void @foo()
	call void @bar(i32 150)
	call void @moo(i32 1)
	call void @foo()
	call void @moo(i32 0)
	ret void
}

