@.str0 = constant [12 x i8] c"val is true\00"
@.str1 = constant [13 x i8] c"val is false\00"
@.str2 = constant [5 x i8] c"true\00"
@.str3 = constant [5 x i8] c"true\00"

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

define void @printByValue(i32) {
	%t0 = alloca i32
	store i32 %0, i32* %t0
	; >>> evaluating if condition
	%t1 = load i32, i32* %t0
	%t2 = icmp ne i32 %t1, 0
	br i1 %t2, label %label_0, label %label_2
	; >>> then block
label_0:
	%t3 = getelementptr [12 x i8], [12 x i8]* @.str0, i32 0, i32 0
	call void @print(i8* %t3)
	br label %label_1
	; >>> else block
label_2:
	%t4 = getelementptr [13 x i8], [13 x i8]* @.str1, i32 0, i32 0
	call void @print(i8* %t4)
	br label %label_1
	; >>> end if
label_1:
	ret void
}

define void @main() {
	call void @printByValue(i32 1)
	call void @printByValue(i32 0)
	; >>> evaluating if condition
	%t5 = icmp ne i32 1, 0
	br i1 %t5, label %label_3, label %label_4
	; >>> then block
label_3:
	%t6 = getelementptr [5 x i8], [5 x i8]* @.str2, i32 0, i32 0
	call void @print(i8* %t6)
	br label %label_4
	; >>> end if
label_4:
	; >>> evaluating if condition
	%t7 = icmp ne i32 0, 0
	br label %label_7
label_7:
	br i1 %t7, label %label_6, label %label_5
label_5:
	%t8 = icmp ne i32 0, 0
	br label %label_10
label_10:
	br i1 %t8, label %label_8, label %label_9
label_8:
	%t9 = icmp ne i32 1, 0
	br label %label_11
label_11:
	br label %label_9
label_9:
	%t10 = phi i1 [ 0, %label_10 ], [ %t9, %label_11 ]
	%t11 = zext i1 %t10 to i32
	%t12 = icmp ne i32 %t11, 0
	br label %label_12
label_12:
	br label %label_6
label_6:
	%t13 = phi i1 [ true, %label_7 ], [ %t12, %label_12 ]
	%t14 = zext i1 %t13 to i32
	%t15 = icmp ne i32 %t14, 0
	br i1 %t15, label %label_13, label %label_14
	; >>> then block
label_13:
	%t16 = getelementptr [5 x i8], [5 x i8]* @.str3, i32 0, i32 0
	call void @print(i8* %t16)
	br label %label_14
	; >>> end if
label_14:
	ret void
}

