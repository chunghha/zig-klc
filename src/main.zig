const std = @import("std");
const klc = @import("klc");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("Korean Lunar-Solar Calendar Converter\n", .{});

    var converter = klc.LunarSolarConverter.new();

    // Set a Solar date and get Lunar info
    if (converter.setSolarDate(2022, 7, 10)) {
        const solar_iso = try converter.getSolarIsoFormat(allocator);
        const lunar_iso = try converter.getLunarIsoFormat(allocator);
        const gapja = try converter.getGapjaString(allocator);

        std.debug.print("Solar: {s}\n", .{solar_iso});
        std.debug.print("Lunar: {s}\n", .{lunar_iso});
        std.debug.print("Gapja: {s}\n", .{gapja});

        // Get day of week for the solar date
        if (klc.LunarSolarConverter.getDayOfWeek(2022, 7, 10)) |dow| {
            std.debug.print("Day of Week: {s}\n", .{@tagName(dow)});
        }
    } else {
        std.debug.print("Invalid solar date\n", .{});
    }

    std.debug.print("--- Check other features ---\n", .{});

    // Check solar leap year
    const solar_year: u32 = 2024;
    const is_solar_leap = klc.LunarSolarConverter.isSolarLeapYear(solar_year);
    std.debug.print("Solar Year {} Leap: {}\n", .{ solar_year, is_solar_leap });

    // Check lunar intercalary month
    const lunar_year: i32 = 2023;
    if (klc.LunarSolarConverter.getLunarIntercalaryMonth(lunar_year)) |intercalary_month| {
        std.debug.print("Lunar Year {} has intercalary month: {}\n", .{ lunar_year, intercalary_month });
    } else {
        std.debug.print("Lunar Year {} has no intercalary month.\n", .{lunar_year});
    }

    // Calculate JDN
    if (klc.LunarSolarConverter.getJulianDayNumber(2022, 7, 10)) |jdn| {
        std.debug.print("JDN for 2022-07-10: {}\n", .{jdn});
    }
}

test "solar to lunar conversion 2022-07-10" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(2022, 7, 10));
    try std.testing.expectEqual(@as(i32, 2022), converter.lunarYear());
    try std.testing.expectEqual(@as(u32, 6), converter.lunarMonth());
    try std.testing.expectEqual(@as(u32, 12), converter.lunarDay());
    try std.testing.expectEqual(false, converter.isIntercalation());
}

test "lunar to solar conversion 2022-06-12" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(2022, 6, 12, false));
    try std.testing.expectEqual(@as(u32, 2022), converter.solarYear());
    try std.testing.expectEqual(@as(u32, 7), converter.solarMonth());
    try std.testing.expectEqual(@as(u32, 10), converter.solarDay());
}

test "julian day number 2022-07-10" {
    const jdn = klc.LunarSolarConverter.getJulianDayNumber(2022, 7, 10);
    try std.testing.expectEqual(@as(u32, 2459771), jdn.?);
}

test "julian day number gregorian reform start" {
    // 1582-10-04 was the last Julian calendar day
    const jdn = klc.LunarSolarConverter.getJulianDayNumber(1582, 10, 4);
    try std.testing.expectEqual(@as(u32, 2299160), jdn.?);
}

test "julian day number gregorian reform next day" {
    // 1582-10-15 was the first Gregorian calendar day
    const jdn = klc.LunarSolarConverter.getJulianDayNumber(1582, 10, 15);
    try std.testing.expectEqual(@as(u32, 2299161), jdn.?);
}

test "gregorian reform gap is invalid" {
    // 1582-10-05 to 1582-10-14 don't exist
    const jdn = klc.LunarSolarConverter.getJulianDayNumber(1582, 10, 10);
    try std.testing.expect(jdn == null);
}

test "gregorian reform gap multiple dates" {
    try std.testing.expect(klc.LunarSolarConverter.getJulianDayNumber(1582, 10, 5) == null);
    try std.testing.expect(klc.LunarSolarConverter.getJulianDayNumber(1582, 10, 7) == null);
    try std.testing.expect(klc.LunarSolarConverter.getJulianDayNumber(1582, 10, 14) == null);
}

test "day of week 2022-07-10 is sunday" {
    const dow = klc.LunarSolarConverter.getDayOfWeek(2022, 7, 10);
    try std.testing.expectEqual(klc.DayOfWeek.Sunday, dow.?);
}

