//===-- Unittests for the DyadicFloat class -------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/__support/FPUtil/FPBits.h"
#include "src/__support/FPUtil/fpbits_str.h"
#include "test/UnitTest/Test.h"

using LIBC_NAMESPACE::fputil::FPBits;
using LIBC_NAMESPACE::fputil::FPType;
using LIBC_NAMESPACE::fputil::Sign;
using LIBC_NAMESPACE::fputil::internal::FPRep;

TEST(LlvmLibcFPBitsTest, FPType_IEEE754_Binary16) {
  using Rep = FPRep<FPType::IEEE754_Binary16>;
  using u16 = typename Rep::StorageType;

  EXPECT_EQ(u16(0b0'00000'0000000000), u16(Rep::zero()));
  EXPECT_EQ(u16(0b0'01111'0000000000), u16(Rep::one()));
  EXPECT_EQ(u16(0b0'00000'0000000001), u16(Rep::min_subnormal()));
  EXPECT_EQ(u16(0b0'00000'1111111111), u16(Rep::max_subnormal()));
  EXPECT_EQ(u16(0b0'00001'0000000000), u16(Rep::min_normal()));
  EXPECT_EQ(u16(0b0'11110'1111111111), u16(Rep::max_normal()));
  EXPECT_EQ(u16(0b0'11111'0000000000), u16(Rep::inf()));
  EXPECT_EQ(u16(0b0'11111'0100000000), u16(Rep::signaling_nan()));
  EXPECT_EQ(u16(0b0'11111'1000000000), u16(Rep::quiet_nan()));
}

TEST(LlvmLibcFPBitsTest, FPType_IEEE754_Binary32) {
  using Rep = FPRep<FPType::IEEE754_Binary32>;
  using u32 = typename Rep::StorageType;

  EXPECT_EQ(u32(0b0'00000000'00000000000000000000000), u32(Rep::zero()));
  EXPECT_EQ(u32(0b0'01111111'00000000000000000000000), u32(Rep::one()));
  EXPECT_EQ(u32(0b0'00000000'00000000000000000000001),
            u32(Rep::min_subnormal()));
  EXPECT_EQ(u32(0b0'00000000'11111111111111111111111),
            u32(Rep::max_subnormal()));
  EXPECT_EQ(u32(0b0'00000001'00000000000000000000000), u32(Rep::min_normal()));
  EXPECT_EQ(u32(0b0'11111110'11111111111111111111111), u32(Rep::max_normal()));
  EXPECT_EQ(u32(0b0'11111111'00000000000000000000000), u32(Rep::inf()));
  EXPECT_EQ(u32(0b0'11111111'01000000000000000000000),
            u32(Rep::signaling_nan()));
  EXPECT_EQ(u32(0b0'11111111'10000000000000000000000), u32(Rep::quiet_nan()));
}

TEST(LlvmLibcFPBitsTest, FPType_IEEE754_Binary64) {
  using Rep = FPRep<FPType::IEEE754_Binary64>;
  using u64 = typename Rep::StorageType;

  EXPECT_EQ(
      u64(0b0'00000000000'0000000000000000000000000000000000000000000000000000),
      u64(Rep::zero()));
  EXPECT_EQ(
      u64(0b0'01111111111'0000000000000000000000000000000000000000000000000000),
      u64(Rep::one()));
  EXPECT_EQ(
      u64(0b0'00000000000'0000000000000000000000000000000000000000000000000001),
      u64(Rep::min_subnormal()));
  EXPECT_EQ(
      u64(0b0'00000000000'1111111111111111111111111111111111111111111111111111),
      u64(Rep::max_subnormal()));
  EXPECT_EQ(
      u64(0b0'00000000001'0000000000000000000000000000000000000000000000000000),
      u64(Rep::min_normal()));
  EXPECT_EQ(
      u64(0b0'11111111110'1111111111111111111111111111111111111111111111111111),
      u64(Rep::max_normal()));
  EXPECT_EQ(
      u64(0b0'11111111111'0000000000000000000000000000000000000000000000000000),
      u64(Rep::inf()));
  EXPECT_EQ(
      u64(0b0'11111111111'0100000000000000000000000000000000000000000000000000),
      u64(Rep::signaling_nan()));
  EXPECT_EQ(
      u64(0b0'11111111111'1000000000000000000000000000000000000000000000000000),
      u64(Rep::quiet_nan()));
}

static constexpr UInt128 u128(uint64_t hi, uint64_t lo) {
#if defined(__SIZEOF_INT128__)
  return __uint128_t(hi) << 64 | __uint128_t(lo);
#else
  return UInt128({lo, hi});
#endif
}

