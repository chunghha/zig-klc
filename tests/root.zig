const std = @import("std");
const root = @import("root");

test "getLunarData returns correct data" {
    const data = root.getLunarData(1391);

    try std.testing.expectEqual(data, 0x82c40653);
}

test "getLunarIntercalationMonth returns correct month" {
    const data = root.getLunarData(1391);
    const intercalationMonth = root.getLunarIntercalationMonth(data);

    try std.testing.expectEqual(u32(0), intercalationMonth);
}

test "shiftLunarDays returns correct shifted days" {
    const shiftedDays = root.shiftLunarDays(1391);

    try std.testing.expectEqual(shiftedDays, 0x065);
}

test "getLunarDays returns correct days for non-intercalation month" {
    const days = root.getLunarDays(1391, 1, false);

    try std.testing.expectEqual(days, root.LUNAR_BIG_MONTH_DAY);
}

test "getLunarDays returns correct days for intercalation month" {
    const days = root.getLunarDays(1391, 1, true);

    try std.testing.expectEqual(days, root.LUNAR_SMALL_MONTH_DAY);
}

test "getLunarDaysBeforeBaseYear returns correct days" {
    const expectedDays: u32 = 0;
    const year: u32 = 2023;
    const result: u32 = root.getLunarDaysBeforeBaseYear(year);

    try std.testing.expect(result == expectedDays);
}

test "getLunarDaysBeforeBaseMonth without intercalation returns correct days" {
    const expectedDays: u32 = 0;
    const year: u32 = 2023;
    const month: u32 = 5;
    const result: u32 = root.getLunarDaysBeforeBaseMonth(year, month, false);

    try std.testing.expect(result == expectedDays);
}

test "getLunarDaysBeforeBaseMonth with intercalation returns correct days" {
    const expectedDays: u32 = 0;
    const year: u32 = 2023;
    const month: u32 = 5;
    const result: u32 = root.getLunarDaysBeforeBaseMonth(year, month, true);

    try std.testing.expect(result == expectedDays);
}

test "getLunarAbsDays without intercalation returns correct days" {
    const expectedDays: u32 = 0;
    const year: u32 = 2023;
    const month: u32 = 5;
    const day: u32 = 15;
    const result: u32 = root.getLunarAbsDays(year, month, day, false);

    try std.testing.expect(result == expectedDays);
}

test "getLunarAbsDays with intercalation returns correct days" {
    const expectedDays: u32 = 0;
    const year: u32 = 2023;
    const month: u32 = 5;
    const day: u32 = 15;
    const result: u32 = root.getLunarAbsDays(year, month, day, true);

    try std.testing.expect(result == expectedDays);
}

test "isSolarIntercalationYear returns correct boolean" {
    const lunarData: u32 = 0x40000000; // Example data where the 30th bit is set
    const result: bool = root.isSolarIntercalationYear(lunarData);

    try std.testing.expect(result == true);

    const lunarDataNotIntercalation: u32 = 0x00000000; // Example data where the 30th bit is not set
    const resultNotIntercalation: bool = root.isSolarIntercalationYear(lunarDataNotIntercalation);

    try std.testing.expect(resultNotIntercalation == false);
}

test "hiftSolarDays for a regular year returns correct days" {
    const expectedDays: u32 = root.SOLAR_SMALL_YEAR_DAY;
    const year: u32 = 2023; // Replace with the test year
    const result: u32 = root.shiftSolarDays(year);

    try std.testing.expect(result == expectedDays);
}

test "shiftSolarDays for an intercalation year returns correct days" {
    const expectedDays: u32 = root.SOLAR_BIG_YEAR_DAY;
    const year: u32 = 2024;
    const result: u32 = root.shiftSolarDays(year);

    try std.testing.expect(result == expectedDays);
}

test "shiftSolarDays for the year 1582 returns correct days" {
    const expectedDays: u32 = root.SOLAR_SMALL_YEAR_DAY - 10;
    const year: u32 = 1582;
    const result: u32 = root.shiftSolarDays(year);

    try std.testing.expect(result == expectedDays);
}

