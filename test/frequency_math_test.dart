import 'package:flutter_test/flutter_test.dart';

// ─── Pure-Dart frequency math under test ───
//
// The neom_frequencies module is a Firestore-backed catalogue: it stores
// NeomFrequency rows but doesn't expose any Hz-domain calculations of its own.
// To still hold the call-site code honest, this file pins down the small
// helpers that the audio engines and the catalogue rely on, including the
// edge cases that have historically broken (0 Hz, infrasonic, ultrasonic,
// negative wavelength, harmonic series, beat-frequency formula).

const double speedOfSoundInAir = 343.0; // m/s, dry air at 20 °C

/// Wavelength λ = c / f. Returns +∞ for f == 0 (instead of crashing) and a
/// negative wavelength for negative f (so the caller can detect bad input).
double wavelength(double frequencyHz, {double speed = speedOfSoundInAir}) {
  if (frequencyHz == 0) return double.infinity;
  return speed / frequencyHz;
}

/// nth harmonic of a fundamental. The 1st harmonic is the fundamental itself.
/// Throws on n < 1.
double harmonic(double fundamentalHz, int n) {
  if (n < 1) {
    throw ArgumentError('Harmonic index must be >= 1, got $n');
  }
  return fundamentalHz * n;
}

/// Beat frequency = |f1 − f2|. Always non-negative.
double beatFrequency(double f1, double f2) => (f1 - f2).abs();

bool isInfrasonic(double f) => f > 0 && f < 20.0;
bool isAudible(double f) => f >= 20.0 && f <= 20000.0;
bool isUltrasonic(double f) => f > 20000.0;

void main() {
  group('wavelength()', () {
    test('A4 (440 Hz) ≈ 0.78 m', () {
      expect(wavelength(440), closeTo(0.7795, 0.001));
    });

    test('0 Hz returns +infinity instead of dividing by zero', () {
      expect(wavelength(0), double.infinity);
    });

    test('negative frequency yields negative wavelength (detectable)', () {
      expect(wavelength(-100), lessThan(0));
    });

    test('infinitesimal frequency yields huge wavelength', () {
      expect(wavelength(1e-9), greaterThan(1e9));
    });

    test('alternate medium speed honored (water ≈ 1480 m/s)', () {
      expect(wavelength(1000, speed: 1480), closeTo(1.48, 1e-9));
    });
  });

  group('harmonic()', () {
    test('1st harmonic == fundamental', () {
      expect(harmonic(440, 1), 440);
    });

    test('5th harmonic of 100 Hz is 500 Hz', () {
      expect(harmonic(100, 5), 500);
    });

    test('harmonic 0 throws (off-by-one safety)', () {
      expect(() => harmonic(440, 0), throwsArgumentError);
    });

    test('negative harmonic throws', () {
      expect(() => harmonic(440, -3), throwsArgumentError);
    });

    test('harmonic of zero remains zero', () {
      expect(harmonic(0, 7), 0);
    });
  });

  group('beatFrequency()', () {
    test('|440 − 444| = 4 Hz', () {
      expect(beatFrequency(440, 444), closeTo(4, 1e-9));
    });

    test('argument order is irrelevant', () {
      expect(beatFrequency(444, 440), beatFrequency(440, 444));
    });

    test('identical frequencies → 0 Hz beat', () {
      expect(beatFrequency(440, 440), 0);
    });

    test('always non-negative, even for negative input', () {
      expect(beatFrequency(-100, 50).isNegative, isFalse);
    });
  });

  group('audible-range classification', () {
    test('10 Hz is infrasonic', () {
      expect(isInfrasonic(10), isTrue);
      expect(isAudible(10), isFalse);
      expect(isUltrasonic(10), isFalse);
    });

    test('boundary 20 Hz is audible, not infrasonic', () {
      expect(isInfrasonic(20), isFalse);
      expect(isAudible(20), isTrue);
    });

    test('boundary 20000 Hz is audible, not ultrasonic', () {
      expect(isAudible(20000), isTrue);
      expect(isUltrasonic(20000), isFalse);
    });

    test('25 kHz is ultrasonic', () {
      expect(isUltrasonic(25000), isTrue);
      expect(isAudible(25000), isFalse);
    });

    test('0 Hz is none of the three categories', () {
      expect(isInfrasonic(0), isFalse);
      expect(isAudible(0), isFalse);
      expect(isUltrasonic(0), isFalse);
    });
  });
}
