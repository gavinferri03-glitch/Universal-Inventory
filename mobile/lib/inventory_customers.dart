
part of 'inventory_data.dart';

extension InventoryCustomers on InventoryData {
  // CUSTOMER MANAGEMENT

  void addCustomer({
    required String name,
    String phone = '',
    String email = '',
    String address = '',
    String city = '',
    String country = 'Nepal',
    String notes = '',
  }) {
    if (name.trim().isEmpty) {
      throw Exception('Customer name is required.');
    }

    final code = generateCustomerCode();

    _customers.add(
      InventoryCustomer(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        code: code,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
        address: address.trim(),
        city: city.trim(),
        country: country.trim(),
        notes: notes.trim(),
        createdAt: DateTime.now(),
        active: true,
      ),
    );

    notifyListeners();
  }

  void updateCustomer({
    required String customerId,
    required String name,
    String phone = '',
    String email = '',
    String address = '',
    String city = '',
    String country = 'Nepal',
    String notes = '',
  }) {
    final customer = getCustomerById(customerId);

    if (customer == null) {
      throw Exception('Customer not found.');
    }

    if (name.trim().isEmpty) {
      throw Exception('Customer name is required.');
    }

    customer.name = name.trim();
    customer.phone = phone.trim();
    customer.email = email.trim();
    customer.address = address.trim();
    customer.city = city.trim();
    customer.country = country.trim();
    customer.notes = notes.trim();

    notifyListeners();
  }

  void deleteCustomer(String customerId) {
    if (getCustomerById(customerId) == null) {
      throw Exception('Customer not found.');
    }

    _customers.removeWhere((e) => e.id == customerId);
    notifyListeners();
  }

  void toggleCustomerStatus(String customerId) {
    final customer = getCustomerById(customerId);

    if (customer == null) {
      throw Exception('Customer not found.');
    }

    customer.active = !customer.active;
    notifyListeners();
  }
}
