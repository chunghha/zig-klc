const std = @import("std");

/// Version information
pub const VERSION = "0.1.3";
pub const DESCRIPTION = "Korean Lunar-Solar Calendar Converter (Zig port of rs-klc)";

/// Korean Lunar-Solar Calendar Converter
///
/// This module converts between Korean lunar calendar (음력) and Gregorian solar calendar (양력)
/// dates, supporting dates from 1391-01-01 (lunar) / 1391-02-05 (solar) to 2050-11-18 (lunar) / 2050-12-31 (solar).
///
/// The implementation correctly handles the Gregorian calendar reform of October 1582,
/// where dates 1582-10-05 through 1582-10-14 do not exist. Dates before 1582-10-05 use
/// the Julian calendar rules, while dates from 1582-10-15 onward use Gregorian rules.
///
/// Intercalary (leap) months (윤달) are supported and tracked via the pre-calculated
/// KOREAN_LUNAR_DATA array derived from astronomical calculations.
///
/// Gapja (간지) calculation supports the traditional sexagenary cycle (60-year cycle)
/// for years, months, and days in both Korean and Chinese character representations.
/// Represents the days of the week.
pub const DayOfWeek = enum {
    /// Monday (월요일)
    Monday,
    /// Tuesday (화요일)
    Tuesday,
    /// Wednesday (수요일)
    Wednesday,
    /// Thursday (목요일)
    Thursday,
    /// Friday (금요일)
    Friday,
    /// Saturday (토요일)
    Saturday,
    /// Sunday (일요일)
    Sunday,

    pub fn fromJdn(jdn: u32) DayOfWeek {
        return switch (jdn % 7) {
            0 => .Monday,
            1 => .Tuesday,
            2 => .Wednesday,
            3 => .Thursday,
            4 => .Friday,
            5 => .Saturday,
            6 => .Sunday,
            else => .Sunday, // fallback
        };
    }
};

/// Supported date ranges (minimum lunar date: 1391-01-01)
pub const KOREAN_LUNAR_MIN_VALUE: u32 = 13910101;
/// Supported date ranges (maximum lunar date: 2050-11-18)
pub const KOREAN_LUNAR_MAX_VALUE: u32 = 20501118;
/// Supported date ranges (minimum solar date: 1391-02-05)
pub const KOREAN_SOLAR_MIN_VALUE: u32 = 13910205;
/// Supported date ranges (maximum solar date: 2050-12-31)
pub const KOREAN_SOLAR_MAX_VALUE: u32 = 20501231;

const KOREAN_LUNAR_BASE_YEAR: i32 = 1391;
const SOLAR_LUNAR_DAY_DIFF: u32 = 35;

const LUNAR_SMALL_MONTH_DAY: u32 = 29;
const LUNAR_BIG_MONTH_DAY: u32 = 30;
const SOLAR_SMALL_YEAR_DAY: u32 = 365;
const SOLAR_BIG_YEAR_DAY: u32 = 366;

const SOLAR_DAYS: [13]u32 = [_]u32{ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 29 };

const KOREAN_CHEONGAN: [10][]const u8 = [_][]const u8{
    "갑", "을", "병", "정", "무", "기", "경", "신", "임", "계",
};

const KOREAN_GANJI: [12][]const u8 = [_][]const u8{
    "자", "축", "인", "묘", "진", "사", "오", "미", "신", "유", "술", "해",
};

const KOREAN_GAPJA_UNIT: [3][]const u8 = [_][]const u8{
    "년", "월", "일",
};

const CHINESE_CHEONGAN: [10][]const u8 = [_][]const u8{
    "甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸",
};

const CHINESE_GANJI: [12][]const u8 = [_][]const u8{
    "子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥",
};

const CHINESE_GAPJA_UNIT: [3][]const u8 = [_][]const u8{
    "年", "月", "日",
};

const INTERCALATION_STR: [2][]const u8 = [_][]const u8{
    "윤", "閏",
};

