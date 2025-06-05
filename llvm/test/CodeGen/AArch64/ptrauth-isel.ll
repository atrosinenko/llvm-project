; RUN: llc < %s -mtriple arm64e-apple-darwin             -print-isel-input -stop-after=finalize-isel -global-isel=0                      2>&1 | FileCheck --check-prefixes=CHECK,DAGISEL %s
; RUN: llc < %s -mtriple arm64e-apple-darwin             -print-isel-input -stop-after=finalize-isel -global-isel=1 -global-isel-abort=1 2>&1 | FileCheck --check-prefixes=CHECK,GISEL   %s
; RUN: llc < %s -mtriple aarch64-linux-gnu -mattr=+pauth -print-isel-input -stop-after=finalize-isel -global-isel=0                      2>&1 | FileCheck --check-prefixes=CHECK,DAGISEL %s
; RUN: llc < %s -mtriple aarch64-linux-gnu -mattr=+pauth -print-isel-input -stop-after=finalize-isel -global-isel=1 -global-isel-abort=1 2>&1 | FileCheck --check-prefixes=CHECK,GISEL   %s

; Check MIR produced by the instruction selector to validate properties that
; cannot be reliably tested by only inspecting the final asm output.

@discvar = global i64 0

; Make sure the components of blend(addr, imm) are recognized and passed to
; AUT / PAC / AUTPAC pseudo via separate operands to prevent substitution of
; the immediate modifier. MIR output of the instruction selector is inspected,
; as it is hard to reliably distinguish MOVKXi immediately followed by a
; pseudo from a standalone pseudo instruction carrying address and immediate
; modifiers in its separate operands by only observing the final asm output.

define i64 @blend_and_auth_same_bb(i64 %addr) {
entry:
  %addrdisc = load i64, ptr @discvar
  %disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
  %authed = call i64 @llvm.ptrauth.auth(i64 %addr, i32 2, i64 %disc)
  ret i64 %authed
}

define i64 @blend_and_sign_same_bb(i64 %addr) {
entry:
  %addrdisc = load i64, ptr @discvar
  %disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
  %signed = call i64 @llvm.ptrauth.sign(i64 %addr, i32 2, i64 %disc)
  ret i64 %signed
}

define i64 @blend_and_resign_same_bb(i64 %addr) {
entry:
  %addrdisc = load i64, ptr @discvar
  %auth.disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
  %sign.disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 123)
  %resigned = call i64 @llvm.ptrauth.resign(i64 %addr, i32 2, i64 %auth.disc, i32 3, i64 %sign.disc)
  ret i64 %resigned
}

; In the below test cases both %addrdisc and %disc are computed (i.e. they are
; neither global addresses, nor function arguments) in a different basic block,
; making them harder to express via ISD::PtrAuthGlobalAddress.

define i64 @blend_and_auth_different_bbs(i64 %addr, i64 %cond) {
entry:
  %addrdisc = load i64, ptr @discvar
  %disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
  %cond.b = icmp ne i64 %cond, 0
  br i1 %cond.b, label %next, label %exit

next:
  call void asm sideeffect "nop", "r"(i64 %disc)
  br label %exit

exit:
  %authed = call i64 @llvm.ptrauth.auth(i64 %addr, i32 2, i64 %disc)
  ret i64 %authed
}

define i64 @blend_and_sign_different_bbs(i64 %addr, i64 %cond) {
entry:
  %addrdisc = load i64, ptr @discvar
  %disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
  %cond.b = icmp ne i64 %cond, 0
  br i1 %cond.b, label %next, label %exit

next:
  call void asm sideeffect "nop", "r"(i64 %disc)
  br label %exit

exit:
  %signed = call i64 @llvm.ptrauth.sign(i64 %addr, i32 2, i64 %disc)
  ret i64 %signed
}

define i64 @blend_and_resign_different_bbs(i64 %addr, i64 %cond) {
entry:
  %addrdisc = load i64, ptr @discvar
  %auth.disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
  %sign.disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 123)
  %cond.b = icmp ne i64 %cond, 0
  br i1 %cond.b, label %next, label %exit

next:
  call void asm sideeffect "nop", "r,r"(i64 %auth.disc, i64 %sign.disc)
  br label %exit

exit:
  %resigned = call i64 @llvm.ptrauth.resign(i64 %addr, i32 2, i64 %auth.disc, i32 3, i64 %sign.disc)
  ret i64 %resigned
}

; CHECK:      *** Final LLVM Code input to ISel ***
; CHECK:      define i64 @blend_and_auth_same_bb(i64 %addr){{.*}} {
; CHECK-NEXT: entry:
; CHECK-NEXT:   %addrdisc = load i64, ptr @discvar, align 8
; CHECK-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
; CHECK-NEXT:   %authed = call i64 @llvm.ptrauth.auth(i64 %addr, i32 2, i64 %disc)
; CHECK-NEXT:   ret i64 %authed
; CHECK-NEXT: }

