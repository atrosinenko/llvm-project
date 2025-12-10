; RUN: not llvm-as < %s 2>&1 | FileCheck %s

@var = global i32 0

; CHECK: error: schema of ptrauth constant must be a tuple of i64
@auth_var = global ptr ptrauth (ptr @var, [i64 0, i64 0, ptr null])