const KOREAN_LUNAR_DATA: [660]u32 = [_]u32{
    0x82c40653, 0xc301c6a9, 0x82c405aa, 0x82c60ab5, 0x830092bd, 0xc2c402b6, 0x82c60c37, 0x82fe552e,
    0x82c40c96, 0xc2c60e4b, 0x82fe3752, 0x82c60daa, 0x8301b5b4, 0xc2c6056d, 0x82c402ae, 0x83007a3d,
    0x82c40a2d, 0xc2c40d15, 0x83004d95, 0x82c40b52, 0x8300cb69, 0xc2c60ada, 0x82c6055d, 0x8301925b,
    0x82c4045b, 0xc2c40a2b, 0x83005aab, 0x82c40a95, 0x82c40b52, 0xc3001eaa, 0x82c60ab6, 0x8300c55b,
    0x82c604b7, 0xc2c40457, 0x83007537, 0x82c4052b, 0x82c40695, 0xc3014695, 0x82c405aa, 0x8300c9b5,
    0x82c60a6e, 0xc2c404ae, 0x83008a5e, 0x82c40a56, 0x82c40d2a, 0xc3006eaa, 0x82c60d55, 0x82c4056a,
    0x8301295a, 0xc2c6095e, 0x8300b4af, 0x82c4049b, 0x82c40a4d, 0xc3007d2e, 0x82c40b2a, 0x82c60b55,
    0x830045d5, 0xc2c402da, 0x82c6095b, 0x83011157, 0x82c4049b, 0xc3009a4f, 0x82c4064b, 0x82c406a9,
    0x83006aea, 0xc2c606b5, 0x82c402b6, 0x83002aae, 0x82c60937, 0xc2ffb496, 0x82c40c96, 0x82c60e4b,
    0x82fe76b2, 0xc2c60daa, 0x82c605ad, 0x8300336d, 0x82c4026e, 0xc2c4092e, 0x83002d2d, 0x82c40c95,
    0x83009d4d, 0xc2c40b4a, 0x82c60b69, 0x8301655a, 0x82c6055b, 0xc2c4025d, 0x83002a5b, 0x82c4092b,
    0x8300aa97, 0xc2c40695, 0x82c4074a, 0x83008b5a, 0x82c60ab6, 0xc2c6053b, 0x830042b7, 0x82c40257,
    0x82c4052b, 0xc3001d2b, 0x82c40695, 0x830096ad, 0x82c405aa, 0xc2c60ab5, 0x830054ed, 0x82c404ae,
    0x82c60a57, 0xc2ff344e, 0x82c40d2a, 0x8301bd94, 0x82c60d55, 0xc2c4056a, 0x8300797a, 0x82c6095d,
    0x82c404ae, 0xc3004a9b, 0x82c40a4d, 0x82c40d25, 0x83011aaa, 0xc2c60b55, 0x8300956d, 0x82c402da,
    0x82c6095b, 0xc30054b7, 0x82c40497, 0x82c40a4b, 0x83004b4b, 0xc2c406a9, 0x8300cad5, 0x82c605b5,
    0x82c402b6, 0xc300895e, 0x82c6092f, 0x82c40497, 0x82fe4696, 0xc2c40d4a, 0x8300cea5, 0x82c60d69,
    0x82c6056d, 0xc301a2b5, 0x82c4026e, 0x82c4052e, 0x83006cad, 0xc2c40c95, 0x82c40d4a, 0x83002f4a,
    0x82c60b59, 0xc300c56d, 0x82c6055b, 0x82c4025d, 0x8300793b, 0xc2c4092b, 0x82c40a95, 0x83015b15,
    0x82c406ca, 0xc2c60ad5, 0x830112b6, 0x82c604bb, 0x8300925f, 0xc2c40257, 0x82c4052b, 0x82fe6aaa,
    0x82c60e95, 0xc2c406aa, 0x83003baa, 0x82c60ab5, 0x8300b4b7, 0xc2c404ae, 0x82c60a57, 0x82fe752d,
    0x82c40d26, 0xc2c60d95, 0x830055d5, 0x82c4056a, 0x82c6096d, 0xc300255d, 0x82c404ae, 0x8300aa4f,
    0x82c40a4d, 0xc2c40d25, 0x83006d69, 0x82c60b55, 0x82c4035a, 0xc3002aba, 0x82c6095b, 0x8301c49b,
    0x82c40497, 0xc2c40a4b, 0x83008b2b, 0x82c406a5, 0x82c406d4, 0xc3034ab5, 0x82c402b6, 0x82c60937,
    0x8300252f, 0xc2c40497, 0x82fe964e, 0x82c40d4a, 0x82c60ea5, 0xc30166a9, 0x82c6056d, 0x82c402b6,
    0x8301385e, 0xc2c4092e, 0x8300bc97, 0x82c40c95, 0x82c40d4a, 0xc3008daa, 0x82c60b4d, 0x82c6056b,
    0x830042db, 0xc2c4025d, 0x82c4092d, 0x83002d33, 0x82c40a95, 0xc3009b4d, 0x82c406aa, 0x82c60ad5,
    0x83006575, 0xc2c604bb, 0x82c4025b, 0x83013457, 0x82c4052b, 0xc2ffba94, 0x82c60e95, 0x82c406aa,
    0x83008ada, 0xc2c609b5, 0x82c404b6, 0x83004aae, 0x82c60a4f, 0xc2c20526, 0x83012d26, 0x82c60d55,
    0x8301a5a9, 0xc2c4056a, 0x82c6096d, 0x8301649d, 0x82c4049e, 0xc2c40a4d, 0x83004d4d, 0x82c40d25,
    0x8300bd53, 0xc2c40b54, 0x82c60b5a, 0x8301895a, 0x82c6095b, 0xc2c4049b, 0x83004a97, 0x82c40a4b,
    0x82c40aa5, 0xc3001ea5, 0x82c406d4, 0x8302badb, 0x82c402b6, 0xc2c60937, 0x830064af, 0x82c40497,
    0x82c4064b, 0xc2fe374a, 0x82c60da5, 0x8300b6b5, 0x82c6056d, 0xc2c402ba, 0x8300793e, 0x82c4092e,
    0x82c40c96, 0xc3015d15, 0x82c40d4a, 0x82c60da5, 0x83013555, 0xc2c4056a, 0x83007a7a, 0x82c60a5d,
    0x82c4092d, 0xc3006aab, 0x82c40a95, 0x82c40b4a, 0x83004baa, 0xc2c60ad5, 0x82c4055a, 0x830128ba,
    0x82c60a5b, 0xc3007537, 0x82c4052b, 0x82c40a95, 0x83015715, 0xc2c406aa, 0x82c60ad9, 0x830035b5,
    0x82c404b6, 0xc3008a5e, 0x82c40a4e, 0x82c40d26, 0x83006ea6, 0xc2c40d52, 0x82c60daa, 0x8301466a,
    0x82c6056d, 0xc2c404ae, 0x83003a9d, 0x82c40a4d, 0x83007d2b, 0xc2c40b25, 0x82c40d52, 0x83015d54,
    0x82c60b5a, 0xc2c6055d, 0x8300355b, 0x82c4049d, 0x83007657, 0x82c40a4b, 0x82c40aa5, 0x83006b65,
    0x82c406d2, 0xc2c60ada, 0x830045b6, 0x82c60937, 0x82c40497, 0xc3003697, 0x82c40a4d, 0x82fe76aa,
    0x82c60da5, 0xc2c405aa, 0x83005aec, 0x82c60aae, 0x82c4092e, 0xc3003d2e, 0x82c40c96, 0x83018d45,
    0x82c40d4a, 0xc2c60d55, 0x83016595, 0x82c4056a, 0x82c60a6d, 0xc300455d, 0x82c4052d, 0x82c40a95,
    0x83003e95, 0xc2c40b4a, 0x83017b4a, 0x82c609d5, 0x82c4055a, 0xc3015a3a, 0x82c60a5b, 0x82c4052b,
    0x83014a17, 0xc2c40693, 0x830096ab, 0x82c406aa, 0x82c60ab5, 0xc30064f5, 0x82c404b6, 0x82c60a57,
    0x82fe452e, 0xc2c40d16, 0x82c60e93, 0x82fe3752, 0x82c60daa, 0xc30175aa, 0x82c6056d, 0x82c404ae,
    0x83015a1b, 0xc2c40a2d, 0x82c40d15, 0x83004da5, 0x82c40b52, 0xc3009d6a, 0x82c60ada, 0x82c6055d,
    0x8301629b, 0xc2c4045b, 0x82c40a2b, 0x83005b2b, 0x82c40a95, 0xc2c40b52, 0x83012ab2, 0x82c60ad6,
    0x83017556, 0xc2c60537, 0x82c40457, 0x83005657, 0x82c4052b, 0xc2c40695, 0x83003795, 0x82c405aa,
    0x8300aab6, 0xc2c60a6d, 0x82c404ae, 0x8300696e, 0x82c40a56, 0xc2c40d2a, 0x83005eaa, 0x82c60d55,
    0x82c405aa, 0xc3003b6a, 0x82c60a6d, 0x830074bd, 0x82c404ab, 0xc2c40a8d, 0x83005d55, 0x82c40b2a,
    0x82c60b55, 0xc30045d5, 0x82c404da, 0x82c6095d, 0x83002557, 0xc2c4049b, 0x83006a97, 0x82c4064b,
    0x82c406a9, 0x83004baa, 0x82c606b5, 0x82c402ba, 0x83002ab6, 0xc2c60937, 0x82fe652e, 0x82c40d16,
    0x82c60e4b, 0xc2fe56d2, 0x82c60da9, 0x82c605b5, 0x8300336d, 0xc2c402ae, 0x82c40a2e, 0x83002e2d,
    0x82c40c95, 0xc3006d55, 0x82c40b52, 0x82c60b69, 0x830045da, 0xc2c6055b, 0x82c4025d, 0x83003a5b,
    0x82c4092b, 0xc3017a8b, 0x82c40a95, 0x82c40b4a, 0x83015b2a, 0xc2c60ad5, 0x82c6055b, 0x830042b7,
    0x82c40257, 0xc300952f, 0x82c4052b, 0x82c40695, 0x830066d5, 0xc2c405aa, 0x82c60ab5, 0x8300456d,
    0x82c404ae, 0xc2c60a57, 0x82ff3456, 0x82c40d2a, 0x83017e8a, 0xc2c60d55, 0x82c405aa, 0x83005ada,
    0x82c6095d, 0xc2c404ae, 0x83004aab, 0x82c40a4d, 0x83008d2b, 0xc2c40b29, 0x82c60b55, 0x83007575,
    0x82c402da, 0xc2c6095d, 0x830054d7, 0x82c4049b, 0x82c40a4b, 0xc3013a4b, 0x82c406a9, 0x83008ad9,
    0x82c606b5, 0xc2c402b6, 0x83015936, 0x82c60937, 0x82c40497, 0xc2fe4696, 0x82c40e4a, 0x8300aea6,
    0x82c60da9, 0xc2c605ad, 0x830162ad, 0x82c402ae, 0x82c4092e, 0xc3005cad, 0x82c40c95, 0x82c40d4a,
    0x83013d4a, 0xc2c60b69, 0x8300757a, 0x82c6055b, 0x82c4025d, 0xc300595b, 0x82c4092b, 0x82c40a95,
    0x83004d95, 0xc2c40b4a, 0x82c60b55, 0x830026d5, 0x82c6055b, 0xc3006277, 0x82c40257, 0x82c4052b,
    0x82fe5aaa, 0xc2c60e95, 0x82c406aa, 0x83003baa, 0x82c60ab5, 0x830084bd, 0x82c404ae, 0x82c60a57,
    0x82fe554d, 0xc2c40d26, 0x82c60d95, 0x83014655, 0x82c4056a, 0xc2c609ad, 0x8300255d, 0x82c404ae,
    0x83006a5b, 0xc2c40a4d, 0x82c40d25, 0x83005da9, 0x82c60b55, 0xc2c4056a, 0x83002ada, 0x82c6095d,
    0x830074bb, 0xc2c4049b, 0x82c40a4b, 0x83005b4b, 0x82c406a9, 0xc2c40ad4, 0x83024bb5, 0x82c402b6,
    0x82c6095b, 0xc3002537, 0x82c40497, 0x82fe6656, 0x82c40e4a, 0xc2c60ea5, 0x830156a9, 0x82c605b5,
    0x82c402b6, 0xc30138ae, 0x82c4092e, 0x83017c8d, 0x82c40c95, 0xc2c40d4a, 0x83016d8a, 0x82c60b69,
    0x82c6056d, 0xc301425b, 0x82c4025d, 0x82c4092d, 0x83002d2b, 0xc2c40a95, 0x83007d55, 0x82c40b4a,
    0x82c60b55, 0xc3015555, 0x82c604db, 0x82c4025b, 0x83013857, 0xc2c4052b, 0x83008a9b, 0x82c40695,
    0x82c406aa, 0xc3006aea, 0x82c60ab5, 0x82c404b6, 0x83004aae, 0xc2c60a57, 0x82c40527, 0x82fe3726,
    0x82c60d95, 0xc30076b5, 0x82c4056a, 0x82c609ad, 0x830054dd, 0xc2c404ae, 0x82c40a4e, 0x83004d4d,
    0x82c40d25, 0xc3008d59, 0x82c40b54, 0x82c60d6a, 0x8301695a, 0xc2c6095b, 0x82c4049b, 0x83004a9b,
    0x82c40a4b, 0xc300ab27, 0x82c406a5, 0x82c406d4, 0x83026b75, 0xc2c402b6, 0x82c6095b, 0x830054b7,
    0x82c40497, 0xc2c4064b, 0x82fe374a, 0x82c60ea5, 0x830086d9, 0xc2c605ad, 0x82c402b6, 0x8300596e,
    0x82c4092e, 0xc2c40c96, 0x83004e95, 0x82c40d4a, 0x82c60da5, 0xc3002755, 0x82c4056c, 0x83027abb,
    0x82c4025d, 0xc2c4092d, 0x83005cab, 0x82c40a95, 0x82c40b4a, 0xc3013b4a, 0x82c60b55, 0x8300955d,
    0x82c404ba, 0xc2c60a5b, 0x83005557, 0x82c4052b, 0x82c40a95, 0xc3004b95, 0x82c406aa, 0x82c60ad5,
    0x830026b5, 0xc2c404b6, 0x83006a6e, 0x82c60a57, 0x82c40527, 0xc2fe56a6, 0x82c60d93, 0x82c405aa,
    0x83003b6a, 0xc2c6096d, 0x8300b4af, 0x82c404ae, 0x82c40a4d, 0xc3016d0d, 0x82c40d25, 0x82c40d52,
    0x83005dd4, 0xc2c60b6a, 0x82c6096d, 0x8300255b, 0x82c4049b, 0xc3007a57, 0x82c40a4b, 0x82c40b25,
    0x83015b25, 0xc2c406d4, 0x82c60ada, 0x830138b6,
};

