; RUN: rm -rf %t && split-file %s %t && cd %t

;--- nodisc.ll

; RUN: opt -S < nodisc.ll             | FileCheck %s --check-prefix=NODISC
; RUN: llvm-as < nodisc.ll | llvm-dis | FileCheck %s --check-prefix=NODISC

@llvm.global_ctors = appending global [2 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo1, i32 0, i64 55764), ptr null }, { i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo2, i32 0, i64 55764), ptr null }]
@llvm.global_dtors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @bar, i32 0, i64 55764), ptr null }]

define void @foo1() {
  ret void
}

define void @foo2() {
  ret void
}

define void @bar() {
  ret void
}

; NODISC: @llvm.global_ctors = appending global [2 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @foo1, ptr null }, { i32, ptr, ptr } { i32 65535, ptr @foo2, ptr null }]
; NODISC: @llvm.global_dtors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @bar, ptr null }]
; NODISC: !llvm.module.flags = !{!0}
; NODISC: !0 = !{i32 1, !"ptrauth-init-fini", i32 1}

;--- disc.ll

; RUN: opt -S < disc.ll             | FileCheck %s --check-prefix=DISC
; RUN: llvm-as < disc.ll | llvm-dis | FileCheck %s --check-prefix=DISC

@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo, i32 0, i64 55764, ptr inttoptr (i64 1 to ptr)), ptr null }]
@llvm.global_dtors = appending global [2 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @bar1, i32 0, i64 55764, ptr inttoptr (i64 1 to ptr)), ptr null }, { i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @bar2, i32 0, i64 55764, ptr inttoptr (i64 1 to ptr)), ptr null }]

define void @foo() {
  ret void
}

define void @bar1() {
  ret void
}

define void @bar2() {
  ret void
}

; DISC: @llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @foo, ptr null }]
; DISC: @llvm.global_dtors = appending global [2 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @bar1, ptr null }, { i32, ptr, ptr } { i32 65535, ptr @bar2, ptr null }]
; DISC: !llvm.module.flags = !{!0, !1}
; DISC: !0 = !{i32 1, !"ptrauth-init-fini", i32 1}
; DISC: !1 = !{i32 1, !"ptrauth-init-fini-address-discriminator", i32 1}

;--- err1.ll

; RUN: not opt -S < err1.ll                          2>&1 | FileCheck %s --check-prefix=ERR1
; RUN: llvm-as --disable-verify < err1.ll | llvm-dis 2>&1 | FileCheck %s --check-prefix=ERR1-PASSTHROUGH

; ERR1: signing of ctors/dtors should be requested via module flags
; ERR1-PASSTHROUGH: @llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo, i32 0, i64 55764, ptr inttoptr (i64 2 to ptr)), ptr null }]
; ERR1-PASSTHROUGH-NOT: !llvm.module.flags

@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo, i32 0, i64 55764, ptr inttoptr (i64 2 to ptr)), ptr null }]

define void @foo() {
  ret void
}

;--- err2.ll

; RUN: not opt -S < err2.ll                          2>&1 | FileCheck %s --check-prefix=ERR2
; RUN: llvm-as --disable-verify < err2.ll | llvm-dis 2>&1 | FileCheck %s --check-prefix=ERR2-PASSTHROUGH

; ERR2: signing of ctors/dtors should be requested via module flags
; ERR2-PASSTHROUGH: @llvm.global_dtors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @bar, i32 0, i64 55764, ptr @g), ptr null }]
; ERR2-PASSTHROUGH-NOT: !llvm.module.flags

@g = external global ptr
@llvm.global_dtors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @bar, i32 0, i64 55764, ptr @g), ptr null }]

define void @bar() {
  ret void
}

;--- disagreement1.ll

; RUN: not opt -S < disagreement1.ll                          2>&1 | FileCheck %s --check-prefix=DISAGREEMENT1
; RUN: llvm-as --disable-verify < disagreement1.ll | llvm-dis 2>&1 | FileCheck %s --check-prefix=DISAGREEMENT1-PASSTHROUGH

; DISAGREEMENT1: signing of ctors/dtors should be requested via module flags
; DISAGREEMENT1-PASSTHROUGH: @llvm.global_ctors = appending global [2 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo, i32 0, i64 55764), ptr null }, { i32, ptr, ptr } { i32 65535, ptr @bar, ptr null }]
; DISAGREEMENT1-PASSTHROUGH-NOT: !llvm.module.flags

@llvm.global_ctors = appending global [2 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo, i32 0, i64 55764), ptr null }, { i32, ptr, ptr } { i32 65535, ptr @bar, ptr null }]

define void @foo() {
  ret void
}

define void @bar() {
  ret void
}

;--- disagreement2.ll

; RUN: not opt -S < disagreement2.ll                          2>&1 | FileCheck %s --check-prefix=DISAGREEMENT2
; RUN: llvm-as --disable-verify < disagreement2.ll | llvm-dis 2>&1 | FileCheck %s --check-prefix=DISAGREEMENT2-PASSTHROUGH

; DISAGREEMENT2: signing of ctors/dtors should be requested via module flags
; DISAGREEMENT2-PASSTHROUGH: @llvm.global_ctors = appending global [2 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo, i32 0, i64 55764), ptr null }, { i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @bar, i32 0, i64 55764, ptr inttoptr (i64 1 to ptr)), ptr null }]
; DISAGREEMENT2-PASSTHROUGH-NOT: !llvm.module.flags

@llvm.global_ctors = appending global [2 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo, i32 0, i64 55764), ptr null }, { i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @bar, i32 0, i64 55764, ptr inttoptr (i64 1 to ptr)), ptr null }]

define void @foo() {
  ret void
}

define void @bar() {
  ret void
}

;--- disagreement3.ll

; RUN: not opt -S < disagreement3.ll                          2>&1 | FileCheck %s --check-prefix=DISAGREEMENT3
; RUN: llvm-as --disable-verify < disagreement3.ll | llvm-dis 2>&1 | FileCheck %s --check-prefix=DISAGREEMENT3-PASSTHROUGH

; DISAGREEMENT3: signing of ctors/dtors should be requested via module flags
; DISAGREEMENT3-PASSTHROUGH: @llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo, i32 0, i64 55764), ptr null }]
; DISAGREEMENT3-PASSTHROUGH: @llvm.global_dtors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @bar, i32 0, i64 55764, ptr inttoptr (i64 1 to ptr)), ptr null }]
; DISAGREEMENT3-PASSTHROUGH-NOT: !llvm.module.flags

@llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @foo, i32 0, i64 55764), ptr null }]
@llvm.global_dtors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr ptrauth (ptr @bar, i32 0, i64 55764, ptr inttoptr (i64 1 to ptr)), ptr null }]

define void @foo() {
  ret void
}

define void @bar() {
  ret void
}
