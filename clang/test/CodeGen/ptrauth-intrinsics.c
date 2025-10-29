// RUN: %clang_cc1 -triple arm64-apple-ios -fptrauth-intrinsics -emit-llvm %s  -o - | FileCheck %s
// RUN: %clang_cc1 -triple aarch64-elf     -fptrauth-intrinsics -emit-llvm %s  -o - | FileCheck %s
//
// RUN: %clang_cc1 -triple arm64-apple-ios -fptrauth-intrinsics -emit-llvm %s  -o - -fexperimental-new-constant-interpreter | FileCheck %s
// RUN: %clang_cc1 -triple aarch64-elf     -fptrauth-intrinsics -emit-llvm %s  -o - -fexperimental-new-constant-interpreter | FileCheck %s

void (*fnptr)(void);
long int_discriminator;
void *ptr_discriminator;
long signature;

// CHECK-LABEL: define {{.*}}void @test_auth()
void test_auth() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[T0:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: [[DISC0:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[DISC:%.*]] = ptrtoint ptr [[DISC0]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.auth(i64 [[T0]]) [ "ptrauth"(i64 0, i64 0, i64 [[DISC]]) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  fnptr = __builtin_ptrauth_auth(fnptr, 0, ptr_discriminator);
}

// CHECK-LABEL: define {{.*}}void @test_strip()
void test_strip() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[T0:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.strip(i64 [[T0]]) [ "ptrauth"(i64 0) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  fnptr = __builtin_ptrauth_strip(fnptr, 0);
}

// CHECK-LABEL: define {{.*}}void @test_sign_unauthenticated()
void test_sign_unauthenticated() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[T0:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: [[DISC0:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[DISC:%.*]] = ptrtoint ptr [[DISC0]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.sign(i64 [[T0]]) [ "ptrauth"(i64 0, i64 0, i64 [[DISC]]) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  fnptr = __builtin_ptrauth_sign_unauthenticated(fnptr, 0, ptr_discriminator);
}

// CHECK-LABEL: define {{.*}}void @test_auth_and_resign()
void test_auth_and_resign() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[T0:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: [[DISC0:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[DISC:%.*]] = ptrtoint ptr [[DISC0]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.resign(i64 [[T0]]) [ "ptrauth"(i64 0, i64 0, i64 [[DISC]]), "ptrauth"(i64 3, i64 15, i64 0) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  fnptr = __builtin_ptrauth_auth_and_resign(fnptr, 0, ptr_discriminator, 3, 15);
}

// CHECK-LABEL: define {{.*}}void @test_auth_load_relative_and_sign()
void test_auth_load_relative_and_sign() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[T0:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: [[DISC0:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[DISC:%.*]] = ptrtoint ptr [[DISC0]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.resign.load.relative(i64 [[T0]], i64 16) [ "ptrauth"(i64 0, i64 0, i64 [[DISC]]), "ptrauth"(i64 3, i64 15, i64 0) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  fnptr = __builtin_ptrauth_auth_load_relative_and_sign(fnptr, 0, ptr_discriminator, 3, 15, 16L);
}

// CHECK-LABEL: define {{.*}}void @test_auth_blend_generic_discriminator()
void test_auth_blend_generic_discriminator() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[CAST_PTR:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: [[DISC:%.*]] = load i64, ptr @int_discriminator,
  // CHECK-NEXT: [[BLEND:%.*]] = call i64 @llvm.ptrauth.blend(i64 [[CAST_PTR]], i64 [[DISC]])
  // CHECK-NEXT: [[FNPTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[CAST_FNPTR:%.*]] = ptrtoint ptr [[FNPTR]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.auth(i64 [[CAST_FNPTR]]) [ "ptrauth"(i64 0, i64 0, i64 [[BLEND]]) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  unsigned long discr = __builtin_ptrauth_blend_discriminator(ptr_discriminator, int_discriminator);
  fnptr = __builtin_ptrauth_auth(fnptr, 0, discr);
}

// CHECK-LABEL: define {{.*}}void @test_sign_blend_generic_discriminator()
void test_sign_blend_generic_discriminator() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[CAST_PTR:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: [[DISC:%.*]] = load i64, ptr @int_discriminator,
  // CHECK-NEXT: [[BLEND:%.*]] = call i64 @llvm.ptrauth.blend(i64 [[CAST_PTR]], i64 [[DISC]])
  // CHECK-NEXT: [[FNPTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[CAST_FNPTR:%.*]] = ptrtoint ptr [[FNPTR]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.sign(i64 [[CAST_FNPTR]]) [ "ptrauth"(i64 0, i64 0, i64 [[BLEND]]) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  unsigned long discr = __builtin_ptrauth_blend_discriminator(ptr_discriminator, int_discriminator);
  fnptr = __builtin_ptrauth_sign_unauthenticated(fnptr, 0, discr);
}

// CHECK-LABEL: define {{.*}}void @test_resign_blend_generic_discriminator()
void test_resign_blend_generic_discriminator() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[CAST_PTR:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: [[DISC:%.*]] = load i64, ptr @int_discriminator,
  // CHECK-NEXT: [[BLEND:%.*]] = call i64 @llvm.ptrauth.blend(i64 [[CAST_PTR]], i64 [[DISC]])
  // CHECK-NEXT: [[FNPTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[CAST_FNPTR:%.*]] = ptrtoint ptr [[FNPTR]] to i64
  // CHECK-NEXT: call i64 @llvm.ptrauth.blend(i64 ptrtoint (ptr @int_discriminator to i64), i64 1234)
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.resign(i64 [[CAST_FNPTR]]) [ "ptrauth"(i64 0, i64 0, i64 [[BLEND]]), "ptrauth"(i64 1, i64 1234, i64 ptrtoint (ptr @int_discriminator to i64)) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  unsigned long discr = __builtin_ptrauth_blend_discriminator(ptr_discriminator, int_discriminator);
  fnptr = __builtin_ptrauth_auth_and_resign(fnptr, 0, discr, 1, __builtin_ptrauth_blend_discriminator(&int_discriminator, 1234));
}

// CHECK-LABEL: define {{.*}}void @test_auth_blend_discriminator()
void test_auth_blend_discriminator() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[CAST_PTR:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: call i64 @llvm.ptrauth.blend(i64 [[CAST_PTR]], i64 42)
  // CHECK-NEXT: [[FNPTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[CAST_FNPTR:%.*]] = ptrtoint ptr [[FNPTR]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.auth(i64 [[CAST_FNPTR]]) [ "ptrauth"(i64 0, i64 42, i64 [[CAST_PTR]]) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  unsigned long discr = __builtin_ptrauth_blend_discriminator(ptr_discriminator, 42);
  fnptr = __builtin_ptrauth_auth(fnptr, 0, discr);
}

// CHECK-LABEL: define {{.*}}void @test_sign_blend_discriminator()
void test_sign_blend_discriminator() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[CAST_PTR:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: call i64 @llvm.ptrauth.blend(i64 [[CAST_PTR]], i64 42)
  // CHECK-NEXT: [[FNPTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[CAST_FNPTR:%.*]] = ptrtoint ptr [[FNPTR]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.sign(i64 [[CAST_FNPTR]]) [ "ptrauth"(i64 0, i64 42, i64 [[CAST_PTR]]) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  unsigned long discr = __builtin_ptrauth_blend_discriminator(ptr_discriminator, 42);
  fnptr = __builtin_ptrauth_sign_unauthenticated(fnptr, 0, discr);
}

// CHECK-LABEL: define {{.*}}void @test_resign_blend_discriminator()
void test_resign_blend_discriminator() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[CAST_PTR:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: call i64 @llvm.ptrauth.blend(i64 [[CAST_PTR]], i64 42)
  // CHECK-NEXT: [[FNPTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[CAST_FNPTR:%.*]] = ptrtoint ptr [[FNPTR]] to i64
  // CHECK-NEXT: call i64 @llvm.ptrauth.blend(i64 ptrtoint (ptr @int_discriminator to i64), i64 1234)
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.resign(i64 [[CAST_FNPTR]]) [ "ptrauth"(i64 0, i64 42, i64 [[CAST_PTR]]), "ptrauth"(i64 1, i64 1234, i64 ptrtoint (ptr @int_discriminator to i64)) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  unsigned long discr = __builtin_ptrauth_blend_discriminator(ptr_discriminator, 42);
  fnptr = __builtin_ptrauth_auth_and_resign(fnptr, 0, discr, 1, __builtin_ptrauth_blend_discriminator(&int_discriminator, 1234));
}

// CHECK-LABEL: define {{.*}}void @test_resign_twice_the_same_blend()
void test_resign_twice_the_same_blend() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[CAST_PTR:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: call i64 @llvm.ptrauth.blend(i64 [[CAST_PTR]], i64 42)
  // CHECK-NEXT: [[FNPTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[CAST_FNPTR:%.*]] = ptrtoint ptr [[FNPTR]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.resign(i64 [[CAST_FNPTR]]) [ "ptrauth"(i64 0, i64 42, i64 [[CAST_PTR]]), "ptrauth"(i64 1, i64 42, i64 [[CAST_PTR]]) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  unsigned long discr = __builtin_ptrauth_blend_discriminator(ptr_discriminator, 42);
  fnptr = __builtin_ptrauth_auth_and_resign(fnptr, 0, discr, 1, discr);
}

// CHECK-LABEL: define {{.*}}void @test_blend_discriminator_wide_const()
void test_blend_discriminator_wide_const() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[CAST_PTR:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: [[BLEND:%.*]] = call i64 @llvm.ptrauth.blend(i64 [[CAST_PTR]], i64 1234567)
  // CHECK-NEXT: [[FNPTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[CAST_FNPTR:%.*]] = ptrtoint ptr [[FNPTR]] to i64
  // CHECK-NEXT: [[T1:%.*]] = call i64 @llvm.ptrauth.auth(i64 [[CAST_FNPTR]]) [ "ptrauth"(i64 0, i64 0, i64 [[BLEND]]) ]
  // CHECK-NEXT: [[RESULT:%.*]] = inttoptr  i64 [[T1]] to ptr
  // CHECK-NEXT: store ptr [[RESULT]], ptr @fnptr,
  unsigned long discr = __builtin_ptrauth_blend_discriminator(ptr_discriminator, 1234567);
  fnptr = __builtin_ptrauth_auth(fnptr, 0, discr);
}

// CHECK-LABEL: define {{.*}}void @test_sign_generic_data()
void test_sign_generic_data() {
  // CHECK:      [[PTR:%.*]] = load ptr, ptr @fnptr,
  // CHECK-NEXT: [[T0:%.*]] = ptrtoint ptr [[PTR]] to i64
  // CHECK-NEXT: [[DISC0:%.*]] = load ptr, ptr @ptr_discriminator,
  // CHECK-NEXT: [[DISC:%.*]] = ptrtoint ptr [[DISC0]] to i64
  // CHECK-NEXT: [[RESULT:%.*]] = call i64 @llvm.ptrauth.sign.generic(i64 [[T0]], i64 [[DISC]])
  // CHECK-NEXT: store i64 [[RESULT]], ptr @signature,
  signature = __builtin_ptrauth_sign_generic_data(fnptr, ptr_discriminator);
}

// CHECK-LABEL: define {{.*}}void @test_string_discriminator()
void test_string_discriminator() {
  // CHECK:      [[X:%.*]] = alloca i32

  // Check a couple of random discriminators used by Swift.

  // CHECK:      store i32 58298, ptr [[X]],
  int x = __builtin_ptrauth_string_discriminator("InitializeWithCopy");

  // CHECK:      store i32 9112, ptr [[X]],
  x = __builtin_ptrauth_string_discriminator("DestroyArray");
}
