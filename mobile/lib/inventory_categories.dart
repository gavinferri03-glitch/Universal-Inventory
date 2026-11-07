part of 'inventory_data.dart';

extension InventoryCategories on InventoryData {
  void addCategory({
    required String name,
    required String code,
    String description = '',
  }) {
    final cleanName = name.trim();
    final cleanCode = code.trim();

    if (cleanName.isEmpty || cleanCode.isEmpty) {
      throw Exception('Category name and code are required.');
    }

    if (_categories.any(
      (item) => item.name.toLowerCase() == cleanName.toLowerCase(),
    )) {
      throw Exception('Category name already exists.');
    }

    if (_categories.any(
      (item) => item.code.toLowerCase() == cleanCode.toLowerCase(),
    )) {
      throw Exception('Category code already exists.');
    }

    _categories.add(
      InventoryCategory(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: cleanName,
        code: cleanCode,
        description: description.trim(),
        active: true,
      ),
    );

    notifyListeners();
  }

  void updateCategory({
    required String categoryId,
    required String name,
    String description = '',
  }) {
    final index = _categories.indexWhere(
      (item) => item.id == categoryId,
    );

    if (index == -1) {
      throw Exception('Category not found.');
    }

    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      throw Exception('Category name is required.');
    }

    if (_categories.any(
      (item) =>
          item.id != categoryId &&
          item.name.toLowerCase() == cleanName.toLowerCase(),
    )) {
      throw Exception('Category name already exists.');
    }

    final oldCategory = _categories[index];

    _categories[index] = InventoryCategory(
      id: oldCategory.id,
      name: cleanName,
      code: oldCategory.code,
      description: description.trim(),
      active: oldCategory.active,
    );

    notifyListeners();
  }

  int get activeCategoryCount =>
      _categories.where((item) => item.active).length;

  int getCategoryProductCount(String categoryId) {
    final category = getCategoryById(categoryId);

    if (category == null) return 0;

    return _products
        .where(
          (item) =>
              item.category.toLowerCase() ==
              category.name.toLowerCase(),
        )
        .length;
  }

  void deleteCategory(String categoryId) {
    final category = getCategoryById(categoryId);

    if (category == null) {
      throw Exception('Category not found.');
    }

    if (_products.any(
      (item) =>
          item.category.toLowerCase() ==
          category.name.toLowerCase(),
    )) {
      throw Exception('Cannot delete a category containing products.');
    }

    _categories.removeWhere((item) => item.id == categoryId);
    notifyListeners();
  }

  void toggleCategoryStatus(String categoryId) {
    final index = _categories.indexWhere(
      (item) => item.id == categoryId,
    );

    if (index == -1) {
      throw Exception('Category not found.');
    }

    final oldCategory = _categories[index];

    _categories[index] = InventoryCategory(
      id: oldCategory.id,
      name: oldCategory.name,
      code: oldCategory.code,
      description: oldCategory.description,
      active: !oldCategory.active,
    );

    notifyListeners();
  }
}