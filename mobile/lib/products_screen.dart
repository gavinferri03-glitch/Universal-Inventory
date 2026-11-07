
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'code_generator.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final Color blue = const Color(0xFF5798FF);
  final Color panel = const Color(0xFF121D2D);
  final Color muted = const Color(0xFF91A4BE);

  final TextEditingController searchController =
      TextEditingController();

  String selectedCategory = 'All';

  final List<String> units = [
    'Pieces',
    'Boxes',
    'Packets',
    'Kilograms',
    'Grams',
    'Litres',
    'Metres',
    'Pairs',
    'Cartons',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<InventoryProduct> getFilteredProducts(
    List<InventoryProduct> products,
  ) {
    final query = searchController.text.trim().toLowerCase();

    return products.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(query) ||
          product.sku.toLowerCase().contains(query) ||
          product.barcode.toLowerCase().contains(query) ||
          product.supplier.toLowerCase().contains(query);

      final matchesCategory = selectedCategory == 'All' ||
          product.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
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
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: _decoration(label),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: blue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _readOnlyCode(String code, String label) {
    return TextFormField(
      initialValue: code,
      readOnly: true,
      style: const TextStyle(
        color: Colors.white70,
        fontWeight: FontWeight.bold,
      ),
      decoration: _decoration(label).copyWith(
        suffixIcon: Icon(
          Icons.lock_outline,
          color: muted,
        ),
      ),
    );
  }

  // ==========================================================
  // ADD PRODUCT
  // ==========================================================

  void addProduct() {
    final inventory = ref.read(inventoryProvider);

    final activeBranches = inventory.branches
        .where((branch) => branch.active)
        .toList();

    final activeCategories = inventory.categories
        .where((category) => category.active)
        .toList();

    if (activeBranches.isEmpty) {
      showMessage('Please create an active branch first.');
      return;
    }

    if (activeCategories.isEmpty) {
      showMessage(
        'Please create or activate a category first.',
      );
      return;
    }

    final nameController = TextEditingController();
    final barcodeController = TextEditingController();
    final descriptionController = TextEditingController();
    final costController = TextEditingController();
    final sellingController = TextEditingController();
    final quantityController =
        TextEditingController(text: '0');
    final minimumController =
        TextEditingController(text: '5');
    final supplierController = TextEditingController();

    final generatedSku = CodeGenerator.next(
      prefix: 'PR',
      existingCodes:
          inventory.products.map((product) => product.sku),
    );

    String category = activeCategories.first.name;
    String unit = 'Pieces';
    String selectedBranchId = activeBranches.first.id;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Add New Product',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _sectionTitle('Basic Information'),

                      _field(
                        nameController,
                        'Product Name *',
                      ),

                      _readOnlyCode(
                        generatedSku,
                        'Automatically Generated Product Code',
                      ),

                      const SizedBox(height: 12),

                      _field(
                        barcodeController,
                        'Barcode',
                      ),

                      _field(
                        descriptionController,
                        'Product Description',
                        maxLines: 3,
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: category,
                        dropdownColor: panel,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _decoration('Category *'),
                        items: activeCategories.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.name,
                            child: Text(item.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              category = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle('Pricing Information'),

                      _field(
                        costController,
                        'Cost / Purchase Price *',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      _field(
                        sellingController,
                        'Selling Price *',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle('Stock Information'),

                      DropdownButtonFormField<String>(
                        value: unit,
                        dropdownColor: panel,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration:
                            _decoration('Unit of Measurement'),
                        items: units.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              unit = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      _field(
                        quantityController,
                        'Opening Quantity *',
                        keyboardType: TextInputType.number,
                      ),

                      _field(
                        minimumController,
                        'Minimum Stock Alert Level *',
                        keyboardType: TextInputType.number,
                      ),

                      DropdownButtonFormField<String>(
                        value: selectedBranchId,
                        dropdownColor: panel,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _decoration('Initial Branch'),
                        items: activeBranches.map((branch) {
                          return DropdownMenuItem<String>(
                            value: branch.id,
                            child: Text(branch.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedBranchId = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle('Supplier Information'),

                      _field(
                        supplierController,
                        'Supplier Name',
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'The opening quantity will be assigned to the selected branch. You can allocate more stock to other branches later.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: muted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final cost = double.tryParse(
                      costController.text.trim(),
                    );
                    final selling = double.tryParse(
                      sellingController.text.trim(),
                    );
                    final quantity = int.tryParse(
                      quantityController.text.trim(),
                    );
                    final minimum = int.tryParse(
                      minimumController.text.trim(),
                    );

                    if (name.isEmpty ||
                        cost == null ||
                        selling == null ||
                        quantity == null ||
                        minimum == null ||
                        cost < 0 ||
                        selling < 0 ||
                        quantity < 0 ||
                        minimum < 0) {
                      showMessage(
                        'Please enter valid product details.',
                      );
                      return;
                    }

                    try {
                      ref.read(inventoryProvider).addProduct(
                            name: name,
                            sku: generatedSku,
                            category: category,
                            barcode:
                                barcodeController.text.trim(),
                            description:
                                descriptionController.text.trim(),
                            costPrice: cost,
                            sellingPrice: selling,
                            unit: unit,
                            openingQuantity: quantity,
                            minimumStock: minimum,
                            supplier:
                                supplierController.text.trim(),
                            initialBranchId: selectedBranchId,
                          );

                      Navigator.pop(dialogContext);

                      showMessage(
                        'Product added successfully. Code: $generatedSku',
                      );
                    } catch (error) {
                      showMessage(
                        error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                      );
                    }
                  },
                  child: const Text('Save Product'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      barcodeController.dispose();
      descriptionController.dispose();
      costController.dispose();
      sellingController.dispose();
      quantityController.dispose();
      minimumController.dispose();
      supplierController.dispose();
    });
  }

  // ==========================================================
  // EDIT PRODUCT
  // ==========================================================

  void editProduct(InventoryProduct product) {
    final inventory = ref.read(inventoryProvider);

    final activeCategories = inventory.categories
        .where((category) => category.active)
        .toList();

    if (activeCategories.isEmpty) {
      showMessage(
        'Please activate at least one category before editing.',
      );
      return;
    }

    final nameController =
        TextEditingController(text: product.name);
    final barcodeController =
        TextEditingController(text: product.barcode);
    final descriptionController =
        TextEditingController(text: product.description);
    final costController = TextEditingController(
      text: product.costPrice.toString(),
    );
    final sellingController = TextEditingController(
      text: product.sellingPrice.toString(),
    );
    final minimumController = TextEditingController(
      text: product.minimumStock.toString(),
    );
    final supplierController =
        TextEditingController(text: product.supplier);

    final categoryNames =
        activeCategories.map((item) => item.name).toList();

    String category = categoryNames.contains(product.category)
        ? product.category
        : categoryNames.first;

    String unit =
        units.contains(product.unit) ? product.unit : units.first;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: panel,
              title: const Text(
                'Edit Product',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _sectionTitle('Product Information'),

                      _field(
                        nameController,
                        'Product Name *',
                      ),

                      _readOnlyCode(
                        product.sku,
                        'Product Code',
                      ),

                      const SizedBox(height: 12),

                      _field(
                        barcodeController,
                        'Barcode',
                      ),

                      _field(
                        descriptionController,
                        'Product Description',
                        maxLines: 3,
                      ),

                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: category,
                        dropdownColor: panel,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _decoration('Category *'),
                        items: activeCategories.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.name,
                            child: Text(item.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              category = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle('Pricing Information'),

                      _field(
                        costController,
                        'Cost / Purchase Price *',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      _field(
                        sellingController,
                        'Selling Price *',
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle('Product Settings'),

                      DropdownButtonFormField<String>(
                        value: unit,
                        dropdownColor: panel,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration:
                            _decoration('Unit of Measurement'),
                        items: units.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              unit = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 12),

                      _field(
                        minimumController,
                        'Minimum Stock Alert Level *',
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle('Supplier Information'),

                      _field(
                        supplierController,
                        'Supplier Name',
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Product code and current stock quantities cannot be changed from this form. Use Stock Management to adjust stock.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: muted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final cost = double.tryParse(
                      costController.text.trim(),
                    );
                    final selling = double.tryParse(
                      sellingController.text.trim(),
                    );
                    final minimum = int.tryParse(
                      minimumController.text.trim(),
                    );

                    if (name.isEmpty ||
                        cost == null ||
                        selling == null ||
                        minimum == null ||
                        cost < 0 ||
                        selling < 0 ||
                        minimum < 0) {
                      showMessage(
                        'Please enter valid product details.',
                      );
                      return;
                    }

                    try {
                      ref.read(inventoryProvider).updateProduct(
                            productId: product.id,
                            name: name,
                            category: category,
                            costPrice: cost,
                            sellingPrice: selling,
                            barcode:
                                barcodeController.text.trim(),
                            description:
                                descriptionController.text.trim(),
                            unit: unit,
                            minimumStock: minimum,
                            supplier:
                                supplierController.text.trim(),
                          );

                      Navigator.pop(dialogContext);
                      showMessage(
                        'Product updated successfully.',
                      );
                    } catch (error) {
                      showMessage(
                        error.toString().replaceFirst(
                              'Exception: ',
                              '',
                            ),
                      );
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      barcodeController.dispose();
      descriptionController.dispose();
      costController.dispose();
      sellingController.dispose();
      minimumController.dispose();
      supplierController.dispose();
    });
  }

  // ==========================================================
  // PRODUCT DETAILS
  // ==========================================================

  void showProductDetails(InventoryProduct product) {
    final inventory = ref.read(inventoryProvider);
    final branches = inventory.branches;

    showModalBottomSheet<bool>(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(22),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: muted.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${product.sku} • ${product.category}',
                  style: TextStyle(color: muted),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext, true);
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Product'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                _detailRow('Product Code', product.sku),
                _detailRow('Category', product.category),
                _detailRow('Barcode', product.barcode),
                _detailRow('Description', product.description),
                _detailRow('Supplier', product.supplier),
                _detailRow('Unit', product.unit),

                _detailRow(
                  'Cost Price',
                  'Rs. ${product.costPrice.toStringAsFixed(2)}',
                ),

                _detailRow(
                  'Selling Price',
                  'Rs. ${product.sellingPrice.toStringAsFixed(2)}',
                ),

                _detailRow(
                  'Profit per Unit',
                  'Rs. ${product.profitPerUnit.toStringAsFixed(2)}',
                ),

                _detailRow(
                  'Profit Margin',
                  '${product.profitMargin.toStringAsFixed(1)}%',
                ),

                _detailRow(
                  'Minimum Stock',
                  '${product.minimumStock} ${product.unit}',
                ),

                _detailRow(
                  'Total Stock',
                  '${product.quantity} ${product.unit}',
                ),

                const SizedBox(height: 20),

                Text(
                  'Branch-wise Stock',
                  style: TextStyle(
                    color: blue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                ...branches.map((branch) {
                  final quantity =
                      product.branchQuantities[branch.id] ?? 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF080B12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            branch.name,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '$quantity ${product.unit}',
                          style: TextStyle(
                            color: quantity <= product.minimumStock
                                ? Colors.orangeAccent
                                : Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    ).then((shouldEdit) {
      if (shouldEdit == true && mounted) {
        editProduct(product);
      }
    });
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              title,
              style: TextStyle(color: muted),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MAIN SCREEN
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);

    // Categories are now read directly from shared inventory data.
    final allCategories = inventory.categories;

    final categoryNames = allCategories
        .map((category) => category.name)
        .toList();

    // Keep inactive categories visible as filters so existing
    // products assigned to them can still be found.
    final filterCategories = ['All', ...categoryNames];

    if (!filterCategories.contains(selectedCategory)) {
      selectedCategory = 'All';
    }

    final visibleProducts =
        getFilteredProducts(inventory.products);

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        foregroundColor: Colors.white,
        title: const Text(
          'Product Master',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: addProduct,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Product',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:
                      'Search name, SKU, barcode or supplier...',
                  hintStyle: TextStyle(color: muted),
                  prefixIcon: Icon(
                    Icons.search,
                    color: blue,
                  ),
                  filled: true,
                  fillColor: panel,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 45,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: filterCategories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = filterCategories[index];
                  final selected =
                      selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    selectedColor: blue,
                    backgroundColor: panel,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : muted,
                    ),
                    side: BorderSide.none,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                12,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Product Inventory',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${visibleProducts.length} Products',
                    style: TextStyle(
                      color: blue,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: visibleProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No products found.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        90,
                      ),
                      itemCount: visibleProducts.length,
                      itemBuilder: (context, index) {
                        final product = visibleProducts[index];

                        final lowStock =
                            product.quantity <=
                                product.minimumStock;

                        return Card(
                          color: panel,
                          margin: const EdgeInsets.only(
                            bottom: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.all(14),
                            onTap: () {
                              showProductDetails(product);
                            },
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: blue.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                color: blue,
                              ),
                            ),
                            title: Text(
                              product.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(
                                top: 7,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${product.sku} • ${product.category}',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 11,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    'Cost: Rs. ${product.costPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 11,
                                    ),
                                  ),

                                  Text(
                                    'Selling: Rs. ${product.sellingPrice.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    product.supplier.isEmpty
                                        ? 'Supplier: Not specified'
                                        : 'Supplier: ${product.supplier}',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${product.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  product.unit,
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 10,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  lowStock ? 'Low Stock' : 'In Stock',
                                  style: TextStyle(
                                    color: lowStock
                                        ? Colors.orangeAccent
                                        : Colors.greenAccent,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addProduct,
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
