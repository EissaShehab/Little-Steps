import 'package:flutter_test/flutter_test.dart';
import 'package:littlesteps/shared/utils/app_validator.dart';

void main() {
  group('Email Validation', () {
    test('should return true for valid emails', () {
      expect(AppValidator.isValidEmail('test@example.com'), true);
      expect(AppValidator.isValidEmail('user.name@domain.co'), true);
      expect(AppValidator.isValidEmail('john_doe123@sub.domain.net'), true);
    });

    test('should return false for invalid emails', () {
      expect(AppValidator.isValidEmail('test@com'), false); // Missing domain
      expect(AppValidator.isValidEmail('test.com'), false); // Missing @
      expect(
          AppValidator.isValidEmail('@example.com'), false); // Missing username
      expect(AppValidator.isValidEmail('user@domain.'),
          false); // Incomplete domain
      expect(AppValidator.isValidEmail('user@@domain.com'), false); // Double @
    });
  });

  group('Password Validation', () {
    test('should return true for valid passwords', () {
      expect(AppValidator.isValidPassword('StrongP@ss1'), true);
      expect(AppValidator.isValidPassword('Test123!'), true);
      expect(AppValidator.isValidPassword('A1!a2@B3#'), true);
    });

    test('should return false for passwords missing conditions', () {
      expect(AppValidator.isValidPassword('weakpass'),
          false); // No uppercase, number, or special
      expect(AppValidator.isValidPassword('NOCAPS123!'), false); // No lowercase
      expect(
          AppValidator.isValidPassword('noupper123!'), false); // No uppercase
      expect(AppValidator.isValidPassword('NoNumber!'), false); // No digit
      expect(
          AppValidator.isValidPassword('NoSpecial1'), false); // No special char
      expect(AppValidator.isValidPassword('Sh0!'), false); // Too short
    });
  });

  group('Name Validation', () {
    test('should return true for valid names', () {
      expect(AppValidator.isValidName('Ali'), true);
      expect(AppValidator.isValidName('Lana'), true);
      expect(AppValidator.isValidName('A B'), true); // حتى لو فيه مسافة
    });

    test('should return false for invalid names', () {
      expect(AppValidator.isValidName(''), false);
      expect(AppValidator.isValidName('A'), false); // أقل من 2
      expect(AppValidator.isValidName(' '), false); // فقط مسافة
    });
  });

  group('Measurement Validation', () {
    test('should return true for valid measurements within range', () {
      expect(AppValidator.isValidMeasurement(10.5, 1, 30), true);
      expect(AppValidator.isValidMeasurement(45.0, 40, 120), true);
      expect(AppValidator.isValidMeasurement(34.0, 30, 60), true);
    });

    test('should return false for out-of-range measurements', () {
      expect(
          AppValidator.isValidMeasurement(0.5, 1, 30), false); // أقل من المين
      expect(AppValidator.isValidMeasurement(130.0, 40, 120),
          false); // أكبر من الماكس
      expect(AppValidator.isValidMeasurement(-5.0, 1, 30), false); // قيمة سالبة
    });
  });

  group('Age Validation', () {
    test('should return true for valid ages between 0 and 60', () {
      expect(AppValidator.isValidAge(0), true);
      expect(AppValidator.isValidAge(12), true);
      expect(AppValidator.isValidAge(60), true);
    });

    test('should return false for invalid ages', () {
      expect(AppValidator.isValidAge(-1), false);
      expect(AppValidator.isValidAge(61), false);
      expect(AppValidator.isValidAge(999), false);
    });
  });

  group('Symptoms Map Validation', () {
    test('should return true for valid symptom maps', () {
      expect(AppValidator.isValidSymptomsMap({'Fever': 1}), true);
      expect(AppValidator.isValidSymptomsMap({'Cough': 2, 'Fever': 3}), true);
      expect(AppValidator.isValidSymptomsMap({'Pain': 4}), true);
    });

    test('should return false for empty or invalid symptom maps', () {
      expect(AppValidator.isValidSymptomsMap({}), false); // فارغ
      expect(
          AppValidator.isValidSymptomsMap({'Cough': 0}), false); // خارج النطاق
      expect(
          AppValidator.isValidSymptomsMap({'Fever': 5}), false); // خارج النطاق
      expect(AppValidator.isValidSymptomsMap({'Fever': -1}), false); // سالبة
    });
  });
}
