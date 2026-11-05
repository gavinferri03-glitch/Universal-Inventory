
import 'package:flutter/material.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController searchController = TextEditingController();

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Electronics',
    'Accessories',
    'Furniture',
    'Other',
  ];

  final List<Map<String, dynamic>> products = [
    {
      'name': 'Wireless Mouse',
      'sku': 'ELE-001',
      'category': 'Electronics',
      'price': 850.0,
      'quantity': 20,
    },
    {
      'name': 'USB Keyboard',
      'sku': 'ACC-002',
      'category': 'Accessories',
      'price': 1200.0,
      'quantity': 8,
    },
    {
      'name': 'HDMI Cable',
      'sku': 'ACC-003',
      'category': 'Accessories',
      'price': 450.0,
      'quantity': 5,
    },
    {
      'name': 'Bluetooth Speaker',
      'sku': 'ELE-004',
      'category': 'Electronics',
      'price': 2500.0,
      'quantity': 35,
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    return products.where((product) {
      final query = searchController.text.toLowerCase();

      final matchesSearch =
          product['name'].toString().toLowerCase().contains(query) ||
          product['sku'].toString().toLowerCase().contains(query);

      final matchesCategory = selectedCategory == 'All' ||
          product['category'] == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void addProduct() {
    final nameController = TextEditingController();
    final skuController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();

    String category = 'Electronics';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF172436),
              title: const Text(
                'Add New Product',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _field(nameController, 'Product Name'),
                    _field(skuController, 'SKU / Product Code'),
                    _field(
                      priceController,
                      'Selling Price',
                      keyboardType: TextInputType.number,
                    ),
                    _field(
                      quantityController,
                      'Opening Quantity',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: category,
                      dropdownColor: const Color(0xFF172436),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                      items: categories
                          .where((item) => item != 'All')
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => category = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final sku = skuController.text.trim();
                    final price = double.tryParse(priceController.text);
                    final quantity =
                        int.tryParse(quantityController.text);

                    if (name.isEmpty ||
                        sku.isEmpty ||
                        price == null ||
                        quantity == null ||
                        price < 0 ||
                        quantity < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter valid product details.'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      products.add({
                        'name': name,
                        'sku': sku,
                        'category': category,
                        'price': price,
                        'quantity': quantity,
                      });
                    });

                    Navigator.pop(dialogContext);
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
      skuController.dispose();
      priceController.dispose();
      quantityController.dispose();
    });
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleProducts = filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1421),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101927),
        foregroundColor: Colors.white,
        title: const Text(
          'Products',
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
                  hintText: 'Search products or SKU...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF78AEFF),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF172436),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final selected = selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => selectedCategory = category);
                    },
                    selectedColor: const Color(0xFF347FE2),
                    backgroundColor: const Color(0xFF172436),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                    ),
                    side: BorderSide.none,
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    style: const TextStyle(
                      color: Color(0xFF78AEFF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: visibleProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'No products found.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: visibleProducts.length,
                      itemBuilder: (context, index) {
                        final product = visibleProducts[index];
                        final quantity = product['quantity'] as int;
                        final lowStock = quantity <= 10;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF172436),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF347FE2)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_outlined,
                                  color: Color(0xFF78AEFF),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'].toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${product['sku']} • ${product['category']}',
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rs. ${product['price']}',
                                      style: const TextStyle(
                                        color: Color(0xFF78AEFF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$quantity units',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    lowStock ? 'Low Stock' : 'In Stock',
                                    style: TextStyle(
                                      color: lowStock
                                          ? const Color(0xFFFFB454)
                                          : const Color(0xFF54D69A),
                                      fontSize: 11,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addProduct,
        backgroundColor: const Color(0xFF347FE2),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
