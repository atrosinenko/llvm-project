// REQUIRES: aarch64-registered-target

// RUN: %clang_cc1 -triple aarch64-elf -target-feature +pauth -fptrauth-calls -fptrauth-init-fini    \
// RUN:   -emit-llvm %s -o - | FileCheck --check-prefix=COMMON,SIGNED %s

// RUN: %clang_cc1 -triple aarch64-elf -target-feature +pauth -fptrauth-calls -fptrauth-init-fini    \
// RUN:   -fptrauth-init-fini-address-discrimination -emit-llvm %s -o - | FileCheck --check-prefix=COMMON,ADDRDISC %s

// RUN: %clang_cc1 -triple aarch64-elf -target-feature +pauth -fptrauth-calls \
// RUN:   -emit-llvm %s -o - | FileCheck --check-prefix=COMMON,UNSIGNED %s

// RUN: %clang_cc1 -triple aarch64-elf -target-feature +pauth -fptrauth-calls -fptrauth-init-fini-address-discrimination \
// RUN:   -emit-llvm %s -o - | FileCheck --check-prefix=COMMON,UNSIGNED %s

// RUN: %clang_cc1 -triple aarch64-elf -target-feature +pauth                 -fptrauth-init-fini    \
// RUN:   -emit-llvm %s -o - | FileCheck --check-prefix=COMMON,UNSIGNED %s

// COMMON: @llvm.global_ctors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @foo, ptr null }]
// COMMON: @llvm.global_dtors = appending global [1 x { i32, ptr, ptr }] [{ i32, ptr, ptr } { i32 65535, ptr @bar, ptr null }]

// UNSIGNED-NOT: ptrauth-init-fini

// SIGNED: !llvm.module.flags = !{!0}
// SIGNED: !0 = !{i32 1, !"ptrauth-init-fini", !1}
// SIGNED: !1 = !{i32 0, i64 55764, ptr null}

// ADDRDISC: !llvm.module.flags = !{!0}
// ADDRDISC: !0 = !{i32 1, !"ptrauth-init-fini", !1}
// ADDRDISC: !1 = !{i32 0, i64 55764, ptr inttoptr (i64 1 to ptr)}

volatile int x = 0;

__attribute__((constructor)) void foo(void) {
  x = 42;
}

__attribute__((destructor)) void bar(void) {
  x = 24;
}

int main() {
  return x;
}
