@.str0 = constant [23 x i8] c"Error division by zero\00"
@.str1 = constant [6 x i8] c"FIRE!\00"
@.str2 = constant [2 x i8] c"*\00"
@.str3 = constant [2 x i8] c"-\00"

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
	%t0 = alloca i32
	store i32 1, i32* %t0
	%t1 = alloca i32
	%t2 = zext i8 1 to i32
	store i32 %t2, i32* %t1
	; >>> Begin while condition evaluation
	br label %label_1
label_1:
	%t3 = load i32, i32* %t0
	%t5 = icmp slt i32 %t3, 12
	%t6 = zext i1 %t5 to i32
	%t7 = icmp ne i32 %t6, 0
	br i1 %t7, label %label_0, label %label_2
	; >>> Begin while code
label_0:
	%t8 = zext i8 1 to i32
	store i32 %t8, i32* %t1
	; >>> Begin while condition evaluation
	br label %label_4
label_4:
	%t9 = load i32, i32* %t1
	%t11 = icmp slt i32 %t9, 12
	%t12 = zext i1 %t11 to i32
	%t13 = icmp ne i32 %t12, 0
	br i1 %t13, label %label_3, label %label_5
	; >>> Begin while code
label_3:
	; >>> evaluating if condition
	%t14 = load i32, i32* %t0
	%t15 = load i32, i32* %t1
	%t16 = mul i32 %t14, %t15
	%t17 = load i32, i32* %t0
	%t18 = load i32, i32* %t1
	%t19 = mul i32 %t17, %t18
	
; >>> check division by zero
	%t21 = icmp eq i32 10, 0
	br i1 %t21, label %label_6, label %label_7
label_6:
	call void @print(i8* getelementptr ([23 x i8], [23 x i8]* @.str0, i32 0, i32 0))
	call void @exit(i32 0)
	unreachable
label_7:
	; >>> end check division by zero

	%t20 = sdiv i32 %t19, 10
	%t22 = mul i32 %t20, 10
	%t23 = sub i32 %t16, %t22
	%t25 = icmp eq i32 %t23, 0
	%t26 = zext i1 %t25 to i32
	%t27 = icmp ne i32 %t26, 0
	br i1 %t27, label %label_8, label %label_9
	; >>> then block
label_8:
	br label %label_5
label_10:
	br label %label_9
	; >>> end if
label_9:
	%t28 = alloca i32
	store i32 0, i32* %t28
	; >>> Begin while condition evaluation
	br label %label_12
label_12:
	%t29 = load i32, i32* %t28
	%t30 = load i32, i32* %t0
	%t31 = load i32, i32* %t1
	%t32 = mul i32 %t30, %t31
	%t34 = icmp slt i32 %t29, %t32
	%t35 = zext i1 %t34 to i32
	%t36 = icmp ne i32 %t35, 0
	br i1 %t36, label %label_11, label %label_13
	; >>> Begin while code
label_11:
	%t37 = load i32, i32* %t28
	%t38 = add i32 %t37, 1
	store i32 %t38, i32* %t28
	; >>> evaluating if condition
	%t39 = load i32, i32* %t28
	
; >>> check division by zero
	%t41 = icmp eq i32 2, 0
	br i1 %t41, label %label_14, label %label_15
label_14:
	call void @print(i8* getelementptr ([23 x i8], [23 x i8]* @.str0, i32 0, i32 0))
	call void @exit(i32 0)
	unreachable
label_15:
	; >>> end check division by zero

	%t40 = sdiv i32 %t39, 2
	%t43 = icmp eq i32 %t40, 0
	%t44 = zext i1 %t43 to i32
	%t45 = icmp ne i32 %t44, 0
	br i1 %t45, label %label_16, label %label_17
	; >>> then block
label_16:
	%t46 = getelementptr [6 x i8], [6 x i8]* @.str1, i32 0, i32 0
	call void @print(i8* %t46)
	br label %label_12
label_18:
	br label %label_17
	; >>> end if
label_17:
	%t47 = getelementptr [2 x i8], [2 x i8]* @.str2, i32 0, i32 0
	call void @print(i8* %t47)
	; >>> evaluating if condition
	%t48 = load i32, i32* %t28
	%t49 = load i32, i32* %t28
	
; >>> check division by zero
	%t51 = icmp eq i32 2, 0
	br i1 %t51, label %label_19, label %label_20
label_19:
	call void @print(i8* getelementptr ([23 x i8], [23 x i8]* @.str0, i32 0, i32 0))
	call void @exit(i32 0)
	unreachable
label_20:
	; >>> end check division by zero

	%t50 = sdiv i32 %t49, 2
	%t52 = mul i32 %t50, 2
	%t53 = sub i32 %t48, %t52
	%t55 = icmp eq i32 %t53, 0
	%t56 = zext i1 %t55 to i32
	%t57 = icmp ne i32 %t56, 0
	br i1 %t57, label %label_21, label %label_22
	; >>> then block
label_21:
	%t58 = getelementptr [2 x i8], [2 x i8]* @.str3, i32 0, i32 0
	call void @print(i8* %t58)
	br label %label_12
label_23:
	br label %label_22
	; >>> end if
label_22:
	br label %label_12
	; >>> end while block
label_13:
	%t59 = load i32, i32* %t1
	%t60 = add i32 %t59, 1
	%t61 = and i32 %t60, 255
	store i32 %t61, i32* %t1
	br label %label_4
	; >>> end while block
label_5:
	%t62 = load i32, i32* %t0
	%t63 = add i32 %t62, 1
	store i32 %t63, i32* %t0
	br label %label_1
	; >>> end while block
label_2:
	ret void
}

