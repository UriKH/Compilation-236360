@.str0 = constant [2 x i8] c"*\00"
@.str1 = constant [2 x i8] c"*\00"

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

define i32 @fib(i32) {
	%t0 = alloca i32
	store i32 %0, i32* %t0
	; >>> evaluating if condition
	%t1 = load i32, i32* %t0
	%t3 = icmp eq i32 %t1, 0
	%t4 = zext i1 %t3 to i32
	%t5 = icmp ne i32 %t4, 0
	br label %label_2
label_2:
	br i1 %t5, label %label_1, label %label_0
label_0:
	%t6 = load i32, i32* %t0
	%t8 = icmp eq i32 %t6, 1
	%t9 = zext i1 %t8 to i32
	%t10 = icmp ne i32 %t9, 0
	br label %label_3
label_3:
	br label %label_1
label_1:
	%t11 = phi i1 [ true, %label_2 ], [ %t10, %label_3 ]
	%t12 = zext i1 %t11 to i32
	%t13 = icmp ne i32 %t12, 0
	br i1 %t13, label %label_4, label %label_5
	; >>> then block
label_4:
	ret i32 1
label_6:
	br label %label_5
	; >>> end if
label_5:
	%t14 = load i32, i32* %t0
	%t15 = sub i32 %t14, 1
	%t16 = and i32 %t15, 255
	%t17 = call i32 @fib(i32 %t16)
	%t18 = load i32, i32* %t0
	%t19 = sub i32 %t18, 2
	%t20 = and i32 %t19, 255
	%t21 = call i32 @fib(i32 %t20)
	%t22 = add i32 %t17, %t21
	ret i32 %t22
label_7:
	ret i32 0
}

define void @main() {
	%t23 = alloca i32
	%t24 = zext i8 0 to i32
	store i32 %t24, i32* %t23
	; >>> Begin while condition evaluation
	br label %label_9
label_9:
	%t25 = load i32, i32* %t23
	%t27 = icmp slt i32 %t25, 10
	%t28 = zext i1 %t27 to i32
	%t29 = icmp ne i32 %t28, 0
	br i1 %t29, label %label_8, label %label_10
	; >>> Begin while code
label_8:
	%t30 = load i32, i32* %t23
	%t31 = call i32 @fib(i32 %t30)
	call void @printi(i32 %t31)
	; >>> evaluating if condition
	%t32 = load i32, i32* %t23
	%t33 = add i32 %t32, 1
	%t35 = icmp slt i32 %t33, 10
	%t36 = zext i1 %t35 to i32
	%t37 = icmp ne i32 %t36, 0
	br i1 %t37, label %label_11, label %label_12
	; >>> then block
label_11:
	%t38 = getelementptr [2 x i8], [2 x i8]* @.str0, i32 0, i32 0
	call void @print(i8* %t38)
	br label %label_12
	; >>> end if
label_12:
	%t39 = load i32, i32* %t23
	%t40 = add i32 %t39, 1
	%t41 = and i32 %t40, 255
	store i32 %t41, i32* %t23
	br label %label_9
	; >>> end while block
label_10:
	%t42 = getelementptr [2 x i8], [2 x i8]* @.str1, i32 0, i32 0
	call void @print(i8* %t42)
	ret void
}

