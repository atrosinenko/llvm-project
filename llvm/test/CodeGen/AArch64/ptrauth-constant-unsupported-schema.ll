; RUN: split-file %s %t
; REQUIRES: x86-registered-target

; Note: x86 here is an arbitrary target that does *not* support PtrAuth - to be
;       used by unsupported-target.ll test case.
; Note: Target-specific constraints are checked during the ISel, thus the
;       corresponding test cases have RUN lines duplicated: for DAGISel and
;       for GlobalISel.

; FIXME Several kinds of invalid ptrauth constants are first unconditionally
;       rejected by LLParser, then asserted-on by ConstantPtrAuth constructor
;       (but only in assertion builds) and then unconditionally rejected by the
;       verifier (if IR verification is requested). This way the verifier is
;       not very testable.
; FIXME Is it feasible to assemble an invalid *.bc for testing?

;--- empty.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/empty.ll 2>&1 | FileCheck --check-prefix=EMPTY %s

; Empty schemas are rejected by target-independent *.ll source parser.

; EMPTY:      <stdin>:{{.*}}:11: error: schema of ptrauth constant must not be empty
; EMPTY-NEXT: ret ptr ptrauth (ptr @glob, [])

@glob = external global i32

define ptr @test() {
  ret ptr ptrauth (ptr @glob, [])
}

;--- wrong-type-i32.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-type-i32.ll 2>&1 | FileCheck --check-prefix=WRONG-TYPE-I32 %s

; WRONG-TYPE-I32:      <stdin>:{{.*}}:11: error: schema of ptrauth constant must be a tuple of i64
; WRONG-TYPE-I32-NEXT: ret ptr ptrauth (ptr @glob, [i32 0, i64 0, i64 0])

@glob = external global i32

define ptr @test() {
  ret ptr ptrauth (ptr @glob, [i32 0, i64 0, i64 0])
}

;--- wrong-type-ptr.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-type-ptr.ll 2>&1 | FileCheck --check-prefix=WRONG-TYPE-PTR %s

; WRONG-TYPE-PTR:      <stdin>:{{.*}}:11: error: schema of ptrauth constant must be a tuple of i64
; WRONG-TYPE-PTR-NEXT: ret ptr ptrauth (ptr @glob, [i64 0, i64 0, ptr null])

@glob = external global i32

define ptr @test() {
  ret ptr ptrauth (ptr @glob, [i64 0, i64 0, ptr null])
}

;--- unsupported-target.ll
; RUN: not llc -mtriple x86_64 -global-isel=0                      < %t/unsupported-target.ll 2>&1 | FileCheck --check-prefix=UNSUPPORTED-TARGET %s
; RUN: not llc -mtriple x86_64 -global-isel=1 -global-isel-abort=1 < %t/unsupported-target.ll 2>&1 | FileCheck --check-prefix=UNSUPPORTED-TARGET %s

; UNSUPPORTED-TARGET:      Ptrauth schema violates target-specific constraints:
; UNSUPPORTED-TARGET-NEXT: ptr ptrauth (ptr @glob, [i64 0, i64 0, i64 0])
; UNSUPPORTED-TARGET-NEXT: LLVM ERROR: Invalid ptrauth schema: this target does not support pointer authentication

@glob = external global i32

define ptr @test() {
  ret ptr ptrauth (ptr @glob, [i64 0, i64 0, i64 0])
}

;--- wrong-not-3-ops.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-not-3-ops.ll 2>&1 | FileCheck --check-prefix=WRONG-NOT-3-OPS %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-not-3-ops.ll 2>&1 | FileCheck --check-prefix=WRONG-NOT-3-OPS %s

; WRONG-NOT-3-OPS:      Ptrauth schema violates target-specific constraints:
; WRONG-NOT-3-OPS-NEXT: ptr ptrauth (ptr @glob, [i64 0, i64 0])
; WRONG-NOT-3-OPS-NEXT: LLVM ERROR: Invalid ptrauth schema: three-element ptrauth schema expected

@glob = external global i32

define ptr @test() {
  ret ptr ptrauth (ptr @glob, [i64 0, i64 0])
}

;--- wrong-key-negative.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-key-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-NEGATIVE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-key-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-NEGATIVE %s