test "getSolarDays for a regular month returns correct days" {
    const expectedDays: u32 = 31;
    const year: u32 = 2023;
    const month: u32 = 1;
    const result: u32 = root.getSolarDays(year, month);

    try std.testing.expect(result == expectedDays);
}

test "getSolarDays for February in an intercalation year returns correct days" {
    const expectedDays: u32 = 29;
    const year: u32 = 2024;
    const month: u32 = 2;
    const result: u32 = root.getSolarDays(year, month);

    try std.testing.expect(result == expectedDays);
}

test "getSolarDays for October 1582 returns correct days" {
    const expectedDays: u32 = 21;
    const year: u32 = 1582;
    const month: u32 = 10;
    const result: u32 = root.getSolarDays(year, month);

    try std.testing.expect(result == expectedDays);
}

test "getSolarDayBeforeBaseYear returns correct days" {
    const expectedDays: u32 = 0;
    const year: u32 = 2023;
    const result: u32 = root.getSolarDayBeforeBaseYear(year);

    try std.testing.expect(result == expectedDays);
}

test "getSolarDaysBeforeBaseMonth returns correct days" {
    const expectedDays: u32 = 0;
    const year: u32 = 2023;
    const month: u32 = 5;
    const result: u32 = root.getSolarDaysBeforeBaseMonth(year, month);

    try std.testing.expect(result == expectedDays);
}

test "getSolarAbsDays returns correct days" {
    const expectedDays: u32 = 0;
    const year: u32 = 2023;
    const month: u32 = 5;
    const day: u32 = 15;
    const result: u32 = root.getSolarAbsDays(year, month, day);

    try std.testing.expect(result == expectedDays);
}

test "setSolarDateByLunarDate sets correct solar date" {
    const solarYear: u32 = 0;
    const solarMonth: u32 = 0;
    const solarDay: u32 = 0;

    const lunarYear: u32 = 2023;
    const lunarMonth: u32 = 5;
    const lunarDay: u32 = 15;
    const isIntercalation: bool = false;

    root.setSolarDateByLunarDate(lunarYear, lunarMonth, lunarDay, isIntercalation);

    const expectedSolarYear: u32 = 2023;
    const expectedSolarMonth: u32 = 6;
    const expectedSolarDay: u32 = 1;

    try std.testing.expect(solarYear == expectedSolarYear);
    try std.testing.expect(solarMonth == expectedSolarMonth);
    try std.testing.expect(solarDay == expectedSolarDay);
}

test "setLunarDateBySolarDate sets correct lunar date" {
    const lunarYear: u32 = 0;
    const lunarMonth: u32 = 0;
    const lunarDay: u32 = 0;

    const solarYear: u32 = 2023;
    const solarMonth: u32 = 5;
    const solarDay: u32 = 15;

    root.setLunarDateBySolarDate(solarYear, solarMonth, solarDay);

    const expectedLunarYear: u32 = 2023;
    const expectedLunarMonth: u32 = 4;
    const expectedLunarDay: u32 = 25;

    try std.testing.expect(lunarYear == expectedLunarYear);
    try std.testing.expect(lunarMonth == expectedLunarMonth);
    try std.testing.expect(lunarDay == expectedLunarDay);
}

test "isValidMin for lunar date returns correct boolean" {
    const isLunar: bool = true;
    const dateValue: i32 = root.KOREAN_LUNAR_MIN_VALUE;
    const result: bool = root.isValidMin(isLunar, dateValue);

    try std.testing.expect(result == true);
}

test "isValidMin for solar date returns correct boolean" {
    const isLunar: bool = false;
    const dateValue: i32 = root.KOREAN_SOLAR_MIN_VALUE;
    const result: bool = root.isValidMin(isLunar, dateValue);

    try std.testing.expect(result == true);
}

