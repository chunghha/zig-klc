const std = @import("std");
const klc = @import("klc");

/// 예제 8: 종합 예제 - 모든 기능 활용
/// Example 8: Comprehensive Example - Using All Features
///
/// 이 예제는 라이브러리의 모든 주요 기능을 한 번에 보여줍니다.
/// 특정 날짜에 대해 다양한 정보를 출력합니다.
///
/// This example demonstrates all major features of the library at once.
/// It prints various information about a specific date.

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    std.debug.print("╔════════════════════════════════════════════════════════╗\n", .{});
    std.debug.print("║  한국 양음력 변환 라이브러리 - 종합 예제                    ║\n", .{});
    std.debug.print("║  Korean Lunar-Solar Calendar - Comprehensive Example     ║\n", .{});
    std.debug.print("╚════════════════════════════════════════════════════════╝\n\n", .{});

    var converter = klc.LunarSolarConverter.new();

    // 2024년 2월 10일(설날)을 기준으로
    const solar_year: u32 = 2024;
    const solar_month: u32 = 2;
    const solar_day: u32 = 10;

    if (converter.setSolarDate(solar_year, solar_month, solar_day)) {
        // 1. 기본 정보
        std.debug.print("[1] 기본 정보 (Basic Information)\n", .{});
        std.debug.print("────────────────────────────────────────────────────\n", .{});

        const solar_iso = try converter.getSolarIsoFormat(allocator);
        const lunar_iso = try converter.getLunarIsoFormat(allocator);

        std.debug.print("양력 (Gregorian):   {s}\n", .{solar_iso});
        std.debug.print("음력 (Lunar):       {s}\n", .{lunar_iso});

        // 2. 요일 정보
        std.debug.print("\n[2] 요일 정보 (Day of Week Information)\n", .{});
        std.debug.print("────────────────────────────────────────────────────\n", .{});

        if (klc.LunarSolarConverter.getDayOfWeek(solar_year, solar_month, solar_day)) |dow| {
            std.debug.print("요일: {s}\n", .{@tagName(dow)});
        }

        // 3. 간지 정보
        std.debug.print("\n[3] 간지 정보 (Gapja/Sexagenary Cycle)\n", .{});
        std.debug.print("────────────────────────────────────────────────────\n", .{});

        const korean_gapja = try converter.getGapjaString(allocator);
        const chinese_gapja = try converter.getChineseGapjaString(allocator);

        std.debug.print("한글:  {s}\n", .{korean_gapja});
        std.debug.print("중문:  {s}\n", .{chinese_gapja});

        // 4. 율리우스 적일
        std.debug.print("\n[4] 율리우스 적일 (Julian Day Number)\n", .{});
        std.debug.print("────────────────────────────────────────────────────\n", .{});

        if (klc.LunarSolarConverter.getJulianDayNumber(solar_year, solar_month, solar_day)) |jdn| {
            std.debug.print("JDN: {d}\n", .{jdn});
            std.debug.print("(기원전 4713년 1월 1일부터 경과한 일수)\n", .{});
        }

        // 5. 윤년 정보
        std.debug.print("\n[5] 윤년 정보 (Leap Year Information)\n", .{});
        std.debug.print("────────────────────────────────────────────────────\n", .{});

        const is_leap = klc.LunarSolarConverter.isSolarLeapYear(solar_year);
        std.debug.print("{d}년: {s}\n", .{
            solar_year,
            if (is_leap) "윤년 (Leap Year)" else "평년 (Regular Year)",
        });

        // 6. 윤달 정보
        std.debug.print("\n[6] 윤달 정보 (Intercalary Month)\n", .{});
        std.debug.print("────────────────────────────────────────────────────\n", .{});

        const lunar_year = @as(u32, @intCast(converter.lunarYear()));
        if (klc.LunarSolarConverter.getLunarIntercalaryMonth(converter.lunarYear())) |intercalary| {
            std.debug.print("{d}년: {d}월이 윤달입니다\n", .{ lunar_year, intercalary });
        } else {
            std.debug.print("{d}년: 윤달이 없습니다\n", .{lunar_year});
        }

        // 7. 범위 정보
        std.debug.print("\n[7] 지원 범위 (Supported Date Range)\n", .{});
        std.debug.print("────────────────────────────────────────────────────\n", .{});

        std.debug.print("음력: {d}-{d:0>2}-{d:0>2} ~ {d}-{d:0>2}-{d:0>2}\n", .{
            klc.KOREAN_LUNAR_MIN_VALUE / 10000,
            (klc.KOREAN_LUNAR_MIN_VALUE % 10000) / 100,
            klc.KOREAN_LUNAR_MIN_VALUE % 100,
            klc.KOREAN_LUNAR_MAX_VALUE / 10000,
            (klc.KOREAN_LUNAR_MAX_VALUE % 10000) / 100,
            klc.KOREAN_LUNAR_MAX_VALUE % 100,
        });

        std.debug.print("양력: {d}-{d:0>2}-{d:0>2} ~ {d}-{d:0>2}-{d:0>2}\n", .{
            klc.KOREAN_SOLAR_MIN_VALUE / 10000,
            (klc.KOREAN_SOLAR_MIN_VALUE % 10000) / 100,
            klc.KOREAN_SOLAR_MIN_VALUE % 100,
            klc.KOREAN_SOLAR_MAX_VALUE / 10000,
            (klc.KOREAN_SOLAR_MAX_VALUE % 10000) / 100,
            klc.KOREAN_SOLAR_MAX_VALUE % 100,
        });

        std.debug.print("\n╔════════════════════════════════════════════════════════╗\n", .{});
        std.debug.print("║  변환 완료 (Conversion Complete)                      ║\n", .{});
        std.debug.print("╚════════════════════════════════════════════════════════╝\n", .{});
    } else {
        std.debug.print("오류: 유효하지 않은 날짜입니다.\n", .{});
    }
}
