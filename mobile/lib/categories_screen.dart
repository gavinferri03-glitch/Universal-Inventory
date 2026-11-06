
import 'package:flutter/material.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final Color blue = const Color(0xFF5798FF);
  final Color panel = const Color(0xFF121D2D);
  final Color muted = const Color(0xFF91A4BE);

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Electronics', 'code': 'CAT-001', 'description': 'Electronic devices and equipment', 'active': true},
    {'name': 'Accessories', 'code': 'CAT-002', 'description': 'Computer and mobile accessories', 'active': true},
    {'name': 'Furniture', 'code': 'CAT-003', 'description': 'Office and home furniture', 'active': true},
    {'name': 'Other', 'code': 'CAT-004', 'description': 'Miscellaneous products', 'active': true},
  ];

  String searchText = '';

  List<Map<String, dynamic>> get filteredCategories {
    return categories.where((category) {
      final name = category['name'].toString().toLowerCase();
      final code = category['code'].toString().toLowerCase();
      return name.contains(searchText.toLowerCase()) ||
          code.contains(searchText.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showCategoryDialog({int? index}) {
    final isEditing = index != null;
    final nameController = TextEditingController(
      text: isEditing ? categories[index]['name'] : '',
    );
    final codeController = TextEditingController(
      text: isEditing ? categories[index]['code'] : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? categories[index]['description'] : '',
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
                _field(codeController, 'Category Code *'),
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
                final code = codeController.text.trim();
                final description = descriptionController.text.trim();

                if (name.isEmpty || code.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name and code are required.'),
                    ),
                  );
                  return;
                }

                final duplicate = categories.indexWhere(
                  (category) =>
                      category['code'].toString().toLowerCase() ==
                          code.toLowerCase() &&
                      (!isEditing || categories[index] != category),
                );

                if (duplicate != -1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This category code already exists.'),
                    ),
                  );
                  return;
                }

                setState(() {
                  if (isEditing) {
                    categories[index] = {
                      ...categories[index],
                      'name': name,
                      'code': code,
                      'description': description,
                    };
                  } else {
                    categories.add({
                      'name': name,
                      'code': code,
                      'description': description,
                      'active': true,
                    });
                  }
                });

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Category updated successfully.'
                          : 'Category added successfully.',
                    ),
                  ),
                );
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
          borderSide: BorderSide(color: muted.withOpacity(0.25)),
        ),
      ),
    );
  }

  void deleteCategory(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: const Text(
          'Delete Category?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this category?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => categories.removeAt(index));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category deleted.')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    final activeCount =
        categories.where((category) => category['active'] == true).length;

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
                  activeCount,
                  Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() => searchText = value);
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search categories...',
                hintStyle: TextStyle(color: muted),
                prefixIcon: Icon(Icons.search, color: muted),
                filled: true,
                fillColor: panel,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
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
                        final originalIndex = categories.indexOf(category);
                        final isActive = category['active'] == true;

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
                                          category['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          category['code'],
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
                                          index: originalIndex,
                                        );
                                      } else if (value == 'toggle') {
                                        setState(() {
                                          categories[originalIndex]['active'] =
                                              !isActive;
                                        });
                                      } else if (value == 'delete') {
                                        deleteCategory(originalIndex);
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
                                          isActive
                                              ? 'Deactivate'
                                              : 'Activate',
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
                              if (category['description']
                                  .toString()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  category['description'],
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
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
