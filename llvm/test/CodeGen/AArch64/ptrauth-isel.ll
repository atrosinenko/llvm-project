; RUN: llc < %s -mtriple arm64e-apple-darwin             -verify-machineinstrs -stop-after=finalize-isel -global-isel=0 \
; RUN:     | FileCheck %s --check-prefixes=CHECK,DARWIN --implicit-check-not=name: --implicit-check-not=MOVKXi
; RUN: llc < %s -mtriple arm64e-apple-darwin             -verify-machineinstrs -stop-after=finalize-isel -global-isel=1 -global-isel-abort=1 \
; RUN:     | FileCheck %s --check-prefixes=CHECK,DARWIN --implicit-check-not=name: --implicit-check-not=MOVKXi
; RUN: llc < %s -mtriple aarch64-linux-gnu -mattr=+pauth -verify-machineinstrs -stop-after=finalize-isel -global-isel=0 \
; RUN:     | FileCheck %s --check-prefixes=CHECK,ELF --implicit-check-not=name: --implicit-check-not=MOVKXi
; RUN: llc < %s -mtriple aarch64-linux-gnu -mattr=+pauth -verify-machineinstrs -stop-after=finalize-isel -global-isel=1 -global-isel-abort=1 \
; RUN:     | FileCheck %s --check-prefixes=CHECK,ELF --implicit-check-not=name: --implicit-check-not=MOVKXi

; Check MIR produced by the instruction selector to validate properties that
; cannot be reliably tested by only inspecting the final asm output.

@discvar = dso_local global i64 0

; Make sure zero address modifier is translated directly into a $noreg operand
; at the MIR level instead of a virtual register containing zero value.
;
; All relevant intrinsics are checked because some are selected by TableGen
; patterns and some other are selected by C++ code.

define ptr @pac_no_addr_modif_optimized(ptr %addr) {
  ; CHECK-LABEL: name: pac_no_addr_modif_optimized
  ; CHECK:         {{.*}} = PAC {{[^,]+}}, 2, 42, $noreg, implicit-def dead $x16, implicit-def dead $x17
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call ptr @llvm.ptrauth.sign.p0(ptr %addr) [ "ptrauth"(i64 2, i64 42, i64 0) ]
  ret ptr %signed
}

define ptr @pac_no_addr_modif_not_optimized(ptr %addr) noinline optnone {
  ; CHECK-LABEL: name: pac_no_addr_modif_not_optimized
  ; CHECK:         {{.*}} = PAC {{[^,]+}}, 2, 42, $noreg, implicit-def dead $x16, implicit-def dead $x17
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call ptr @llvm.ptrauth.sign.p0(ptr %addr) [ "ptrauth"(i64 2, i64 42, i64 0) ]
  ret ptr %signed
}

define ptr @aut_no_addr_modif_optimized(ptr %addr) {
  ; CHECK-LABEL: name: aut_no_addr_modif_optimized
  ; DARWIN:        AUTx16x17 2, 42, $noreg, implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
  ; ELF:           {{.*}} = AUTxMxN {{[^,]+}}, 2, 42, $noreg, implicit-def dead $nzcv
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call ptr @llvm.ptrauth.auth.p0(ptr %addr) [ "ptrauth"(i64 2, i64 42, i64 0) ]
  ret ptr %signed
}

define ptr @aut_no_addr_modif_not_optimized(ptr %addr) noinline optnone {
  ; CHECK-LABEL: name: aut_no_addr_modif_not_optimized
  ; DARWIN:        AUTx16x17 2, 42, $noreg, implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
  ; ELF:           {{.*}} = AUTxMxN {{[^,]+}}, 2, 42, $noreg, implicit-def dead $nzcv
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call ptr @llvm.ptrauth.auth.p0(ptr %addr) [ "ptrauth"(i64 2, i64 42, i64 0) ]
  ret ptr %signed
}

define ptr @resign_no_addr_modif_optimized(ptr %addr) {
  ; CHECK-LABEL: name: resign_no_addr_modif_optimized
  ; CHECK:         AUTPAC 2, 42, $noreg, 2, 123, $noreg, implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call ptr @llvm.ptrauth.resign.p0(ptr %addr) [ "ptrauth"(i64 2, i64 42, i64 0), "ptrauth"(i64 2, i64 123, i64 0) ]
  ret ptr %signed
}

define ptr @resign_no_addr_modif_not_optimized(ptr %addr) noinline optnone {
  ; CHECK-LABEL: name: resign_no_addr_modif_not_optimized
  ; CHECK:         AUTPAC 2, 42, $noreg, 2, 123, $noreg, implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
  ; CHECK:         RET_ReallyLR implicit $x0
entry:
  %signed = call ptr @llvm.ptrauth.resign.p0(ptr %addr) [ "ptrauth"(i64 2, i64 42, i64 0), "ptrauth"(i64 2, i64 123, i64 0) ]
  ret ptr %signed
}

; On non-Darwin platforms, AUTxMxN allows allocating arbitrary scratch registers.
; To simplify expansion of AUTxMxN in AArch64AsmPrinter, $Scratch operand
; should be marked as @earlyclobber, which is checked by this test case.
define ptr @autxmxn_earlyclobbered_scratch(ptr %addr, i64 %disc) {
  ; DARWIN-LABEL: name: autxmxn_earlyclobbered_scratch
  ; DARWIN:   [[COPY:%[0-9]+]]:gpr64noip = COPY $x1
  ; DARWIN:   AUTx16x17 2, 0, [[COPY]], implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
  ; DARWIN:   RET_ReallyLR implicit $x0
  ;
  ; ELF-LABEL: name: autxmxn_earlyclobbered_scratch
  ; ELF:   [[COPY:%[0-9]+]]:gpr64 = COPY $x1
  ; ELF:   {{.*}} = AUTxMxN {{[^,]+}}, 2, 0, [[COPY]], implicit-def dead $nzcv
  ; ELF:   RET_ReallyLR implicit $x0
entry:
  %auted = call ptr @llvm.ptrauth.auth.p0(ptr %addr) [ "ptrauth"(i64 2, i64 0, i64 %disc) ]
  ret ptr %auted
}
