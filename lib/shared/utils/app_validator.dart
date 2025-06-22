class AppValidator {
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email.trim());
  }

  static bool isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  static bool isValidMeasurement(double value, double min, double max) {
    return value >= min && value <= max;
  }

  static bool isValidAge(int age) {
    return age >= 0 && age <= 60;
  }

  static bool isValidSymptomsMap(Map<String, int> symptoms) {
    if (symptoms.isEmpty) return false;
    return symptoms.values.every((v) => v >= 1 && v <= 4);
  }
}
