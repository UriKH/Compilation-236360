@.str0 = constant [4 x i8] c"f1.\00"
@.str1 = constant [4 x i8] c"f2.\00"

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

define i32 @f1() {
	%t0 = getelementptr [4 x i8], [4 x i8]* @.str0, i32 0, i32 0
	call void @print(i8* %t0)
	ret i32 1
label_0:
	ret i32 0
}

define i32 @f2() {
	%t1 = getelementptr [4 x i8], [4 x i8]* @.str1, i32 0, i32 0
	call void @print(i8* %t1)
	ret i32 0
label_1:
	ret i32 0
}

define void @main() {
	; >>> evaluating if condition
	%t2 = call i32 @f1()
	%t3 = icmp ne i32 %t2, 0
	br label %label_4
label_4:
	br i1 %t3, label %label_3, label %label_2
label_2:
	%t4 = call i32 @f2()
	%t5 = icmp ne i32 %t4, 0
	br label %label_5
label_5:
	br label %label_3
label_3:
	%t6 = phi i1 [ true, %label_4 ], [ %t5, %label_5 ]
	%t7 = zext i1 %t6 to i32
	%t8 = icmp ne i32 %t7, 0
	br i1 %t8, label %label_6, label %label_7
	; >>> then block
label_6:
	%t9 = alloca i32
	store i32 0, i32* %t9
	br label %label_7
	; >>> end if
label_7:
	; >>> evaluating if condition
	%t10 = call i32 @f2()
	%t11 = icmp ne i32 %t10, 0
	br label %label_10
label_10:
	br i1 %t11, label %label_9, label %label_8
label_8:
	%t12 = call i32 @f1()
	%t13 = icmp ne i32 %t12, 0
	br label %label_11
label_11:
	br label %label_9
label_9:
	%t14 = phi i1 [ true, %label_10 ], [ %t13, %label_11 ]
	%t15 = zext i1 %t14 to i32
	%t16 = icmp ne i32 %t15, 0
	br i1 %t16, label %label_12, label %label_13
	; >>> then block
label_12:
	%t17 = alloca i32
	store i32 0, i32* %t17
	br label %label_13
	; >>> end if
label_13:
	; >>> evaluating if condition
	%t18 = call i32 @f2()
	%t19 = xor i32 %t18, 1
	%t20 = icmp ne i32 %t19, 0
	br label %label_16
label_16:
	br i1 %t20, label %label_15, label %label_14
label_14:
	%t21 = call i32 @f1()
	%t22 = icmp ne i32 %t21, 0
	br label %label_17
label_17:
	br label %label_15
label_15:
	%t23 = phi i1 [ true, %label_16 ], [ %t22, %label_17 ]
	%t24 = zext i1 %t23 to i32
	%t25 = icmp ne i32 %t24, 0
	br i1 %t25, label %label_18, label %label_19
	; >>> then block
label_18:
	%t26 = alloca i32
	store i32 0, i32* %t26
	br label %label_19
	; >>> end if
label_19:
	; >>> evaluating if condition
	%t27 = call i32 @f1()
	%t28 = icmp ne i32 %t27, 0
	br label %label_22
label_22:
	br i1 %t28, label %label_20, label %label_21
label_20:
	%t29 = call i32 @f2()
	%t30 = icmp ne i32 %t29, 0
	br label %label_23
label_23:
	br label %label_21
label_21:
	%t31 = phi i1 [ 0, %label_22 ], [ %t30, %label_23 ]
	%t32 = zext i1 %t31 to i32
	%t33 = icmp ne i32 %t32, 0
	br i1 %t33, label %label_24, label %label_25
	; >>> then block
label_24:
	%t34 = alloca i32
	store i32 0, i32* %t34
	br label %label_25
	; >>> end if
label_25:
	; >>> evaluating if condition
	%t35 = call i32 @f2()
	%t36 = icmp ne i32 %t35, 0
	br label %label_28
label_28:
	br i1 %t36, label %label_26, label %label_27
label_26:
	%t37 = call i32 @f1()
	%t38 = icmp ne i32 %t37, 0
	br label %label_29
label_29:
	br label %label_27
label_27:
	%t39 = phi i1 [ 0, %label_28 ], [ %t38, %label_29 ]
	%t40 = zext i1 %t39 to i32
	%t41 = icmp ne i32 %t40, 0
	br i1 %t41, label %label_30, label %label_31
	; >>> then block
label_30:
	%t42 = alloca i32
	store i32 0, i32* %t42
	br label %label_31
	; >>> end if
label_31:
	; >>> evaluating if condition
	%t43 = call i32 @f2()
	%t44 = xor i32 %t43, 1
	%t45 = icmp ne i32 %t44, 0
	br label %label_34
label_34:
	br i1 %t45, label %label_32, label %label_33
label_32:
	%t46 = call i32 @f1()
	%t47 = icmp ne i32 %t46, 0
	br label %label_35
label_35:
	br label %label_33
label_33:
	%t48 = phi i1 [ 0, %label_34 ], [ %t47, %label_35 ]
	%t49 = zext i1 %t48 to i32
	%t50 = icmp ne i32 %t49, 0
	br i1 %t50, label %label_36, label %label_37
	; >>> then block
label_36:
	%t51 = alloca i32
	store i32 0, i32* %t51
	br label %label_37
	; >>> end if
label_37:
	%t52 = alloca i32
	store i32 0, i32* %t52
	; >>> Begin while condition evaluation
	br label %label_39
label_39:
	%t53 = call i32 @f1()
	%t54 = icmp ne i32 %t53, 0
	br label %label_43
label_43:
	br i1 %t54, label %label_41, label %label_42
label_41:
	%t55 = load i32, i32* %t52
	%t57 = icmp slt i32 %t55, 2
	%t58 = zext i1 %t57 to i32
	%t59 = icmp ne i32 %t58, 0
	br label %label_44
label_44:
	br label %label_42
label_42:
	%t60 = phi i1 [ 0, %label_43 ], [ %t59, %label_44 ]
	%t61 = zext i1 %t60 to i32
	%t62 = icmp ne i32 %t61, 0
	br i1 %t62, label %label_38, label %label_40
	; >>> Begin while code
label_38:
	%t63 = load i32, i32* %t52
	%t64 = add i32 %t63, 2
	store i32 %t64, i32* %t52
	%t65 = load i32, i32* %t52
	call void @printi(i32 %t65)
	br label %label_39
	; >>> end while block
label_40:
	store i32 0, i32* %t52
	; >>> Begin while condition evaluation
	br label %label_46
label_46:
	%t66 = call i32 @f2()
	%t67 = icmp ne i32 %t66, 0
	br label %label_50
label_50:
	br i1 %t67, label %label_49, label %label_48
label_48:
	%t68 = load i32, i32* %t52
	%t70 = icmp slt i32 %t68, 2
	%t71 = zext i1 %t70 to i32
	%t72 = icmp ne i32 %t71, 0
	br label %label_51
label_51:
	br label %label_49
label_49:
	%t73 = phi i1 [ true, %label_50 ], [ %t72, %label_51 ]
	%t74 = zext i1 %t73 to i32
	%t75 = icmp ne i32 %t74, 0
	br i1 %t75, label %label_45, label %label_47
	; >>> Begin while code
label_45:
	%t76 = load i32, i32* %t52
	%t77 = add i32 %t76, 3
	store i32 %t77, i32* %t52
	%t78 = load i32, i32* %t52
	call void @printi(i32 %t78)
	br label %label_46
	; >>> end while block
label_47:
	ret void
}

