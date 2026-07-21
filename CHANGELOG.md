# Changelog

## [2.0.0-unreleased] - 2026-07-21
- Refactor and compatibility updates for frequency_controller.dart.

## Unreleased - System updates
- Actualizaciones de estabilidad y compatibilidad.

All notable changes to neom_frequencies will be documented in this file.

## [2.0.0] - 2025-02-09

### Changed
- Fixed import ordering across all files (directives_ordering lint)
- Removed unnecessary cupertino.dart import in frequency_widgets.dart
- Fixed unnecessary underscores in itemBuilder parameters
- README.md with comprehensive documentation and ROADMAP 2026
- Migrated from GetX to SINT framework

### Improved
- Code compliance with flutter_lints ^6.0.0
- Clean Architecture adherence

## [1.3.0] - 2025-01-15

### Added
- FrequencyController with SINT state management
- RootFrequenciesPage for favorite frequencies display
- FrequencyPage for frequency selection
- Animated text kit integration for UI

### Changed
- Updated SDK constraint to >=3.8.0 <4.0.0
- Updated flutter_lints to ^6.0.0

## [1.2.0-dev] - 2024-11-01

### Added
- Initial modular structure following Open Neom architecture
- Core frequency domain models (Frequency, FrequencyPreset, FrequencyProfile)
- Abstract interfaces (FrequencyRepository, FrequencyService)
- Base controller (FrequencyController) with GetX state management
- Integration contracts with neom_generator module

### Changed
- Refactored legacy monolithic frequency code into Clean Architecture layers
- Migrated state management to GetX pattern
- Standardized all models to use immutable data patterns

### Removed
- Deprecated direct Firebase dependencies (moved to neom_core)
- Redundant utility classes
- Legacy state management code

## [1.0.0] - 2024-08-15

### Added
- Initial release
- Basic frequency management
- Integration with neom_core and neom_commons
