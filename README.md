# Korean Lunar-Solar Calendar Library (Zig)

[![Zig](https://img.shields.io/badge/Zig-0.13+-blue.svg)](https://ziglang.org/)

This is a **Zig port** of the [rs-klc](https://crates.io/crates/rs-klc) Rust crate, providing accurate Korean Lunar-Solar calendar conversions.

한국 양음력 변환을 위한 Zig 라이브러리로, Rust의 rs-klc 크레이트를 Zig로 포팅한 것입니다.

## Features

- **Accurate conversions**: Between Gregorian (Solar) and Korean Lunar calendars
- **Gapja (Sexagenary cycle)**: Traditional Korean/Chinese date representation
- **Julian Day Numbers**: Astronomical date calculations
- **Leap year/month handling**: Proper intercalary month detection
- **Day of week calculation**: Based on Julian Day Number
- **Memory safe**: Leveraging Zig's compile-time safety
- **KASI verified**: Algorithms validated against Korea Astronomy and Space Science Institute

## Examples

Examples demonstrating how to use the Korean Lunar-Solar Calendar Conversion library.

## 예제 목록 (Example List)

### 01_basic_conversion.zig
**기본 양력-음력 변환**

가장 간단한 사용 예제입니다. 양력 날짜를 음력으로 변환하는 방법을 보여줍니다.

```zig
var converter = klc.LunarSolarConverter.new();
if (converter.setSolarDate(2022, 7, 10)) {
    // 음력 정보 사용
}
```

---

### 02_lunar_to_solar.zig
**음력-양력 역변환**

음력 날짜를 양력 날짜로 변환하는 방법을 보여줍니다. 
특히 한국 설날(정월 초하루)과 같은 음력 날짜 변환에 유용합니다.

```zig
if (converter.setLunarDate(2024, 1, 1, false)) {
    // 양력 정보 사용
}
```

---

### 03_intercalary_month.zig
**윤달(Leap Month) 처리**

음력에서 약 19년마다 나타나는 윤달(윤월)을 감지하고 처리하는 방법을 보여줍니다.

- 2023년: 윤 2월
- 주어진 연도의 윤달 월 확인
- 윤달 날짜의 정확한 변환

```zig
if (let intercalary = klc.LunarSolarConverter.getLunarIntercalaryMonth(2023)) {
    std.debug.print("2023년 윤달: {d}월", intercalary);
}
```

---

### 04_gapja_sexagenary.zig
**간지(Gapja) - 육십간지 순환**

전통적인 동양 날짜 체계인 간지를 계산하는 방법을 보여줍니다.

- 천간(Cheongan): 10개 순환
- 지지(Ganji): 12개 순환
- 조합: 60년 주기
- 한글 및 중문 표현

```zig
const korean_gapja = try converter.getGapjaString(allocator);
const chinese_gapja = try converter.getChineseGapjaString(allocator);
```

예: 임인년 정미월 갑자일 (壬寅年 丁未月 甲子日)

---

### 05_julian_day_number.zig
**율리우스 적일(Julian Day Number) 계산**

천문학적 날짜 표현인 율리우스 적일(JDN)을 계산하는 방법을 보여줍니다.

- 기원전 4713년부터의 경과 일수
- 서로 다른 역법 간의 변환 기준
- 그레고리력 개정(1582년 10월 5-14일) 처리

```zig
if (let jdn = klc.LunarSolarConverter.getJulianDayNumber(2022, 7, 10)) {
    std.debug.print("JDN: {d}", jdn);
}
```

---

### 06_leap_year.zig
**윤년(Leap Year) 계산**

양력(그레고리력)의 윤년 판정 규칙을 보여줍니다.

윤년 규칙:
- 4로 나누어떨어지는 해 → 윤년
- 100으로 나누어떨어지는 해 → 평년
- 400으로 나누어떨어지는 해 → 윤년

예: 2000년(윤년), 1900년(평년), 2024년(윤년)

```zig
const is_leap = klc.LunarSolarConverter.isSolarLeapYear(2024);
```

---

### 07_day_of_week.zig
**요일(Day of Week) 계산**

주어진 양력 날짜의 요일을 계산하는 방법을 보여줍니다.

- 월요일 ~ 일요일
- 율리우스 적일 기반 계산
- 특정 날짜의 요일 패턴

```zig
if (let dow = klc.LunarSolarConverter.getDayOfWeek(2024, 2, 10)) {
    std.debug.print("요일: {s}", @tagName(dow));
}
```

---

### 08_comprehensive_example.zig
**종합 예제 - 모든 기능 활용**

라이브러리의 모든 주요 기능을 한 번에 보여주는 종합 예제입니다.

특정 날짜(2024년 2월 10일)에 대해:
1. 기본 정보 (양력/음력)
2. 요일 정보
3. 간지 정보 (한글/중문)
4. 율리우스 적일
5. 윤년 정보
6. 윤달 정보
7. 지원 범위

---

## 실행 방법 (How to Run)

### 개별 예제 실행

```bash
# 예제 1 실행
zig build-exe examples/01_basic_conversion.zig -Mklc=src/root.zig

# 예제 8 실행 (종합 예제)
zig build-exe examples/08_comprehensive_example.zig -Mklc=src/root.zig
```

### Zig 프로젝트 내에서 실행

프로젝트의 `build.zig`를 수정하여 예제를 추가하면:

```bash
zig build example1
zig build example8
```

### Taskfile을 사용한 실행

프로젝트의 `Taskfile.yml`를 사용하여 편리하게 예제를 실행할 수 있습니다:

```bash
task example1
task example8
```

사용 가능한 모든 예제 태스크:
- `task example1`: 기본 양력-음력 변환
- `task example2`: 음력-양력 역변환
- `task example3`: 윤달 처리
- `task example4`: 간지 계산
- `task example5`: 율리우스 적일 계산
- `task example6`: 윤년 판정
- `task example7`: 요일 계산
- `task example8`: 종합 예제

---

## 메모리 관리 (Memory Management)

예제들은 `ArenaAllocator`를 사용하여 메모리를 관리합니다:

```zig
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
defer arena.deinit();
const allocator = arena.allocator();

// 문자열 반환 함수들에 allocator 전달
const lunar_iso = try converter.getLunarIsoFormat(allocator);
```

메모리 누수 방지를 위해 결과 문자열을 사용한 후:

```zig
defer allocator.free(lunar_iso);
```

---

## 오류 처리 (Error Handling)

날짜 설정 함수들은 유효성 검증을 수행합니다:

```zig
if (converter.setSolarDate(2022, 7, 10)) {
    // 유효한 날짜 - 계속 진행
} else {
    // 유효하지 않은 날짜 - 오류 처리
    std.debug.print("유효하지 않은 날짜입니다.\n", .{});
}
```

유효한 날짜 범위:
- 양력: 1391-02-05 ~ 2050-12-31
- 음력: 1391-01-01 ~ 2050-11-18

---

## 참고 사항 (Notes)

1. **한글 문자열**: 모든 예제에서 한글 주석과 출력을 포함합니다.
2. **KASI 검증**: 코드의 변환 로직은 한국천문연구원(KASI) 기준으로 검증되었습니다.
3. **그레고리력 개정**: 1582년 10월 5-14일은 존재하지 않습니다.
4. **메모리 안전성**: Zig의 명시적 메모리 관리로 안전한 코드 작성이 가능합니다.

---

## 관련 자료 (References)

- [Korea Astronomy and Space Science Institute (KASI) Calendar Converter](https://astro.kasi.re.kr/life/pageView/8)
- [Julian Day Number](https://en.wikipedia.org/wiki/Julian_day)
- [Gregorian Calendar](https://en.wikipedia.org/wiki/Gregorian_calendar)
- [East Asian Sexagenary Cycle (干支)](https://en.wikipedia.org/wiki/Sexagenary_cycle)

---

## 추가 도움말 (Additional Help)

각 예제 파일의 상단에는 상세한 설명이 주석으로 포함되어 있습니다.
각 파일을 열어서 한글 설명을 읽으면 더 자세한 이해가 가능합니다.

For more detailed explanations, open each example file and read the Korean comments at the top.