; CHECK:      *** Final LLVM Code input to ISel ***
; CHECK:      define i64 @blend_and_sign_same_bb(i64 %addr){{.*}} {
; CHECK-NEXT: entry:
; CHECK-NEXT:   %addrdisc = load i64, ptr @discvar, align 8
; CHECK-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
; CHECK-NEXT:   %signed = call i64 @llvm.ptrauth.sign(i64 %addr, i32 2, i64 %disc)
; CHECK-NEXT:   ret i64 %signed
; CHECK-NEXT: }

; CHECK:      *** Final LLVM Code input to ISel ***
; CHECK:      define i64 @blend_and_resign_same_bb(i64 %addr){{.*}} {
; CHECK-NEXT: entry:
; CHECK-NEXT:   %addrdisc = load i64, ptr @discvar, align 8
; CHECK-NEXT:   %auth.disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
; CHECK-NEXT:   %sign.disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 123)
; CHECK-NEXT:   %resigned = call i64 @llvm.ptrauth.resign(i64 %addr, i32 2, i64 %auth.disc, i32 3, i64 %sign.disc)
; CHECK-NEXT:   ret i64 %resigned
; CHECK-NEXT: }


; CHECK:      *** Final LLVM Code input to ISel ***
; CHECK:      define i64 @blend_and_auth_different_bbs(i64 %addr, i64 %cond){{.*}} {
; CHECK-NEXT: entry:
; CHECK-NEXT:   %addrdisc = load i64, ptr @discvar, align 8
; CHECK-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
; CHECK-NEXT:   %cond.b = icmp ne i64 %cond, 0
; CHECK-NEXT:   br i1 %cond.b, label %next, label %exit
; CHECK-EMPTY:
; CHECK-NEXT: next:                                             ; preds = %entry
; CHECK-NEXT:   call void asm sideeffect "nop", "r"(i64 %disc)
; CHECK-NEXT:   br label %exit
; CHECK-EMPTY:
; CHECK-NEXT: exit:                                             ; preds = %next, %entry
; CHECK-NEXT:   %authed = call i64 @llvm.ptrauth.auth(i64 %addr, i32 2, i64 %disc)
; CHECK-NEXT:   ret i64 %authed
; CHECK-NEXT: }

; CHECK:      *** Final LLVM Code input to ISel ***
; CHECK:      define i64 @blend_and_sign_different_bbs(i64 %addr, i64 %cond){{.*}} {
; CHECK-NEXT: entry:
; CHECK-NEXT:   %addrdisc = load i64, ptr @discvar, align 8
; CHECK-NEXT:   %disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
; CHECK-NEXT:   %cond.b = icmp ne i64 %cond, 0
; CHECK-NEXT:   br i1 %cond.b, label %next, label %exit
; CHECK-EMPTY:
; CHECK-NEXT: next:                                             ; preds = %entry
; CHECK-NEXT:   call void asm sideeffect "nop", "r"(i64 %disc)
; CHECK-NEXT:   br label %exit
; CHECK-EMPTY:
; CHECK-NEXT: exit:                                             ; preds = %next, %entry
; CHECK-NEXT:   %signed = call i64 @llvm.ptrauth.sign(i64 %addr, i32 2, i64 %disc)
; CHECK-NEXT:   ret i64 %signed
; CHECK-NEXT: }

; CHECK:      *** Final LLVM Code input to ISel ***
; CHECK:      define i64 @blend_and_resign_different_bbs(i64 %addr, i64 %cond){{.*}} {
; CHECK-NEXT: entry:
; CHECK-NEXT:   %addrdisc = load i64, ptr @discvar, align 8
; CHECK-NEXT:   %auth.disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 42)
; CHECK-NEXT:   %sign.disc = call i64 @llvm.ptrauth.blend(i64 %addrdisc, i64 123)
; CHECK-NEXT:   %cond.b = icmp ne i64 %cond, 0
; CHECK-NEXT:   br i1 %cond.b, label %next, label %exit
; CHECK-EMPTY:
; CHECK-NEXT: next:                                             ; preds = %entry
; CHECK-NEXT:   call void asm sideeffect "nop", "r,r"(i64 %auth.disc, i64 %sign.disc)
; CHECK-NEXT:   br label %exit
; CHECK-EMPTY:
; CHECK-NEXT: exit:                                             ; preds = %next, %entry
; CHECK-NEXT:   %resigned = call i64 @llvm.ptrauth.resign(i64 %addr, i32 2, i64 %auth.disc, i32 3, i64 %sign.disc)
; CHECK-NEXT:   ret i64 %resigned
; CHECK-NEXT: }

