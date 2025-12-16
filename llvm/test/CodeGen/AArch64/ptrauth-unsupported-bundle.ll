; RUN: split-file %s %t
; REQUIRES: x86-registered-target

; Note: x86 here is an arbitrary target that does *not* support PtrAuth - to be
;       used by unsupported-target-*.ll test cases.
; Note: Target-specific constraints are checked during the ISel, thus the
;       corresponding test cases have RUN lines duplicated: for DAGISel and
;       for GlobalISel.

;--- empty.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/empty.ll 2>&1 | FileCheck --check-prefix=EMPTY %s

; Empty "ptrauth" bundles are rejected by target-independent LLVM IR Verifier.

; EMPTY:      Expected non-empty ptrauth bundle
; EMPTY-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"() ]
; EMPTY-NEXT: llc: error: '<stdin>': input module cannot be verified

define i64 @test(i64 %p) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"() ]
  ret i64 %res
}

;--- wrong-type-i32.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-type-i32.ll 2>&1 | FileCheck --check-prefix=WRONG-TYPE-I32 %s

; Non-i64 operands of "ptrauth" bundles are rejected by target-independent
; LLVM IR Verifier, provided they cannot be auto-upgraded when the LLVM IR
; source is being read.

; WRONG-TYPE-I32:      Ptrauth bundle must only contain i64 operands
; WRONG-TYPE-I32-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i32 0, i32 0, i64 0) ]
; WRONG-TYPE-I32-NEXT: llc: error: '<stdin>': input module cannot be verified

define i64 @test(i64 %p) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i32 0, i32 0, i64 0) ]
  ret i64 %res
}

;--- wrong-type-ptr.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-type-ptr.ll 2>&1 | FileCheck --check-prefix=WRONG-TYPE-PTR %s

; WRONG-TYPE-PTR:      Ptrauth bundle must only contain i64 operands
; WRONG-TYPE-PTR-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 0, ptr %arg) ]
; WRONG-TYPE-PTR-NEXT: llc: error: '<stdin>': input module cannot be verified

define i64 @test(i64 %p, ptr %arg) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 0, ptr %arg) ]
  ret i64 %res
}

;--- wrong-not-one-bundle.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-not-one-bundle.ll 2>&1 | FileCheck --check-prefix=WRONG-NOT-ONE-BUNDLE %s

; Wrong number of "ptrauth" bundles is rejected by target-independent
; LLVM IR Verifier.

; WRONG-NOT-ONE-BUNDLE:      Expected exactly one ptrauth bundle
; WRONG-NOT-ONE-BUNDLE-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 0, i64 0, i64 0) ]
; WRONG-NOT-ONE-BUNDLE-NEXT: llc: error: '<stdin>': input module cannot be verified

define i64 @test(i64 %p) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 0, i64 0, i64 0) ]
  ret i64 %res
}

;--- wrong-not-two-bundles.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-not-two-bundles.ll 2>&1 | FileCheck --check-prefix=WRONG-NOT-TWO-BUNDLES %s

; WRONG-NOT-TWO-BUNDLES:      Expected exactly two ptrauth bundles
; WRONG-NOT-TWO-BUNDLES-NEXT: %res = call i64 @llvm.ptrauth.resign(i64 %p) [ "ptrauth"(i64 0, i64 0, i64 0) ]
; WRONG-NOT-TWO-BUNDLES-NEXT: llc: error: '<stdin>': input module cannot be verified

define i64 @test(i64 %p) {
  %res = call i64 @llvm.ptrauth.resign(i64 %p) [ "ptrauth"(i64 0, i64 0, i64 0) ]
  ret i64 %res
}

;--- wrong-missing-bundle.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-missing-bundle.ll 2>&1 | FileCheck --check-prefix=WRONG-MISSING-BUNDLE %s

; WRONG-MISSING-BUNDLE:      Expected exactly one ptrauth bundle
; WRONG-MISSING-BUNDLE-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p)
; WRONG-MISSING-BUNDLE-NEXT: llc: error: '<stdin>': input module cannot be verified

define i64 @test(i64 %p) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p)
  ret i64 %res
}

;--- wrong-indirect-call-multiple-bundles.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-indirect-call-multiple-bundles.ll 2>&1 | FileCheck --check-prefix=WRONG-INDIRECT-CALL-MULTIPLE-BUNDLES %s

; WRONG-INDIRECT-CALL-MULTIPLE-BUNDLES:      Multiple ptrauth operand bundles on a function call
; WRONG-INDIRECT-CALL-MULTIPLE-BUNDLES-NEXT: %res = call i64 %fptr() [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 0, i64 0, i64 0) ]
; WRONG-INDIRECT-CALL-MULTIPLE-BUNDLES-NEXT: llc: error: '<stdin>': input module cannot be verified

