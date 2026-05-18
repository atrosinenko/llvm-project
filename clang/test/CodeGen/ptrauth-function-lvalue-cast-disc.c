// RUN: %clang_cc1 %s -triple arm64e-apple-ios13 -fptrauth-calls -fptrauth-intrinsics -emit-llvm -o- -fptrauth-function-pointer-type-discrimination | FileCheck -check-prefixes CHECK,TYPE %s
// RUN: %clang_cc1 %s -triple aarch64-linux-gnu  -fptrauth-calls -fptrauth-intrinsics -emit-llvm -o- -fptrauth-function-pointer-type-discrimination | FileCheck -check-prefixes CHECK,TYPE %s
// RUN: %clang_cc1 %s -triple arm64e-apple-ios13 -fptrauth-calls -fptrauth-intrinsics -emit-llvm -o- | FileCheck -check-prefixes CHECK,ZERO %s
// RUN: %clang_cc1 %s -triple aarch64-linux-gnu  -fptrauth-calls -fptrauth-intrinsics -emit-llvm -o- | FileCheck -check-prefixes CHECK,ZERO %s

typedef void (*fptr_t)(void);

char *cptr;
void (*fptr)(void);

// CHECK-LABEL: define{{.*}} void @test1
void test1() {
  // TYPE: [[LOAD:%.*]] = load ptr, ptr @cptr
  // TYPE: call ptr @llvm.ptrauth.resign.p0(ptr [[LOAD]]) [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 0, i64 18983, i64 0) ]
  // TYPE: call void {{.*}}() [ "ptrauth"(i64 0, i64 18983, i64 0) ]
  // ZERO-NOT: @llvm.ptrauth.resign

  (*(fptr_t)cptr)();
}

// CHECK-LABEL: define{{.*}} i8 @test2
char test2() {
  return *(char *)fptr;

  // TYPE: [[LOAD:%.*]] = load ptr, ptr @fptr
  // TYPE: [[CMP:%.*]] = icmp ne ptr [[LOAD]], null
  // TYPE-NEXT: br i1 [[CMP]], label %[[NONNULL:.*]], label %[[CONT:.*]]

  // TYPE: [[NONNULL]]:
  // TYPE: [[CALL:%.*]] = call ptr @llvm.ptrauth.resign.p0(ptr [[LOAD]]) [ "ptrauth"(i64 0, i64 18983, i64 0), "ptrauth"(i64 0, i64 0, i64 0) ]

  // TYPE: [[CONT]]:
  // TYPE: phi ptr [ null, {{.*}} ], [ [[CALL]], %[[NONNULL]] ]
  // ZERO-NOT: @llvm.ptrauth.resign
}

// CHECK-LABEL: define{{.*}} void @test4
void test4() {
  (*((fptr_t)(&*((char *)(&*(fptr_t)cptr)))))();

  // CHECK: [[LOAD:%.*]] = load ptr, ptr @cptr
  // TYPE-NEXT: [[RESIGN:%.*]] = call ptr @llvm.ptrauth.resign.p0(ptr [[LOAD]]) [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 0, i64 18983, i64 0) ]
  // TYPE-NEXT: call void [[RESIGN]]() [ "ptrauth"(i64 0, i64 18983, i64 0) ]
  // ZERO-NOT: @llvm.ptrauth.resign
  // ZERO: call void [[LOAD]]() [ "ptrauth"(i64 0, i64 0, i64 0) ]
}

void *vptr;
// CHECK-LABEL: define{{.*}} void @test5
void test5() {
  vptr = &*(char *)fptr;

  // TYPE: [[LOAD:%.*]] = load ptr, ptr @fptr
  // TYPE-NEXT: [[CMP]] = icmp ne ptr [[LOAD]], null
  // TYPE-NEXT: br i1 [[CMP]], label %[[NONNULL:.*]], label %[[CONT:.*]]

  // TYPE: [[NONNULL]]:
  // TYPE: [[RESIGN:%.*]] = call ptr @llvm.ptrauth.resign.p0(ptr {{.*}}) [ "ptrauth"(i64 0, i64 18983, i64 0), "ptrauth"(i64 0, i64 0, i64 0) ]

  // TYPE: [[CONT]]:
  // TYPE: [[PHI:%.*]] = phi ptr [ null, {{.*}} ], [ [[RESIGN]], %[[NONNULL]] ]
  // TYPE: store ptr [[PHI]], ptr @vptr
  // ZERO-NOT: @llvm.ptrauth.resign
}