/// Korean Lunar-Solar Calendar Converter
pub const LunarSolarConverter = struct {
    lunar_year: i32,
    lunar_month: u32,
    lunar_day: u32,
    is_intercalation: bool,
    solar_year: u32,
    solar_month: u32,
    solar_day: u32,
    gapja_year_inx: [3]?usize,
    gapja_month_inx: [3]?usize,
    gapja_day_inx: [3]?usize,

    /// Creates a new, default `LunarSolarConverter` instance.
    pub fn new() LunarSolarConverter {
        return LunarSolarConverter{
            .lunar_year = 0,
            .lunar_month = 0,
            .lunar_day = 0,
            .is_intercalation = false,
            .solar_year = 0,
            .solar_month = 0,
            .solar_day = 0,
            .gapja_year_inx = [_]?usize{ null, null, null },
            .gapja_month_inx = [_]?usize{ null, null, null },
            .gapja_day_inx = [_]?usize{ null, null, null },
        };
    }

    fn getLunarData(year: i32) u32 {
        if (year < KOREAN_LUNAR_BASE_YEAR) {
            return 0;
        }
        const index = @as(usize, @intCast(year - KOREAN_LUNAR_BASE_YEAR));
        if (index >= KOREAN_LUNAR_DATA.len) {
            return 0;
        }
        return KOREAN_LUNAR_DATA[index];
    }

    fn getLunarIntercalationMonth(lunarData: u32) u32 {
        return (lunarData >> 12) & 0x000F;
    }

    fn shiftLunarDays(year: i32) u32 {
        const lunarData = getLunarData(year);
        if (lunarData == 0) {
            return 0;
        }
        return (lunarData >> 17) & 0x01ff;
    }

    /// Returns true if the given lunar month (1-12) is a 30-day month in the given year.
    fn isLunarMonthBig(year: i32, month: u32) bool {
        const lunarData = getLunarData(year);
        if (month > 0 and month < 13) {
            const bitPos = 12 - month;
            return ((lunarData >> @as(u5, @intCast(bitPos))) & 0x01) != 0;
        }
        return false;
    }

    /// Returns true if the intercalary month is a 30-day month in the given year.
    fn isIntercalaryMonthBig(lunarData: u32) bool {
        return ((lunarData >> 16) & 0x01) != 0;
    }

    fn getLunarDays(year: i32, month: u32, is_intercalation_param: bool) u32 {
        const lunarData = getLunarData(year);
        const intercalationMonth = getLunarIntercalationMonth(lunarData);

        if (is_intercalation_param and intercalationMonth == month) {
            return if (isIntercalaryMonthBig(lunarData)) LUNAR_BIG_MONTH_DAY else LUNAR_SMALL_MONTH_DAY;
        } else if (month > 0 and month < 13) {
            return if (isLunarMonthBig(year, month)) LUNAR_BIG_MONTH_DAY else LUNAR_SMALL_MONTH_DAY;
        }

        return 0;
    }

    fn getLunarDaysBeforeBaseYear(year: i32) u32 {
        var days: u32 = 0;
        var baseYear = KOREAN_LUNAR_BASE_YEAR;
        while (baseYear < year) : (baseYear += 1) {
            days += shiftLunarDays(baseYear);
        }
        return days;
    }

    fn getLunarDaysBeforeBaseMonth(year: i32, month: u32, is_intercalation_param: bool) u32 {
        var days: u32 = 0;
        if (year < KOREAN_LUNAR_BASE_YEAR or month == 0) {
            return 0;
        }

        const lunarData = getLunarData(year);
        const intercalationMonth = getLunarIntercalationMonth(lunarData);

        var baseMonth: u32 = 1;
        while (baseMonth < month) : (baseMonth += 1) {
            days += getLunarDays(year, baseMonth, false);
            if (intercalationMonth > 0 and intercalationMonth == baseMonth) {
                days += getLunarDays(year, intercalationMonth, true);
            }
        }

        if (is_intercalation_param and intercalationMonth == month) {
            days += getLunarDays(year, intercalationMonth, true);
        }

        return days;
    }

    fn getLunarAbsDays(year: i32, month: u32, day: u32, is_intercalation_param: bool) u32 {
        if (year < KOREAN_LUNAR_BASE_YEAR) {
            return 0;
        }
        return getLunarDaysBeforeBaseYear(year) +
            getLunarDaysBeforeBaseMonth(year, month, is_intercalation_param) +
            day;
    }

    fn isGregorianLeap(year: i32) bool {
        if (year <= 1582) {
            // Before Gregorian reform, Julian calendar used
            return @mod(year, 4) == 0;
        } else {
            // Gregorian calendar rules
            return (@mod(year, 4) == 0 and @mod(year, 100) != 0) or (@mod(year, 400) == 0);
        }
    }

    fn shiftSolarDays(year: i32) u32 {
        var days: u32 = if (isGregorianLeap(year)) SOLAR_BIG_YEAR_DAY else SOLAR_SMALL_YEAR_DAY;
        if (year == 1582) {
            days -= 10;
        }
        return days;
    }

    fn getSolarDays(year: i32, month: u32) u32 {
        if (month == 2 and isGregorianLeap(year)) {
            return SOLAR_DAYS[12]; // 29 days
        } else if (month > 0 and month < 13) {
            return SOLAR_DAYS[month - 1];
        }
        return 0;
    }

    fn getSolarDayBeforeBaseYear(year: i32) u32 {
        var days: u32 = 0;
        var baseYear = KOREAN_LUNAR_BASE_YEAR;
        while (baseYear < year) : (baseYear += 1) {
            days += shiftSolarDays(baseYear);
        }
        return days;
    }

    fn getSolarDaysBeforeBaseMonth(year: i32, month: u32) u32 {
        var days: u32 = 0;
        var baseMonth: u32 = 1;
        while (baseMonth < month) : (baseMonth += 1) {
            days += getSolarDays(year, baseMonth);
        }
        return days;
    }

    fn getSolarAbsDays(year: i32, month: u32, day: u32) u32 {
        if (year < KOREAN_LUNAR_BASE_YEAR) {
            return 0;
        }
        var days = getSolarDayBeforeBaseYear(year) +
            getSolarDaysBeforeBaseMonth(year, month) +
            day;
        days -= SOLAR_LUNAR_DAY_DIFF;
        return days;
    }

    /// Sets the converter's date based on a Lunar date.
    ///
    /// Arguments:
    /// - lunar_year: The lunar year.
    /// - lunar_month: The lunar month (1-12).
    /// - lunar_day: The lunar day.
    /// - is_intercalation: true if the month is an intercalary (leap) month.
    ///
    /// Returns true if the provided lunar date is valid and within the supported range,
    /// false otherwise. If true, the corresponding solar date is calculated and stored.
    pub fn setLunarDate(self: *LunarSolarConverter, lunar_year: i32, lunar_month: u32, lunar_day: u32, is_intercalation: bool) bool {
        var isValid = false;

        if (checkValidDate(true, is_intercalation, @as(u32, @intCast(lunar_year)), lunar_month, lunar_day)) {
            self.is_intercalation = is_intercalation and
                (getLunarIntercalationMonth(getLunarData(lunar_year)) == lunar_month);
            self.setSolarDateByLunarDate(lunar_year, lunar_month, lunar_day, self.is_intercalation);
            isValid = true;
        }

        return isValid;
    }

    /// Sets the converter's date based on a Solar (Gregorian) date.
    ///
    /// Arguments:
    /// - solar_year: The solar year.
    /// - solar_month: The solar month (1-12).
    /// - solar_day: The solar day.
    ///
    /// Returns true if the provided solar date is valid and within the supported range
    /// (handles the 1582 Gregorian reform gap), false otherwise. If true,
    /// the corresponding lunar date is calculated and stored.
    pub fn setSolarDate(self: *LunarSolarConverter, solar_year: u32, solar_month: u32, solar_day: u32) bool {
        var isValid = false;

        if (checkValidDate(false, false, solar_year, solar_month, solar_day)) {
            self.solar_year = solar_year;
            self.solar_month = solar_month;
            self.solar_day = solar_day;
            self.setLunarDateBySolarDate(solar_year, solar_month, solar_day);
            isValid = true;
        }

        return isValid;
    }

    fn setSolarDateByLunarDate(self: *LunarSolarConverter, lunar_year: i32, lunar_month: u32, lunar_day: u32, is_intercalation_param: bool) void {
        const absDays = getLunarAbsDays(lunar_year, lunar_month, lunar_day, is_intercalation_param);

        if (absDays < getSolarAbsDays(lunar_year + 1, 1, 1)) {
            self.solar_year = @as(u32, @intCast(lunar_year));
        } else {
            self.solar_year = @as(u32, @intCast(lunar_year + 1));
        }

        self.solar_month = 12;
        while (self.solar_month > 0) : (self.solar_month -= 1) {
            const absDaysByMonth = getSolarAbsDays(@as(i32, @intCast(self.solar_year)), self.solar_month, 1);
            if (absDays >= absDaysByMonth) {
                self.solar_day = absDays - absDaysByMonth + 1;
                break;
            }
        }

        if (self.solar_year == 1582 and self.solar_month == 10 and self.solar_day > 4) {
            self.solar_day += 10;
        }
    }

    fn setLunarDateBySolarDate(self: *LunarSolarConverter, solar_year: u32, solar_month: u32, solar_day: u32) void {
        const absDays = getSolarAbsDays(@as(i32, @intCast(solar_year)), solar_month, solar_day);

        self.is_intercalation = false;

        if (absDays >= getLunarAbsDays(@as(i32, @intCast(solar_year)), 1, 1, false)) {
            self.lunar_year = @as(i32, @intCast(solar_year));
        } else {
            self.lunar_year = @as(i32, @intCast(solar_year - 1));
        }

        self.lunar_month = 12;
        while (self.lunar_month > 0) : (self.lunar_month -= 1) {
            const absDaysByMonth = getLunarAbsDays(self.lunar_year, self.lunar_month, 1, false);

            if (absDays >= absDaysByMonth) {
                if (getLunarIntercalationMonth(getLunarData(self.lunar_year)) == self.lunar_month) {
                    self.is_intercalation = absDays >= getLunarAbsDays(self.lunar_year, self.lunar_month, 1, true);
                }

                self.lunar_day = absDays - getLunarAbsDays(self.lunar_year, self.lunar_month, 1, self.is_intercalation) + 1;
                break;
            }
        }
    }

    fn checkValidDate(isLunar: bool, is_intercalation_param: bool, year: u32, month: u32, day: u32) bool {
        var isValid = false;
        const dateValue = year * 10000 + month * 100 + day;

        // 1582. 10. 5 ~ 1582. 10. 14 is not enabled
        if ((isLunar and KOREAN_LUNAR_MIN_VALUE <= dateValue and KOREAN_LUNAR_MAX_VALUE >= dateValue) or
            (!isLunar and KOREAN_SOLAR_MIN_VALUE <= dateValue and KOREAN_SOLAR_MAX_VALUE >= dateValue))
        {
            var dayLimit: u32 = 0;

            if (month > 0 and month < 13 and day > 0) {
                if (isLunar) {
                    if (is_intercalation_param and getLunarIntercalationMonth(getLunarData(@as(i32, @intCast(year)))) != month) {
                        return false;
                    }
                    dayLimit = getLunarDays(@as(i32, @intCast(year)), month, is_intercalation_param);
                } else {
                    dayLimit = getSolarDays(@as(i32, @intCast(year)), month);
                }

                if (!isLunar and year == 1582 and month == 10) {
                    if (day > 4 and day < 15) {
                        return false;
                    } else {
                        dayLimit += 10;
                    }
                }

                if (day <= dayLimit) {
                    isValid = true;
                }
            }
        }

        return isValid;
    }

    /// Checks if all gapja indices (year, month, day) have been calculated and are valid.
    fn areGapjaIndicesValid(self: LunarSolarConverter) bool {
        return self.gapja_year_inx[0] != null and self.gapja_year_inx[1] != null and
            self.gapja_month_inx[0] != null and self.gapja_month_inx[1] != null and
            self.gapja_day_inx[0] != null and self.gapja_day_inx[1] != null;
    }

    /// Calculates gapja indices using the sexagenary cycle (60-year cycle).
    ///
    /// Gapja (간지) represents a date using two components:
    /// - Cheongan (천간): 10-element cycle (甲乙丙丁戊己庚辛壬癸)
    /// - Ganji (지지): 12-element cycle (子丑寅卯辰巳午未申酉戌亥)
    /// These combine to form a 60-year (10*12) cycle.
    ///
    /// Year gapja: offset by +7 from base year (astronomical convention)
    /// Month gapja: offset by +5 for Cheongan, +1 for Ganji
    /// Day gapja: offset by +4 for Cheongan, +0 for Ganji
    fn getGapja(self: *LunarSolarConverter) void {
        const absDays = getLunarAbsDays(self.lunar_year, self.lunar_month, self.lunar_day, self.is_intercalation);

        if (absDays > 0) {
            const yearOffset = @as(usize, @intCast((self.lunar_year + 7) - KOREAN_LUNAR_BASE_YEAR));
            self.gapja_year_inx[0] = yearOffset % KOREAN_CHEONGAN.len;
            self.gapja_year_inx[1] = yearOffset % KOREAN_GANJI.len;

            var monthCount = self.lunar_month;
            monthCount += 12 * @as(u32, @intCast(self.lunar_year - KOREAN_LUNAR_BASE_YEAR));
            self.gapja_month_inx[0] = @as(usize, @intCast((monthCount + 5) % @as(u32, @intCast(KOREAN_CHEONGAN.len))));
            self.gapja_month_inx[1] = @as(usize, @intCast((monthCount + 1) % @as(u32, @intCast(KOREAN_GANJI.len))));

            self.gapja_day_inx[0] = @as(usize, @intCast((absDays + 4) % @as(u32, @intCast(KOREAN_CHEONGAN.len))));
            self.gapja_day_inx[1] = @as(usize, @intCast(absDays % @as(u32, @intCast(KOREAN_GANJI.len))));
        } else {
            self.gapja_year_inx = [_]?usize{ null, null, null };
            self.gapja_month_inx = [_]?usize{ null, null, null };
            self.gapja_day_inx = [_]?usize{ null, null, null };
        }
    }

    /// Returns the calculated Korean Gapja (간지) string for the current date.
    /// Format: "[Year]년 [Month]월 [Day]일" (e.g., "임인년 정미월 갑자일").
    /// Appends " (윤월)" if the current lunar month is intercalary.
    /// Returns an empty string if the date is invalid.
    pub fn getGapjaString(self: *LunarSolarConverter, allocator: std.mem.Allocator) ![]u8 {
        self.getGapja();

        if (!self.areGapjaIndicesValid()) {
            return try allocator.dupe(u8, "");
        }

        var result: std.ArrayList(u8) = .empty;
        defer result.deinit(allocator);

        try result.appendSlice(allocator, KOREAN_CHEONGAN[self.gapja_year_inx[0].?]);
        try result.appendSlice(allocator, KOREAN_GANJI[self.gapja_year_inx[1].?]);
        try result.appendSlice(allocator, KOREAN_GAPJA_UNIT[0]);

        try result.append(allocator, ' ');

        try result.appendSlice(allocator, KOREAN_CHEONGAN[self.gapja_month_inx[0].?]);
        try result.appendSlice(allocator, KOREAN_GANJI[self.gapja_month_inx[1].?]);
        try result.appendSlice(allocator, KOREAN_GAPJA_UNIT[1]);

        try result.append(allocator, ' ');

        try result.appendSlice(allocator, KOREAN_CHEONGAN[self.gapja_day_inx[0].?]);
        try result.appendSlice(allocator, KOREAN_GANJI[self.gapja_day_inx[1].?]);
        try result.appendSlice(allocator, KOREAN_GAPJA_UNIT[2]);

        if (self.is_intercalation) {
            try result.appendSlice(allocator, " (");
            try result.appendSlice(allocator, INTERCALATION_STR[0]);
            try result.appendSlice(allocator, KOREAN_GAPJA_UNIT[1]);
            try result.append(allocator, ')');
        }

        return result.toOwnedSlice(allocator);
    }

    /// Returns the calculated Chinese Gapja string for the current date.
    /// Format: "[Year]年 [Month]月 [Day]日" (e.g., "壬寅年 丁未月 甲子日").
    /// Appends " (閏月)" if the current lunar month is intercalary.
    /// Returns an empty string if the date is invalid.
    pub fn getChineseGapjaString(self: *LunarSolarConverter, allocator: std.mem.Allocator) ![]u8 {
        self.getGapja();

        if (!self.areGapjaIndicesValid()) {
            return try allocator.dupe(u8, "");
        }

        var result: std.ArrayList(u8) = .empty;
        defer result.deinit(allocator);

        try result.appendSlice(allocator, CHINESE_CHEONGAN[self.gapja_year_inx[0].?]);
        try result.appendSlice(allocator, CHINESE_GANJI[self.gapja_year_inx[1].?]);
        try result.appendSlice(allocator, CHINESE_GAPJA_UNIT[0]);

        try result.append(allocator, ' ');

        try result.appendSlice(allocator, CHINESE_CHEONGAN[self.gapja_month_inx[0].?]);
        try result.appendSlice(allocator, CHINESE_GANJI[self.gapja_month_inx[1].?]);
        try result.appendSlice(allocator, CHINESE_GAPJA_UNIT[1]);

        try result.append(allocator, ' ');

        try result.appendSlice(allocator, CHINESE_CHEONGAN[self.gapja_day_inx[0].?]);
        try result.appendSlice(allocator, CHINESE_GANJI[self.gapja_day_inx[1].?]);
        try result.appendSlice(allocator, CHINESE_GAPJA_UNIT[2]);

        if (self.is_intercalation) {
            try result.appendSlice(allocator, " (");
            try result.appendSlice(allocator, INTERCALATION_STR[1]);
            try result.appendSlice(allocator, CHINESE_GAPJA_UNIT[1]);
            try result.append(allocator, ')');
        }

        return result.toOwnedSlice(allocator);
    }

    /// Returns the calculated Lunar date in ISO 8601 format (YYYY-MM-DD).
    /// Appends " Intercalation" if the current lunar month is intercalary.
    pub fn getLunarIsoFormat(self: LunarSolarConverter, allocator: std.mem.Allocator) ![]u8 {
        const intercalation_str = if (self.is_intercalation) " Intercalation" else "";
        return try std.fmt.allocPrint(allocator, "{d:0>4}-{d:0>2}-{d:0>2}{s}", .{
            @as(u32, @intCast(self.lunar_year)),
            self.lunar_month,
            self.lunar_day,
            intercalation_str,
        });
    }

    /// Returns the calculated Solar date in ISO 8601 format (YYYY-MM-DD).
    pub fn getSolarIsoFormat(self: LunarSolarConverter, allocator: std.mem.Allocator) ![]u8 {
        return try std.fmt.allocPrint(allocator, "{d:0>4}-{d:0>2}-{d:0>2}", .{
            self.solar_year,
            self.solar_month,
            self.solar_day,
        });
    }

    /// Calculates the Julian Day Number (JDN) for a given Solar date.
    ///
    /// The JDN is the integer number of days elapsed since noon UTC on January 1, 4713 BC (Julian calendar).
    /// This implementation uses the algorithm described on Wikipedia and other sources,
    /// correctly handling the transition from the Julian to the Gregorian calendar in October 1582.
    ///
    /// The algorithm adjusts the month and year before calculation: January and February are
    /// treated as months 13 and 14 of the previous year. This simplifies the leap year calculations.
    ///
    /// Arguments:
    /// - year: The solar year.
    /// - month: The solar month (1-12).
    /// - day: The solar day.
    ///
    /// Returns the JDN if the date is valid, or null if the date
    /// is invalid (e.g., within the 1582 Gregorian reform gap from Oct 5 to Oct 14).
    pub fn getJulianDayNumber(year: u32, month: u32, day: u32) ?u32 {
        // Check for invalid date in the Gregorian reform gap
        if (year == 1582 and month == 10 and day > 4 and day < 15) {
            return null;
        }
        // Basic month/day validation (simplified, primarily for algorithm safety)
        if (month == 0 or month > 12 or day == 0 or day > 31) {
            return null;
        }

        // Use i32 for calculations
        const y = @as(i32, @intCast(year));
        const m = @as(i32, @intCast(month));
        const d = @as(i32, @intCast(day));

        // Adjust month/year for Jan/Feb for calculation
        const adj_y = if (m <= 2) y - 1 else y;
        const adj_m = if (m <= 2) m + 12 else m;

        // Calculate base Julian part using integer arithmetic
        const julian_base = @divFloor(1461 * (adj_y + 4716), 4) + @divFloor(153 * (adj_m + 1), 5) + d;

        // Determine Gregorian correction term 'b'
        const b: i32 = if (y > 1582 or (y == 1582 and m > 10) or (y == 1582 and m == 10 and d >= 15)) blk: {
            // Apply correction only for Gregorian dates (starting from 1582-10-15)
            const term1 = @divFloor(adj_y, 100); // Note: Use adj_y here consistent with algorithm derivations
            break :blk 2 - term1 + @divFloor(term1, 4);
        } else 0; // No correction for Julian dates (up to 1582-10-04)

        // Combine base, correction, and standard offset (-1524)
        const jdn = julian_base + b - 1524;

        return @as(u32, @intCast(jdn));
    }

    /// Calculates the day of the week for a given Solar date.
    ///
    /// Uses the Julian Day Number calculation internally.
    ///
    /// Arguments:
    /// - year: The solar year.
    /// - month: The solar month (1-12).
    /// - day: The solar day.
    ///
    /// Returns the day of the week if the date is valid, or null if the date is invalid.
    pub fn getDayOfWeek(year: u32, month: u32, day: u32) ?DayOfWeek {
        const jdn = getJulianDayNumber(year, month, day) orelse return null;
        return DayOfWeek.fromJdn(jdn);
    }

    /// Checks if a given solar year is a leap year according to the Gregorian calendar rules.
    ///
    /// For years before or during 1582, the Julian calendar rule (divisible by 4) is used.
    /// For years after 1582, the Gregorian rules apply: divisible by 4, unless divisible by 100 but not by 400.
    ///
    /// Arguments:
    /// - year: The solar year.
    ///
    /// Returns true if the year is a leap year, false otherwise.
    pub fn isSolarLeapYear(year: u32) bool {
        return isGregorianLeap(@as(i32, @intCast(year)));
    }

    /// Gets the intercalary (leap) month (윤달) for a given lunar year, if one exists.
    ///
    /// Based on the pre-calculated KOREAN_LUNAR_DATA.
    ///
    /// Arguments:
    /// - year: The lunar year.
    ///
    /// Returns the intercalary month number (1-12) if the year has one, or null if not.
    pub fn getLunarIntercalaryMonth(year: i32) ?u32 {
        if (year < KOREAN_LUNAR_BASE_YEAR or
            year > KOREAN_LUNAR_BASE_YEAR + @as(i32, @intCast(KOREAN_LUNAR_DATA.len - 1)))
        {
            return null; // Year out of supported range
        }
        const lunarData = getLunarData(year);
        const intercalaryMonth = getLunarIntercalationMonth(lunarData);
        return if (intercalaryMonth > 0) intercalaryMonth else null;
    }

    // Getters for date fields
    pub fn lunarYear(self: LunarSolarConverter) i32 {
        return self.lunar_year;
    }
    pub fn lunarMonth(self: LunarSolarConverter) u32 {
        return self.lunar_month;
    }
    pub fn lunarDay(self: LunarSolarConverter) u32 {
        return self.lunar_day;
    }
    pub fn isIntercalation(self: LunarSolarConverter) bool {
        return self.is_intercalation;
    }
    pub fn solarYear(self: LunarSolarConverter) u32 {
        return self.solar_year;
    }
    pub fn solarMonth(self: LunarSolarConverter) u32 {
        return self.solar_month;
    }
    pub fn solarDay(self: LunarSolarConverter) u32 {
        return self.solar_day;
    }
};
