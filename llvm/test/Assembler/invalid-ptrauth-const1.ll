; RUN: not llvm-as < %s 2>&1 | FileCheck %s

@var = global i32 0

; CHECK: error: base pointer of ptrauth constant must be a pointer
@auth_var = global ptr ptrauth (i32 42, [i64 0, i64 0, i64 0])
