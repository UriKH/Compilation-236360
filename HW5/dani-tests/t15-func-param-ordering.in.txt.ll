@.str0 = constant [4 x i8] c"f1!\00"
@.str1 = constant [4 x i8] c"f2!\00"
@.str2 = constant [4 x i8] c"f3!\00"
@.str3 = constant [14 x i8] c"call me maybe\00"

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

define i32 @f1(i32) {
	%t0 = alloca i32
	store i32 %0, i32* %t0
	%t1 = getelementptr [4 x i8], [4 x i8]* @.str0, i32 0, i32 0
	call void @print(i8* %t1)
	%t2 = load i32, i32* %t0
	ret i32 %t2
label_0:
	ret i32 0
}

define i32 @f2(i32) {
	%t3 = alloca i32
	store i32 %0, i32* %t3
	%t4 = getelementptr [4 x i8], [4 x i8]* @.str1, i32 0, i32 0
	call void @print(i8* %t4)
	%t5 = load i32, i32* %t3
	ret i32 %t5
label_1:
	ret i32 0
}

define i32 @f3(i32) {
	%t6 = alloca i32
	store i32 %0, i32* %t6
	%t7 = getelementptr [4 x i8], [4 x i8]* @.str2, i32 0, i32 0
	call void @print(i8* %t7)
	%t8 = load i32, i32* %t6
	ret i32 %t8
label_2:
	ret i32 0
}

define void @callMe(i32, i32, i32, i32, i32, i32, i32, i32) {
	%t9 = alloca i32
	store i32 %0, i32* %t9
	%t10 = alloca i32
	store i32 %1, i32* %t10
	%t11 = alloca i32
	store i32 %2, i32* %t11
	%t12 = alloca i32
	store i32 %3, i32* %t12
	%t13 = alloca i32
	store i32 %4, i32* %t13
	%t14 = alloca i32
	store i32 %5, i32* %t14
	%t15 = alloca i32
	store i32 %6, i32* %t15
	%t16 = alloca i32
	store i32 %7, i32* %t16
	%t17 = getelementptr [14 x i8], [14 x i8]* @.str3, i32 0, i32 0
	call void @print(i8* %t17)
	%t18 = load i32, i32* %t9
	call void @printi(i32 %t18)
	%t19 = load i32, i32* %t10
	call void @printi(i32 %t19)
	%t20 = load i32, i32* %t11
	call void @printi(i32 %t20)
	%t21 = load i32, i32* %t14
	call void @printi(i32 %t21)
	%t22 = load i32, i32* %t15
	call void @printi(i32 %t22)
	ret void
}

define void @main() {
	%t23 = call i32 @f1(i32 2)
	%t24 = call i32 @f2(i32 4)
	%t25 = call i32 @f2(i32 5)
	%t26 = call i32 @f3(i32 1)
	%t27 = call i32 @f3(i32 0)
	%t28 = call i32 @f2(i32 3)
	%t29 = call i32 @f1(i32 22)
	%t30 = call i32 @f3(i32 0)
	call void @callMe(i32 %t23, i32 %t24, i32 %t25, i32 %t26, i32 %t27, i32 %t28, i32 %t29, i32 %t30)
	ret void
}

