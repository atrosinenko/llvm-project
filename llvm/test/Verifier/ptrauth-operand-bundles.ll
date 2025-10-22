; RUN: not opt -passes=verify < %s 2>&1 | FileCheck %s

declare void @g()

define void @test_ptrauth_bundle(i64 %arg.64, ptr %arg.ptr, ptr %ok) {

; CHECK: Multiple ptrauth operand bundles on a function call
; CHECK-NEXT: call void %arg.ptr() [ "ptrauth"(i64 42, i64 100), "ptrauth"(i64 42, i64 %arg.64) ]
  call void %arg.ptr() [ "ptrauth"(i64 42, i64 100), "ptrauth"(i64 42, i64 %arg.64) ]

; CHECK: Direct call cannot have a ptrauth bundle
; CHECK-NEXT: call void @g() [ "ptrauth"(i32 42, i64 120) ]
  call void @g() [ "ptrauth"(i32 42, i64 120) ]

; CHECK-NOT: call void %ok()
  call void %ok() [ "ptrauth"(i32 42, i64 120) ]   ; OK
  call void %ok() [ "ptrauth"(i32 42, i64 %arg.64) ] ; OK
  call void %ok() [ "ptrauth"(i64 %arg.64, i64 123) ] ; OK
  call void %ok() [ "ptrauth"(i64 %arg.64, i64 123, i64 %arg.64, i64 42) ] ; OK

; CHECK: Expected non-empty ptrauth bundle
; CHECK-NEXT: call void %arg.ptr() [ "ptrauth"() ]
  call void %arg.ptr() [ "ptrauth"() ]

; CHECK: Expected exactly one ptrauth bundle
; CHECK-NEXT: call i64 @llvm.ptrauth.strip(i64 0)
; CHECK: Expected exactly one ptrauth bundle
; CHECK-NEXT: call i64 @llvm.ptrauth.strip(i64 0) [ "ptrauth"(i64 42, i64 120), "ptrauth"(i64 42, i64 120) ]
; CHECK-NOT:  @llvm.ptrauth.strip
  call i64 @llvm.ptrauth.strip(i64 0)
  call i64 @llvm.ptrauth.strip(i64 0) [ "ptrauth"(i64 42, i64 120), "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.strip(i64 0) [ "ptrauth"(i64 42, i64 120) ]
  call i64 @llvm.ptrauth.strip(i64 0) [ "ptrauth"(i64 %arg.64) ]

  ret void
}