TEST(LlvmLibcFPBitsTest, FPType_IEEE754_Binary128) {
  using Rep = FPRep<FPType::IEEE754_Binary128>;

  EXPECT_EQ(
      u128(0b0'000000000000000'000000000000000000000000000000000000000000000000,
           0b0000000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::zero()));
  EXPECT_EQ(
      u128(0b0'011111111111111'000000000000000000000000000000000000000000000000,
           0b0000000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::one()));
  EXPECT_EQ(
      u128(0b0'000000000000000'000000000000000000000000000000000000000000000000,
           0b0000000000000000000000000000000000000000000000000000000000000001),
      UInt128(Rep::min_subnormal()));
  EXPECT_EQ(
      u128(0b0'000000000000000'111111111111111111111111111111111111111111111111,
           0b1111111111111111111111111111111111111111111111111111111111111111),
      UInt128(Rep::max_subnormal()));
  EXPECT_EQ(
      u128(0b0'000000000000001'000000000000000000000000000000000000000000000000,
           0b0000000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::min_normal()));
  EXPECT_EQ(
      u128(0b0'111111111111110'111111111111111111111111111111111111111111111111,
           0b1111111111111111111111111111111111111111111111111111111111111111),
      UInt128(Rep::max_normal()));
  EXPECT_EQ(
      u128(0b0'111111111111111'000000000000000000000000000000000000000000000000,
           0b0000000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::inf()));
  EXPECT_EQ(
      u128(0b0'111111111111111'010000000000000000000000000000000000000000000000,
           0b0000000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::signaling_nan()));
  EXPECT_EQ(
      u128(0b0'111111111111111'100000000000000000000000000000000000000000000000,
           0b0000000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::quiet_nan()));
}

TEST(LlvmLibcFPBitsTest, FPType_X86_Binary80) {
  using Rep = FPRep<FPType::X86_Binary80>;

  EXPECT_EQ(
      u128(0b0'000000000000000,
           0b0000000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::zero()));
  EXPECT_EQ(
      u128(0b0'011111111111111,
           0b1000000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::one()));
  EXPECT_EQ(
      u128(0b0'000000000000000,
           0b0000000000000000000000000000000000000000000000000000000000000001),
      UInt128(Rep::min_subnormal()));
  EXPECT_EQ(
      u128(0b0'000000000000000,
           0b0111111111111111111111111111111111111111111111111111111111111111),
      UInt128(Rep::max_subnormal()));
  EXPECT_EQ(
      u128(0b0'000000000000001,
           0b1000000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::min_normal()));
  EXPECT_EQ(
      u128(0b0'111111111111110,
           0b1111111111111111111111111111111111111111111111111111111111111111),
      UInt128(Rep::max_normal()));
  EXPECT_EQ(
      u128(0b0'111111111111111,
           0b1000000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::inf()));
  EXPECT_EQ(
      u128(0b0'111111111111111,
           0b1010000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::signaling_nan()));
  EXPECT_EQ(
      u128(0b0'111111111111111,
           0b1100000000000000000000000000000000000000000000000000000000000000),
      UInt128(Rep::quiet_nan()));
}

TEST(LlvmLibcFPBitsTest, FPType_X86_Binary80_IsNan) {
  using Rep = FPRep<FPType::X86_Binary80>;

  const auto is_nan = [](uint64_t hi, uint64_t lo) {
    Rep rep;
    rep.set_uintval(u128(hi, lo));
    return rep.is_nan();
  };

  EXPECT_TRUE(is_nan(
      0b0'111111111111111, // NAN : Pseudo-Infinity
      0b0000000000000000000000000000000000000000000000000000000000000000));
  EXPECT_TRUE(is_nan(
      0b0'111111111111111, // NAN : Pseudo Not a Number
      0b0000000000000000000000000000000000000000000000000000000000000001));
  EXPECT_TRUE(is_nan(
      0b0'111111111111111, // NAN : Pseudo Not a Number
      0b0100000000000000000000000000000000000000000000000000000000000000));
  EXPECT_TRUE(is_nan(
      0b0'111111111111111, // NAN : Signalling Not a Number
      0b1000000000000000000000000000000000000000000000000000000000000001));
  EXPECT_TRUE(is_nan(
      0b0'111111111111111, // NAN : Floating-point Indefinite
      0b1100000000000000000000000000000000000000000000000000000000000000));
  EXPECT_TRUE(is_nan(
      0b0'111111111111111, // NAN : Quiet Not a Number
      0b1100000000000000000000000000000000000000000000000000000000000001));
  EXPECT_TRUE(is_nan(
      0b0'111111111111110, // NAN : Unnormal
      0b0000000000000000000000000000000000000000000000000000000000000000));

  EXPECT_FALSE(is_nan(
      0b0'000000000000000, // Zero
      0b0000000000000000000000000000000000000000000000000000000000000000));
  EXPECT_FALSE(is_nan(
      0b0'000000000000000, // Subnormal
      0b0000000000000000000000000000000000000000000000000000000000000001));
  EXPECT_FALSE(is_nan(
      0b0'000000000000000, // Pseudo Denormal
      0b1000000000000000000000000000000000000000000000000000000000000001));
  EXPECT_FALSE(is_nan(
      0b0'111111111111111, // Infinity
      0b1000000000000000000000000000000000000000000000000000000000000000));
  EXPECT_FALSE(is_nan(
      0b0'111111111111110, // Normalized
      0b1000000000000000000000000000000000000000000000000000000000000000));
}

