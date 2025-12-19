const std = @import("std");
const klc = @import("klc");

/// 예제 6: 윤년(Leap Year) 계산
/// Example 6: Leap Year Calculation
///
/// 윤년은 양력(Gregorian calendar)에서 특정 규칙으로 정의됩니다:
/// - 4로 나누어떨어지는 해는 윤년
/// - 단, 100으로 나누어떨어지면 평년
/// - 단, 400으로 나누어떨어지면 윤년
///
/// Leap years in the Gregorian calendar follow these rules:
/// - Divisible by 4 → leap year
/// - Divisible by 100 → not a leap year
/// - Divisible by 400 → leap year
pub fn main() !void {
    std.debug.print("=== 윤년(Leap Year) 판정 ===\n\n", .{});

    // 다양한 연도의 윤년 판정
    // Check leap year status for various years
    const test_years = [_]struct {
        year: u32,
        expected: bool,
        reason: []const u8,
    }{
        .{ .year = 2000, .expected = true, .reason = "400의 배수 (divisible by 400)" },
        .{ .year = 1900, .expected = false, .reason = "100의 배수이지만 400의 배수 아님 (divisible by 100, not by 400)" },
        .{ .year = 2020, .expected = true, .reason = "4의 배수 (divisible by 4)" },
        .{ .year = 2023, .expected = false, .reason = "4로 나누어떨어지지 않음 (not divisible by 4)" },
        .{ .year = 2024, .expected = true, .reason = "4의 배수 (divisible by 4)" },
        .{ .year = 2100, .expected = false, .reason = "100의 배수이지만 400의 배수 아님 (divisible by 100, not by 400)" },
        .{ .year = 2400, .expected = true, .reason = "400의 배수 (divisible by 400)" },
    };

    var correct_count: u32 = 0;

    for (test_years) |t| {
        const is_leap = klc.LunarSolarConverter.isSolarLeapYear(t.year);
        const status = if (is_leap == t.expected) "✓" else "✗";

        std.debug.print("{d}: {s} {s}\n", .{
            t.year,
            if (is_leap) "윤년 (Leap)" else "평년 (Regular)",
            status,
        });
        std.debug.print("  사유: {s}\n\n", .{t.reason});

        if (is_leap == t.expected) {
            correct_count += 1;
        }
    }

    std.debug.print("=== 판정 결과 ===\n", .{});
    std.debug.print("정확도: {d}/{d}\n", .{ correct_count, test_years.len });

    // 음력 윤달과의 차이 설명
    std.debug.print("\n=== 참고: 윤달(Intercalary Month)과의 차이 ===\n\n", .{});
    std.debug.print("양력 윤년(Solar Leap Year):\n", .{});
    std.debug.print("  - 2월이 28일에서 29일로 증가\n", .{});
    std.debug.print("  - February gains one extra day\n\n", .{});

    std.debug.print("음력 윤달(Lunar Intercalary Month):\n", .{});
    std.debug.print("  - 윤달이 한 달 전체가 추가됨\n", .{});
    std.debug.print("  - An entire extra month is added (약 19년마다)\n", .{});
}
