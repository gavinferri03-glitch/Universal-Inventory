
part of 'inventory_data.dart';

extension InventoryCategories on InventoryData{
  // CATEGORY MANAGEMENT

  void addCategory({
    required String name,
    required String code,
    String description = '',
  }) {
    if (name.trim().isEmpty || code.trim().isEmpty) {
      throw Exception('Category name and code are required.');
    }

    if (_categories.any(
      (e) => e.name.toLowerCase() == name.trim().toLowerCase(),
    )) {
      throw Exception('Category name already exists.');
    }

    if (_categories.any(
      (e) => e.code.toLowerCase() == code.trim().toLowerCase(),
    )) {
      throw Exception('Category code already exists.');
    }

    _categories.add(
      InventoryCategory(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        code: code.trim(),
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
    final category = getCategoryById(categoryId);

    if (category == null) {
      throw Exception('Category not found.');
    }

    if (name.trim().isEmpty) {
      throw Exception('Category name is required.');
    }

    if (_categories.any(
      (e) =>
          e.id != categoryId &&
          e.name.toLowerCase() == name.trim().toLowerCase(),
    )) {
      throw Exception('Category name already exists.');
    }

    category.name = name.trim();
    category.description = description.trim();

    notifyListeners();
  }

  int get activeCategoryCount =>
      _categories.where((e) => e.active).length;

  int getCategoryProductCount(String categoryId) {
    final category = getCategoryById(categoryId);
    if (category == null) return 0;

    return _products
        .where(
          (e) => e.category.toLowerCase() == category.name.toLowerCase(),
        )
        .length;
  }

  void deleteCategory(String categoryId) {
    final category = getCategoryById(categoryId);

    if (category == null) {
      throw Exception('Category not found.');
    }

    if (_products.any(
      (e) => e.category.toLowerCase() == category.name.toLowerCase(),
    )) {
      throw Exception('Cannot delete a category containing products.');
    }

    _categories.removeWhere((e) => e.id == categoryId);
    notifyListeners();
  }

  void toggleCategoryStatus(String categoryId) {
    final category = getCategoryById(categoryId);

    if (category == null) {
      throw Exception('Category not found.');
    }

    category.active = !category.active;
    notifyListeners();
  }
}
