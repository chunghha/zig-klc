const std = @import("std");
const klc = @import("klc");

/// 예제 1: 기본 양력-음력 변환
/// Example 1: Basic Gregorian-Lunar Calendar Conversion
///
/// 이 예제는 양력(Solar/Gregorian) 날짜를 음력(Lunar) 날짜로 변환하는
/// 가장 기본적인 사용 방법을 보여줍니다.
///
/// This example demonstrates the most basic usage of converting
/// a Gregorian date to a Lunar date.

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // LunarSolarConverter 인스턴스 생성
    // Create a new LunarSolarConverter instance
    var converter = klc.LunarSolarConverter.new();

    // 양력 날짜 설정: 2022년 7월 10일
    // Set a Gregorian date: July 10, 2022
    if (converter.setSolarDate(2022, 7, 10)) {
        // 변환된 음력 날짜 출력
        // Print the converted lunar date
        std.debug.print("양력 (Solar): 2022-07-10\n", .{});
        std.debug.print("음력 (Lunar): {d:0>4}-{d:0>2}-{d:0>2}\n", .{
            @as(u32, @intCast(converter.lunarYear())),
            converter.lunarMonth(),
            converter.lunarDay(),
        });

        // ISO 8601 형식으로 출력
        // Print in ISO 8601 format
        const lunar_iso = try converter.getLunarIsoFormat(allocator);
        std.debug.print("ISO 형식: {s}\n", .{lunar_iso});
    } else {
        std.debug.print("유효하지 않은 날짜입니다.\n", .{});
    }
}
