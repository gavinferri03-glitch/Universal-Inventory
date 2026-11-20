
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_suppliers.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() =>
      _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  static const Color blue = Color(0xFF5798FF);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);

  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';
  String filter = 'all';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  InputDecoration decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
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

  Future<void> showSupplierDialog({
    InventorySupplier? supplier,
  }) async {
    final editing = supplier != null;
    final formKey = GlobalKey<FormState>();

    final name = TextEditingController(text: supplier?.name ?? '');
    final code = TextEditingController(text: supplier?.code ?? '');
    final contact = TextEditingController(
      text: supplier?.contactPerson ?? '',
    );
    final phone = TextEditingController(text: supplier?.phone ?? '');
    final email = TextEditingController(text: supplier?.email ?? '');
    final address = TextEditingController(
      text: supplier?.address ?? '',
    );
    final panVat = TextEditingController(
      text: supplier?.panVat ?? '',
    );

    String payment = supplier?.paymentTerms ?? 'Cash';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: panel,
              title: Text(
                editing ? 'Edit Supplier' : 'Add Supplier',
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
                        _formField(name, 'Supplier Name *'),
                        const SizedBox(height: 12),
                        _formField(
                          code,
                          editing
                              ? 'Supplier Code *'
                              : 'Supplier Code (optional)',
                        ),
                        const SizedBox(height: 12),
                        _formField(contact, 'Contact Person'),
                        const SizedBox(height: 12),
                        _formField(
                          phone,
                          'Phone Number *',
                          keyboard: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        _formField(
                          email,
                          'Email Address',
                          keyboard: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _formField(
                          address,
                          'Address',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        _formField(panVat, 'PAN / VAT Number'),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: payment,
                          dropdownColor: panel,
                          style: const TextStyle(color: Colors.white),
                          decoration: decoration('Payment Terms'),
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
                  child: const Text(
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
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: Text(editing ? 'Update' : 'Save Supplier'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      try {
        final data = ref.read(inventorySupplierProvider);

        if (editing) {
          await data.updateSupplier(
            supplierId: supplier.id,
            name: name.text,
            code: code.text,
            phone: phone.text,
            contactPerson: contact.text,
            email: email.text,
            address: address.text,
            panVat: panVat.text,
            paymentTerms: payment,
          );
        } else {
          await data.addSupplier(
            name: name.text,
            code: code.text,
            phone: phone.text,
            contactPerson: contact.text,
            email: email.text,
            address: address.text,
            panVat: panVat.text,
            paymentTerms: payment,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(
              content: Text(
                editing
                    ? 'Supplier updated successfully.'
                    : 'Supplier saved successfully.',
              ),
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(this.context).showSnackBar(
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

  Widget _formField(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: decoration(label),
      validator: (value) {
        if (label.contains('*') && (value == null || value.trim().isEmpty)) {
          return 'This field is required.';
        }
        if (label == 'Email Address' &&
            value != null &&
            value.trim().isNotEmpty &&
            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                .hasMatch(value.trim())) {
          return 'Enter a valid email address.';
        }
        return null;
      },
    );
  }

  Widget summaryCard(String title, int count, IconData icon) {
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
            const SizedBox(height: 9),
            Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title, style: const TextStyle(color: muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void showDetails(InventorySupplier supplier) {
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
                Text(
                  supplier.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(supplier.code,
                    style: const TextStyle(color: muted)),
                const Divider(height: 28, color: Colors.white12),
                _detail('Contact Person', supplier.contactPerson),
                _detail('Phone', supplier.phone),
                _detail('Email', supplier.email),
                _detail('Address', supplier.address),
                _detail('PAN / VAT', supplier.panVat),
                _detail('Payment Terms', supplier.paymentTerms),
                _detail('Status', supplier.active ? 'Active' : 'Inactive'),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      showSupplierDialog(supplier: supplier);
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

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(label,
                style: const TextStyle(color: muted, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> toggleStatus(InventorySupplier supplier) async {
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

  @override
  Widget build(BuildContext context) {
    final initialization = ref.watch(supplierInitializationProvider);
    final data = ref.watch(inventorySupplierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        foregroundColor: Colors.white,
        title: const Text('Supplier Master'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSupplierDialog(),
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Supplier'),
      ),
      body: initialization.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: blue),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Could not load suppliers.\n$error',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        data: (_) {
          final all = data.suppliers;
          final active = data.activeSupplierCount;
          final inactive = data.inactiveSupplierCount;

          var visible = data.searchSuppliers(searchText);

          if (filter == 'active') {
            visible = visible.where((e) => e.active).toList();
          } else if (filter == 'inactive') {
            visible = visible.where((e) => !e.active).toList();
          }

          visible.sort((a, b) =>
              a.name.toLowerCase().compareTo(b.name.toLowerCase()));

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    summaryCard(
                      'Total Suppliers',
                      all.length,
                      Icons.local_shipping_outlined,
                    ),
                    const SizedBox(width: 10),
                    summaryCard(
                      'Active',
                      active,
                      Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 10),
                    summaryCard(
                      'Inactive',
                      inactive,
                      Icons.pause_circle_outline,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() => searchText = value);
                  },
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
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: filter,
                  dropdownColor: panel,
                  style: const TextStyle(color: Colors.white),
                  decoration: decoration('Show suppliers'),
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All suppliers'),
                    ),
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Active suppliers'),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('Inactive suppliers'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => filter = value);
                  },
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: visible.isEmpty
                      ? const Center(
                          child: Text(
                            'No suppliers found.\nTap Add Supplier to create one.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: muted),
                          ),
                        )
                      : ListView.builder(
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final supplier = visible[index];

                            return InkWell(
                              onTap: () => showDetails(supplier),
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
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
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
                                            supplier.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${supplier.code} • ${supplier.phone}',
                 