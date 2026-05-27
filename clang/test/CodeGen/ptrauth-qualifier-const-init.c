// RUN: %clang_cc1 -triple arm64-apple-ios -fptrauth-calls -fptrauth-intrinsics -emit-llvm %s  -o - | FileCheck %s
// RUN: %clang_cc1 -triple aarch64-linux-gnu -fptrauth-calls -fptrauth-intrinsics -emit-llvm %s  -o - | FileCheck %s

// Constant initializers for data pointers.
extern int external_int;

// CHECK: @g1 = global ptr ptrauth (ptr @external_int, [i64 1, i64 56, i64 0])
int * __ptrauth(1,0,56) g1 = &external_int;

// CHECK: @g2 = global ptr ptrauth (ptr @external_int, [i64 1, i64 1272, i64 ptrtoint (ptr @g2 to i64)])
int * __ptrauth(1,1,1272) g2 = &external_int;

// CHECK: @g3 = global ptr null
int * __ptrauth(1,1,871) g3 = 0;

// FIXME: should we make a ptrauth constant for this absolute symbol?
// CHECK: @g4 = global ptr inttoptr (i64 1230 to ptr)
int * __ptrauth(1,1,1902) g4 = (int*) 1230;

// CHECK: @ga = global [3 x ptr] [
// CHECK-SAME: ptr ptrauth (ptr @external_int, [i64 1, i64 712, i64 ptrtoint (ptr @ga to i64)]),
// CHECK-SAME: ptr ptrauth (ptr @external_int, [i64 1, i64 712, i64 ptrtoint (ptr getelementptr inbounds ([3 x ptr], ptr @ga, i32 0, i32 1) to i64)]),
// CHECK-SAME: ptr ptrauth (ptr @external_int, [i64 1, i64 712, i64 ptrtoint (ptr getelementptr inbounds ([3 x ptr], ptr @ga, i32 0, i32 2) to i64)])]
int * __ptrauth(1,1,712) ga[3] = { &external_int, &external_int, &external_int };

struct A {
  int * __ptrauth(1,0,431) f0;
  int * __ptrauth(1,0,9182) f1;
  int * __ptrauth(1,0,783) f2;
};

// CHECK: @gs1 = global %struct.A {
// CHECK-SAME: ptr ptrauth (ptr @external_int, [i64 1, i64 431, i64 0]),
// CHECK-SAME: ptr ptrauth (ptr @external_int, [i64 1, i64 9182, i64 0]),
// CHECK-SAME: ptr ptrauth (ptr @external_int, [i64 1, i64 783, i64 0]) }
struct A gs1 = { &external_int, &external_int, &external_int };

struct B {
  int * __ptrauth(1,1,1276) f0;
  int * __ptrauth(1,1,23674) f1;
  int * __ptrauth(1,1,163) f2;
};

// CHECK: @gs2 = global %struct.B {
// CHECK-SAME: ptr ptrauth (ptr @external_int, [i64 1, i64 1276, i64 ptrtoint (ptr @gs2 to i64)]),
// CHECK-SAME: ptr ptrauth (ptr @external_int, [i64 1, i64 23674, i64 ptrtoint (ptr getelementptr inbounds (%struct.B, ptr @gs2, i32 0, i32 1) to i64)]),
// CHECK-SAME: ptr ptrauth (ptr @external_int, [i64 1, i64 163, i64 ptrtoint (ptr getelementptr inbounds (%struct.B, ptr @gs2, i32 0, i32 2) to i64)]) }
struct B gs2 = { &external_int, &external_int, &external_int };

// Constant initializers for function pointers.
extern void external_function(void);
typedef void (*fpt)(void);

// CHECK: @f1 = global ptr ptrauth (ptr @external_function, [i64 1, i64 56, i64 0])
fpt __ptrauth(1,0,56) f1 = &external_function;

// CHECK: @f2 = global ptr ptrauth (ptr @external_function, [i64 1, i64 1272, i64 ptrtoint (ptr @f2 to i64)])
fpt __ptrauth(1,1,1272) f2 = &external_function;

// CHECK: @fa = global [3 x ptr] [
// CHECK-SAME: ptr ptrauth (ptr @external_function, [i64 1, i64 712, i64 ptrtoint (ptr @fa to i64)]),
// CHECK-SAME: ptr ptrauth (ptr @external_function, [i64 1, i64 712, i64 ptrtoint (ptr getelementptr inbounds ([3 x ptr], ptr @fa, i32 0, i32 1) to i64)]),
// CHECK-SAME: ptr ptrauth (ptr @external_function, [i64 1, i64 712, i64 ptrtoint (ptr getelementptr inbounds ([3 x ptr], ptr @fa, i32 0, i32 2) to i64)])]
fpt __ptrauth(1,1,712) fa[3] = { &external_function, &external_function, &external_function };

struct C {
  fpt __ptrauth(1,0,431) f0;
  fpt __ptrauth(1,0,9182) f1;
  fpt __ptrauth(1,0,783) f2;
};
// CHECK: @fs1 = global %struct.C {
// CHECK-SAME: ptr ptrauth (ptr @external_function, [i64 1, i64 431, i64 0]),
// CHECK-SAME: ptr ptrauth (ptr @external_function, [i64 1, i64 9182, i64 0]),
// CHECK-SAME: ptr ptrauth (ptr @external_function, [i64 1, i64 783, i64 0]) }
struct C fs1 = { &external_function, &external_function, &external_function };

struct D {
  fpt __ptrauth(1,1,1276) f0;
  fpt __ptrauth(1,1,23674) f1;
  fpt __ptrauth(1,1,163) f2;
};
// CHECK: @fs2 = global %struct.D {
// CHECK-SAME: ptr ptrauth (ptr @external_function, [i64 1, i64 1276, i64 ptrtoint (ptr @fs2 to i64)]),
// CHECK-SAME: ptr ptrauth (ptr @external_function, [i64 1, i64 23674, i64 ptrtoint (ptr getelementptr inbounds (%struct.D, ptr @fs2, i32 0, i32 1) to i64)]),
// CHECK-SAME: ptr ptrauth (ptr @external_function, [i64 1, i64 163, i64 ptrtoint (ptr getelementptr inbounds (%struct.D, ptr @fs2, i32 0, i32 2) to i64)]) }
struct D fs2 = { &external_function, &external_function, &external_function };
