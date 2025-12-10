; RUN: not opt -passes=verify < %s 2>&1 | FileCheck %s

@g = external global i8

; CHECK: ptrauth constant deactivation symbol must be a global value or null
@ptr = global ptr ptrauth (ptr @g, [i64 0, i64 65535, i64 0], ptr inttoptr (i64 16 to ptr))
