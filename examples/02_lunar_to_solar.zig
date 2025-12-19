const std = @import("std");
const klc = @import("klc");

/// 예제 2: 음력-양력 역변환
/// Example 2: Lunar to Gregorian Reverse Conversion
///
/// 이 예제는 음력 날짜를 양력 날짜로 변환하는 방법을 보여줍니다.
///
/// This example demonstrates how to convert a lunar date to a Gregorian date.

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var converter = klc.LunarSolarConverter.new();

    // 음력 날짜 설정: 2024년 1월 1일 (정월 초하루 - 설날)
    // Set a lunar date: 1st day of 1st lunar month (Korean New Year)
    // 네 번째 인자는 윤달(intercalary month) 여부입니다.
    // The fourth parameter indicates if it's an intercalary month.
    if (converter.setLunarDate(2024, 1, 1, false)) {
        std.debug.print("음력 (Lunar): 2024-01-01 (정월 초하루)\n", .{});
        std.debug.print("양력 (Solar): {d:0>4}-{d:0>2}-{d:0>2}\n", .{
            converter.solarYear(),
            converter.solarMonth(),
            converter.solarDay(),
        });

        // ISO 형식으로도 출력
        // Also print in ISO format
        const solar_iso = try converter.getSolarIsoFormat(allocator);
        std.debug.print("ISO 형식: {s}\n", .{solar_iso});

        // 요일 정보도 함께 표시 (양력 기준)
        // Also display the day of week (based on solar date)
        if (klc.LunarSolarConverter.getDayOfWeek(converter.solarYear(), converter.solarMonth(), converter.solarDay())) |dow| {
            std.debug.print("요일 (Day of Week): {s}\n", .{@tagName(dow)});
        }
    } else {
        std.debug.print("유효하지 않은 음력 날짜입니다.\n", .{});
    }
}