define i64 @test(ptr %fptr) {
  %res = call i64 %fptr() [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 0, i64 0, i64 0) ]
  ret i64 %res
}
;--- unsupported-target-intrinsic.ll
; RUN: not llc -mtriple x86_64                                     < %t/unsupported-target-intrinsic.ll 2>&1 | FileCheck --check-prefix=UNSUPPORTED-TARGET-INTRINSIC %s
; RUN: not llc -mtriple x86_64 -global-isel=1 -global-isel-abort=1 < %t/unsupported-target-intrinsic.ll 2>&1 | FileCheck --check-prefix=UNSUPPORTED-TARGET-INTRINSIC %s

; UNSUPPORTED-TARGET-INTRINSIC:      Ptrauth schema violates target-specific constraints:
; UNSUPPORTED-TARGET-INTRINSIC-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0) ]
; UNSUPPORTED-TARGET-INTRINSIC-NEXT: LLVM ERROR: Invalid ptrauth schema: this target does not support pointer authentication

define i64 @test(i64 %p) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0) ]
  ret i64 %res
}

;--- unsupported-target-indirect-call.ll
; RUN: not llc -mtriple x86_64                                     < %t/unsupported-target-indirect-call.ll 2>&1 | FileCheck --check-prefix=UNSUPPORTED-TARGET-INDIRECT-CALL %s
; RUN: not llc -mtriple x86_64 -global-isel=1 -global-isel-abort=1 < %t/unsupported-target-indirect-call.ll 2>&1 | FileCheck --check-prefix=UNSUPPORTED-TARGET-INDIRECT-CALL %s

; UNSUPPORTED-TARGET-INDIRECT-CALL:      Ptrauth schema violates target-specific constraints:
; UNSUPPORTED-TARGET-INDIRECT-CALL-NEXT: %res = call i64 %fptr() [ "ptrauth"(i64 0) ]
; UNSUPPORTED-TARGET-INDIRECT-CALL-NEXT: LLVM ERROR: Invalid ptrauth schema: this target does not support pointer authentication

define i64 @test(ptr %fptr) {
  %res = call i64 %fptr() [ "ptrauth"(i64 0) ]
  ret i64 %res
}

;--- wrong-not-3-ops.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-not-3-ops.ll 2>&1 | FileCheck --check-prefix=WRONG-NOT-3-OPS %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-not-3-ops.ll 2>&1 | FileCheck --check-prefix=WRONG-NOT-3-OPS %s

; Single-operand bundles may be used on AArch64, but not by this intrinsic.

; WRONG-NOT-3-OPS:      Ptrauth schema violates target-specific constraints:
; WRONG-NOT-3-OPS-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0) ]
; WRONG-NOT-3-OPS-NEXT: LLVM ERROR: Invalid ptrauth schema: test: three-element ptrauth schema expected

define i64 @test(i64 %p) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0) ]
  ret i64 %res
}

;--- wrong-not-1-ops.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-not-1-ops.ll 2>&1 | FileCheck --check-prefix=WRONG-NOT-1-OPS %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-not-1-ops.ll 2>&1 | FileCheck --check-prefix=WRONG-NOT-1-OPS %s

; Three-operand bundles may be used on AArch64, but not by this intrinsic.

; WRONG-NOT-1-OPS:      Ptrauth schema violates target-specific constraints:
; WRONG-NOT-1-OPS-NEXT: %res = call i64 @llvm.ptrauth.strip(i64 %p) [ "ptrauth"(i64 0, i64 0, i64 0) ]
; WRONG-NOT-1-OPS-NEXT: LLVM ERROR: Invalid ptrauth schema: test: single-element ptrauth schema expected

define i64 @test(i64 %p) {
  %res = call i64 @llvm.ptrauth.strip(i64 %p) [ "ptrauth"(i64 0, i64 0, i64 0) ]
  ret i64 %res
}

;--- wrong-num-operands.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-num-operands.ll 2>&1 | FileCheck --check-prefix=WRONG-NUM-OPERANDS %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-num-operands.ll 2>&1 | FileCheck --check-prefix=WRONG-NUM-OPERANDS %s

; Four-operand bundles are never used on AArch64.

; WRONG-NUM-OPERANDS:      Ptrauth schema violates target-specific constraints:
; WRONG-NUM-OPERANDS-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 0, i64 0, i64 0) ]
; WRONG-NUM-OPERANDS-NEXT: LLVM ERROR: Invalid ptrauth schema: test: three-element ptrauth schema expected

define i64 @test(i64 %p, i64 %arg) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 0, i64 0, i64 0) ]
  ret i64 %res
}

;--- wrong-key-not-const.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-key-not-const.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-NOT-CONST %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-key-not-const.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-NOT-CONST %s

; WRONG-KEY-NOT-CONST:      Ptrauth schema violates target-specific constraints:
; WRONG-KEY-NOT-CONST-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 %arg, i64 0, i64 0) ]
; WRONG-KEY-NOT-CONST-NEXT: LLVM ERROR: Invalid ptrauth schema: test: key must be constant in range [0, 3]

define i64 @test(i64 %p, i64 %arg) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 %arg, i64 0, i64 0) ]
  ret i64 %res
}

;--- wrong-key-negative.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-key-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-NEGATIVE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-key-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-NEGATIVE %s

