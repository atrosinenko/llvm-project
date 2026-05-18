; RUN: llc < %s -O0 -mtriple=aarch64-none-linux-gnu -mattr=+pauth -global-isel=0 | FileCheck %s
; RUN: llc < %s -O2 -mtriple=aarch64-none-linux-gnu -mattr=+pauth -global-isel=0 | FileCheck %s
; RUN: llc < %s -O0 -mtriple=aarch64-none-linux-gnu -mattr=+pauth -global-isel=1 -global-isel-abort=1 | FileCheck %s
; RUN: llc < %s -O2 -mtriple=aarch64-none-linux-gnu -mattr=+pauth -global-isel=1 -global-isel-abort=1 | FileCheck %s

@ds = external global i8

declare void @f(ptr %p)

; CHECK: call:
define void @call(ptr %p) {
  ; CHECK: [[LABEL:.L.*]]:
  ; CHECK-NEXT: .reloc [[LABEL]], R_AARCH64_PATCHINST, ds
  ; CHECK-NEXT: bl f
  notail call void @f(ptr %p) [ "deactivation-symbol"(ptr @ds) ]
  ret void
}

; CHECK: pauth_sign_zero:
define ptr @pauth_sign_zero(ptr %p) {
  ; CHECK: [[LABEL:.L.*]]:
  ; CHECK-NEXT: .reloc [[LABEL]], R_AARCH64_PATCHINST, ds
  ; CHECK-NEXT: paciza x0
  %signed = call ptr @llvm.ptrauth.sign(ptr %p) [ "ptrauth"(i64 0, i64 0, i64 0), "deactivation-symbol"(ptr @ds) ]
  ret ptr %signed
}

; CHECK: pauth_sign_const:
define ptr @pauth_sign_const(ptr %p) {
  ; CHECK: mov x16, #12345
  ; CHECK-NEXT: [[LABEL:.L.*]]:
  ; CHECK-NEXT: .reloc [[LABEL]], R_AARCH64_PATCHINST, ds
  ; CHECK-NEXT: pacia x0, x16
  %signed = call ptr @llvm.ptrauth.sign(ptr %p) [ "ptrauth"(i64 0, i64 12345, i64 0), "deactivation-symbol"(ptr @ds) ]
  ret ptr %signed
}

; CHECK: pauth_sign:
define ptr @pauth_sign(ptr %p, i64 %d) {
  ; CHECK: [[LABEL:.L.*]]:
  ; CHECK-NEXT: .reloc [[LABEL]], R_AARCH64_PATCHINST, ds
  ; CHECK-NEXT: pacia x0, x1
  %signed = call ptr @llvm.ptrauth.sign(ptr %p) [ "ptrauth"(i64 0, i64 0, i64 %d), "deactivation-symbol"(ptr @ds) ]
  ret ptr %signed
}

; CHECK: pauth_auth_zero:
define ptr @pauth_auth_zero(ptr %p) {
  ; CHECK: [[LABEL:.L.*]]:
  ; CHECK-NEXT: .reloc [[LABEL]], R_AARCH64_PATCHINST, ds
  ; CHECK-NEXT: autiza x0
  %authed = call ptr @llvm.ptrauth.auth(ptr %p) [ "ptrauth"(i64 0, i64 0, i64 0), "deactivation-symbol"(ptr @ds) ]
  ret ptr %authed
}

; CHECK: pauth_auth_const:
define ptr @pauth_auth_const(ptr %p) {
  ; CHECK: mov x8, #12345
  ; CHECK-NEXT: [[LABEL:.L.*]]:
  ; CHECK-NEXT: .reloc [[LABEL]], R_AARCH64_PATCHINST, ds
  ; CHECK-NEXT: autia x0, x8
  %authed = call ptr @llvm.ptrauth.auth(ptr %p) [ "ptrauth"(i64 0, i64 12345, i64 0), "deactivation-symbol"(ptr @ds) ]
  ret ptr %authed
}

; CHECK: pauth_auth:
define ptr @pauth_auth(ptr %p, i64 %d) {
  ; CHECK: [[LABEL:.L.*]]:
  ; CHECK-NEXT: .reloc [[LABEL]], R_AARCH64_PATCHINST, ds
  ; CHECK-NEXT: autia x0, x1
  %authed = call ptr @llvm.ptrauth.auth(ptr %p) [ "ptrauth"(i64 0, i64 0, i64 %d), "deactivation-symbol"(ptr @ds) ]
  ret ptr %authed
}
