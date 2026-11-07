part of 'inventory_data.dart';

extension InventoryCustomers on InventoryData {
  int get activeCustomerCount {
    return _customers.where((customer) => customer.active).length;
  }

  void addCustomer(
    String name,
    String phone,
    String email,
    String address,
    String city,
    String country,
    String notes,
  ) {
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw Exception('Customer name is required.');
    }

    final customer = InventoryCustomer(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      code: generateCustomerCode(),
      name: cleanName,
      phone: phone.trim(),
      email: email.trim(),
      address: address.trim(),
      city: city.trim(),
      country: country.trim(),
      notes: notes.trim(),
      createdAt: DateTime.now(),
      active: true,
    );

    _customers.add(customer);
    notifyListeners();
  }

  void updateCustomer({
    required String customerId,
    required String name,
    required String phone,
    required String email,
    required String address,
    required String city,
    required String country,
    required String notes,
  }) {
    final index = _customers.indexWhere(
      (customer) => customer.id == customerId,
    );

    if (index == -1) {
      throw Exception('Customer not found.');
    }

    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw Exception('Customer name is required.');
    }

    final oldCustomer = _customers[index];

    _customers[index] = InventoryCustomer(
      id: oldCustomer.id,
      code: oldCustomer.code,
      name: cleanName,
      phone: phone.trim(),
      email: email.trim(),
      address: address.trim(),
      city: city.trim(),
      country: country.trim(),
      notes: notes.trim(),
      createdAt: oldCustomer.createdAt,
      active: oldCustomer.active,
    );

    notifyListeners();
  }

  void deleteCustomer(String customerId) {
    _customers.removeWhere(
      (customer) => customer.id == customerId,
    );

    notifyListeners();
  }

  void toggleCustomerStatus(String customerId) {
    final index = _customers.indexWhere(
      (customer) => customer.id == customerId,
    );

    if (index == -1) {
      return;
    }

    final customer = _customers[index];

    _customers[index] = InventoryCustomer(
      id: customer.id,
      code: customer.code,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      city: customer.city,
      country: customer.country,
      notes: customer.notes,
      createdAt: customer.createdAt,
      active: !customer.active,
    );

    notifyListeners();
  }

  List<InventoryCustomer> searchCustomers(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) {
      return List.unmodifiable(_customers);
    }

    return _customers.where((customer) {
      return customer.name.toLowerCase().contains(search) ||
          customer.code.toLowerCase().contains(search) ||
          customer.phone.toLowerCase().contains(search) ||
          customer.email.toLowerCase().contains(search);
    }).toList();
  }
}