// RUN: %clang_cc1 -triple arm64-apple-ios -fptrauth-intrinsics -emit-llvm %s  -o - 2>&1 | FileCheck --implicit-check-not=warning: %s
// RUN: %clang_cc1 -triple aarch64-elf     -fptrauth-intrinsics -emit-llvm %s  -o - 2>&1 | FileCheck --implicit-check-not=warning: %s

void *test_eliminated_blend(void *ptr, void *arg) {
  unsigned long discr = __builtin_ptrauth_blend_discriminator(arg, 42);
  return __builtin_ptrauth_auth(ptr, 2, discr);
}

void *test_too_wide_constant(void *ptr, void *arg) {
// CHECK: {{.*}}/ptrauth-intrinsic-blend.c:[[# @LINE-1]]:{{[0-9]+}}: warning: failed to eliminate call to @llvm.ptrauth.blend intrinsic [-Wpass-failed]
// CHECK: void *test_too_wide_constant(void *ptr, void *arg) {
  unsigned long discr = __builtin_ptrauth_blend_discriminator(arg, 12345678);
  return __builtin_ptrauth_auth(ptr, 2, discr);
}

unsigned long test_standalone_blend(void *arg) {
// CHECK: {{.*}}/ptrauth-intrinsic-blend.c:[[# @LINE-1]]:{{[0-9]+}}: warning: failed to eliminate call to @llvm.ptrauth.blend intrinsic [-Wpass-failed]
// CHECK: unsigned long test_standalone_blend(void *arg) {
  return __builtin_ptrauth_blend_discriminator(arg, 42);
}
