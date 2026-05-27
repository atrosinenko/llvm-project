// RUN: %clang_cc1 -triple arm64-apple-ios -debug-info-kind=line-tables-only -dwarf-version=5 -emit-llvm -verify -fptrauth-intrinsics %s -o /dev/null

typedef __UINTPTR_TYPE__ uintptr_t;

void callee(uintptr_t disc);

uintptr_t test_blend_usage(int *dp) {
  (void)__builtin_ptrauth_blend_discriminator(dp, 1);

  uintptr_t tmp1 = __builtin_ptrauth_blend_discriminator(dp, 2);
  int *tmp2 = __builtin_ptrauth_sign_unauthenticated(dp, 0, tmp1);

  callee(__builtin_ptrauth_blend_discriminator(dp, 3));
  // expected-warning@-1 {{failed to eliminate call to @llvm.ptrauth.blend intrinsic}}

  return __builtin_ptrauth_blend_discriminator(dp, 4);
  // expected-warning@-1 {{failed to eliminate call to @llvm.ptrauth.blend intrinsic}}
}

void *test_too_wide_constant(void *ptr, void *arg) {
  unsigned long discr = __builtin_ptrauth_blend_discriminator(arg, 12345678);
  // expected-warning@-1 {{failed to eliminate call to @llvm.ptrauth.blend intrinsic}}
  return __builtin_ptrauth_auth(ptr, 2, discr);
}
