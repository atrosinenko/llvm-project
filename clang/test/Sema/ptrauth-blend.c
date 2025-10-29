// RUN: %clang_cc1 -triple arm64-apple-ios -emit-llvm -verify -fptrauth-intrinsics %s -o /dev/null

typedef __UINTPTR_TYPE__ uintptr_t;

void callee(uintptr_t disc);

// expected-no-diagnostics

uintptr_t test_blend_can_only_be_used_as_argument_of_ptrauth_intrinsic(int *dp) {
  (void)__builtin_ptrauth_blend_discriminator(dp, 1);
  uintptr_t tmp1 = __builtin_ptrauth_blend_discriminator(dp, 2);
  int *tmp2 = __builtin_ptrauth_sign_unauthenticated(dp, 0, tmp1);
  callee(__builtin_ptrauth_blend_discriminator(dp, 3));
  return __builtin_ptrauth_blend_discriminator(dp, 4);
}
