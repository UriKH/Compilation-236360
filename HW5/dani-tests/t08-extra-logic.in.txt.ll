@.str0 = constant [7 x i8] c"equal!\00"
@.str1 = constant [17 x i8] c"shouldn't happen\00"
@.str2 = constant [9 x i8] c"smaller!\00"
@.str3 = constant [17 x i8] c"shouldn't happen\00"
@.str4 = constant [23 x i8] c"Error division by zero\00"
@.str5 = constant [20 x i8] c"short circuit works\00"
@.str6 = constant [32 x i8] c"wrong but at least didn't crash\00"
@.str7 = constant [5 x i8] c"good\00"

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
	; >>> evaluating if condition
	%t1 = icmp eq i32 100, 100
	%t2 = zext i1 %t1 to i32
	%t3 = icmp ne i32 %t2, 0
	br i1 %t3, label %label_0, label %label_2
	; >>> then block
label_0:
	%t4 = getelementptr [7 x i8], [7 x i8]* @.str0, i32 0, i32 0
	call void @print(i8* %t4)
	br label %label_1
	; >>> else block
label_2:
	%t5 = getelementptr [17 x i8], [17 x i8]* @.str1, i32 0, i32 0
	call void @print(i8* %t5)
	br label %label_1
	; >>> end if
label_1:
	; >>> evaluating if condition
	%t7 = icmp slt i32 5, 6
	%t8 = zext i1 %t7 to i32
	%t9 = icmp ne i32 %t8, 0
	br i1 %t9, label %label_3, label %label_5
	; >>> then block
label_3:
	%t10 = getelementptr [9 x i8], [9 x i8]* @.str2, i32 0, i32 0
	call void @print(i8* %t10)
	br label %label_4
	; >>> else block
label_5:
	%t11 = getelementptr [17 x i8], [17 x i8]* @.str3, i32 0, i32 0
	call void @print(i8* %t11)
	br label %label_4
	; >>> end if
label_4:
	; >>> evaluating if condition
	%t13 = icmp sle i32 4, 5
	%t14 = zext i1 %t13 to i32
	%t15 = icmp ne i32 %t14, 0
	br label %label_8
label_8:
	br i1 %t15, label %label_7, label %label_6
label_6:
	
; >>> check division by zero
	%t17 = icmp eq i32 0, 0
	br i1 %t17, label %label_9, label %label_10
label_9:
	call void @print(i8* getelementptr ([23 x i8], [23 x i8]* @.str4, i32 0, i32 0))
	call void @exit(i32 0)
	unreachable
label_10:
	; >>> end check division by zero

	%t16 = sdiv i32 8, 0
	%t19 = icmp slt i32 %t16, 10
	%t20 = zext i1 %t19 to i32
	%t21 = icmp ne i32 %t20, 0
	br label %label_11
label_11:
	br label %label_7
label_7:
	%t22 = phi i1 [ true, %label_8 ], [ %t21, %label_11 ]
	%t23 = zext i1 %t22 to i32
	%t24 = icmp ne i32 %t23, 0
	br i1 %t24, label %label_12, label %label_13
	; >>> then block
label_12:
	%t25 = getelementptr [20 x i8], [20 x i8]* @.str5, i32 0, i32 0
	call void @print(i8* %t25)
	br label %label_13
	; >>> end if
label_13:
	; >>> evaluating if condition
	%t27 = icmp sgt i32 5, 100
	%t28 = zext i1 %t27 to i32
	%t29 = icmp ne i32 %t28, 0
	br label %label_16
label_16:
	br i1 %t29, label %label_14, label %label_15
label_14:
	
; >>> check division by zero
	%t31 = icmp eq i32 0, 0
	br i1 %t31, label %label_17, label %label_18
label_17:
	call void @print(i8* getelementptr ([23 x i8], [23 x i8]* @.str4, i32 0, i32 0))
	call void @exit(i32 0)
	unreachable
label_18:
	; >>> end check division by zero

	%t30 = udiv i32 6, 0
	%t32 = and i32 %t30, 255
	%t34 = icmp ne i32 %t32, 1
	%t35 = zext i1 %t34 to i32
	%t36 = icmp ne i32 %t35, 0
	br label %label_19
label_19:
	br label %label_15
label_15:
	%t37 = phi i1 [ 0, %label_16 ], [ %t36, %label_19 ]
	%t38 = zext i1 %t37 to i32
	%t39 = icmp ne i32 %t38, 0
	br i1 %t39, label %label_20, label %label_21
	; >>> then block
label_20:
	%t40 = getelementptr [32 x i8], [32 x i8]* @.str6, i32 0, i32 0
	call void @print(i8* %t40)
	br label %label_21
	; >>> end if
label_21:
	; >>> evaluating if condition
	%t42 = icmp ne i32 1, 1
	%t43 = zext i1 %t42 to i32
	%t44 = xor i32 %t43, 1
	%t45 = icmp ne i32 %t44, 0
	br label %label_24
label_24:
	br i1 %t45, label %label_22, label %label_23
label_22:
	%t47 = icmp sge i32 8, 2
	%t48 = zext i1 %t47 to i32
	%t49 = icmp ne i32 %t48, 0
	br label %label_25
label_25:
	br label %label_23
label_23:
	%t50 = phi i1 [ 0, %label_24 ], [ %t49, %label_25 ]
	%t51 = zext i1 %t50 to i32
	%t52 = icmp ne i32 %t51, 0
	br i1 %t52, label %label_26, label %label_27
	; >>> then block
label_26:
	%t53 = getelementptr [5 x i8], [5 x i8]* @.str7, i32 0, i32 0
	call void @print(i8* %t53)
	br label %label_27
	; >>> end if
label_27:
	ret void
}

