
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'code_generator.dart';
import 'inventory_data.dart';
import 'list_tools.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final Color blue = const Color(0xFF5798FF);
  final Color panel = const Color(0xFF121D2D);
  final Color muted = const Color(0xFF91A4BE);

  final TextEditingController searchController = TextEditingController();

  String searchText = '';
  String selectedSort = 'name_az';
  String selectedFilter = 'all';

  List<InventoryCategory> getFilteredCategories(
    List<InventoryCategory> categories,
  ) {
    final search = searchText.trim().toLowerCase();

    List<InventoryCategory> result = categories.where((category) {
      final matchesSearch = search.isEmpty ||
          category.name.toLowerCase().contains(search) ||
          category.code.toLowerCase().contains(search) ||
          category.description.toLowerCase().contains(search);

      final matchesFilter =
          selectedFilter == 'all' ||
          (selectedFilter == 'active' && category.active) ||
          (selectedFilter == 'inactive' && !category.active);

      return matchesSearch && matchesFilter;
    }).toList();

    switch (selectedSort) {
      case 'name_za':
        result.sort((a, b) => b.name.toLowerCase().compareTo(
              a.name.toLowerCase(),
            ));
        break;
      case 'products_high':
        result.sort((a, b) =>
            ref.read(inventoryProvider)
                .getCategoryProductCount(b.id)
                .compareTo(
                  ref.read(inventoryProvider)
                      .getCategoryProductCount(a.id),
                ));
        break;
      case 'products_low':
        result.sort((a, b) =>
            ref.read(inventoryProvider)
                .getCategoryProductCount(a.id)
                .compareTo(
                  ref.read(inventoryProvider)
                      .getCategoryProductCount(b.id),
                ));
        break;
      case 'active_first':
        result.sort((a, b) =>
            (b.active ? 1 : 0).compareTo(a.active ? 1 : 0));
        break;
      case 'inactive_first':
        result.sort((a, b) =>
            (a.active ? 1 : 0).compareTo(b.active ? 1 : 0));
        break;
      default:
        result.sort((a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ));
    }

    return result;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showCategoryDialog({InventoryCategory? category}) {
    final inventory = ref.read(inventoryProvider);
    final isEditing = category != null;

    final nameController = TextEditingController(
      text: category?.name ?? '',
    );
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );

    final code = isEditing
        ? category.code
        : CodeGenerator.next(
            prefix: 'CAT',
            existingCodes: inventory.categories.map((item) => item.code),
          );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panel,
          title: Text(
            isEditing ? 'Edit Category' : 'Add Category',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(nameController, 'Category Name *'),
                const SizedBox(height: 12),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(text: code),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Category Code (Auto-generated)',
                    labelStyle: TextStyle(color: muted),
                    filled: true,
                    fillColor: const Color(0xFF080B12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _field(
                  descriptionController,
                  'Description',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: muted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name = nameController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isEmpty) {
                  showMessage('Category name is required.');
                  return;
                }

                try {
                  if (isEditing) {
                    inventory.updateCategory(
                      categoryId: category.id,
                      name: name,
                      description: description,
                    );
                  } else {
                    inventory.addCategory(
                      name: name,
                      code: code,
                      description: description,
                    );
                  }

                  Navigator.pop(dialogContext);
                  setState(() {});
                  showMessage(
                    isEditing
                        ? 'Category updated successfully.'
                        : 'Category added successfully.',
                  );
                } catch (error) {
                  showMessage(
                    error.toString().replaceFirst('Exception: ', ''),
                  );
                }
              },
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: muted),
        filled: true,
        fillColor: const Color(0xFF080B12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: muted.withOpacity(0.25),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: blue, size: 22),
            const SizedBox(height: 10),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void confirmDelete(InventoryCategory category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panel,
          title: const Text(
            'Delete Category?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete "${category.name}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                try {
                  ref.read(inventoryProvider).deleteCategory(category.id);
                  Navigator.pop(dialogContext);
                  setState(() {});
                  showMessage('Category deleted successfully.');
                } catch (error) {
                  Navigator.pop(dialogContext);
                  showMessage(
                    error.toString().replaceFirst('Exception: ', ''),
                  );
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void toggleCategory(InventoryCategory category) {
    try {
      ref.read(inventoryProvider).toggleCategoryStatus(category.id);
      setState(() {});
      showMessage(
        category.active
            ? 'Category deactivated.'
            : 'Category activated.',
      );
    } catch (error) {
      showMessage(
        error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final categories = inventory.categories;
    final filteredCategories = getFilteredCategories(categories);

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        foregroundColor: Colors.white,
        title: const Text('Categories'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCategoryDialog(),
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _summaryCard(
                  'Total Categories',
                  categories.length,
                  Icons.category_outlined,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  'Active Categories',
                  inventory.activeCategoryCount,
                  Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 20),
            InventoryListToolbar(
              searchController: searchController,
              searchHint: 'Search category name, code or description...',
              onSearchChanged: (value) {
                setState(() => searchText = value);
              },
              sortOptions: const {
                'name_az': 'Name: A–Z',
                'name_za': 'Name: Z–A',
                'products_high': 'Most products',
                'products_low': 'Fewest products',
                'active_first': 'Active first',
                'inactive_first': 'Inactive first',
              },
              selectedSort: selectedSort,
              onSortChanged: (value) {
                setState(() => selectedSort = value);
              },
              filterOptions: const {
                'all': 'All categories',
                'active': 'Active only',
                'inactive': 'Inactive only',
              },
              selectedFilter: selectedFilter,
              onFilterChanged: (value) {
                setState(() => selectedFilter = value);
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredCategories.isEmpty
                  ? Center(
                      child: Text(
                        'No categories found.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];
                        final isActive = category.active;
                        final productCount =
                            inventory.getCategoryProductCount(category.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: panel,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                      color: blue.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.category_outlined,
                                      color: blue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category.name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          category.code,
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: muted,
                                    ),
                                    color: panel,
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        showCategoryDialog(
                                          category: category,
                                        );
                                      } else if (value == 'toggle') {
                                        toggleCategory(category);
                                      } else if (value == 'delete') {
                                        confirmDelete(category);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'toggle',
                                        child: Text(
                                          isActive ? 'Deactivate' : 'Activate',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (category.description.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  category.description,
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Products: $productCount',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? Colors.green.withOpacity(0.15)
                                          : Colors.red.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isActive ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        color: isActive
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
