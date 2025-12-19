const std = @import("std");
const klc = @import("klc");

/// 예제 3: 윤달(Intercalary Month) 처리
/// Example 3: Handling Intercalary (Leap) Months
///
/// 음력에서는 19년마다 윤달(leap month)이 있습니다.
/// 이 예제는 윤달을 감지하고 처리하는 방법을 보여줍니다.
///
/// The lunar calendar has intercalary months approximately every 19 years.
/// This example shows how to detect and handle intercalary months.

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // 2023년의 경우 윤달이 2월입니다 (윤 2월)
    // In 2023, the intercalary month is the 2nd lunar month
    std.debug.print("=== 2023년 윤달 정보 ===\n\n", .{});

    // 주어진 년도의 윤달 정보 확인
    // Check if a given year has an intercalary month
    if (klc.LunarSolarConverter.getLunarIntercalaryMonth(2023)) |intercalary_month| {
        std.debug.print("2023년에는 {d}월의 윤달이 있습니다.\n", .{intercalary_month});
        std.debug.print("(즉, 정월, 윤2월, 3월, 4월, ... 순입니다)\n\n", .{});
    } else {
        std.debug.print("2023년에는 윤달이 없습니다.\n", .{});
    }

    // 윤달 날짜 변환 예시
    // Example of converting an intercalary month date
    var converter = klc.LunarSolarConverter.new();

    // 음력 2023년 윤 2월 15일을 양력으로 변환
    // Convert lunar 2023-2(intercalary)-15 to Gregorian
    if (converter.setLunarDate(2023, 2, 15, true)) {
        const lunar_iso = try converter.getLunarIsoFormat(allocator);
        const solar_iso = try converter.getSolarIsoFormat(allocator);

        std.debug.print("음력: {s}\n", .{lunar_iso});
        std.debug.print("양력: {s}\n", .{solar_iso});
        std.debug.print("윤달 여부: {}\n", .{converter.isIntercalation()});
    }

    // 윤달이 없는 년도 확인
    // Check a year without intercalary month
    std.debug.print("\n=== 2024년 윤달 정보 ===\n\n", .{});

    if (klc.LunarSolarConverter.getLunarIntercalaryMonth(2024)) |intercalary_month| {
        std.debug.print("2024년에는 {d}월의 윤달이 있습니다.\n", .{intercalary_month});
    } else {
        std.debug.print("2024년에는 윤달이 없습니다.\n", .{});
    }
}
