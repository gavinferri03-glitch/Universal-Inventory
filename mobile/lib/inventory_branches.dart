
part of 'inventory_data.dart';

extension InventoryBranches on InventoryData {
  // BRANCH MANAGEMENT

  void addBranch({
    required String name,
    required String code,
    String city = '',
    String address = '',
    String phone = '',
    String email = '',
    String manager = '',
  }) {
    if (name.trim().isEmpty || code.trim().isEmpty) {
      throw Exception('Branch name and code are required.');
    }

    if (_branches.any(
      (e) => e.code.toLowerCase() == code.trim().toLowerCase(),
    )) {
      throw Exception('Branch code already exists.');
    }

    _branches.add(
      InventoryBranch(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        code: code.trim(),
        city: city.trim(),
        address: address.trim(),
        phone: phone.trim(),
        email: email.trim(),
        manager: manager.trim(),
        active: true,
      ),
    );

    notifyListeners();
  }

  void updateBranch({
    required String id,
    required String name,
    required String code,
    String city = '',
    String address = '',
    String phone = '',
    String email = '',
    String manager = '',
  }) {
    final branch = getBranchById(id);

    if (branch == null) {
      throw Exception('Branch not found.');
    }

    if (name.trim().isEmpty || code.trim().isEmpty) {
      throw Exception('Branch name and code are required.');
    }

    if (_branches.any(
      (e) =>
          e.id != id &&
          e.code.toLowerCase() == code.trim().toLowerCase(),
    )) {
      throw Exception('Branch code already exists.');
    }

    branch.name = name.trim();
    branch.code = code.trim();
    branch.city = city.trim();
    branch.address = address.trim();
    branch.phone = phone.trim();
    branch.email = email.trim();
    branch.manager = manager.trim();

    notifyListeners();
  }

  int get activeBranchCount =>
      _branches.where((e) => e.active).length;

  void deleteBranch(String branchId) {
    if (getBranchById(branchId) == null) {
      throw Exception('Branch not found.');
    }

    if (_products.any(
      (e) => (e.branchQuantities[branchId] ?? 0) > 0,
    )) {
      throw Exception('Transfer all stock before deleting this branch.');
    }

    _branches.removeWhere((e) => e.id == branchId);
    notifyListeners();
  }

  void toggleBranchStatus(String branchId) {
    final branch = getBranchById(branchId);

    if (branch == null) {
      throw Exception('Branch not found.');
    }

    branch.active = !branch.active;
    notifyListeners();
  }
}
