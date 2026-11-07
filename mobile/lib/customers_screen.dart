
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'list_tools.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() =>
      _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  static const Color blue = Color(0xFF5798FF);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);
  static const Color background = Color(0xFF080B12);

  final TextEditingController searchController =
      TextEditingController();

  String searchText = '';
  String selectedSort = 'name_az';
  String selectedFilter = 'all';

  final Map<String, String> sortOptions = {
    'name_az': 'Name: A–Z',
    'name_za': 'Name: Z–A',
    'code_az': 'Customer code: A–Z',
    'code_za': 'Customer code: Z–A',
    'newest': 'Newest first',
    'oldest': 'Oldest first',
    'city_az': 'City: A–Z',
  };

  final Map<String, String> filterOptions = {
    'all': 'All customers',
    'active': 'Active customers',
    'inactive': 'Inactive customers',
    'with_email': 'With email',
    'with_phone': 'With phone',
  };

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<InventoryCustomer> getCustomers(
      InventoryData data) {
    final query = searchText.trim().toLowerCase();

    final result = data.searchCustomers(query).where((customer) {
      switch (selectedFilter) {
        case 'active':
          return customer.active;
        case 'inactive':
          return !customer.active;
        case 'with_email':
          return customer.email.isNotEmpty;
        case 'with_phone':
          return customer.phone.isNotEmpty;
        default:
          return true;
      }
    }).toList();

    switch (selectedSort) {
      case 'name_az':
        result.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'name_za':
        result.sort((a, b) =>
            b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'code_az':
        result.sort((a, b) => a.code.compareTo(b.code));
        break;
      case 'code_za':
        result.sort((a, b) => b.code.compareTo(a.code));
        break;
      case 'newest':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'city_az':
        result.sort((a, b) =>
            a.city.toLowerCase().compareTo(b.city.toLowerCase()));
        break;
    }

    return result;
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: muted),
      filled: true,
      fillColor: background,
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

  Future<void> _showCustomerDialog({
    InventoryCustomer? customer,
  }) async {
    final isEditing = customer != null;

    final name = TextEditingController(text: customer?.name ?? '');
    final phone = TextEditingController(text: customer?.phone ?? '');
    final email = TextEditingController(text: customer?.email ?? '');
    final address = TextEditingController(text: customer?.address ?? '');
    final city = TextEditingController(text: customer?.city ?? '');
    final country =
        TextEditingController(text: customer?.country ?? 'Nepal');
    final notes = TextEditingController(text: customer?.notes ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panel,
          title: Text(
            isEditing ? 'Edit Customer' : 'Add Customer',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEditing) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Customer Code: ${customer.code}',
                        style: const TextStyle(
                          color: blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  _field(name, 'Customer Name *'),
                  const SizedBox(height: 12),
                  _field(
                    phone,
                    'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    email,
                    'Email Address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _field(address, 'Address', maxLines: 2),
                  const SizedBox(height: 12),
                  _field(city, 'City'),
                  const SizedBox(height: 12),
                  _field(country, 'Country'),
                  const SizedBox(height: 12),
                  _field(notes, 'Notes', maxLines: 3),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '* Enter at least a phone number or email.',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
                try {
                  final data = ref.read(inventoryProvider);

                  if (isEditing) {
                    data.updateCustomer(
                      customerId: customer.id,
                      name: name.text,
                      phone: phone.text,
                      email: email.text,
                      address: address.text,
                      city: city.text,
                      country: country.text,
                      notes: notes.text,
                    );
                  } else {
                    data.addCustomer(
                      name: name.text,
                      phone: phone.text,
                      email: email.text,
                      address: address.text,
                      city: city.text,
                      country: country.text,
                      notes: notes.text,
                    );
                  }

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEditing
                            ? 'Customer updated successfully.'
                            : 'Customer added successfully.',
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text(isEditing ? 'Update' : 'Save Customer'),
            ),
          ],
        );
      },
    );

    name.dispose();
    phone.dispose();
    email.dispose();
    address.dispose();
    city.dispose();
    country.dispose();
    notes.dispose();
  }

  void _deleteCustomer(InventoryCustomer customer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: const Text(
          'Delete Customer?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete ${customer.name}? This action cannot be undone.',
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
                ref.read(inventoryProvider)
                    .deleteCustomer(customer.id);

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Customer deleted successfully.'),
                  ),
                );
              } catch (e) {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
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

  void _toggleStatus(InventoryCustomer customer) {
    try {
      ref.read(inventoryProvider)
          .toggleCustomerStatus(customer.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            customer.active
                ? 'Customer deactivated.'
                : 'Customer activated.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showDetails(InventoryCustomer customer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
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
                    customer.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    customer.code,
                    style: const TextStyle(color: blue),
                  ),
                  const Divider(
                    height: 28,
                    color: Colors.white12,
                  ),
                  _detailRow('Phone', customer.phone),
                  _detailRow('Email', customer.email),
                  _detailRow('Address', customer.address),
                  _detailRow('City', customer.city),
                  _detailRow('Country', customer.country),
                  _detailRow('Notes', customer.notes),
                  _detailRow(
                    'Created',
                    '${customer.createdAt.day}/'
                    '${customer.createdAt.month}/'
                    '${customer.createdAt.year}',
                  ),
                  _detailRow(
                    'Status',
                    customer.active ? 'Active' : 'Inactive',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _showCustomerDialog(customer: customer);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Customer'),
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
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontSize: 13,
              ),
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

  Widget _summaryCard(
    String title,
    int value,
    IconData icon,
  ) {
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
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerCard(InventoryCustomer customer) {
    return Card(
      color: panel,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: () => _showDetails(customer),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 7,
        ),
        leading: CircleAvatar(
          backgroundColor: blue.withOpacity(0.15),
          child: Text(
            customer.name.isEmpty
                ? '?'
                : customer.name[0].toUpperCase(),
            style: const TextStyle(
              color: blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customer.code,
                style: const TextStyle(
                  color: blue,
                  fontSize: 12,
                ),
              ),
              if (customer.phone.isNotEmpty)
                Text(
                  customer.phone,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
              Text(
                customer.active ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: customer.active
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: muted),
          color: panel,
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showCustomerDialog(customer: customer);
                break;
              case 'status':
                _toggleStatus(customer);
                break;
              case 'delete':
                _deleteCustomer(customer);
                break;
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text(
                'Edit',
                style: TextStyle(color: Colors.white),
              ),
            ),
            PopupMenuItem(
              value: 'status',
              child: Text(
                customer.active ? 'Deactivate' : 'Activate',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(inventoryProvider);
    final customers = getCustomers(data);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: const Text('Customers'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerDialog(),
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Customer'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _summaryCard(
                    'Total',
                    data.totalCustomerCount,
                    Icons.people,
                  ),
                  const SizedBox(width: 10),
                  _summaryCard(
                    'Active',
                    data.activeCustomerCount,
                    Icons.person,
                  ),
                  const SizedBox(width: 10),
                  _summaryCard(
                    'Inactive',
                    data.totalCustomerCount -
                        data.activeCustomerCount,
                    Icons.person_off,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InventoryListToolbar(
                searchController: searchController,
                searchHint: 'Search customers...',
                onSearchChanged: (value) {
                  setState(() => searchText = value);
                },
                sortOptions: sortOptions,
                selectedSort: selectedSort,
                onSortChanged: (value) {
                  setState(() => selectedSort = value);
                },
                filterOptions: filterOptions,
                selectedFilter: selectedFilter,
                onFilterChanged: (value) {
                  setState(() => selectedFilter = value);
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: customers.isEmpty
                  ? const Center(
                      child: Text(
                        'No customers found.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        4,
                        16,
                        90,
                      ),
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        return _customerCard(customers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
