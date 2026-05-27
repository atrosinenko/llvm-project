// RUN: %clang_cc1 -triple arm64-apple-ios   -fptrauth-calls -emit-llvm -std=c++11 %s -o - | FileCheck %s
// RUN: %clang_cc1 -triple aarch64-linux-gnu -fptrauth-calls -emit-llvm -std=c++11 %s -o - | FileCheck %s

namespace Test1 {
  struct B1 {
    virtual void* foo1() {
      return 0;
    }
  };
  struct Pad1 {
    virtual ~Pad1() {}
  };
  struct Proxy1 : Pad1, B1 {
    virtual ~Proxy1() {}
  };
  struct D : virtual Proxy1 {
    virtual ~D() {}
    virtual void* foo1();
  };
  void* D::foo1() {
    return (void*)this;
  }
}

// CHECK-LABEL: define linkonce_odr void @_ZTv0_n24_N5Test11DD0Ev(ptr noundef %this)
// CHECK: %[[This:.*]] = load ptr
// CHECK: %[[SignedVTable:.*]] = load ptr, ptr %[[This]], align 8
// CHECK: %[[VTable:.*]] = call ptr @llvm.ptrauth.auth.p0(ptr %[[SignedVTable]]) [ "ptrauth"(i64 2, i64 0, i64 0) ]
