# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.5] - 2025-12-19

### Fixed
- GitHub release archive naming pattern mismatch
- Added contents: write permission for release creation
- Update GitHub release action to modern softprops/action-gh-release@v1
- Fix deprecated actions/create-release@v1 token permission issues
- Include release archive as downloadable asset
- Release archive creation using git archive instead of tar
- Code formatting issues in src/ and build.zig files

### Changed
- CI now tests on Linux and macOS platforms only
- Release archives created with git archive for cleaner packaging
- Modernized release workflow with proper asset attachments and permissions

## [0.1.0] - 2025-12-19 (withdrawn)

### Added
- Initial release: Zig port of rs-klc Rust crate
- Complete Korean Lunar-Solar calendar conversion functionality
- Support for dates from 1391-01-01 (lunar) to 2050-11-18 (lunar)
- Gapja (sexagenary cycle) calculations in Korean and Chinese
- Julian Day Number calculations with Gregorian reform handling
- Day of week calculations
- Leap year and intercalary month detection
- Comprehensive test suite with KASI verification
- Examples demonstrating all features
- Taskfile for easy example execution
- Performance benchmarks
- CI/CD pipeline for multiple platforms

### Features
- Accurate bidirectional conversions between Gregorian and Korean Lunar calendars
- Proper handling of Gregorian calendar reform (1582)
- Memory-safe implementation using Zig's allocator system
- Zero-cost abstractions with comptime optimizations

### Verified Against
- Korea Astronomy and Space Science Institute (KASI) official converter
- Historical test cases from 1391 to 2050
- Gregorian reform edge cases

### Port Details
- Original: rs-klc Rust crate
- Ported to: Zig 0.13+ / 0.15+
- Maintained feature parity and accuracy