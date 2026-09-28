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
; EMPTY-NEXT: call void %fptr() [ "ptrauth"() ]
; EMPTY-NEXT: llc: error: '<stdin>': input module cannot be verified

define void @test(ptr %fptr) {
  call void %fptr() [ "ptrauth"() ]
  ret void
}

;--- wrong-type-i32.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-type-i32.ll 2>&1 | FileCheck --check-prefix=WRONG-TYPE-I32 %s

; Non-i64 operands of "ptrauth" bundles are rejected by target-independent
; LLVM IR Verifier, provided they cannot be auto-upgraded when the LLVM IR
; source is being read.

; WRONG-TYPE-I32:      Ptrauth bundle must only contain i64 operands
; WRONG-TYPE-I32-NEXT: call void %fptr() [ "ptrauth"(i32 0, i32 0, i64 0) ]
; WRONG-TYPE-I32-NEXT: llc: error: '<stdin>': input module cannot be verified

define void @test(ptr %fptr) {
  call void %fptr() [ "ptrauth"(i32 0, i32 0, i64 0) ]
  ret void
}

;--- wrong-type-ptr.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-type-ptr.ll 2>&1 | FileCheck --check-prefix=WRONG-TYPE-PTR %s

; WRONG-TYPE-PTR:      Ptrauth bundle must only contain i64 operands
; WRONG-TYPE-PTR-NEXT: call void %fptr() [ "ptrauth"(i64 0, i64 0, ptr %arg) ]
; WRONG-TYPE-PTR-NEXT: llc: error: '<stdin>': input module cannot be verified

define void @test(ptr %fptr, ptr %arg) {
  call void %fptr() [ "ptrauth"(i64 0, i64 0, ptr %arg) ]
  ret void
}

;--- wrong-indirect-call-multiple-bundles.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-indirect-call-multiple-bundles.ll 2>&1 | FileCheck --check-prefix=WRONG-INDIRECT-CALL-MULTIPLE-BUNDLES %s

; WRONG-INDIRECT-CALL-MULTIPLE-BUNDLES:      Multiple ptrauth operand bundles
; WRONG-INDIRECT-CALL-MULTIPLE-BUNDLES-NEXT: %res = call i64 %fptr() [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 0, i64 0, i64 0) ]
; WRONG-INDIRECT-CALL-MULTIPLE-BUNDLES-NEXT: llc: error: '<stdin>': input module cannot be verified

define i64 @test(ptr %fptr) {
  %res = call i64 %fptr() [ "ptrauth"(i64 0, i64 0, i64 0), "ptrauth"(i64 0, i64 0, i64 0) ]
  ret i64 %res
}

;--- unsupported-target-indirect-call.ll
; RUN: not llc -mtriple x86_64                                     < %t/unsupported-target-indirect-call.ll 2>&1 | FileCheck --check-prefix=UNSUPPORTED-TARGET-INDIRECT-CALL %s
; RUN: not llc -mtriple x86_64 -global-isel=1 -global-isel-abort=1 < %t/unsupported-target-indirect-call.ll 2>&1 | FileCheck --check-prefix=UNSUPPORTED-TARGET-INDIRECT-CALL %s

; UNSUPPORTED-TARGET-INDIRECT-CALL:      test: ptrauth schema violates target-specific constraints:
; UNSUPPORTED-TARGET-INDIRECT-CALL-NEXT: call void %fptr() [ "ptrauth"(i64 0) ]
; UNSUPPORTED-TARGET-INDIRECT-CALL-NEXT: LLVM ERROR: Invalid ptrauth schema: this target does not support pointer authentication

define void @test(ptr %fptr) {
  call void %fptr() [ "ptrauth"(i64 0) ]
  ret void
}

;--- wrong-fn-single-operand.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-fn-single-operand.ll 2>&1 | FileCheck --check-prefix=WRONG-FN-SINGLE-OPERAND %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-fn-single-operand.ll 2>&1 | FileCheck --check-prefix=WRONG-FN-SINGLE-OPERAND %s

; WRONG-FN-SINGLE-OPERAND:      test: ptrauth schema violates target-specific constraints:
; WRONG-FN-SINGLE-OPERAND-NEXT: call void %fptr() [ "ptrauth"(i64 0) ]
; WRONG-FN-SINGLE-OPERAND-NEXT: LLVM ERROR: Invalid ptrauth schema: two- or three-element ptrauth schema expected

define void @test(ptr %fptr) {
  call void %fptr() [ "ptrauth"(i64 0) ]
  ret void
}

;--- wrong-fn-four-operands.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-fn-four-operands.ll 2>&1 | FileCheck --check-prefix=WRONG-FN-FOUR-OPERANDS %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-fn-four-operands.ll 2>&1 | FileCheck --check-prefix=WRONG-FN-FOUR-OPERANDS %s

