const std = @import("std");
const klc = @import("klc");

/// 예제 5: 율리우스 적일(Julian Day Number) 계산
/// Example 5: Julian Day Number Calculation
///
/// 율리우스 적일(JDN)은 기원전 4713년 1월 1일부터 시작하여
/// 경과한 날의 수를 나타내는 천문학적 날짜 표현 방식입니다.
/// 이것은 서로 다른 역법(calendar system) 간의 변환을 쉽게 합니다.
///
/// The Julian Day Number (JDN) is an astronomical dating system that
/// counts the number of days elapsed since January 1, 4713 BC.
/// It simplifies conversions between different calendar systems.

pub fn main() !void {
    std.debug.print("=== 율리우스 적일(Julian Day Number) 계산 ===\n\n", .{});

    // 몇 가지 중요한 날짜의 JDN 계산
    // Calculate JDN for several important dates
    const test_dates = [_]struct {
        year: u32,
        month: u32,
        day: u32,
        description: []const u8,
    }{
        .{ .year = 1582, .month = 10, .day = 4, .description = "그레고리력 개정 전 마지막 날 (Last day before Gregorian reform)" },
        .{ .year = 1582, .month = 10, .day = 15, .description = "그레고리력 개정 후 첫 날 (First day after Gregorian reform)" },
        .{ .year = 2000, .month = 2, .day = 5, .description = "새로운 천년 - 한국 설날 (Y2K - Korean New Year)" },
        .{ .year = 2022, .month = 7, .day = 10, .description = "현재 예제 기준 날짜 (Example reference date)" },
        .{ .year = 2024, .month = 2, .day = 10, .description = "최근 설날 (Recent Korean New Year)" },
    };

    for (test_dates) |date_info| {
        if (klc.LunarSolarConverter.getJulianDayNumber(date_info.year, date_info.month, date_info.day)) |jdn| {
            std.debug.print("{d}-{d:0>2}-{d:0>2}: JDN = {d}\n", .{
                date_info.year,
                date_info.month,
                date_info.day,
                jdn,
            });
            std.debug.print("  ({s})\n\n", .{date_info.description});
        } else {
            std.debug.print("{d}-{d:0>2}-{d:0>2}: 유효하지 않은 날짜 (Invalid date)\n", .{
                date_info.year,
                date_info.month,
                date_info.day,
            });
            std.debug.print("  ({s})\n\n", .{date_info.description});
        }
    }

    // 그레고리력 개정으로 인한 갭(gap) 설명
    std.debug.print("=== 그레고리력 개정 (Gregorian Calendar Reform) ===\n\n", .{});
    std.debug.print("1582년 10월 5일부터 10월 14일까지는 존재하지 않습니다.\n", .{});
    std.debug.print("(October 5-14, 1582 do not exist)\n\n", .{});

    // 개정 갭의 유효성 검증
    // Validate the gap dates
    std.debug.print("개정 갭 내의 날짜 확인 (Checking dates within the reform gap):\n", .{});
    for (5..15) |day| {
        const result = klc.LunarSolarConverter.getJulianDayNumber(1582, 10, @as(u32, @intCast(day)));
        const status = if (result == null) "존재하지 않음 ✓" else "존재함 ✗";
        std.debug.print("1582-10-{d:0>2}: {s}\n", .{ day, status });
    }
}