test "isValidMin for invalid lunar date returns correct boolean" {
    const isLunar: bool = true;
    const dateValue: i32 = root.KOREAN_LUNAR_MIN_VALUE - 1;
    const result: bool = root.isValidMin(isLunar, dateValue);

    try std.testing.expect(result == false);
}

test "isValidMin for invalid solar date returns correct boolean" {
    const isLunar: bool = false;
    const dateValue: i32 = root.KOREAN_SOLAR_MIN_VALUE - 1;
    const result: bool = root.isValidMin(isLunar, dateValue);

    try std.testing.expect(result == false);
}

test "isValidMax for lunar date returns correct boolean" {
    const isLunar: bool = true;
    const dateValue: i32 = root.KOREAN_LUNAR_MAX_VALUE;
    const result: bool = root.isValidMax(isLunar, dateValue);

    try std.testing.expect(result == true);
}

test "isValidMax for solar date returns correct boolean" {
    const isLunar: bool = false;
    const dateValue: i32 = root.KOREAN_SOLAR_MAX_VALUE;
    const result: bool = root.isValidMax(isLunar, dateValue);

    try std.testing.expect(result == true);
}

test "isValidMax for invalid lunar date returns correct boolean" {
    const isLunar: bool = true;
    const dateValue: i32 = root.KOREAN_LUNAR_MAX_VALUE + 1;
    const result: bool = root.isValidMax(isLunar, dateValue);

    try std.testing.expect(result == false);
}

test "isValidMax for invalid solar date returns correct boolean" {
    const isLunar: bool = false;
    const dateValue: i32 = root.KOREAN_SOLAR_MAX_VALUE + 1;
    const result: bool = root.isValidMax(isLunar, dateValue);

    try std.testing.expect(result == false);
}

test "checkValidDate for valid lunar date returns correct boolean" {
    const isLunar: bool = true;
    const isIntercalation: bool = false;
    const year: i32 = 2023;
    const month: i32 = 5;
    const day: i32 = 15;
    const result: bool = root.checkValidDate(isLunar, isIntercalation, year, month, day);

    try std.testing.expect(result == true);
}

test "checkValidDate for valid solar date returns correct boolean" {
    const isLunar: bool = false;
    const isIntercalation: bool = false;
    const year: i32 = 2023;
    const month: i32 = 5;
    const day: i32 = 15;
    const result: bool = root.checkValidDate(isLunar, isIntercalation, year, month, day);

    try std.testing.expect(result == true);
}

test "checkValidDate for invalid date in 1582 returns correct boolean" {
    const isLunar: bool = false;
    const isIntercalation: bool = false;
    const year: i32 = 1582;
    const month: i32 = 10;
    const day: i32 = 10;
    const result: bool = root.checkValidDate(isLunar, isIntercalation, year, month, day);

    try std.testing.expect(result == false);
}

test "checkValidDate for invalid lunar date returns correct boolean" {
    const isLunar: bool = true;
    const isIntercalation: bool = false;
    const year: i32 = 2023;
    const month: i32 = 13; // Invalid month
    const day: i32 = 15;
    const result: bool = root.checkValidDate(isLunar, isIntercalation, year, month, day);

    try std.testing.expect(result == false);
}

test "setLunarDate for valid lunar date sets correct boolean" {
    const lYear: u32 = 2023;
    const lMonth: u32 = 5;
    const lDay: u32 = 15;
    const isIntercalation: bool = false;

    const result: bool = root.setLunarDate(lYear, lMonth, lDay, isIntercalation);

    try std.testing.expect(result == true);
}

test "setLunarDate for invalid lunar date sets correct boolean" {
    const lYear: u32 = 2023;
    const lMonth: u32 = 13; // Invalid month
    const lDay: u32 = 15;
    const isIntercalation: bool = false;

    const result: bool = root.setLunarDate(lYear, lMonth, lDay, isIntercalation);

    try std.testing.expect(result == false);
}

