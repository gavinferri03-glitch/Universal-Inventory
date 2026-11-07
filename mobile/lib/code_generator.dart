class CodeGenerator {
  /// Generates the next available code for a record type.
  ///
  /// Example:
  /// prefix: BR
  /// existingCodes: BR-0001, BR-0002
  /// result: BR-0003
  static String next({
    required String prefix,
    required Iterable<String> existingCodes,
    int digits = 4,
  }) {
    final normalizedPrefix = prefix.trim().toUpperCase();

    if (normalizedPrefix.isEmpty) {
      throw ArgumentError('Code prefix cannot be empty.');
    }

    final pattern = RegExp(
      '^${RegExp.escape(normalizedPrefix)}-(\\d+)\$',
      caseSensitive: false,
    );

    var highestNumber = 0;

    for (final code in existingCodes) {
      final match = pattern.firstMatch(code.trim());

      if (match == null) continue;

      final number = int.tryParse(match.group(1) ?? '');

      if (number != null && number > highestNumber) {
        highestNumber = number;
      }
    }

    final nextNumber = highestNumber + 1;

    return '$normalizedPrefix-${nextNumber.toString().padLeft(digits, '0')}';
  }
}