; WRONG-KEY-NEGATIVE:      Ptrauth schema violates target-specific constraints:
; WRONG-KEY-NEGATIVE-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 -1, i64 0, i64 0) ]
; WRONG-KEY-NEGATIVE-NEXT: LLVM ERROR: Invalid ptrauth schema: test: key must be constant in range [0, 3]

define i64 @test(i64 %p, i64 %arg) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 -1, i64 0, i64 0) ]
  ret i64 %res
}

;--- wrong-key-out-of-range.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-key-out-of-range.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-OUT-OF-RANGE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-key-out-of-range.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-OUT-OF-RANGE %s

; WRONG-KEY-OUT-OF-RANGE:      Ptrauth schema violates target-specific constraints:
; WRONG-KEY-OUT-OF-RANGE-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 4, i64 0, i64 0) ]
; WRONG-KEY-OUT-OF-RANGE-NEXT: LLVM ERROR: Invalid ptrauth schema: test: key must be constant in range [0, 3]

define i64 @test(i64 %p, i64 %arg) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 4, i64 0, i64 0) ]
  ret i64 %res
}

;--- wrong-imm-modifier-not-const.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-imm-modifier-not-const.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-NOT-CONST %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-imm-modifier-not-const.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-NOT-CONST %s

; WRONG-IMM-MODIFIER-NOT-CONST:      Ptrauth schema violates target-specific constraints:
; WRONG-IMM-MODIFIER-NOT-CONST-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 %arg, i64 0) ]
; WRONG-IMM-MODIFIER-NOT-CONST-NEXT: LLVM ERROR: Invalid ptrauth schema: test: constant modifier must be 16-bit unsigned constant

define i64 @test(i64 %p, i64 %arg) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 %arg, i64 0) ]
  ret i64 %res
}

;--- wrong-imm-modifier-negative.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-imm-modifier-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-NEGATIVE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-imm-modifier-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-NEGATIVE %s

; WRONG-IMM-MODIFIER-NEGATIVE:      Ptrauth schema violates target-specific constraints:
; WRONG-IMM-MODIFIER-NEGATIVE-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 -1, i64 0) ]
; WRONG-IMM-MODIFIER-NEGATIVE-NEXT: LLVM ERROR: Invalid ptrauth schema: test: constant modifier must be 16-bit unsigned constant

define i64 @test(i64 %p) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 -1, i64 0) ]
  ret i64 %res
}

;--- wrong-imm-modifier-too-wide.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-imm-modifier-too-wide.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-TOO-WIDE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-imm-modifier-too-wide.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-TOO-WIDE %s

; WRONG-IMM-MODIFIER-TOO-WIDE:      Ptrauth schema violates target-specific constraints:
; WRONG-IMM-MODIFIER-TOO-WIDE-NEXT: %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 123456, i64 0) ]
; WRONG-IMM-MODIFIER-TOO-WIDE-NEXT: LLVM ERROR: Invalid ptrauth schema: test: constant modifier must be 16-bit unsigned constant

define i64 @test(i64 %p) {
  %res = call i64 @llvm.ptrauth.sign(i64 %p) [ "ptrauth"(i64 0, i64 123456, i64 0) ]
  ret i64 %res
}

;--- wrong-first-bundle.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-first-bundle.ll 2>&1 | FileCheck --check-prefix=WRONG-FIRST-BUNDLE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-first-bundle.ll 2>&1 | FileCheck --check-prefix=WRONG-FIRST-BUNDLE %s

; If the intrinsic accepts two bundles, both should be checked.

; WRONG-FIRST-BUNDLE:      Ptrauth schema violates target-specific constraints:
; WRONG-FIRST-BUNDLE-NEXT: %res = call i64 @llvm.ptrauth.resign(i64 %p) [ "ptrauth"(i64 %arg, i64 0, i64 0), "ptrauth"(i64 0, i64 0, i64 0) ]
; WRONG-FIRST-BUNDLE-NEXT: LLVM ERROR: Invalid ptrauth schema: test: key must be constant in range [0, 3]

define i64 @test(i64 %p, i64 %arg) {
  %res = call i64 @llvm.ptrauth.resign(i64 %p) [ "ptrauth"(i64 %arg, i64 0, i64 0), "ptrauth"(i64 0, i64 0, i64 0) ]
  ret i64 %res
}

;--- wrong-second-bundle.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-second-bundle.ll 2>&1 | FileCheck --check-prefix=WRONG-SECOND-BUNDLE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-second-bundle.ll 2>&1 | FileCheck --check-prefix=WRONG-SECOND-BUNDLE %s

; WRONG-SECOND-BUNDLE:      Ptrauth schema violates target-specific constraints:
; WRONG-SECOND-BUNDLE-NEXT: %res = call i64 @llvm.ptrauth.resign(i64 %p) [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 %arg, i64 0, i64 0) ]
; WRONG-SECOND-BUNDLE-NEXT: LLVM ERROR: Invalid ptrauth schema: test: key must be constant in range [0, 3]

define i64 @test(i64 %p, i64 %arg) {
  %res = call i64 @llvm.ptrauth.resign(i64 %p) [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 %arg, i64 0, i64 0) ]
  ret i64 %res
}
