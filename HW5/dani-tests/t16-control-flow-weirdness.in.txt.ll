@.str0 = constant [12 x i8] c"already? :(\00"
@.str1 = constant [3 x i8] c"ok\00"
@.str2 = constant [8 x i8] c"alright\00"
@.str3 = constant [6 x i8] c"back!\00"
@.str4 = constant [6 x i8] c"here!\00"
@.str5 = constant [6 x i8] c"great\00"

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

define i32 @foo(i32, i32, i32) {
	%t0 = alloca i32
	store i32 %0, i32* %t0
	%t1 = alloca i32
	store i32 %1, i32* %t1
	%t2 = alloca i32
	store i32 %2, i32* %t2
	%t3 = load i32, i32* %t1
	%t4 = alloca i32
	store i32 %t3, i32* %t4
	%t5 = load i32, i32* %t2
	%t6 = alloca i32
	store i32 %t5, i32* %t6
	; >>> evaluating if condition
	%t7 = load i32, i32* %t0
	%t8 = xor i32 %t7, 1
	%t9 = icmp ne i32 %t8, 0
	br i1 %t9, label %label_0, label %label_1
	; >>> then block
label_0:
	%t10 = getelementptr [12 x i8], [12 x i8]* @.str0, i32 0, i32 0
	call void @print(i8* %t10)
	ret i32 15
label_2:
	br label %label_1
	; >>> end if
label_1:
	%t11 = getelementptr [3 x i8], [3 x i8]* @.str1, i32 0, i32 0
	call void @print(i8* %t11)
	; >>> Begin while condition evaluation
	br label %label_4
label_4:
	%t12 = load i32, i32* %t4
	%t14 = icmp slt i32 %t12, 10
	%t15 = zext i1 %t14 to i32
	%t16 = icmp ne i32 %t15, 0
	br i1 %t16, label %label_3, label %label_5
	; >>> Begin while code
label_3:
	%t17 = load i32, i32* %t4
	%t18 = add i32 %t17, 1
	store i32 %t18, i32* %t4
	; >>> evaluating if condition
	%t19 = load i32, i32* %t0
	%t20 = icmp ne i32 %t19, 0
	br label %label_8
label_8:
	br i1 %t20, label %label_6, label %label_7
label_6:
	%t21 = load i32, i32* %t4
	%t23 = icmp eq i32 %t21, 7
	%t24 = zext i1 %t23 to i32
	%t25 = icmp ne i32 %t24, 0
	br label %label_9
label_9:
	br label %label_7
label_7:
	%t26 = phi i1 [ 0, %label_8 ], [ %t25, %label_9 ]
	%t27 = zext i1 %t26 to i32
	%t28 = icmp ne i32 %t27, 0
	br i1 %t28, label %label_10, label %label_11
	; >>> then block
label_10:
	%t29 = load i32, i32* %t4
	call void @printi(i32 %t29)
	%t30 = getelementptr [8 x i8], [8 x i8]* @.str2, i32 0, i32 0
	call void @print(i8* %t30)
	ret i32 17
label_12:
	br label %label_11
	; >>> end if
label_11:
	br label %label_4
	; >>> end while block
label_5:
	; >>> Begin while condition evaluation
	br label %label_14
label_14:
	%t31 = load i32, i32* %t6
	%t33 = icmp sgt i32 %t31, 12
	%t34 = zext i1 %t33 to i32
	%t35 = icmp ne i32 %t34, 0
	br i1 %t35, label %label_13, label %label_15
	; >>> Begin while code
label_13:
	%t36 = load i32, i32* %t6
	%t37 = sub i32 %t36, 1
	%t38 = and i32 %t37, 255
	store i32 %t38, i32* %t6
	%t39 = load i32, i32* %t6
	call void @printi(i32 %t39)
	%t40 = getelementptr [6 x i8], [6 x i8]* @.str3, i32 0, i32 0
	call void @print(i8* %t40)
	ret i32 18
label_16:
	br label %label_14
	; >>> end while block
label_15:
	%t41 = getelementptr [6 x i8], [6 x i8]* @.str4, i32 0, i32 0
	call void @print(i8* %t41)
	ret i32 322
label_17:
	ret i32 0
}

define i32 @opposite(i32) {
	%t42 = alloca i32
	store i32 %0, i32* %t42
	; >>> Begin while condition evaluation
	br label %label_19
label_19:
	%t43 = icmp ne i32 1, 0
	br i1 %t43, label %label_18, label %label_20
	; >>> Begin while code
label_18:
	; >>> Begin while condition evaluation
	br label %label_22
label_22:
	%t44 = icmp ne i32 1, 0
	br i1 %t44, label %label_21, label %label_23
	; >>> Begin while code
label_21:
	; >>> Begin while condition evaluation
	br label %label_25
label_25:
	%t45 = icmp ne i32 1, 0
	br i1 %t45, label %label_24, label %label_26
	; >>> Begin while code
label_24:
	; >>> Begin while condition evaluation
	br label %label_28
label_28:
	%t46 = icmp ne i32 1, 0
	br i1 %t46, label %label_27, label %label_29
	; >>> Begin while code
label_27:
	; >>> Begin while condition evaluation
	br label %label_31
label_31:
	%t47 = icmp ne i32 1, 0
	br i1 %t47, label %label_30, label %label_32
	; >>> Begin while code
label_30:
	%t48 = load i32, i32* %t42
	%t49 = xor i32 %t48, 1
	ret i32 %t49
label_33:
	br label %label_31
	; >>> end while block
label_32:
	br label %label_29
label_34:
	br label %label_28
	; >>> end while block
label_29:
	br label %label_25
	; >>> end while block
label_26:
	br label %label_22
	; >>> end while block
label_23:
	br label %label_19
	; >>> end while block
label_20:
	%t50 = load i32, i32* %t42
	%t51 = xor i32 %t50, 1
	ret i32 %t51
label_35:
	ret i32 0
}

define i32 @multiply(i32, i32) {
	%t52 = alloca i32
	store i32 %0, i32* %t52
	%t53 = alloca i32
	store i32 %1, i32* %t53
	%t54 = load i32, i32* %t52
	%t55 = load i32, i32* %t53
	%t56 = mul i32 %t54, %t55
	%t57 = and i32 %t56, 255
	ret i32 %t57
label_36:
	ret i32 0
}

define void @main() {
	%t58 = call i32 @foo(i32 0, i32 5, i32 15)
	call void @printi(i32 %t58)
	%t59 = call i32 @foo(i32 1, i32 5, i32 21)
	call void @printi(i32 %t59)
	%t60 = call i32 @foo(i32 1, i32 11, i32 4)
	call void @printi(i32 %t60)
	%t61 = call i32 @foo(i32 1, i32 10, i32 13)
	call void @printi(i32 %t61)
	; >>> evaluating if condition
	%t62 = call i32 @opposite(i32 0)
	%t63 = icmp ne i32 %t62, 0
	br i1 %t63, label %label_37, label %label_38
	; >>> then block
label_37:
	%t64 = getelementptr [6 x i8], [6 x i8]* @.str5, i32 0, i32 0
	call void @print(i8* %t64)
	br label %label_38
	; >>> end if
label_38:
	%t65 = call i32 @multiply(i32 16, i32 16)
	call void @printi(i32 %t65)
	ret void
}

