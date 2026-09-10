abstract final class InputValidators {
  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text)) {
      return 'Enter a valid email address.';
    }
    return null;
  }
  static String? password(String? value) {
    if ((value ?? '').length < 8) return 'Use at least 8 characters.';
    return null;
  }
  static String? name(String? value) {
    final text = (value ?? '').trim();
    if (text.length < 2 || text.length > 60) return 'Use 2 to 60 characters.';
    return null;
  }
  static String? quantity(String? value) {
    final number = double.tryParse((value ?? '').trim());
    if (number == null || !number.isFinite || number <= 0 || number > 100000) {
      return 'Enter a quantity greater than 0 and no more than 100,000.';
    }
    return null;
  }
}