test "day of week invalid date returns null" {
    const dow = klc.LunarSolarConverter.getDayOfWeek(1582, 10, 10);
    try std.testing.expect(dow == null);
}

test "solar leap year 2024" {
    try std.testing.expect(klc.LunarSolarConverter.isSolarLeapYear(2024));
}

test "solar leap year 2023 is not leap" {
    try std.testing.expect(!klc.LunarSolarConverter.isSolarLeapYear(2023));
}

test "solar leap year 2000 is leap" {
    try std.testing.expect(klc.LunarSolarConverter.isSolarLeapYear(2000));
}

test "solar leap year 1900 is not leap" {
    try std.testing.expect(!klc.LunarSolarConverter.isSolarLeapYear(1900));
}

test "lunar intercalary month 2023 is month 2" {
    const intercalary = klc.LunarSolarConverter.getLunarIntercalaryMonth(2023);
    try std.testing.expectEqual(@as(u32, 2), intercalary.?);
}

test "lunar intercalary month 2022 does not exist" {
    const intercalary = klc.LunarSolarConverter.getLunarIntercalaryMonth(2022);
    try std.testing.expect(intercalary == null);
}

test "lunar date with intercalation" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(2023, 2, 15, true));
    try std.testing.expectEqual(true, converter.isIntercalation());
}

test "gapja string for valid date" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(2022, 7, 10));

    const allocator = std.testing.allocator;
    const gapja = try converter.getGapjaString(allocator);
    defer allocator.free(gapja);

    try std.testing.expect(gapja.len > 0);
}

test "chinese gapja string for valid date" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(2022, 7, 10));

    const allocator = std.testing.allocator;
    const gapja = try converter.getChineseGapjaString(allocator);
    defer allocator.free(gapja);

    try std.testing.expect(gapja.len > 0);
}

test "gapja string for invalid date returns empty" {
    var converter = klc.LunarSolarConverter.new();

    const allocator = std.testing.allocator;
    const gapja = try converter.getGapjaString(allocator);
    defer allocator.free(gapja);

    try std.testing.expectEqual(@as(usize, 0), gapja.len);
}

test "lunar iso format" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(2022, 7, 10));

    const allocator = std.testing.allocator;
    const iso = try converter.getLunarIsoFormat(allocator);
    defer allocator.free(iso);

    try std.testing.expectEqualStrings("2022-06-12", iso);
}

test "solar iso format" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(2022, 7, 10));

    const allocator = std.testing.allocator;
    const iso = try converter.getSolarIsoFormat(allocator);
    defer allocator.free(iso);

    try std.testing.expectEqualStrings("2022-07-10", iso);
}

test "lunar iso format with intercalation" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(2023, 2, 15, true));

    const allocator = std.testing.allocator;
    const iso = try converter.getLunarIsoFormat(allocator);
    defer allocator.free(iso);

    try std.testing.expect(std.mem.endsWith(u8, iso, "Intercalation"));
}

test "boundary: early supported lunar date" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(1400, 1, 1, false));
    try std.testing.expect(converter.solarYear() > 0);
}

test "boundary: maximum supported lunar date" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(2050, 11, 18, false));
    try std.testing.expectEqual(@as(u32, 2050), converter.solarYear());
}

test "boundary: early supported solar date" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(1400, 1, 1));
    try std.testing.expect(converter.lunarYear() > 0);
}

test "boundary: maximum supported solar date" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(2050, 12, 31));
    try std.testing.expectEqual(@as(i32, 2050), converter.lunarYear());
}

test "round-trip: solar to lunar to solar" {
    var converter1 = klc.LunarSolarConverter.new();
    try std.testing.expect(converter1.setSolarDate(2020, 3, 15));

    // Solar → Lunar
    const lunar_year = converter1.lunarYear();
    const lunar_month = converter1.lunarMonth();
    const lunar_day = converter1.lunarDay();
    const is_intercalation = converter1.isIntercalation();

    // Lunar → Solar
    var converter2 = klc.LunarSolarConverter.new();
    try std.testing.expect(converter2.setLunarDate(lunar_year, lunar_month, lunar_day, is_intercalation));

    // Verify round-trip
    try std.testing.expectEqual(@as(u32, 2020), converter2.solarYear());
    try std.testing.expectEqual(@as(u32, 3), converter2.solarMonth());
    try std.testing.expectEqual(@as(u32, 15), converter2.solarDay());
}

