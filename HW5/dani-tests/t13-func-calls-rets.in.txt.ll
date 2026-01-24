@.str0 = constant [5 x i8] c"true\00"
@.str1 = constant [6 x i8] c"false\00"
@.str2 = constant [5 x i8] c"true\00"
@.str3 = constant [6 x i8] c"false\00"
@.str4 = constant [5 x i8] c"true\00"
@.str5 = constant [6 x i8] c"false\00"

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

define i32 @func1() {
	%t0 = mul i32 2, 3
	%t1 = add i32 1, %t0
	%t2 = add i32 %t1, 4
	ret i32 %t2
label_0:
	ret i32 0
}

define i32 @func2() {
	ret i32 100
label_1:
	ret i32 0
}

define i32 @func3() {
	ret i32 1
label_2:
	ret i32 0
}

define i32 @func4() {
	ret i32 67
label_3:
	ret i32 0
}

define i32 @func5(i32) {
	%t3 = alloca i32
	store i32 %0, i32* %t3
	%t4 = load i32, i32* %t3
	%t5 = icmp ne i32 %t4, 0
	br label %label_6
label_6:
	br i1 %t5, label %label_5, label %label_4
label_4:
	%t6 = load i32, i32* %t3
	%t7 = xor i32 %t6, 1
	%t8 = icmp ne i32 %t7, 0
	br label %label_7
label_7:
	br label %label_5
label_5:
	%t9 = phi i1 [ true, %label_6 ], [ %t8, %label_7 ]
	%t10 = zext i1 %t9 to i32
	ret i32 %t10
label_8:
	ret i32 0
}

define i32 @func6(i32) {
	%t11 = alloca i32
	store i32 %0, i32* %t11
	%t12 = load i32, i32* %t11
	%t13 = add i32 %t12, 3
	ret i32 %t13
label_9:
	ret i32 0
}

define i32 @func7(i32, i32) {
	%t14 = alloca i32
	store i32 %0, i32* %t14
	%t15 = alloca i32
	store i32 %1, i32* %t15
	%t16 = load i32, i32* %t14
	%t17 = load i32, i32* %t15
	%t19 = icmp sle i32 %t16, %t17
	%t20 = zext i1 %t19 to i32
	%t21 = icmp ne i32 %t20, 0
	br label %label_12
label_12:
	br i1 %t21, label %label_10, label %label_11
label_10:
	%t22 = load i32, i32* %t14
	%t23 = load i32, i32* %t15
	%t25 = icmp ne i32 %t22, %t23
	%t26 = zext i1 %t25 to i32
	%t27 = icmp ne i32 %t26, 0
	br label %label_13
label_13:
	br label %label_11
label_11:
	%t28 = phi i1 [ 0, %label_12 ], [ %t27, %label_13 ]
	%t29 = zext i1 %t28 to i32
	ret i32 %t29
label_14:
	ret i32 0
}

define void @main() {
	%t30 = call i32 @func1()
	call void @printi(i32 %t30)
	%t31 = call i32 @func2()
	call void @printi(i32 %t31)
	; >>> evaluating if condition
	%t32 = call i32 @func3()
	%t33 = icmp ne i32 %t32, 0
	br i1 %t33, label %label_15, label %label_17
	; >>> then block
label_15:
	%t34 = getelementptr [5 x i8], [5 x i8]* @.str0, i32 0, i32 0
	call void @print(i8* %t34)
	br label %label_16
	; >>> else block
label_17:
	%t35 = getelementptr [6 x i8], [6 x i8]* @.str1, i32 0, i32 0
	call void @print(i8* %t35)
	br label %label_16
	; >>> end if
label_16:
	%t36 = call i32 @func4()
	call void @printi(i32 %t36)
	; >>> evaluating if condition
	%t37 = call i32 @func5(i32 1)
	%t38 = icmp ne i32 %t37, 0
	br i1 %t38, label %label_18, label %label_20
	; >>> then block
label_18:
	%t39 = getelementptr [5 x i8], [5 x i8]* @.str2, i32 0, i32 0
	call void @print(i8* %t39)
	br label %label_19
	; >>> else block
label_20:
	%t40 = getelementptr [6 x i8], [6 x i8]* @.str3, i32 0, i32 0
	call void @print(i8* %t40)
	br label %label_19
	; >>> end if
label_19:
	%t41 = call i32 @func6(i32 2)
	call void @printi(i32 %t41)
	; >>> evaluating if condition
	%t42 = call i32 @func7(i32 5, i32 100)
	%t43 = icmp ne i32 %t42, 0
	br i1 %t43, label %label_21, label %label_23
	; >>> then block
label_21:
	%t44 = getelementptr [5 x i8], [5 x i8]* @.str4, i32 0, i32 0
	call void @print(i8* %t44)
	br label %label_22
	; >>> else block
label_23:
	%t45 = getelementptr [6 x i8], [6 x i8]* @.str5, i32 0, i32 0
	call void @print(i8* %t45)
	br label %label_22
	; >>> end if
label_22:
	ret void
}

