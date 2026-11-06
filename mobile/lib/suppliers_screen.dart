
import 'package:flutter/material.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final Color blue = const Color(0xFF5798FF);
  final Color panel = const Color(0xFF121D2D);
  final Color muted = const Color(0xFF91A4BE);

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> suppliers = [
    {
      'name': 'Kathmandu Electronics',
      'code': 'SUP-001',
      'contact': 'Ram Sharma',
      'phone': '9800000001',
      'email': 'info@kathmanduelectronics.com',
      'address': 'New Road, Kathmandu',
      'pan': '123456789',
      'payment': 'Cash',
      'active': true,
    },
    {
      'name': 'Pokhara Trading House',
      'code': 'SUP-002',
      'contact': 'Sita Thapa',
      'phone': '9800000002',
      'email': 'sales@pokharatrading.com',
      'address': 'Lakeside, Pokhara',
      'pan': '987654321',
      'payment': 'Credit 30 Days',
      'active': true,
    },
    {
      'name': 'Himalayan Supplies',
      'code': 'SUP-003',
      'contact': 'Hari Gurung',
      'phone': '9800000003',
      'email': 'hello@himalayansupplies.com',
      'address': 'Lalitpur, Nepal',
      'pan': '',
      'payment': 'Credit 15 Days',
      'active': false,
    },
  ];

  String searchText = '';

  List<Map<String, dynamic>> get filteredSuppliers {
    return suppliers.where((supplier) {
      final query = searchText.toLowerCase();

      return supplier['name'].toString().toLowerCase().contains(query) ||
          supplier['code'].toString().toLowerCase().contains(query) ||
          supplier['contact'].toString().toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showSupplierDialog({int? index}) {
    final isEditing = index != null;
    final supplier = isEditing ? suppliers[index] : null;

    final nameController =
        TextEditingController(text: supplier?['name'] ?? '');
    final codeController =
        TextEditingController(text: supplier?['code'] ?? '');
    final contactController =
        TextEditingController(text: supplier?['contact'] ?? '');
    final phoneController =
        TextEditingController(text: supplier?['phone'] ?? '');
    final emailController =
        TextEditingController(text: supplier?['email'] ?? '');
    final addressController =
        TextEditingController(text: supplier?['address'] ?? '');
    final panController =
        TextEditingController(text: supplier?['pan'] ?? '');

    String payment = supplier?['payment'] ?? 'Cash';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: panel,
              title: Text(
                isEditing ? 'Edit Supplier' : 'Add Supplier',
                style: const TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _field(nameController, 'Supplier Name *'),
                      const SizedBox(height: 12),
                      _field(codeController, 'Supplier Code *'),
                      const SizedBox(height: 12),
                      _field(contactController, 'Contact Person'),
                      const SizedBox(height: 12),
                      _field(
                        phoneController,
                        'Phone Number *',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        emailController,
                        'Email Address',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _field(
                        addressController,
                        'Address',
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      _field(panController, 'PAN / VAT Number'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: payment,
                        dropdownColor: panel,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('Payment Terms'),
                        items: const [
                          DropdownMenuItem(
                            value: 'Cash',
                            child: Text('Cash'),
                          ),
                          DropdownMenuItem(
                            value: 'Credit 15 Days',
                            child: Text('Credit 15 Days'),
                          ),
                          DropdownMenuItem(
                            value: 'Credit 30 Days',
                            child: Text('Credit 30 Days'),
                          ),
                          DropdownMenuItem(
                            value: 'Credit 45 Days',
                            child: Text('Credit 45 Days'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => payment = value);
                          }
                        },
                      ),
                    ],
                  ),
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
                    final phone = phoneController.text.trim();
                    final email = emailController.text.trim();

                    if (name.isEmpty || code.isEmpty || phone.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Supplier name, code and phone are required.',
                          ),
                        ),
                      );
                      return;
                    }

                    if (email.isNotEmpty &&
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid email address.'),
                        ),
                      );
                      return;
                    }

                    final duplicate = suppliers.indexWhere((item) {
                      return item['code'].toString().toLowerCase() ==
                              code.toLowerCase() &&
                          (!isEditing || suppliers[index] != item);
                    });

                    if (duplicate != -1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'This supplier code already exists.',
                          ),
                        ),
                      );
                      return;
                    }

                    final newSupplier = {
                      'name': name,
                      'code': code,
                      'contact': contactController.text.trim(),
                      'phone': phone,
                      'email': email,
                      'address': addressController.text.trim(),
                      'pan': panController.text.trim(),
                      'payment': payment,
                      'active': isEditing
                          ? suppliers[index]['active']
                          : true,
                    };

                    setState(() {
                      if (isEditing) {
                        suppliers[index] = newSupplier;
                      } else {
                        suppliers.add(newSupplier);
                      }
                    });

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Supplier updated successfully.'
                              : 'Supplier added successfully.',
                        ),
                      ),
                    );
                  },
                  child: Text(isEditing ? 'Update' : 'Save Supplier'),
                ),
              ],
            );
          },
        );
      },
    );
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
        borderSide: BorderSide(color: muted.withOpacity(0.25)),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
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

  void deleteSupplier(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: const Text(
          'Delete Supplier?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this supplier?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => suppliers.removeAt(index));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Supplier deleted.')),
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

  void showSupplierDetails(Map<String, dynamic> supplier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: muted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  supplier['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  supplier['code'],
                  style: TextStyle(color: muted),
                ),
                const Divider(height: 28, color: Colors.white12),
                _detailRow('Contact Person', supplier['contact']),
                _detailRow('Phone', supplier['phone']),
                _detailRow('Email', supplier['email']),
                _detailRow('Address', supplier['address']),
                _detailRow('PAN / VAT', supplier['pan']),
                _detailRow('Payment Terms', supplier['payment']),
                _detailRow(
                  'Status',
                  supplier['active'] ? 'Active' : 'Inactive',
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      showSupplierDialog(
                        index: suppliers.indexOf(supplier),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Supplier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: TextStyle(color: muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount =
        suppliers.where((supplier) => supplier['active'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        foregroundColor: Colors.white,
        title: const Text('Suppliers'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSupplierDialog(),
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _summaryCard(
                  'Total Suppliers',
                  suppliers.length,
                  Icons.local_shipping_outlined,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  'Active Suppliers',
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
                hintText: 'Search suppliers...',
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
              child: filteredSuppliers.isEmpty
                  ? Center(
                      child: Text(
                        'No suppliers found.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredSuppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = filteredSuppliers[index];
                        final originalIndex = suppliers.indexOf(supplier);
                        final isActive = supplier['active'] == true;

                        return InkWell(
                          onTap: () => showSupplierDetails(supplier),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: panel,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: blue.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping_outlined,
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
                                        supplier['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        supplier['code'],
                                        style: TextStyle(
                                          color: muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        supplier['phone'],
                                        style: TextStyle(
                                          color: muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: isActive
                                              ? Colors.greenAccent
                                              : Colors.redAccent,
                                          fontSize: 11,
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
                                      showSupplierDialog(
                                        index: originalIndex,
                                      );
                                    } else if (value == 'toggle') {
                                      setState(() {
                                        suppliers[originalIndex]['active'] =
                                            !isActive;
                                      });
                                    } else if (value == 'delete') {
                                      deleteSupplier(originalIndex);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text(
                                        'Edit',
                                        style: TextStyle(color: Colors.white),
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
