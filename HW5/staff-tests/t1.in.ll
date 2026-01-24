@.str0 = constant [5 x i8] c"true\00"
@.str1 = constant [5 x i8] c"true\00"
@.str2 = constant [12 x i8] c"val is true\00"
@.str3 = constant [13 x i8] c"val is false\00"

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
	call void @printByValue(i32 1)
	call void @printByValue(i32 0)
	; >>> evaluating if condition
	%t0 = icmp ne i32 1, 0
	br i1 %t0, label %label_0, label %label_1
	; >>> then block
label_0:
	%t1 = getelementptr [5 x i8], [5 x i8]* @.str0, i32 0, i32 0
	call void @print(i8* %t1)
	br label %label_1
	; >>> end if
label_1:
	; >>> evaluating if condition
	%t2 = icmp ne i32 0, 0
	br label %label_4
label_4:
	br i1 %t2, label %label_3, label %label_2
label_2:
	%t3 = icmp ne i32 0, 0
	br label %label_7
label_7:
	br i1 %t3, label %label_5, label %label_6
label_5:
	%t4 = icmp ne i32 1, 0
	br label %label_8
label_8:
	br label %label_6
label_6:
	%t5 = phi i1 [ 0, %label_7 ], [ %t4, %label_8 ]
	%t6 = zext i1 %t5 to i32
	%t7 = icmp ne i32 %t6, 0
	br label %label_9
label_9:
	br label %label_3
label_3:
	%t8 = phi i1 [ true, %label_4 ], [ %t7, %label_9 ]
	%t9 = zext i1 %t8 to i32
	%t10 = icmp ne i32 %t9, 0
	br i1 %t10, label %label_10, label %label_11
	; >>> then block
label_10:
	%t11 = getelementptr [5 x i8], [5 x i8]* @.str1, i32 0, i32 0
	call void @print(i8* %t11)
	br label %label_11
	; >>> end if
label_11:
	ret void
}

define void @printByValue(i32) {
	%t12 = alloca i32
	store i32 %0, i32* %t12
	; >>> evaluating if condition
	%t13 = load i32, i32* %t12
	%t14 = icmp ne i32 %t13, 0
	br i1 %t14, label %label_12, label %label_14
	; >>> then block
label_12:
	%t15 = getelementptr [12 x i8], [12 x i8]* @.str2, i32 0, i32 0
	call void @print(i8* %t15)
	br label %label_13
	; >>> else block
label_14:
	%t16 = getelementptr [13 x i8], [13 x i8]* @.str3, i32 0, i32 0
	call void @print(i8* %t16)
	br label %label_13
	; >>> end if
label_13:
	ret void
}