; WRONG-FN-FOUR-OPERANDS:      test: ptrauth schema violates target-specific constraints:
; WRONG-FN-FOUR-OPERANDS-NEXT: call void %fptr() [ "ptrauth"(i64 0, i64 0, i64 0, i64 0) ]
; WRONG-FN-FOUR-OPERANDS-NEXT: LLVM ERROR: Invalid ptrauth schema: two- or three-element ptrauth schema expected

define void @test(ptr %fptr) {
  call void %fptr() [ "ptrauth"(i64 0, i64 0, i64 0, i64 0) ]
  ret void
}

;--- wrong-key-not-const.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-key-not-const.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-NOT-CONST %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-key-not-const.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-NOT-CONST %s

; WRONG-KEY-NOT-CONST:      test: ptrauth schema violates target-specific constraints:
; WRONG-KEY-NOT-CONST-NEXT: call void %fptr() [ "ptrauth"(i64 %arg, i64 0, i64 0) ]
; WRONG-KEY-NOT-CONST-NEXT: LLVM ERROR: Invalid ptrauth schema: key must be constant in range [0, 3]

define void @test(ptr %fptr, i64 %arg) {
  call void %fptr() [ "ptrauth"(i64 %arg, i64 0, i64 0) ]
  ret void
}

;--- wrong-key-negative.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-key-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-NEGATIVE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-key-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-NEGATIVE %s

; WRONG-KEY-NEGATIVE:      test: ptrauth schema violates target-specific constraints:
; WRONG-KEY-NEGATIVE-NEXT: call void %fptr() [ "ptrauth"(i64 -1, i64 0, i64 0) ]
; WRONG-KEY-NEGATIVE-NEXT: LLVM ERROR: Invalid ptrauth schema: key must be constant in range [0, 3]

define void @test(ptr %fptr) {
  call void %fptr() [ "ptrauth"(i64 -1, i64 0, i64 0) ]
  ret void
}

;--- wrong-key-out-of-range.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-key-out-of-range.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-OUT-OF-RANGE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-key-out-of-range.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-OUT-OF-RANGE %s

; WRONG-KEY-OUT-OF-RANGE:      test: ptrauth schema violates target-specific constraints:
; WRONG-KEY-OUT-OF-RANGE-NEXT: call void %fptr() [ "ptrauth"(i64 4, i64 0, i64 0) ]
; WRONG-KEY-OUT-OF-RANGE-NEXT: LLVM ERROR: Invalid ptrauth schema: key must be constant in range [0, 3]

define void @test(ptr %fptr) {
  call void %fptr() [ "ptrauth"(i64 4, i64 0, i64 0) ]
  ret void
}

;--- wrong-imm-modifier-not-const.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-imm-modifier-not-const.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-NOT-CONST %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-imm-modifier-not-const.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-NOT-CONST %s

; WRONG-IMM-MODIFIER-NOT-CONST:      test: ptrauth schema violates target-specific constraints:
; WRONG-IMM-MODIFIER-NOT-CONST-NEXT: call void %fptr() [ "ptrauth"(i64 0, i64 %arg, i64 0) ]
; WRONG-IMM-MODIFIER-NOT-CONST-NEXT: LLVM ERROR: Invalid ptrauth schema: constant modifier must be 16-bit unsigned constant

define void @test(ptr %fptr, i64 %arg) {
  call void %fptr() [ "ptrauth"(i64 0, i64 %arg, i64 0) ]
  ret void
}

;--- wrong-imm-modifier-negative.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-imm-modifier-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-NEGATIVE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-imm-modifier-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-NEGATIVE %s

; WRONG-IMM-MODIFIER-NEGATIVE:      test: ptrauth schema violates target-specific constraints:
; WRONG-IMM-MODIFIER-NEGATIVE-NEXT: call void %fptr() [ "ptrauth"(i64 0, i64 -1, i64 0) ]
; WRONG-IMM-MODIFIER-NEGATIVE-NEXT: LLVM ERROR: Invalid ptrauth schema: constant modifier must be 16-bit unsigned constant

define void @test(ptr %fptr) {
  call void %fptr() [ "ptrauth"(i64 0, i64 -1, i64 0) ]
  ret void
}

;--- wrong-imm-modifier-too-wide.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-imm-modifier-too-wide.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-TOO-WIDE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-imm-modifier-too-wide.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-TOO-WIDE %s

; WRONG-IMM-MODIFIER-TOO-WIDE:      test: ptrauth schema violates target-specific constraints:
; WRONG-IMM-MODIFIER-TOO-WIDE-NEXT: call void %fptr() [ "ptrauth"(i64 0, i64 123456, i64 0) ]
; WRONG-IMM-MODIFIER-TOO-WIDE-NEXT: LLVM ERROR: Invalid ptrauth schema: constant modifier must be 16-bit unsigned constant

define void @test(ptr %fptr) {
  call void %fptr() [ "ptrauth"(i64 0, i64 123456, i64 0) ]
  ret void
}
