
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventorySupplier {
  final String id;
  final String code;
  final String name;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String panVat;
  final String paymentTerms;
  final DateTime createdAt;
  bool active;

  InventorySupplier({
    required this.id,
    required this.code,
    required this.name,
    this.contactPerson = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.panVat = '',
    this.paymentTerms = 'Cash',
    required this.createdAt,
    this.active = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'code': code,
        'name': name,
        'contactPerson': contactPerson,
        'phone': phone,
        'email': email,
        'address': address,
        'panVat': panVat,
        'paymentTerms': paymentTerms,
        'createdAt': createdAt.toIso8601String(),
        'active': active,
      };

  factory InventorySupplier.fromMap(Map<String, dynamic> map) {
    return InventorySupplier(
      id: map['id']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      contactPerson: map['contactPerson']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      panVat: map['panVat']?.toString() ?? '',
      paymentTerms: map['paymentTerms']?.toString() ?? 'Cash',
      createdAt: DateTime.tryParse(
            map['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
      active: map['active'] is bool ? map['active'] as bool : true,
    );
  }
}

class InventorySupplierData extends ChangeNotifier {
  InventorySupplierData._();

  static final InventorySupplierData instance =
      InventorySupplierData._();

  static const String _storageKey =
      'universal_inventory_suppliers_v1';

  final List<InventorySupplier> _suppliers = [];

  bool _initialized = false;
  Future<void> _saveQueue = Future<void>.value();

  List<InventorySupplier> get suppliers =>
      List.unmodifiable(_suppliers);

  List<InventorySupplier> get activeSuppliers =>
      List.unmodifiable(_suppliers.where((e) => e.active));

  int get totalSuppliers => _suppliers.length;

  int get activeSupplierCount =>
      _suppliers.where((e) => e.active).length;

  int get inactiveSupplierCount =>
      _suppliers.where((e) => !e.active).length;

  Future<void> initialize() async {
    if (_initialized) return;

    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(_storageKey);

    if (saved != null && saved.isNotEmpty) {
      final decoded = jsonDecode(saved);

      if (decoded is List) {
        _suppliers
          ..clear()
          ..addAll(
            decoded.whereType<Map>().map(
              (item) => InventorySupplier.fromMap(
                Map<String, dynamic>.from(item),
              ),
            ),
          );
      }
    }

    _initialized = true;
    notifyListeners();
  }

  Future<void> _save() {
    final snapshot = jsonEncode(
      _suppliers.map((e) => e.toMap()).toList(),
    );

    _saveQueue = _saveQueue.then((_) async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_storageKey, snapshot);
    });

    return _saveQueue;
  }

  String generateSupplierCode() {
    var number = _suppliers.length + 1;
    var code = 'SUP-${number.toString().padLeft(4, '0')}';

    while (_suppliers.any((e) => e.code == code)) {
      number++;
      code = 'SUP-${number.toString().padLeft(4, '0')}';
    }

    return code;
  }

  InventorySupplier? getSupplierById(String id) {
    for (final supplier in _suppliers) {
      if (supplier.id == id) return supplier;
    }
    return null;
  }

  InventorySupplier? getSupplierByCode(String code) {
    for (final supplier in _suppliers) {
      if (supplier.code.toLowerCase() == code.toLowerCase()) {
        return supplier;
      }
    }
    return null;
  }

  Future<InventorySupplier> addSupplier({
    required String name,
    String code = '',
    String contactPerson = '',
    required String phone,
    String email = '',
    String address = '',
    String panVat = '',
    String paymentTerms = 'Cash',
  }) async {
    final cleanName = name.trim();
    final cleanPhone = phone.trim();
    var cleanCode = code.trim();

    if (cleanName.isEmpty || cleanPhone.isEmpty) {
      throw Exception('Supplier name and phone are required.');
    }

    if (cleanCode.isEmpty) {
      cleanCode = generateSupplierCode();
    }

    if (_suppliers.any(
      (e) => e.code.toLowerCase() == cleanCode.toLowerCase(),
    )) {
      throw Exception('This supplier code already exists.');
    }

    final supplier = InventorySupplier(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      code: cleanCode,
      name: cleanName,
      contactPerson: contactPerson.trim(),
      phone: cleanPhone,
      email: email.trim(),
      address: address.trim(),
      panVat: panVat.trim(),
      paymentTerms: paymentTerms,
      createdAt: DateTime.now(),
    );

    _suppliers.add(supplier);

    await _save();
    notifyListeners();

    return supplier;
  }

  Future<void> updateSupplier({
    required String supplierId,
    required String name,
    required String code,
    required String phone,
    String contactPerson = '',
    String email = '',
    String address = '',
    String panVat = '',
    String paymentTerms = 'Cash',
  }) async {
    final index = _suppliers.indexWhere(
      (e) => e.id == supplierId,
    );

    if (index == -1) {
      throw Exception('Supplier not found.');
    }

    if (name.trim().isEmpty || phone.trim().isEmpty) {
      throw Exception('Supplier name and phone are required.');
    }

    if (code.trim().isEmpty) {
      throw Exception('Supplier code is required.');
    }

    if (_suppliers.any(
      (e) =>
          e.id != supplierId &&
          e.code.toLowerCase() == code.trim().toLowerCase(),
    )) {
      throw Exception('This supplier code already exists.');
    }

    final old = _suppliers[index];

    _suppliers[index] = InventorySupplier(
      id: old.id,
      code: code.trim(),
      name: name.trim(),
      contactPerson: contactPerson.trim(),
      phone: phone.trim(),
      email: email.trim(),
      address: address.trim(),
      panVat: panVat.trim(),
      paymentTerms: paymentTerms,
      createdAt: old.createdAt,
      active: old.active,
    );

    await _save();
    notifyListeners();
  }

  Future<void> setSupplierActive(
    String supplierId,
    bool active,
  ) async {
    final supplier = getSupplierById(supplierId);

    if (supplier == null) {
      throw Exception('Supplier not found.');
    }

    supplier.active = active;

    await _save();
    notifyListeners();
  }

  List<InventorySupplier> searchSuppliers(String query) {
    final value = query.trim().toLowerCase();

    if (value.isEmpty) return suppliers;

    return _suppliers.where((supplier) {
      return supplier.name.toLowerCase().contains(value) ||
          supplier.code.toLowerCase().contains(value) ||
          supplier.phone.toLowerCase().contains(value) ||
          supplier.email.toLowerCase().contains(value) ||
          supplier.contactPerson.toLowerCase().contains(value);
    }).toList();
  }
}

final inventorySupplierProvider =
    ChangeNotifierProvider<InventorySupplierData>((ref) {
  return InventorySupplierData.instance;
});

final supplierInitializationProvider = FutureProvider<void>((ref) async {
  await ref.read(inventorySupplierProvider).initialize();
});