; WRONG-KEY-NEGATIVE:      Ptrauth schema violates target-specific constraints:
; WRONG-KEY-NEGATIVE-NEXT: ptr ptrauth (ptr @glob, [i64 -1, i64 0, i64 0])
; WRONG-KEY-NEGATIVE-NEXT: LLVM ERROR: Invalid ptrauth schema: key must be constant in range [0, 3]

@glob = external global i32

define ptr @test() {
  ret ptr ptrauth (ptr @glob, [i64 -1, i64 0, i64 0])
}

;--- wrong-key-out-of-range.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-key-out-of-range.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-OUT-OF-RANGE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-key-out-of-range.ll 2>&1 | FileCheck --check-prefix=WRONG-KEY-OUT-OF-RANGE %s

; WRONG-KEY-OUT-OF-RANGE:      Ptrauth schema violates target-specific constraints:
; WRONG-KEY-OUT-OF-RANGE-NEXT: ptr ptrauth (ptr @glob, [i64 4, i64 0, i64 0])
; WRONG-KEY-OUT-OF-RANGE-NEXT: LLVM ERROR: Invalid ptrauth schema: key must be constant in range [0, 3]

@glob = external global i32

define ptr @test() {
  ret ptr ptrauth (ptr @glob, [i64 4, i64 0, i64 0])
}

;--- wrong-imm-modifier-negative.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-imm-modifier-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-NEGATIVE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-imm-modifier-negative.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-NEGATIVE %s

; WRONG-IMM-MODIFIER-NEGATIVE:      Ptrauth schema violates target-specific constraints:
; WRONG-IMM-MODIFIER-NEGATIVE-NEXT: ptr ptrauth (ptr @glob, [i64 0, i64 -1, i64 0])
; WRONG-IMM-MODIFIER-NEGATIVE-NEXT: LLVM ERROR: Invalid ptrauth schema: constant modifier must be 16-bit unsigned constant

@glob = external global i32

define ptr @test() {
  ret ptr ptrauth (ptr @glob, [i64 0, i64 -1, i64 0])
}

;--- wrong-imm-modifier-too-wide.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth                                     < %t/wrong-imm-modifier-too-wide.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-TOO-WIDE %s
; RUN: not llc -mtriple aarch64 -mattr=+pauth -global-isel=1 -global-isel-abort=1 < %t/wrong-imm-modifier-too-wide.ll 2>&1 | FileCheck --check-prefix=WRONG-IMM-MODIFIER-TOO-WIDE %s

; WRONG-IMM-MODIFIER-TOO-WIDE:      Ptrauth schema violates target-specific constraints:
; WRONG-IMM-MODIFIER-TOO-WIDE-NEXT: ptr ptrauth (ptr @glob, [i64 0, i64 123456, i64 0])
; WRONG-IMM-MODIFIER-TOO-WIDE-NEXT: LLVM ERROR: Invalid ptrauth schema: constant modifier must be 16-bit unsigned constant

@glob = external global i32

define ptr @test() {
  ret ptr ptrauth (ptr @glob, [i64 0, i64 123456, i64 0])
}

; Global ptrauth constants are validated in AsmPrinter instead of ISel.
; Furthermore, the validation code is not target-neutral now, thus the
; below two test cases check that 1) ptrauth constants are rejected on
; non-supported targets (i.e. by default) and 2) validation code is
; invoked on AArch64.

;--- unsupported-global-constant.ll
; RUN: not --crash llc -mtriple x86_64 < %t/unsupported-global-constant.ll 2>&1 | FileCheck --check-prefix=UNSUPPORTED-GLOBAL-CONSTANT %s

; UNSUPPORTED-GLOBAL-CONSTANT: LLVM ERROR: ptrauth constant lowering not implemented

@glob = external global i32
@const = constant ptr ptrauth (ptr @glob, [i64 0, i64 0])

;--- wrong-global-constant.ll
; RUN: not llc -mtriple aarch64 -mattr=+pauth < %t/wrong-global-constant.ll 2>&1 | FileCheck --check-prefix=WRONG-GLOBAL-CONSTANT %s

; WRONG-GLOBAL-CONSTANT:      Ptrauth schema violates target-specific constraints:
; WRONG-GLOBAL-CONSTANT-NEXT: ptr ptrauth (ptr @glob, [i64 0, i64 0])
; WRONG-GLOBAL-CONSTANT-NEXT: LLVM ERROR: Invalid ptrauth schema: three-element ptrauth schema expected

@glob = external global i32
@const = constant ptr ptrauth (ptr @glob, [i64 0, i64 0])
