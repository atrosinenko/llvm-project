; RUN: not llvm-as < %s 2>&1 | FileCheck %s

@var = global i32 0

; CHECK: error: schema of ptrauth constant must not be empty
@auth_var = global ptr ptrauth (ptr @var, [])
