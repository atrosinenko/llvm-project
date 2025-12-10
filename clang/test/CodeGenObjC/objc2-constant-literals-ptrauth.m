// RUN: %clang_cc1 -triple arm64e-apple-macosx26.0.0 -fobjc-runtime=macosx-26.0.0 -fobjc-constant-literals -fconstant-nsnumber-literals -fconstant-nsarray-literals -fconstant-nsdictionary-literals -fptrauth-intrinsics -fptrauth-calls -fptrauth-objc-isa -I %S/Inputs -emit-llvm -o - %s | FileCheck %s
// rdar://174359070

#include "constant-literal-support.h"

#if __has_feature(objc_bool)
#define YES __objc_yes
#define NO __objc_no
#else
#define YES ((BOOL)1)
#define NO ((BOOL)0)
#endif

// Check that isa pointers in all ObjC constant literal structs are signed with
// ptrauth (key 2, discriminator 0x6AE1 = 27361, address-discriminated).

// CHECK: @_unnamed_nsconstantintegernumber_ = private constant %struct.__builtin_NSConstantIntegerNumber { ptr ptrauth (ptr @"OBJC_CLASS_$_NSConstantIntegerNumber", [i64 2, i64 27361, i64 ptrtoint (ptr @_unnamed_nsconstantintegernumber_ to i64)]), ptr @.str, i64 42 }
// CHECK: @_unnamed_nsconstantfloatnumber_ = private constant %struct.__builtin_NSConstantFloatNumber { ptr ptrauth (ptr @"OBJC_CLASS_$_NSConstantFloatNumber", [i64 2, i64 27361, i64 ptrtoint (ptr @_unnamed_nsconstantfloatnumber_ to i64)])
// CHECK: @_unnamed_nsconstantdoublenumber_ = private constant %struct.__builtin_NSConstantDoubleNumber { ptr ptrauth (ptr @"OBJC_CLASS_$_NSConstantDoubleNumber", [i64 2, i64 27361, i64 ptrtoint (ptr @_unnamed_nsconstantdoublenumber_ to i64)])
// CHECK: @_unnamed_cfstring_ = private global %struct.__NSConstantString_tag { ptr ptrauth (ptr @__CFConstantStringClassReference, [i64 2, i64 27361, i64 ptrtoint (ptr @_unnamed_cfstring_ to i64)])
// CHECK: @_unnamed_nsarray_ = private constant %struct.__builtin_NSArray { ptr ptrauth (ptr @"OBJC_CLASS_$_NSConstantArray", [i64 2, i64 27361, i64 ptrtoint (ptr @_unnamed_nsarray_ to i64)])
// CHECK: @_unnamed_nsdictionary_ = private constant %struct.__builtin_NSDictionary { ptr ptrauth (ptr @"OBJC_CLASS_$_NSConstantDictionary", [i64 2, i64 27361, i64 ptrtoint (ptr @_unnamed_nsdictionary_ to i64)])

int main() {
  NSNumber *n = @42;
  NSNumber *f = @3.14f;
  NSNumber *d = @3.14;
  NSNumber *b = @YES;
  NSArray *a = @[ @"foo" ];
  NSDictionary *dict = @{ @"a" : @1, @"b" : @2 };
  return 0;
}
