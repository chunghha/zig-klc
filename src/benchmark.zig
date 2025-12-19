const std = @import("std");
const klc = @import("klc");

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const start = timer.lap();

    var converter = klc.LunarSolarConverter.new();

    // Benchmark solar to lunar conversions
    var i: u32 = 0;
    while (i < 10000) : (i += 1) {
        const year = 1900 + (i % 150); // 1900-2050 range
        const month = 1 + (i % 12);
        const day = 1 + (i % 28);
        _ = converter.setSolarDate(year, month, day);
    }

    const end = timer.read();
    const elapsed_ns = end - start;
    const elapsed_ms = @as(f64, @floatFromInt(elapsed_ns)) / 1_000_000.0;

    std.debug.print("Benchmark: 10,000 solar->lunar conversions took {:.2}ms\n", .{elapsed_ms});
    std.debug.print("Average: {:.2}μs per conversion\n", .{elapsed_ms * 1000.0 / 10000.0});
}