enum class FP {
  ZERO,
  MIN_SUBNORMAL,
  MAX_SUBNORMAL,
  MIN_NORMAL,
  ONE,
  MAX_NORMAL,
  INF,
  SIGNALING_NAN,
  QUIET_NAN
};

constexpr FP all_fp_values[] = {
    FP::ZERO,       FP::MIN_SUBNORMAL, FP::MAX_SUBNORMAL,
    FP::MIN_NORMAL, FP::ONE,           FP::MAX_NORMAL,
    FP::INF,        FP::SIGNALING_NAN, FP::QUIET_NAN,
};

constexpr Sign all_signs[] = {Sign::POS, Sign::NEG};

using FPTypes = LIBC_NAMESPACE::testing::TypeList<
    FPRep<FPType::IEEE754_Binary16>, FPRep<FPType::IEEE754_Binary32>,
    FPRep<FPType::IEEE754_Binary64>, FPRep<FPType::IEEE754_Binary128>,
    FPRep<FPType::X86_Binary80>>;

template <typename T> constexpr auto make(Sign sign, FP fp) {
  switch (fp) {
  case FP::ZERO:
    return T::zero(sign);
  case FP::MIN_SUBNORMAL:
    return T::min_subnormal(sign);
  case FP::MAX_SUBNORMAL:
    return T::max_subnormal(sign);
  case FP::MIN_NORMAL:
    return T::min_normal(sign);
  case FP::ONE:
    return T::one(sign);
  case FP::MAX_NORMAL:
    return T::max_normal(sign);
  case FP::INF:
    return T::inf(sign);
  case FP::SIGNALING_NAN:
    return T::signaling_nan(sign);
  case FP::QUIET_NAN:
    return T::quiet_nan(sign);
  }
};

// Tests all properties for all types of float.
TYPED_TEST(LlvmLibcFPBitsTest, Properties, FPTypes) {
  for (Sign sign : all_signs) {
    for (FP fp : all_fp_values) {
      const T value = make<T>(sign, fp);
      // is_zero
      ASSERT_EQ(value.is_zero(), fp == FP::ZERO);
      // is_inf_or_nan
      ASSERT_EQ(value.is_inf_or_nan(), fp == FP::INF ||
                                           fp == FP::SIGNALING_NAN ||
                                           fp == FP::QUIET_NAN);
      // is_finite
      ASSERT_EQ(value.is_finite(), fp != FP::INF && fp != FP::SIGNALING_NAN &&
                                       fp != FP::QUIET_NAN);
      // is_inf
      ASSERT_EQ(value.is_inf(), fp == FP::INF);
      // is_nan
      ASSERT_EQ(value.is_nan(), fp == FP::SIGNALING_NAN || fp == FP::QUIET_NAN);
      // is_normal
      ASSERT_EQ(value.is_normal(),
                fp == FP::MIN_NORMAL || fp == FP::ONE || fp == FP::MAX_NORMAL);
      // is_quiet_nan
      ASSERT_EQ(value.is_quiet_nan(), fp == FP::QUIET_NAN);
      // is_signaling_nan
      ASSERT_EQ(value.is_signaling_nan(), fp == FP::SIGNALING_NAN);
      // is_subnormal
      ASSERT_EQ(value.is_subnormal(), fp == FP::ZERO ||
                                          fp == FP::MIN_SUBNORMAL ||
                                          fp == FP::MAX_SUBNORMAL);
      // is_pos
      ASSERT_EQ(value.is_pos(), sign == Sign::POS);
      ASSERT_EQ(value.sign().is_pos(), sign == Sign::POS);
      // is_neg
      ASSERT_EQ(value.is_neg(), sign == Sign::NEG);
      ASSERT_EQ(value.sign().is_neg(), sign == Sign::NEG);
    }
  }
}

