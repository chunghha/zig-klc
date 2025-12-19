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
