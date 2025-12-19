const std = @import("std");
const root = @import("root");

// Tests for exported constants and static functions

test "exported constants are correct" {
    try std.testing.expectEqual(@as(u32, 13910101), root.KOREAN_LUNAR_MIN_VALUE);
    try std.testing.expectEqual(@as(u32, 20501118), root.KOREAN_LUNAR_MAX_VALUE);
    try std.testing.expectEqual(@as(u32, 13910205), root.KOREAN_SOLAR_MIN_VALUE);
    try std.testing.expectEqual(@as(u32, 20501231), root.KOREAN_SOLAR_MAX_VALUE);
}

test "julian day number calculation" {
    const jdn = root.LunarSolarConverter.getJulianDayNumber(2022, 7, 10);
    try std.testing.expectEqual(@as(u32, 2459771), jdn.?);
}

test "day of week calculation" {
    const dow = root.LunarSolarConverter.getDayOfWeek(2022, 7, 10);
    try std.testing.expectEqual(root.DayOfWeek.Sunday, dow.?);
}

test "solar leap year detection" {
    try std.testing.expect(root.LunarSolarConverter.isSolarLeapYear(2024));
    try std.testing.expect(!root.LunarSolarConverter.isSolarLeapYear(2023));
    try std.testing.expect(root.LunarSolarConverter.isSolarLeapYear(2000));
    try std.testing.expect(!root.LunarSolarConverter.isSolarLeapYear(1900));
}

test "lunar intercalary month detection" {
    const intercalary = root.LunarSolarConverter.getLunarIntercalaryMonth(2023);
    try std.testing.expectEqual(@as(u32, 2), intercalary.?);

    const no_intercalary = root.LunarSolarConverter.getLunarIntercalaryMonth(2022);
    try std.testing.expect(no_intercalary == null);
}

test "gregorian reform gap is invalid" {
    const jdn = root.LunarSolarConverter.getJulianDayNumber(1582, 10, 10);
    try std.testing.expect(jdn == null);
}