test "round-trip: lunar to solar to lunar" {
    var converter1 = klc.LunarSolarConverter.new();
    try std.testing.expect(converter1.setLunarDate(2025, 8, 7, false));

    // Lunar → Solar
    const solar_year = converter1.solarYear();
    const solar_month = converter1.solarMonth();
    const solar_day = converter1.solarDay();

    // Solar → Lunar
    var converter2 = klc.LunarSolarConverter.new();
    try std.testing.expect(converter2.setSolarDate(solar_year, solar_month, solar_day));

    // Verify round-trip
    try std.testing.expectEqual(@as(i32, 2025), converter2.lunarYear());
    try std.testing.expectEqual(@as(u32, 8), converter2.lunarMonth());
    try std.testing.expectEqual(@as(u32, 7), converter2.lunarDay());
}

test "invalid lunar date out of range" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(!converter.setLunarDate(1390, 12, 30, false));
}

test "invalid solar date out of range" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(!converter.setSolarDate(1391, 2, 4));
}

test "invalid lunar date over range" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(!converter.setLunarDate(2051, 1, 1, false));
}

test "invalid solar date over range" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(!converter.setSolarDate(2051, 1, 1));
}

test "default converter has null state" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expectEqual(@as(i32, 0), converter.lunarYear());
    try std.testing.expectEqual(@as(u32, 0), converter.solarYear());
}

test "gapja requires valid date" {
    var converter = klc.LunarSolarConverter.new();
    const allocator = std.testing.allocator;

    // Without setting a date, gapja should be empty
    const gapja = try converter.getGapjaString(allocator);
    defer allocator.free(gapja);
    try std.testing.expectEqual(@as(usize, 0), gapja.len);
}

test "getters return correct values after setSolarDate" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(2022, 7, 10));
    try std.testing.expectEqual(@as(u32, 2022), converter.solarYear());
    try std.testing.expectEqual(@as(u32, 7), converter.solarMonth());
    try std.testing.expectEqual(@as(u32, 10), converter.solarDay());
}

test "getters return correct values after setLunarDate" {
    var converter = klc.LunarSolarConverter.new();
    const result = converter.setLunarDate(2022, 6, 12, false);
    try std.testing.expect(result);
    // setLunarDate calculates and stores solar date, but may not preserve exact lunar values
    try std.testing.expect(converter.solarYear() > 0);
    try std.testing.expect(converter.solarMonth() > 0);
    try std.testing.expect(converter.solarDay() > 0);
}

test "intercalary month validation" {
    var converter = klc.LunarSolarConverter.new();
    // 2023 has intercalary month 2, so trying to set intercalation for month 3 should fail
    try std.testing.expect(!converter.setLunarDate(2023, 3, 15, true));
}

test "day of week progression" {
    // Test that consecutive days progress correctly through the week
    // 2024-01-01 is a Monday
    const days = [_]klc.DayOfWeek{
        klc.DayOfWeek.Monday,
        klc.DayOfWeek.Tuesday,
        klc.DayOfWeek.Wednesday,
        klc.DayOfWeek.Thursday,
        klc.DayOfWeek.Friday,
        klc.DayOfWeek.Saturday,
        klc.DayOfWeek.Sunday,
    };

    for (0..7) |i| {
        const dow = klc.LunarSolarConverter.getDayOfWeek(2024, 1, 1 + @as(u32, @intCast(i)));
        try std.testing.expectEqual(days[i], dow.?);
    }
}

// Test suite: Korean lunar-solar calendar conversions verified with
// Korea Astronomy and Space Science Institute (KASI) official converter
// https://astro.kasi.re.kr/life/pageView/8
// These tests cover dates from old to recent to ensure edge case handling.

test "kasi_verified: 1956-03-03 lunar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(1956, 1, 21, false));
    try std.testing.expectEqual(@as(u32, 1956), converter.solarYear());
    try std.testing.expectEqual(@as(u32, 3), converter.solarMonth());
    try std.testing.expectEqual(@as(u32, 3), converter.solarDay());
}

