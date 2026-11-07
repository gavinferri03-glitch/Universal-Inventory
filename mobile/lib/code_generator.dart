
class CodeGenerator {
  // Standard code prefixes used throughout Universal Inventory.
  static const String productPrefix = 'PR';
  static const String categoryPrefix = 'CAT';
  static const String branchPrefix = 'BR';
  static const String supplierPrefix = 'SUP';
  static const String customerPrefix = 'CUS';
  static const String stockPrefix = 'STK';
  static const String transferPrefix = 'TRF';
  static const String invoicePrefix = 'INV';

  /// Generates the next available sequential code.
  ///
  /// Example:
  /// existingCodes: ['PR-0001', 'PR-0002']
  /// result: PR-0003
  static String next({
    required String prefix,
    required Iterable<String> existingCodes,
    int digits = 4,
  }) {
    final normalizedPrefix = prefix.trim().toUpperCase();

    if (normalizedPrefix.isEmpty) {
      throw ArgumentError('Code prefix cannot be empty.');
    }

    if (digits < 1 || digits > 12) {
      throw ArgumentError('Digits must be between 1 and 12.');
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

  static String nextProduct(Iterable<String> existingCodes) {
    return next(
      prefix: productPrefix,
      existingCodes: existingCodes,
    );
  }

  static String nextCategory(Iterable<String> existingCodes) {
    return next(
      prefix: categoryPrefix,
      existingCodes: existingCodes,
    );
  }

  static String nextBranch(Iterable<String> existingCodes) {
    return next(
      prefix: branchPrefix,
      existingCodes: existingCodes,
    );
  }

  static String nextSupplier(Iterable<String> existingCodes) {
    return next(
      prefix: supplierPrefix,
      existingCodes: existingCodes,
    );
  }

  static String nextCustomer(Iterable<String> existingCodes) {
    return next(
      prefix: customerPrefix,
      existingCodes: existingCodes,
    );
  }

  static String nextStockMovement(Iterable<String> existingCodes) {
    return next(
      prefix: stockPrefix,
      existingCodes: existingCodes,
    );
  }

  static String nextTransfer(Iterable<String> existingCodes) {
    return next(
      prefix: transferPrefix,
      existingCodes: existingCodes,
    );
  }

  static String nextInvoice(Iterable<String> existingCodes) {
    return next(
      prefix: invoicePrefix,
      existingCodes: existingCodes,
    );
  }
}
