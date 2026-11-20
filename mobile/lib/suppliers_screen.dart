
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_suppliers.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  final searchController = TextEditingController();
  String search = '';

  static const bg = Color(0xFF080B12);
  static const panel = Color(0xFF121D2D);
  static const blue = Color(0xFF5798FF);
  static const muted = Color(0xFF91A4BE);

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> editSupplier({InventorySupplier? supplier}) async {
    final name = TextEditingController(text: supplier?.name ?? '');
    final code = TextEditingController(text: supplier?.code ?? '');
    final contact = TextEditingController(
      text: supplier?.contactPerson ?? '',
    );
    final phone = TextEditingController(text: supplier?.phone ?? '');
    final email = TextEditingController(text: supplier?.email ?? '');
    final address = TextEditingController(text: supplier?.address ?? '');
    final panVat = TextEditingController(text: supplier?.panVat ?? '');

    String payment = supplier?.paymentTerms ?? 'Cash';

    final formKey = GlobalKey<FormState>();

    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: panel,
              title: Text(
                supplier == null ? 'Add Supplier' : 'Edit Supplier',
                style: const TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        field(name, 'Supplier Name *'),
                        field(code, 'Supplier Code (optional)'),
                        field(contact, 'Contact Person'),
                        field(phone, 'Phone Number *',
                            keyboard: TextInputType.phone),
                        field(email, 'Email Address',
                            keyboard: TextInputType.emailAddress),
                        field(address, 'Address', maxLines: 2),
                        field(panVat, 'PAN / VAT Number'),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: payment,
                          dropdownColor: panel,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputDecoration('Payment Terms'),
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (save == true && mounted) {
      try {
        final data = ref.read(inventorySupplierProvider);

        if (supplier == null) {
          await data.addSupplier(
            name: name.text,
            code: code.text,
            contactPerson: contact.text,
            phone: phone.text,
            email: email.text,
            address: address.text,
            panVat: panVat.text,
            paymentTerms: payment,
          );
        } else {
          await data.updateSupplier(
            supplierId: supplier.id,
            name: name.text,
            code: code.text,
            contactPerson: contact.text,
            phone: phone.text,
            email: email.text,
            address: address.text,
            panVat: panVat.text,
            paymentTerms: payment,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier saved successfully.')),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.toString())),
          );
        }
      }
    }

    name.dispose();
    code.dispose();
    contact.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    panVat.dispose();
  }

  Widget field(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: inputDecoration(label),
        validator: (value) {
          if (label.endsWith('*') &&
              (value == null || value.trim().isEmpty)) {
            return 'This field is required.';
          }
          if (label == 'Email Address' &&
              value != null &&
              value.trim().isNotEmpty &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                  .hasMatch(value.trim())) {
            return 'Enter a valid email.';
          }
          return null;
        },
      ),
    );
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
      filled: true,
      fillColor: bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Future<void> toggleSupplier(InventorySupplier supplier) async {
    try {
      await ref.read(inventorySupplierProvider).setSupplierActive(
            supplier.id,
            !supplier.active,
          );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  void showSupplier(InventorySupplier supplier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                detail('Code', supplier.code),
                detail('Contact', supplier.contactPerson),
                detail('Phone', supplier.phone),
                detail('Email', supplier.email),
                detail('Address', supplier.address),
                detail('PAN / VAT', supplier.panVat),
                detail('Payment', supplier.paymentTerms),
                detail('Status', supplier.active ? 'Active' : 'Inactive'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          editSupplier(supplier: supplier);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          toggleSupplier(supplier);
                        },
                        child: Text(
                          supplier.active ? 'Deactivate' : 'Activate',
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
    );
  }

  Widget detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: Text(label, style: const TextStyle(color: muted)),
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

  @override
  Widget build(BuildContext context) {
    final initialization = ref.watch(supplierInitializationProvider);
    final data = ref.watch(inventorySupplierProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        title: const Text('Supplier Master'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => editSupplier(),
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
      body: initialization.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Unable to load suppliers: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (_) {
          final suppliers = data.searchSuppliers(search);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    statCard('Total', data.totalSuppliers),
                    const SizedBox(width: 10),
                    statCard('Active', data.activeSupplierCount),
                    const SizedBox(width: 10),
                    statCard('Inactive', data.inactiveSupplierCount),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: searchController,
                  onChanged: (value) => setState(() => search = value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search suppliers...',
                    hintStyle: const TextStyle(color: muted),
                    prefixIcon: const Icon(Icons.search, color: muted),
                    filled: true,
                    fillColor: panel,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: suppliers.isEmpty
                      ? const Center(
                          child: Text(
                            'No suppliers found.\nTap Add Supplier to begin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: muted),
                          ),
                        )
                      : ListView.builder(
                          itemCount: suppliers.length,
                          itemBuilder: (context, index) {
                            final supplier = suppliers[index];

                            return Card(
                              color: panel,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                onTap: () => showSupplier(supplier),
                                leading: const CircleAvatar(
                                  backgroundColor: bg,
                                  child: Icon(
                                    Icons.local_shipping_outlined,
                                    color: blue,
                                  ),
                                ),
                                title: Text(
                                  supplier.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${supplier.code} • ${supplier.phone}\n${supplier.active ? 'Active' : 'Inactive'}',
                                  style: const TextStyle(color: muted),
                                ),
                                isThreeLine: true,
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  color: muted,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget statCard(String label, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
