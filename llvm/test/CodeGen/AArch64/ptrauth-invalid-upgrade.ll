; RUN: split-file %s %t

;--- wrong-intrinsic-with-ptrauth-bundle.ll
; RUN: not opt -passes=verify -S < %t/wrong-intrinsic-with-ptrauth-bundle.ll 2>&1 | FileCheck --check-prefix=WRONG-INTRINSIC-WITH-PTRAUTH-BUNDLE %s

; This test case does not involve auto-upgrading, but it shows the behavior of
; the IR verifier if any unrelated intrinsic would be formally auto-upgraded.

; WRONG-INTRINSIC-WITH-PTRAUTH-BUNDLE:      Unexpected ptrauth bundle
; WRONG-INTRINSIC-WITH-PTRAUTH-BUNDLE-NEXT:   %1 = call i64 @llvm.ptrauth.sign.generic(i64 %p, i64 0) [ "ptrauth"(i64 1, i64 42, i64 %addr) ]
; WRONG-INTRINSIC-WITH-PTRAUTH-BUNDLE-NEXT: /data/ast/llvm-project/build/bin/opt: -: error: input module is broken!

define void @test(i64 %p, ptr %auth_like_fn, i64 %addr) {
  ; The below call uses the new-style all-i64 ptrauth bundle.
  call i64 @llvm.ptrauth.sign.generic(i64 %p, i64 0) [ "ptrauth"(i64 1, i64 42, i64 %addr) ]
  ret void
}
