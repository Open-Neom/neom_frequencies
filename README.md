# neom_frequencies

Frequency Management module for the Open Neom ecosystem.

neom_frequencies is a specialized module dedicated to managing and displaying detailed frequency information. It serves as a complementary component to neom_generator, focusing on the visualization, organization, and interaction with frequency data. This module integrates seamlessly with the Open Neom platform, adhering to its modular architecture and Clean Architecture principles.

## Features & Responsibilities

### Frequency Visualization
- Detailed displays of frequency data
- Waveforms and spectrograms
- Visual representations for user understanding

### Frequency Organization
- Categorize and tag frequency presets
- Favorite frequency management
- Easy access and retrieval

### Interactive Controls
- Intuitive UI elements for adjusting parameters
- Amplitude, duration, and modulation controls
- Real-time parameter updates

### Integration with neom_generator
- Seamless connection with neom_generator module
- Fetch and display real-time frequency data
- "Neom Chamber" integration

### User Customization
- Save personalized frequency settings
- Create custom frequency profiles
- Use cases: meditation, focus, relaxation

### Data Persistence
- Local storage of frequency presets
- Configuration retention across sessions
- Firebase sync for cloud backup

## Architecture

```
lib/
├── frequency_routes.dart
├── ui/
│   ├── frequency_controller.dart
│   ├── frequency_page.dart
│   ├── root_frequencies_page.dart
│   └── widgets/
│       └── frequency_widgets.dart
├── utils/
│   └── constants/
│       └── frequency_translation_constants.dart
└── neom_frequencies.dart
```

## Dependencies

```yaml
dependencies:
  neom_core: ^2.0.0       # Core services and models
  neom_commons: ^2.0.0    # Shared UI components
  sint: ^1.0.0            # State management (SINT framework)
  animated_text_kit: ^4.2.3  # Text animations
```

## Usage

### Displaying Frequency Selection Page

```dart
import 'package:neom_frequencies/ui/frequency_page.dart';

class MyFrequencyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FrequencyPage(), // Displays the frequency selection
    );
  }
}
```

### Accessing Favorite Frequencies

```dart
import 'package:neom_frequencies/ui/root_frequencies_page.dart';

// Navigate to user's favorite frequencies
Sint.toNamed(AppRouteConstants.frequencyFav);
```

### Registering Routes

```dart
import 'package:neom_frequencies/frequency_routes.dart';

// Add to your app routes
final routes = [
  ...FrequencyRoutes.routes,
  // other routes
];
```

## Frequency Data Model

Each frequency includes:
- **id**: Unique identifier
- **name**: Frequency name
- **frequency**: Value in Hz
- **description**: Detailed description
- **isFav**: User favorite status
- **isMain**: Primary frequency flag

## ROADMAP 2026

### Q1 2026 - Enhanced Visualization
- [ ] Real-time waveform display
- [ ] Spectrogram visualization
- [ ] Frequency comparison view
- [ ] Custom color themes for frequencies

### Q2 2026 - Advanced Profiles
- [ ] Multiple frequency profile presets
- [ ] Profile sharing between users
- [ ] Import/export frequency configurations
- [ ] Scheduled frequency sessions

### Q3 2026 - Audio Integration
- [ ] Direct audio playback integration
- [ ] Binaural beat generation
- [ ] Isochronic tone support
- [ ] Background frequency playback

### Q4 2026 - Analytics & Insights
- [ ] Frequency usage statistics
- [ ] Session duration tracking
- [ ] Mood/effect correlation analysis
- [ ] Personalized frequency recommendations

## State Management

neom_frequencies uses the SINT framework (GetX replacement) for:
- Reactive state with `Rx` types
- Controller lifecycle management
- Dependency injection
- Route management

## Contributing

We welcome contributions! Whether you're fixing bugs, improving documentation, or adding new features related to frequency visualization and management, your help is appreciated.

## License

This project is licensed under the Apache License, Version 2.0, January 2004. See the LICENSE file for details.