; CHECK-LABEL: name:            blend_and_auth_same_bb
; CHECK:       body:
; CHECK:         bb.{{[0-9]+}}.entry:
; CHECK:           %[[ADDRDISC:[0-9]+]]:gpr64 = LDRXui
; CHECK:           %{{[0-9]+}}:gpr64 = MOVKXi %[[ADDRDISC]], 42, 48
; CHECK:           %[[ADDRDISC1:[0-9]+]]:gpr64noip = COPY %[[ADDRDISC]]
; CHECK:           $x16 = COPY %{{[0-9]+}}
; CHECK:           AUT 2, 42, %[[ADDRDISC1]], implicit-def $x16, implicit-def $x17, implicit-def $nzcv, implicit $x16
; CHECK:           %{{[0-9]+}}:gpr64 = COPY $x16
; CHECK:           RET_ReallyLR

; CHECK-LABEL: name:            blend_and_sign_same_bb
; CHECK:       body:
; CHECK:         bb.{{[0-9]+}}.entry:
; CHECK:           %[[ADDRDISC:[0-9]+]]:gpr64 = LDRXui
; CHECK:           %{{[0-9]+}}:gpr64noip = MOVKXi %[[ADDRDISC]], 42, 48
; CHECK:           %[[ADDRDISC1:[0-9]+]]:gpr64noip = COPY %[[ADDRDISC]]
; CHECK:           %{{[0-9]+}}:gpr64 = PAC %{{[0-9]+}}, 2, 42, {{(killed )?}}%[[ADDRDISC1]], implicit-def dead $x17
; CHECK:           RET_ReallyLR

; CHECK-LABEL: name:            blend_and_resign_same_bb
; CHECK:       body:
; CHECK:         bb.{{[0-9]+}}.entry:
; CHECK:           %[[ADDRDISC:[0-9]+]]:gpr64noip = LDRXui
; CHECK:           $x16 = COPY %{{[0-9]+}}
; CHECK:           AUTPAC 2, 42, %[[ADDRDISC]], 3, 123, %[[ADDRDISC]], implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
; CHECK:           {{.*}} = COPY $x16

; CHECK-LABEL: name:            blend_and_auth_different_bbs
; CHECK:       body:
; CHECK:         bb.{{[0-9]+}}.entry:
; CHECK:           %[[ADDRDISC:[0-9]+]]:gpr64 = LDRXui
; CHECK:           %{{[0-9]+}}:gpr64 = MOVKXi %[[ADDRDISC]], 42, 48
; CHECK:         bb.{{[0-9]+}}.next:
; CHECK:         bb.{{[0-9]+}}.exit:
; CHECK-NOT:       MOVKXi
; CHECK:           %[[ADDRDISC1:[0-9]+]]:gpr64noip = COPY %[[ADDRDISC]]
; CHECK-NOT:       MOVKXi
; CHECK:           AUT 2, 42, %[[ADDRDISC1]], implicit-def $x16, implicit-def $x17, implicit-def $nzcv, implicit $x16
; CHECK:           RET_ReallyLR

; CHECK-LABEL: name:            blend_and_sign_different_bbs
; CHECK:       body:
; CHECK:         bb.{{[0-9]+}}.entry:
; CHECK:           %[[ADDRDISC:[0-9]+]]:gpr64 = LDRXui
; CHECK:           {{.*}} = MOVKXi %[[ADDRDISC]], 42, 48
; CHECK:         bb.{{[0-9]+}}.next:
; CHECK:         bb.{{[0-9]+}}.exit:
; CHECK-NOT:       MOVKXi
; CHECK:           %[[ADDRDISC1:[0-9]+]]:gpr64noip = COPY %[[ADDRDISC]]
; CHECK-NOT:       MOVKXi
; CHECK:           %{{[0-9]+}}:gpr64 = PAC %{{[0-9]+}}, 2, 42, {{(killed )?}}%[[ADDRDISC1]], implicit-def dead $x17
; CHECK:           RET_ReallyLR

; CHECK-LABEL: name:            blend_and_resign_different_bbs
; CHECK:       body:
; CHECK:         bb.{{[0-9]+}}.entry:
; DAGISEL:         %[[ADDRDISC:[0-9]+]]:gpr64 = LDRXui
; GISEL:           %[[ADDRDISC:[0-9]+]]:gpr64noip = LDRXui
; CHECK:         bb.{{[0-9]+}}.next:
; CHECK:         bb.{{[0-9]+}}.exit:
; CHECK-NOT:       MOVKXi
; CHECK:           $x16 = COPY %{{[0-9]+}}
; DAGISEL:         %[[ADDRDISC1:[0-9]+]]:gpr64noip = COPY %[[ADDRDISC]]
; DAGISEL:         %[[ADDRDISC2:[0-9]+]]:gpr64noip = COPY %[[ADDRDISC]]
; DAGISEL:         AUTPAC 2, 42, %[[ADDRDISC1]], 3, 123, %[[ADDRDISC2]], implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
; GISEL:           AUTPAC 2, 42, %[[ADDRDISC]],  3, 123, %[[ADDRDISC]],  implicit-def $x16, implicit-def {{(dead )?}}$x17, implicit-def dead $nzcv, implicit $x16
; CHECK:           {{.*}} = COPY $x16
; CHECK:           RET_ReallyLR