test "setSolarDate for valid solar date sets correct boolean" {
    const sYear: u32 = 2023;
    const sMonth: u32 = 5;
    const sDay: u32 = 15;

    const result: bool = root.setSolarDate(sYear, sMonth, sDay);

    try std.testing.expect(result == true);
}

test "setSolarDate for invalid solar date sets correct boolean" {
    const sYear: u32 = 2023;
    const sMonth: u32 = 13; // Invalid month
    const sDay: u32 = 15;

    const result: bool = root.setSolarDate(sYear, sMonth, sDay);

    try std.testing.expect(result == false);
}

test "getGapJa returns correct gapja indices" {
    // Set up the lunar date and intercalation flag
    const lunarYear = 2023;
    const lunarMonth = 5;
    const lunarDay = 15;
    const isIntercalation = false;

    // Expected values based on the logic
    const expectedGapjaYearInx: [2]u32 = [_]u32{ (2023 + 7 - root.KOREAN_LUNAR_BASE_YEAR) % @as(u32, @intCast(root.KOREAN_CHEONGAN.len)), (2023 + 7 - root.KOREAN_LUNAR_BASE_YEAR) % @as(u32, @intCast(root.KOREAN_GANJI.len)) };
    const monthCount: u32 = 5 + 12 * (2023 - root.KOREAN_LUNAR_BASE_YEAR);
    const expectedGapjaMonthInx: [2]u32 = [_]u32{ (monthCount + 5) % @as(u32, @intCast(root.KOREAN_CHEONGAN.len)), (monthCount + 1) % @as(u32, @intCast(root.KOREAN_GANJI.len)) };
    const absDays: u32 = root.getLunarAbsDays(lunarYear, lunarMonth, lunarDay, isIntercalation);
    const expectedGapjaDayInx: [2]u32 = [_]u32{ (absDays + 4) % @as(u32, @intCast(root.KOREAN_CHEONGAN.len)), absDays % @as(u32, @intCast(root.KOREAN_GANJI.len)) };

    // Call the function
    root.getGapJa();

    // Check the results
    try std.testing.expect(root.gapjaYearInx[0] == expectedGapjaYearInx[0]);
    try std.testing.expect(root.gapjaYearInx[1] == expectedGapjaYearInx[1]);
    try std.testing.expect(root.gapjaMonthInx[0] == expectedGapjaMonthInx[0]);
    try std.testing.expect(root.gapjaMonthInx[1] == expectedGapjaMonthInx[1]);
    try std.testing.expect(root.gapjaDayInx[0] == expectedGapjaDayInx[0]);
    try std.testing.expect(root.gapjaDayInx[1] == expectedGapjaDayInx[1]);
}

test "getGapjaString returns correct gapja string" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const gapja_string = try root.getGapjaString(allocator);

    std.debug.print("{}", .{gapja_string});

    try std.testing.expect(std.mem.eql(u8, gapja_string, "갑을병정무기경신임계"));
}

test "getChineseGapJaString returns correct gapja string" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const gapja_string = root.getChineseGapJaString(allocator);
    if (gapja_string == null) {
        return error.TestFailure;
    }

    std.debug.print("{}", .{gapja_string});

    try std.testing.expect(std.mem.eql(u8, gapja_string, "甲乙丙丁戊己庚辛壬癸"));
}

test "getLunarIsoFormat returns correct ISO format string" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Set up the lunar date and intercalation flag
    const isIntercalation = false;

    const isoStr = try root.getLunarIsoFormat(allocator);

    std.debug.print("{}", .{isoStr});

    try std.testing.expect(std.mem.eql(u8, isoStr, "2023-05-15"));

    // Test with intercalation
    isIntercalation = true;
    const isoStrIntercalation = try root.getLunarIsoFormat(allocator);

    std.debug.print("{}", .{isoStrIntercalation});

    try std.testing.expect(std.mem.eql(u8, isoStrIntercalation, "2023-05-15 Intercalation"));
}
