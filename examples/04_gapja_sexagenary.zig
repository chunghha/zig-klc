const std = @import("std");
const klc = @import("klc");

/// 예제 4: 간지(Gapja) - 육십간지 순환
/// Example 4: Gapja (Sexagenary Cycle)
///
/// 간지(간지, 간지干支)는 년, 월, 일을 60년 주기로 표현하는
/// 동양의 전통적 날짜 체계입니다.
/// - 천간(天干): 10개의 순환 (갑을병정무기경신임계)
/// - 지지(地支): 12개의 순환 (자축인묘진사오미신유술해)
/// - 조합: 60년 주기 (10 × 12)
///
/// Gapja (Sexagenary Cycle) is a traditional East Asian dating system
/// that expresses years, months, and days in 60-year cycles:
/// - Cheongan (Heavenly Stems): 10-element cycle
/// - Ganji (Earthly Branches): 12-element cycle
/// - Combined: 60-year cycle (10 × 12)

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var converter = klc.LunarSolarConverter.new();

    // 2022년 7월 10일을 기준으로 간지 계산
    // Calculate gapja for July 10, 2022
    if (converter.setSolarDate(2022, 7, 10)) {
        // 한글 간지 표현
        // Korean gapja representation
        const korean_gapja = try converter.getGapjaString(allocator);
        std.debug.print("한글 간지 (Korean): {s}\n", .{korean_gapja});

        // 중문 간지 표현
        // Chinese gapja representation
        const chinese_gapja = try converter.getChineseGapjaString(allocator);
        std.debug.print("중문 간지 (Chinese): {s}\n", .{chinese_gapja});

        std.debug.print("\n간지 구성:\n", .{});
        std.debug.print("- 년(Year): 천간(Cheongan) + 지지(Ganji)\n", .{});
        std.debug.print("- 월(Month): 천간(Cheongan) + 지지(Ganji)\n", .{});
        std.debug.print("- 일(Day): 천간(Cheongan) + 지지(Ganji)\n", .{});
    }

    // 다른 날짜의 간지도 확인해봅시다
    // Let's check gapja for other dates
    std.debug.print("\n=== 다양한 날짜의 간지 ===\n\n", .{});

    const test_dates = [_][3]u32{
        .{ 2000, 2, 5 }, // 새로운 천년
        .{ 2024, 1, 1 }, // 최근 설날
        .{ 1975, 2, 11 }, // 역사적 날짜
    };

    for (test_dates) |date| {
        var test_converter = klc.LunarSolarConverter.new();
        if (test_converter.setSolarDate(date[0], date[1], date[2])) {
            const lunar_iso = try test_converter.getLunarIsoFormat(allocator);
            const gapja = try test_converter.getGapjaString(allocator);
            std.debug.print("{d}-{d:0>2}-{d:0>2} (음력: {s}) → {s}\n", .{
                date[0],
                date[1],
                date[2],
                lunar_iso,
                gapja,
            });
        }
    }
}
