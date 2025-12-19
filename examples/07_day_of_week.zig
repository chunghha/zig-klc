const std = @import("std");
const klc = @import("klc");

/// 예제 7: 요일(Day of Week) 계산
/// Example 7: Day of Week Calculation
///
/// 주어진 양력 날짜의 요일을 계산합니다.
/// 율리우스 적일(JDN) 계산을 기반으로 합니다.
///
/// Calculate the day of the week for a given Gregorian date.
/// This is calculated based on the Julian Day Number (JDN).

pub fn main() !void {
    std.debug.print("=== 요일(Day of Week) 계산 ===\n\n", .{});

    // 특정 날짜의 요일 확인
    // Check the day of week for specific dates
    const test_dates = [_]struct {
        year: u32,
        month: u32,
        day: u32,
        description: []const u8,
    }{
        .{ .year = 2024, .month = 1, .day = 1, .description = "2024년 새해 (New Year 2024)" },
        .{ .year = 2024, .month = 2, .day = 10, .description = "2024년 설날 (Korean New Year 2024)" },
        .{ .year = 2000, .month = 1, .day = 1, .description = "밀레니엄 (Millennium)" },
        .{ .year = 2022, .month = 7, .day = 10, .description = "예제 기준 날짜 (Example date)" },
        .{ .year = 1956, .month = 3, .day = 3, .description = "역사적 날짜 (Historical date)" },
    };

    for (test_dates) |date_info| {
        if (klc.LunarSolarConverter.getDayOfWeek(date_info.year, date_info.month, date_info.day)) |dow| {
            const dow_name = @tagName(dow);
            std.debug.print("{d}-{d:0>2}-{d:0>2}: {s} ({s})\n", .{
                date_info.year,
                date_info.month,
                date_info.day,
                dow_name,
                date_info.description,
            });
        } else {
            std.debug.print("{d}-{d:0>2}-{d:0>2}: 유효하지 않은 날짜 (Invalid date)\n", .{
                date_info.year,
                date_info.month,
                date_info.day,
            });
        }
    }

    // 연속된 날짜의 요일 패턴 확인
    std.debug.print("\n=== 연속된 날짜의 요일 패턴 ===\n\n", .{});
    std.debug.print("2024년 1월의 첫 7일:\n", .{});

    const week_days = [_][]const u8{
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday",
    };

    for (1..8) |day| {
        if (klc.LunarSolarConverter.getDayOfWeek(2024, 1, @as(u32, @intCast(day)))) |dow| {
            const dow_name = @tagName(dow);
            std.debug.print("2024-01-{d:0>2}: {s}\n", .{ day, dow_name });
        }
    }

    // 요일의 한글 이름 매핑
    std.debug.print("\n=== 요일 한글/영문 대응 ===\n\n", .{});
    const korean_days = [_][]const u8{
        "월요일 (Monday)",
        "화요일 (Tuesday)",
        "수요일 (Wednesday)",
        "목요일 (Thursday)",
        "금요일 (Friday)",
        "토요일 (Saturday)",
        "일요일 (Sunday)",
    };

    for (korean_days, 0..) |korean_day, i| {
        std.debug.print("  {s}\n", .{korean_day});
    }
}
