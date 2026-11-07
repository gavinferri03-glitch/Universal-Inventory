part of 'inventory_data.dart';

extension InventoryBranches on InventoryData {
  int get activeBranchCount {
    return _branches.where((branch) => branch.active).length;
  }

  void addBranch({
    required String name,
    required String code,
    required String city,
    required String address,
    required String phone,
    required String email,
    required String manager,
  }) {
    final cleanName = name.trim();
    final cleanCode = code.trim();

    if (cleanName.isEmpty || cleanCode.isEmpty) {
      throw Exception('Branch name and code are required.');
    }

    if (_branches.any(
      (branch) => branch.code.toLowerCase() == cleanCode.toLowerCase(),
    )) {
      throw Exception('A branch with this code already exists.');
    }

    _branches.add(
      InventoryBranch(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: cleanName,
        code: cleanCode,
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
    required String city,
    required String address,
    required String phone,
    required String email,
    required String manager,
  }) {
    final index = _branches.indexWhere((branch) => branch.id == id);

    if (index == -1) {
      throw Exception('Branch not found.');
    }

    final cleanName = name.trim();
    final cleanCode = code.trim();

    if (cleanName.isEmpty || cleanCode.isEmpty) {
      throw Exception('Branch name and code are required.');
    }

    if (_branches.any(
      (branch) =>
          branch.id != id &&
          branch.code.toLowerCase() == cleanCode.toLowerCase(),
    )) {
      throw Exception('A branch with this code already exists.');
    }

    final oldBranch = _branches[index];

    _branches[index] = InventoryBranch(
      id: oldBranch.id,
      name: cleanName,
      code: cleanCode,
      city: city.trim(),
      address: address.trim(),
      phone: phone.trim(),
      email: email.trim(),
      manager: manager.trim(),
      active: oldBranch.active,
    );

    notifyListeners();
  }

  void deleteBranch(String branchId) {
    if (!_branches.any((branch) => branch.id == branchId)) {
      return;
    }

    if (_branches.length <= 1) {
      throw Exception('At least one branch must remain.');
    }

    final hasStock = _products.any(
      (product) => (product.branchQuantities[branchId] ?? 0) > 0,
    );

    final hasMovements = _movements.any(
      (movement) => movement.branchId == branchId,
    );

    final hasSales = _sales.any(
      (sale) => sale.branchId == branchId,
    );

    if (hasStock || hasMovements || hasSales) {
      throw Exception(
        'This branch has inventory or transaction records. '
        'Deactivate it instead of deleting it.',
      );
    }

    _branches.removeWhere((branch) => branch.id == branchId);
    notifyListeners();
  }

  void toggleBranchStatus(String branchId) {
    final index = _branches.indexWhere(
      (branch) => branch.id == branchId,
    );

    if (index == -1) {
      return;
    }

    final branch = _branches[index];

    if (branch.active && activeBranchCount <= 1) {
      throw Exception('At least one active branch must remain.');
    }

    _branches[index] = InventoryBranch(
      id: branch.id,
      name: branch.name,
      code: branch.code,
      city: branch.city,
      address: branch.address,
      phone: branch.phone,
      email: branch.email,
      manager: branch.manager,
      active: !branch.active,
    );

    notifyListeners();
  }
}