#define ASSERT_SAME_REP(A, B) ASSERT_EQ(A.uintval(), B.uintval());

TYPED_TEST(LlvmLibcFPBitsTest, NextTowardInf, FPTypes) {
  struct {
    FP before, after;
  } TEST_CASES[] = {
      {FP::ZERO, FP::MIN_SUBNORMAL},          //
      {FP::MAX_SUBNORMAL, FP::MIN_NORMAL},    //
      {FP::MAX_NORMAL, FP::INF},              //
      {FP::INF, FP::INF},                     //
      {FP::QUIET_NAN, FP::QUIET_NAN},         //
      {FP::SIGNALING_NAN, FP::SIGNALING_NAN}, //
  };
  for (Sign sign : all_signs) {
    for (auto tc : TEST_CASES) {
      T val = make<T>(sign, tc.before);
      ASSERT_SAME_REP(val.next_toward_inf(), make<T>(sign, tc.after));
    }
  }
}

TEST(LlvmLibcFPBitsTest, FloatType) {
  using FloatBits = FPBits<float>;

  EXPECT_STREQ(LIBC_NAMESPACE::str(FloatBits::inf(Sign::POS)).c_str(),
               "(+Infinity)");
  EXPECT_STREQ(LIBC_NAMESPACE::str(FloatBits::inf(Sign::NEG)).c_str(),
               "(-Infinity)");
  EXPECT_STREQ(LIBC_NAMESPACE::str(FloatBits::signaling_nan()).c_str(),
               "(NaN)");

  FloatBits zero(0.0f);
  EXPECT_TRUE(zero.is_pos());
  EXPECT_EQ(zero.get_biased_exponent(), static_cast<uint16_t>(0));
  EXPECT_EQ(zero.get_mantissa(), static_cast<uint32_t>(0));
  EXPECT_EQ(zero.uintval(), static_cast<uint32_t>(0x00000000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(zero).c_str(),
               "0x00000000 = (S: 0, E: 0x0000, M: 0x00000000)");

  FloatBits negzero(-0.0f);
  EXPECT_TRUE(negzero.is_neg());
  EXPECT_EQ(negzero.get_biased_exponent(), static_cast<uint16_t>(0));
  EXPECT_EQ(negzero.get_mantissa(), static_cast<uint32_t>(0));
  EXPECT_EQ(negzero.uintval(), static_cast<uint32_t>(0x80000000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(negzero).c_str(),
               "0x80000000 = (S: 1, E: 0x0000, M: 0x00000000)");

  FloatBits one(1.0f);
  EXPECT_TRUE(one.is_pos());
  EXPECT_EQ(one.get_biased_exponent(), static_cast<uint16_t>(0x7F));
  EXPECT_EQ(one.get_mantissa(), static_cast<uint32_t>(0));
  EXPECT_EQ(one.uintval(), static_cast<uint32_t>(0x3F800000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(one).c_str(),
               "0x3F800000 = (S: 0, E: 0x007F, M: 0x00000000)");

  FloatBits negone(-1.0f);
  EXPECT_TRUE(negone.is_neg());
  EXPECT_EQ(negone.get_biased_exponent(), static_cast<uint16_t>(0x7F));
  EXPECT_EQ(negone.get_mantissa(), static_cast<uint32_t>(0));
  EXPECT_EQ(negone.uintval(), static_cast<uint32_t>(0xBF800000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(negone).c_str(),
               "0xBF800000 = (S: 1, E: 0x007F, M: 0x00000000)");

  FloatBits num(1.125f);
  EXPECT_TRUE(num.is_pos());
  EXPECT_EQ(num.get_biased_exponent(), static_cast<uint16_t>(0x7F));
  EXPECT_EQ(num.get_mantissa(), static_cast<uint32_t>(0x00100000));
  EXPECT_EQ(num.uintval(), static_cast<uint32_t>(0x3F900000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(num).c_str(),
               "0x3F900000 = (S: 0, E: 0x007F, M: 0x00100000)");

  FloatBits negnum(-1.125f);
  EXPECT_TRUE(negnum.is_neg());
  EXPECT_EQ(negnum.get_biased_exponent(), static_cast<uint16_t>(0x7F));
  EXPECT_EQ(negnum.get_mantissa(), static_cast<uint32_t>(0x00100000));
  EXPECT_EQ(negnum.uintval(), static_cast<uint32_t>(0xBF900000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(negnum).c_str(),
               "0xBF900000 = (S: 1, E: 0x007F, M: 0x00100000)");

  FloatBits quiet_nan = FloatBits::quiet_nan();
  EXPECT_EQ(quiet_nan.is_quiet_nan(), true);
}

TEST(LlvmLibcFPBitsTest, DoubleType) {
  using DoubleBits = FPBits<double>;

  EXPECT_STREQ(LIBC_NAMESPACE::str(DoubleBits::inf(Sign::POS)).c_str(),
               "(+Infinity)");
  EXPECT_STREQ(LIBC_NAMESPACE::str(DoubleBits::inf(Sign::NEG)).c_str(),
               "(-Infinity)");
  EXPECT_STREQ(LIBC_NAMESPACE::str(DoubleBits::signaling_nan()).c_str(),
               "(NaN)");

  DoubleBits zero(0.0);
  EXPECT_TRUE(zero.is_pos());
  EXPECT_EQ(zero.get_biased_exponent(), static_cast<uint16_t>(0x0000));
  EXPECT_EQ(zero.get_mantissa(), static_cast<uint64_t>(0x0000000000000000));
  EXPECT_EQ(zero.uintval(), static_cast<uint64_t>(0x0000000000000000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(zero).c_str(),
               "0x0000000000000000 = (S: 0, E: 0x0000, M: 0x0000000000000000)");

  DoubleBits negzero(-0.0);
  EXPECT_TRUE(negzero.is_neg());
  EXPECT_EQ(negzero.get_biased_exponent(), static_cast<uint16_t>(0x0000));
  EXPECT_EQ(negzero.get_mantissa(), static_cast<uint64_t>(0x0000000000000000));
  EXPECT_EQ(negzero.uintval(), static_cast<uint64_t>(0x8000000000000000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(negzero).c_str(),
               "0x8000000000000000 = (S: 1, E: 0x0000, M: 0x0000000000000000)");

  DoubleBits one(1.0);
  EXPECT_TRUE(one.is_pos());
  EXPECT_EQ(one.get_biased_exponent(), static_cast<uint16_t>(0x03FF));
  EXPECT_EQ(one.get_mantissa(), static_cast<uint64_t>(0x0000000000000000));
  EXPECT_EQ(one.uintval(), static_cast<uint64_t>(0x3FF0000000000000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(one).c_str(),
               "0x3FF0000000000000 = (S: 0, E: 0x03FF, M: 0x0000000000000000)");

  DoubleBits negone(-1.0);
  EXPECT_TRUE(negone.is_neg());
  EXPECT_EQ(negone.get_biased_exponent(), static_cast<uint16_t>(0x03FF));
  EXPECT_EQ(negone.get_mantissa(), static_cast<uint64_t>(0x0000000000000000));
  EXPECT_EQ(negone.uintval(), static_cast<uint64_t>(0xBFF0000000000000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(negone).c_str(),
               "0xBFF0000000000000 = (S: 1, E: 0x03FF, M: 0x0000000000000000)");

  DoubleBits num(1.125);
  EXPECT_TRUE(num.is_pos());
  EXPECT_EQ(num.get_biased_exponent(), static_cast<uint16_t>(0x03FF));
  EXPECT_EQ(num.get_mantissa(), static_cast<uint64_t>(0x0002000000000000));
  EXPECT_EQ(num.uintval(), static_cast<uint64_t>(0x3FF2000000000000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(num).c_str(),
               "0x3FF2000000000000 = (S: 0, E: 0x03FF, M: 0x0002000000000000)");

  DoubleBits negnum(-1.125);
  EXPECT_TRUE(negnum.is_neg());
  EXPECT_EQ(negnum.get_biased_exponent(), static_cast<uint16_t>(0x03FF));
  EXPECT_EQ(negnum.get_mantissa(), static_cast<uint64_t>(0x0002000000000000));
  EXPECT_EQ(negnum.uintval(), static_cast<uint64_t>(0xBFF2000000000000));
  EXPECT_STREQ(LIBC_NAMESPACE::str(negnum).c_str(),
               "0xBFF2000000000000 = (S: 1, E: 0x03FF, M: 0x0002000000000000)");

  DoubleBits quiet_nan = DoubleBits::quiet_nan();
  EXPECT_EQ(quiet_nan.is_quiet_nan(), true);
}

#ifdef LIBC_TARGET_ARCH_IS_X86
TEST(LlvmLibcFPBitsTest, X86LongDoubleType) {
  using LongDoubleBits = FPBits<long double>;

  if constexpr (sizeof(long double) == sizeof(double))
    return; // The tests for the "double" type cover for this case.

  EXPECT_STREQ(LIBC_NAMESPACE::str(LongDoubleBits::inf(Sign::POS)).c_str(),
               "(+Infinity)");
  EXPECT_STREQ(LIBC_NAMESPACE::str(LongDoubleBits::inf(Sign::NEG)).c_str(),
               "(-Infinity)");
  EXPECT_STREQ(LIBC_NAMESPACE::str(LongDoubleBits::signaling_nan()).c_str(),
               "(NaN)");

  LongDoubleBits zero(0.0l);
  EXPECT_TRUE(zero.is_pos());
  EXPECT_EQ(zero.get_biased_exponent(), static_cast<uint16_t>(0x0000));
  EXPECT_EQ(zero.get_mantissa(), static_cast<UInt128>(0x0000000000000000)
                                     << 64);
  EXPECT_EQ(zero.uintval(), static_cast<UInt128>(0x0000000000000000) << 64);
  EXPECT_STREQ(
      LIBC_NAMESPACE::str(zero).c_str(),
      "0x00000000000000000000000000000000 = "
      "(S: 0, E: 0x0000, I: 0, M: 0x00000000000000000000000000000000)");

  LongDoubleBits negzero(-0.0l);
  EXPECT_TRUE(negzero.is_neg());
  EXPECT_EQ(negzero.get_biased_exponent(), static_cast<uint16_t>(0x0000));
  EXPECT_EQ(negzero.get_mantissa(), static_cast<UInt128>(0x0000000000000000)
                                        << 64);
  EXPECT_EQ(negzero.uintval(), static_cast<UInt128>(0x1) << 79);
  EXPECT_STREQ(
      LIBC_NAMESPACE::str(negzero).c_str(),
      "0x00000000000080000000000000000000 = "
      "(S: 1, E: 0x0000, I: 0, M: 0x00000000000000000000000000000000)");

  LongDoubleBits one(1.0l);
  EXPECT_TRUE(one.is_pos());
  EXPECT_EQ(one.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(one.get_mantissa(), static_cast<UInt128>(0x0000000000000000) << 64);
  EXPECT_EQ(one.uintval(), static_cast<UInt128>(0x3FFF8) << 60);
  EXPECT_STREQ(
      LIBC_NAMESPACE::str(one).c_str(),
      "0x0000000000003FFF8000000000000000 = "
      "(S: 0, E: 0x3FFF, I: 1, M: 0x00000000000000000000000000000000)");

  LongDoubleBits negone(-1.0l);
  EXPECT_TRUE(negone.is_neg());
  EXPECT_EQ(negone.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(negone.get_mantissa(), static_cast<UInt128>(0x0000000000000000)
                                       << 64);
  EXPECT_EQ(negone.uintval(), static_cast<UInt128>(0xBFFF8) << 60);
  EXPECT_STREQ(
      LIBC_NAMESPACE::str(negone).c_str(),
      "0x000000000000BFFF8000000000000000 = "
      "(S: 1, E: 0x3FFF, I: 1, M: 0x00000000000000000000000000000000)");

  LongDoubleBits num(1.125l);
  EXPECT_TRUE(num.is_pos());
  EXPECT_EQ(num.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(num.get_mantissa(), static_cast<UInt128>(0x1) << 60);
  EXPECT_EQ(num.uintval(), static_cast<UInt128>(0x3FFF9) << 60);
  EXPECT_STREQ(
      LIBC_NAMESPACE::str(num).c_str(),
      "0x0000000000003FFF9000000000000000 = "
      "(S: 0, E: 0x3FFF, I: 1, M: 0x00000000000000001000000000000000)");

  LongDoubleBits negnum(-1.125l);
  EXPECT_TRUE(negnum.is_neg());
  EXPECT_EQ(negnum.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(negnum.get_mantissa(), static_cast<UInt128>(0x1) << 60);
  EXPECT_EQ(negnum.uintval(), static_cast<UInt128>(0xBFFF9) << 60);
  EXPECT_STREQ(
      LIBC_NAMESPACE::str(negnum).c_str(),
      "0x000000000000BFFF9000000000000000 = "
      "(S: 1, E: 0x3FFF, I: 1, M: 0x00000000000000001000000000000000)");

  LongDoubleBits quiet_nan = LongDoubleBits::quiet_nan();
  EXPECT_EQ(quiet_nan.is_quiet_nan(), true);
}
#else
TEST(LlvmLibcFPBitsTest, LongDoubleType) {
#if defined(LIBC_LONG_DOUBLE_IS_FLOAT64)
  return; // The tests for the "double" type cover for this case.
#else
  using LongDoubleBits = FPBits<long double>;

  EXPECT_STREQ(LIBC_NAMESPACE::str(LongDoubleBits::inf(Sign::POS)).c_str(),
               "(+Infinity)");
  EXPECT_STREQ(LIBC_NAMESPACE::str(LongDoubleBits::inf(Sign::NEG)).c_str(),
               "(-Infinity)");
  EXPECT_STREQ(LIBC_NAMESPACE::str(LongDoubleBits::signaling_nan()).c_str(),
               "(NaN)");

  LongDoubleBits zero(0.0l);
  EXPECT_TRUE(zero.is_pos());
  EXPECT_EQ(zero.get_biased_exponent(), static_cast<uint16_t>(0x0000));
  EXPECT_EQ(zero.get_mantissa(), static_cast<UInt128>(0x0000000000000000)
                                     << 64);
  EXPECT_EQ(zero.uintval(), static_cast<UInt128>(0x0000000000000000) << 64);
  EXPECT_STREQ(LIBC_NAMESPACE::str(zero).c_str(),
               "0x00000000000000000000000000000000 = "
               "(S: 0, E: 0x0000, M: 0x00000000000000000000000000000000)");

  LongDoubleBits negzero(-0.0l);
  EXPECT_TRUE(negzero.is_neg());
  EXPECT_EQ(negzero.get_biased_exponent(), static_cast<uint16_t>(0x0000));
  EXPECT_EQ(negzero.get_mantissa(), static_cast<UInt128>(0x0000000000000000)
                                        << 64);
  EXPECT_EQ(negzero.uintval(), static_cast<UInt128>(0x1) << 127);
  EXPECT_STREQ(LIBC_NAMESPACE::str(negzero).c_str(),
               "0x80000000000000000000000000000000 = "
               "(S: 1, E: 0x0000, M: 0x00000000000000000000000000000000)");

  LongDoubleBits one(1.0l);
  EXPECT_TRUE(one.is_pos());
  EXPECT_EQ(one.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(one.get_mantissa(), static_cast<UInt128>(0x0000000000000000) << 64);
  EXPECT_EQ(one.uintval(), static_cast<UInt128>(0x3FFF) << 112);
  EXPECT_STREQ(LIBC_NAMESPACE::str(one).c_str(),
               "0x3FFF0000000000000000000000000000 = "
               "(S: 0, E: 0x3FFF, M: 0x00000000000000000000000000000000)");

  LongDoubleBits negone(-1.0l);
  EXPECT_TRUE(negone.is_neg());
  EXPECT_EQ(negone.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(negone.get_mantissa(), static_cast<UInt128>(0x0000000000000000)
                                       << 64);
  EXPECT_EQ(negone.uintval(), static_cast<UInt128>(0xBFFF) << 112);
  EXPECT_STREQ(LIBC_NAMESPACE::str(negone).c_str(),
               "0xBFFF0000000000000000000000000000 = "
               "(S: 1, E: 0x3FFF, M: 0x00000000000000000000000000000000)");

  LongDoubleBits num(1.125l);
  EXPECT_TRUE(num.is_pos());
  EXPECT_EQ(num.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(num.get_mantissa(), static_cast<UInt128>(0x2) << 108);
  EXPECT_EQ(num.uintval(), static_cast<UInt128>(0x3FFF2) << 108);
  EXPECT_STREQ(LIBC_NAMESPACE::str(num).c_str(),
               "0x3FFF2000000000000000000000000000 = "
               "(S: 0, E: 0x3FFF, M: 0x00002000000000000000000000000000)");

  LongDoubleBits negnum(-1.125l);
  EXPECT_TRUE(negnum.is_neg());
  EXPECT_EQ(negnum.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(negnum.get_mantissa(), static_cast<UInt128>(0x2) << 108);
  EXPECT_EQ(negnum.uintval(), static_cast<UInt128>(0xBFFF2) << 108);
  EXPECT_STREQ(LIBC_NAMESPACE::str(negnum).c_str(),
               "0xBFFF2000000000000000000000000000 = "
               "(S: 1, E: 0x3FFF, M: 0x00002000000000000000000000000000)");

  LongDoubleBits quiet_nan = LongDoubleBits::quiet_nan();
  EXPECT_EQ(quiet_nan.is_quiet_nan(), true);
#endif
}
#endif

#if defined(LIBC_COMPILER_HAS_FLOAT128)
TEST(LlvmLibcFPBitsTest, Float128Type) {
  using Float128Bits = FPBits<float128>;

  EXPECT_STREQ(LIBC_NAMESPACE::str(Float128Bits::inf(Sign::POS)).c_str(),
               "(+Infinity)");
  EXPECT_STREQ(LIBC_NAMESPACE::str(Float128Bits::inf(Sign::NEG)).c_str(),
               "(-Infinity)");
  EXPECT_STREQ(LIBC_NAMESPACE::str(Float128Bits::signaling_nan()).c_str(),
               "(NaN)");

  Float128Bits zero = Float128Bits::zero(Sign::POS);
  EXPECT_TRUE(zero.is_pos());
  EXPECT_EQ(zero.get_biased_exponent(), static_cast<uint16_t>(0x0000));
  EXPECT_EQ(zero.get_mantissa(), static_cast<UInt128>(0x0000000000000000)
                                     << 64);
  EXPECT_EQ(zero.uintval(), static_cast<UInt128>(0x0000000000000000) << 64);
  EXPECT_STREQ(LIBC_NAMESPACE::str(zero).c_str(),
               "0x00000000000000000000000000000000 = "
               "(S: 0, E: 0x0000, M: 0x00000000000000000000000000000000)");

  Float128Bits negzero = Float128Bits::zero(Sign::NEG);
  EXPECT_TRUE(negzero.is_neg());
  EXPECT_EQ(negzero.get_biased_exponent(), static_cast<uint16_t>(0x0000));
  EXPECT_EQ(negzero.get_mantissa(), static_cast<UInt128>(0x0000000000000000)
                                        << 64);
  EXPECT_EQ(negzero.uintval(), static_cast<UInt128>(0x1) << 127);
  EXPECT_STREQ(LIBC_NAMESPACE::str(negzero).c_str(),
               "0x80000000000000000000000000000000 = "
               "(S: 1, E: 0x0000, M: 0x00000000000000000000000000000000)");

  Float128Bits one(float128(1.0));
  EXPECT_TRUE(one.is_pos());
  EXPECT_EQ(one.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(one.get_mantissa(), static_cast<UInt128>(0x0000000000000000) << 64);
  EXPECT_EQ(one.uintval(), static_cast<UInt128>(0x3FFF) << 112);
  EXPECT_STREQ(LIBC_NAMESPACE::str(one).c_str(),
               "0x3FFF0000000000000000000000000000 = "
               "(S: 0, E: 0x3FFF, M: 0x00000000000000000000000000000000)");

  Float128Bits negone(float128(-1.0));
  EXPECT_TRUE(negone.is_neg());
  EXPECT_EQ(negone.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(negone.get_mantissa(), static_cast<UInt128>(0x0000000000000000)
                                       << 64);
  EXPECT_EQ(negone.uintval(), static_cast<UInt128>(0xBFFF) << 112);
  EXPECT_STREQ(LIBC_NAMESPACE::str(negone).c_str(),
               "0xBFFF0000000000000000000000000000 = "
               "(S: 1, E: 0x3FFF, M: 0x00000000000000000000000000000000)");

  Float128Bits num(float128(1.125));
  EXPECT_TRUE(num.is_pos());
  EXPECT_EQ(num.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(num.get_mantissa(), static_cast<UInt128>(0x2) << 108);
  EXPECT_EQ(num.uintval(), static_cast<UInt128>(0x3FFF2) << 108);
  EXPECT_STREQ(LIBC_NAMESPACE::str(num).c_str(),
               "0x3FFF2000000000000000000000000000 = "
               "(S: 0, E: 0x3FFF, M: 0x00002000000000000000000000000000)");

  Float128Bits negnum(float128(-1.125));
  EXPECT_TRUE(negnum.is_neg());
  EXPECT_EQ(negnum.get_biased_exponent(), static_cast<uint16_t>(0x3FFF));
  EXPECT_EQ(negnum.get_mantissa(), static_cast<UInt128>(0x2) << 108);
  EXPECT_EQ(negnum.uintval(), static_cast<UInt128>(0xBFFF2) << 108);
  EXPECT_STREQ(LIBC_NAMESPACE::str(negnum).c_str(),
               "0xBFFF2000000000000000000000000000 = "
               "(S: 1, E: 0x3FFF, M: 0x00002000000000000000000000000000)");

  Float128Bits quiet_nan = Float128Bits::quiet_nan();
  EXPECT_EQ(quiet_nan.is_quiet_nan(), true);
}
#endif // LIBC_COMPILER_HAS_FLOAT128