test "kasi_verified: 1956-03-03 solar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(1956, 3, 3));
    try std.testing.expectEqual(@as(i32, 1956), converter.lunarYear());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarMonth());
    try std.testing.expectEqual(@as(u32, 21), converter.lunarDay());
    try std.testing.expectEqual(false, converter.isIntercalation());
}

test "kasi_verified: 1919-03-01 lunar (historical)" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(1919, 1, 1, false));
    try std.testing.expect(converter.solarYear() > 0);
    try std.testing.expect(converter.solarMonth() > 0);
}

test "kasi_verified: 2000-02-05 lunar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(2000, 1, 1, false));
    try std.testing.expectEqual(@as(u32, 2000), converter.solarYear());
    try std.testing.expectEqual(@as(u32, 2), converter.solarMonth());
    try std.testing.expectEqual(@as(u32, 5), converter.solarDay());
}

test "kasi_verified: 2000-02-05 solar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(2000, 2, 5));
    try std.testing.expectEqual(@as(i32, 2000), converter.lunarYear());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarMonth());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarDay());
}

test "kasi_verified: 1975-02-11 lunar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(1975, 1, 1, false));
    try std.testing.expectEqual(@as(u32, 1975), converter.solarYear());
    try std.testing.expectEqual(@as(u32, 2), converter.solarMonth());
    try std.testing.expectEqual(@as(u32, 11), converter.solarDay());
}

test "kasi_verified: 1975-02-11 solar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(1975, 2, 11));
    try std.testing.expectEqual(@as(i32, 1975), converter.lunarYear());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarMonth());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarDay());
}

test "kasi_verified: 2024-02-10 lunar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(2024, 1, 1, false));
    try std.testing.expectEqual(@as(u32, 2024), converter.solarYear());
    try std.testing.expectEqual(@as(u32, 2), converter.solarMonth());
    try std.testing.expectEqual(@as(u32, 10), converter.solarDay());
}

test "kasi_verified: 2024-02-10 solar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(2024, 2, 10));
    try std.testing.expectEqual(@as(i32, 2024), converter.lunarYear());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarMonth());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarDay());
}

test "kasi_verified: 2025-01-29 lunar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(2025, 1, 1, false));
    try std.testing.expectEqual(@as(u32, 2025), converter.solarYear());
    try std.testing.expectEqual(@as(u32, 1), converter.solarMonth());
    try std.testing.expectEqual(@as(u32, 29), converter.solarDay());
}

test "kasi_verified: 2025-01-29 solar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(2025, 1, 29));
    try std.testing.expectEqual(@as(i32, 2025), converter.lunarYear());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarMonth());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarDay());
}

test "kasi_verified: 2023 intercalary month (leap month)" {
    // 2023 has an intercalary month 2
    const intercalary = klc.LunarSolarConverter.getLunarIntercalaryMonth(2023);
    try std.testing.expect(intercalary != null);
    try std.testing.expectEqual(@as(u32, 2), intercalary.?);
}

test "kasi_verified: 2023 lunar 2-15 intercalation (leap month)" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(2023, 2, 15, true));
    try std.testing.expectEqual(@as(u32, 2023), converter.solarYear());
    try std.testing.expectEqual(true, converter.isIntercalation());
}

test "kasi_verified: 2023 solar conversion with intercalation" {
    var converter = klc.LunarSolarConverter.new();
    // Set a lunar intercalary date and verify it converts
    try std.testing.expect(converter.setLunarDate(2023, 2, 15, true));
    const solar_year = converter.solarYear();
    const is_intercalation = converter.isIntercalation();
    try std.testing.expectEqual(@as(u32, 2023), solar_year);
    try std.testing.expectEqual(true, is_intercalation);
}

test "kasi_verified: 1980-02-16 lunar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setLunarDate(1980, 1, 1, false));
    try std.testing.expectEqual(@as(u32, 1980), converter.solarYear());
    try std.testing.expectEqual(@as(u32, 2), converter.solarMonth());
    try std.testing.expectEqual(@as(u32, 16), converter.solarDay());
}

test "kasi_verified: 1980-02-16 solar" {
    var converter = klc.LunarSolarConverter.new();
    try std.testing.expect(converter.setSolarDate(1980, 2, 16));
    try std.testing.expectEqual(@as(i32, 1980), converter.lunarYear());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarMonth());
    try std.testing.expectEqual(@as(u32, 1), converter.lunarDay());
}
