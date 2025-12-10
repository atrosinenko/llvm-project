// REQUIRES: aarch64-registered-target
// RUN: %clang_cc1 %s -x c++ -std=c++11 -triple aarch64-linux-pauthtest -fptrauth-calls -disable-llvm-passes \
// RUN:     -emit-llvm -O0 -o - | FileCheck --check-prefixes=CHECK,DEFAULT %s
// RUN: %clang_cc1 %s -x c++ -std=c++11 -triple aarch64-linux-pauthtest -fptrauth-calls -fptrauth-vtt-vtable-pointer-discrimination \
// RUN:     -disable-llvm-passes -emit-llvm -O0 -o - | FileCheck --check-prefixes=CHECK,DEFAULT %s
// RUN: %clang_cc1 %s -x c++ -std=c++11 -triple aarch64-linux-pauthtest -fptrauth-calls -fptrauth-vtt-vtable-pointer-discrimination \
// RUN:     -fptrauth-vtable-pointer-address-discrimination -disable-llvm-passes -emit-llvm -O0 -o - | FileCheck --check-prefixes=CHECK,ADDRESS %s
// RUN: %clang_cc1 %s -x c++ -std=c++11 -triple aarch64-linux-pauthtest -fptrauth-calls -fptrauth-vtt-vtable-pointer-discrimination \
// RUN:     -fptrauth-vtable-pointer-type-discrimination -disable-llvm-passes -emit-llvm -O0 -o - | FileCheck --check-prefixes=CHECK,TYPE %s
// RUN: %clang_cc1 %s -x c++ -std=c++11 -triple aarch64-linux-pauthtest -fptrauth-calls -fptrauth-vtt-vtable-pointer-discrimination \
// RUN:     -fptrauth-vtable-pointer-address-discrimination -fptrauth-vtable-pointer-type-discrimination \
// RUN:     -disable-llvm-passes -emit-llvm -O0 -o - | FileCheck --check-prefixes=CHECK,ADDRESSTYPE %s

// CHECK:      @_ZTT1D = linkonce_odr unnamed_addr constant [4 x ptr] [
// DEFAULT-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1D, i64 32), [i64 2, i64 0, i64 0]),
// DEFAULT-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTC1D0_1A, i64 32), [i64 2, i64 0, i64 0]),
// DEFAULT-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTC1D0_1A, i64 32), [i64 2, i64 0, i64 0]),
// DEFAULT-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1D, i64 32), [i64 2, i64 0, i64 0])]

// ADDRESS-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1D, i64 32), [i64 2, i64 0, i64 ptrtoint (ptr @_ZTT1D to i64)]),
// ADDRESS-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTC1D0_1A, i64 32), [i64 2, i64 0, i64 ptrtoint (ptr getelementptr (i8, ptr @_ZTT1D, i64 8) to i64)]),
// ADDRESS-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTC1D0_1A, i64 32), [i64 2, i64 0, i64 ptrtoint (ptr getelementptr (i8, ptr @_ZTT1D, i64 16) to i64)]),
// ADDRESS-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1D, i64 32), [i64 2, i64 0, i64 ptrtoint (ptr getelementptr (i8, ptr @_ZTT1D, i64 24) to i64)])]

// TYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1D, i64 32), [i64 2, i64 820, i64 0]),
// TYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTC1D0_1A, i64 32), [i64 2, i64 49118, i64 0]),
// TYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTC1D0_1A, i64 32), [i64 2, i64 49118, i64 0]),
// TYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1D, i64 32), [i64 2, i64 820, i64 0])]

// ADDRESSTYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1D, i64 32), [i64 2, i64 820, i64 ptrtoint (ptr @_ZTT1D to i64)]),
// ADDRESSTYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTC1D0_1A, i64 32), [i64 2, i64 49118, i64 ptrtoint (ptr getelementptr (i8, ptr @_ZTT1D, i64 8) to i64)]),
// ADDRESSTYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTC1D0_1A, i64 32), [i64 2, i64 49118, i64 ptrtoint (ptr getelementptr (i8, ptr @_ZTT1D, i64 16) to i64)]),
// ADDRESSTYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1D, i64 32), [i64 2, i64 820, i64 ptrtoint (ptr getelementptr (i8, ptr @_ZTT1D, i64 24) to i64)])]

// CHECK:      @_ZTT1A = linkonce_odr unnamed_addr constant [2 x ptr] [
// DEFAULT-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1A, i64 32), [i64 2, i64 0, i64 0]),
// DEFAULT-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1A, i64 32), [i64 2, i64 0, i64 0])]

// ADDRESS-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1A, i64 32), [i64 2, i64 0, i64 ptrtoint (ptr @_ZTT1A to i64)]),
// ADDRESS-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1A, i64 32), [i64 2, i64 0, i64 ptrtoint (ptr getelementptr (i8, ptr @_ZTT1A, i64 8) to i64)])]

// TYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1A, i64 32), [i64 2, i64 49118, i64 0]),
// TYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1A, i64 32), [i64 2, i64 49118, i64 0])]

// ADDRESSTYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1A, i64 32), [i64 2, i64 49118, i64 ptrtoint (ptr @_ZTT1A to i64)]),
// ADDRESSTYPE-SAME: ptr ptrauth (ptr getelementptr inbounds inrange(-32, 8) (i8, ptr @_ZTV1A, i64 32), [i64 2, i64 49118, i64 ptrtoint (ptr getelementptr (i8, ptr @_ZTT1A, i64 8) to i64)])]

// CHECK-LABEL: @_ZN1AC2Ev
// CHECK:       %vtt.addr = alloca ptr, align 8
// CHECK:       store ptr %vtt, ptr %vtt.addr, align 8
// CHECK:       [[VTT:%.*]] = load ptr, ptr %vtt.addr, align 8
// CHECK:       [[VTABLE:%.*]] = load ptr, ptr [[VTT]], align 8
// ADDRESS:     [[VTABLE_ADDR:%.*]] = ptrtoint ptr [[VTT]] to i64
// ADDRESSTYPE: [[VTABLE_ADDR:%.*]] = ptrtoint ptr [[VTT]] to i64
// CHECK:       [[VTABLEi64:%.*]] = ptrtoint ptr [[VTABLE]] to i64
// DEFAULT:     call i64 @llvm.ptrauth.auth(i64 [[VTABLEi64]]) [ "ptrauth"(i64 2, i64 0, i64 0) ]
// ADDRESS:     call i64 @llvm.ptrauth.auth(i64 [[VTABLEi64]]) [ "ptrauth"(i64 2, i64 0, i64 [[VTABLE_ADDR]]) ]
// TYPE:        call i64 @llvm.ptrauth.auth(i64 [[VTABLEi64]]) [ "ptrauth"(i64 2, i64 49118, i64 0) ]
// ADDRESSTYPE: call i64 @llvm.ptrauth.auth(i64 [[VTABLEi64]]) [ "ptrauth"(i64 2, i64 49118, i64 [[VTABLE_ADDR]]) ]

// CHECK:       [[VTTOFFSET:%.*]]  = getelementptr inbounds ptr, ptr [[VTT]], i64 1
// CHECK:       [[VTABLE2:%.*]] = load ptr, ptr [[VTTOFFSET]], align 8
// ADDRESS:     [[VTABLE2_ADDR:%.*]] = ptrtoint ptr [[VTTOFFSET]] to i64
// ADDRESSTYPE: [[VTABLE2_ADDR:%.*]] = ptrtoint ptr [[VTTOFFSET]] to i64
// CHECK:       [[VTABLE2i64:%.*]] = ptrtoint ptr [[VTABLE2]] to i64
// DEFAULT:     call i64 @llvm.ptrauth.auth(i64 [[VTABLE2i64]]) [ "ptrauth"(i64 2, i64 0, i64 0) ]
// ADDRESS:     call i64 @llvm.ptrauth.auth(i64 [[VTABLE2i64]]) [ "ptrauth"(i64 2, i64 0, i64 [[VTABLE2_ADDR]]) ]
// TYPE:        call i64 @llvm.ptrauth.auth(i64 [[VTABLE2i64]]) [ "ptrauth"(i64 2, i64 49118, i64 0) ]
// ADDRESSTYPE: call i64 @llvm.ptrauth.auth(i64 [[VTABLE2i64]]) [ "ptrauth"(i64 2, i64 49118, i64 [[VTABLE2_ADDR]]) ]

// CHECK-LABEL: @_ZN1DC2Ev
// CHECK:       %vtt.addr = alloca ptr, align 8
// CHECK:       store ptr %vtt, ptr %vtt.addr, align 8
// CHECK:       [[VTT:%.*]] = load ptr, ptr %vtt.addr, align 8
// CHECK:       [[VTTOFFSET:%.*]] = getelementptr inbounds ptr, ptr [[VTT]], i64 1
// CHECK:       call void @_ZN1AC2Ev(ptr noundef nonnull align 8 dereferenceable(8) %this1, ptr noundef [[VTTOFFSET]])
// CHECK:       [[VTABLE:%.*]] = load ptr, ptr [[VTT]], align 8
// ADDRESS:     [[VTABLE_ADDR:%.*]] = ptrtoint ptr [[VTT]] to i64
// ADDRESSTYPE: [[VTABLE_ADDR:%.*]] = ptrtoint ptr [[VTT]] to i64
// CHECK:       [[VTABLEi64:%.*]] = ptrtoint ptr [[VTABLE]] to i64
// DEFAULT:     call i64 @llvm.ptrauth.auth(i64 [[VTABLEi64]]) [ "ptrauth"(i64 2, i64 0, i64 0) ]
// ADDRESS:     call i64 @llvm.ptrauth.auth(i64 [[VTABLEi64]]) [ "ptrauth"(i64 2, i64 0, i64 [[VTABLE_ADDR]]) ]
// TYPE:        call i64 @llvm.ptrauth.auth(i64 [[VTABLEi64]]) [ "ptrauth"(i64 2, i64 820, i64 0) ]
// ADDRESSTYPE: call i64 @llvm.ptrauth.auth(i64 [[VTABLEi64]]) [ "ptrauth"(i64 2, i64 820, i64 [[VTABLE_ADDR]]) ]

struct V {
    virtual void f();
};

struct A : virtual V {
    A();
};

struct D : A {
    D();
};

A::A() {}
D::D() {}
