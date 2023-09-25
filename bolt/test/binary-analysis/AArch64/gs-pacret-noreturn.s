// Check that there are no false positives related to no-return functions.

// RUN: %clang %cflags -march=armv8.3-a -mbranch-protection=pac-ret %s %p/../../Inputs/asm_main.c -o %t.exe
// RUN: llvm-bolt-binary-analysis %t.exe --noreturnfuncs="doesnotreturn/1" 2>&1 | FileCheck -check-prefix=CHECK --allow-empty %s


// Verify that we can also detect gadgets across basic blocks

        .globl f_call_returning
        .type   f_call_returning,@function
f_call_returning:
        cbz     x0, 1f
        bl      call_returning
1:
        ret
        .size f_call_returning, .-f_call_returning
// CHECK-LABEL:     GS-PAUTH: non-protected ret found in function f_call_returning, basic block .L{{[^,]+}}, at address
// CHECK-NEXT:  The instruction is     {{[0-9a-f]+}}:       ret
// CHECK-NEXT:  The 1 instructions that write to the affected registers after any authentication are:
// CHECK-NEXT:  1.     {{[0-9a-f]+}}:      bl {{.*}}

        .type doesnotreturn,@function
doesnotreturn:
        brk 1
        .size doesnotreturn, .-doesnotreturn

        .globl f_call_noreturn
        .type   f_call_noreturn,@function
f_call_noreturn:
        cbz     x0, 1f
        bl      doesnotreturn
1:
        ret
        .size f_call_noreturn, .-f_call_noreturn
// CHECK-NOT: function f_call_noreturn
