
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'code_generator.dart';
import 'list_tools.dart';

class BranchesScreen extends ConsumerStatefulWidget {
  const BranchesScreen({super.key});

  @override
  ConsumerState<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends ConsumerState<BranchesScreen> {
  static const Color blue = Color(0xFF5798FF);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);

  final TextEditingController searchController = TextEditingController();

  String searchText = '';
  String selectedSort = 'name_az';
  String selectedFilter = 'all';

  List<InventoryBranch> getFilteredBranches(
    List<InventoryBranch> branches,
  ) {
    final query = searchText.trim().toLowerCase();

    final result = branches.where((branch) {
      final searchableText = [
        branch.name,
        branch.code,
        branch.city,
        branch.address,
        branch.phone,
        branch.email,
        branch.manager,
      ].join(' ').toLowerCase();

      final matchesSearch =
          query.isEmpty || searchableText.contains(query);

      final matchesFilter = selectedFilter == 'all' ||
          (selectedFilter == 'active' && branch.active) ||
          (selectedFilter == 'inactive' && !branch.active);

      return matchesSearch && matchesFilter;
    }).toList();

    switch (selectedSort) {
      case 'name_za':
        result.sort((a, b) =>
            b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'city_az':
        result.sort((a, b) =>
            a.city.toLowerCase().compareTo(b.city.toLowerCase()));
        break;
      case 'city_za':
        result.sort((a, b) =>
            b.city.toLowerCase().compareTo(a.city.toLowerCase()));
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
        result.sort((a, b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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

  void showBranchForm({InventoryBranch? branch}) {
    final inventory = ref.read(inventoryProvider);

    final nameController =
        TextEditingController(text: branch?.name ?? '');

    final codeController = TextEditingController(
      text: branch?.code ??
          CodeGenerator.next(
            prefix: 'BR',
            existingCodes: inventory.branches.map((item) => item.code),
          ),
    );

    final cityController =
        TextEditingController(text: branch?.city ?? '');
    final addressController =
        TextEditingController(text: branch?.address ?? '');
    final phoneController =
        TextEditingController(text: branch?.phone ?? '');
    final emailController =
        TextEditingController(text: branch?.email ?? '');
    final managerController =
        TextEditingController(text: branch?.manager ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panel,
          title: Text(
            branch == null ? 'Add Branch' : 'Edit Branch',
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _formField(nameController, 'Branch Name *'),
                  _formField(
                    codeController,
                    'Branch Code (Auto-generated)',
                    readOnly: true,
                  ),
                  _formField(cityController, 'City *'),
                  _formField(addressController, 'Address'),
                  _formField(phoneController, 'Phone Number'),
                  _formField(emailController, 'Email'),
                  _formField(managerController, 'Branch Manager'),
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
                final city = cityController.text.trim();

                if (name.isEmpty || city.isEmpty) {
                  showMessage('Please fill all required fields.');
                  return;
                }

                try {
                  final inventory = ref.read(inventoryProvider);

                  if (branch == null) {
                    inventory.addBranch(
                      name: name,
                      code: code,
                      city: city,
                      address: addressController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      manager: managerController.text.trim(),
                    );
                  } else {
                    inventory.updateBranch(
                      id: branch.id,
                      name: name,
                      code: code,
                      city: city,
                      address: addressController.text.trim(),
                      phone: phoneController.text.trim(),
                      email: emailController.text.trim(),
                      manager: managerController.text.trim(),
                    );
                  }

                  Navigator.pop(dialogContext);
                  setState(() {});

                  showMessage(
                    branch == null
                        ? 'Branch added successfully.'
                        : 'Branch updated successfully.',
                  );
                } catch (error) {
                  showMessage(
                    error.toString().replaceFirst('Exception: ', ''),
                  );
                }
              },
              child: Text(branch == null ? 'Save Branch' : 'Update Branch'),
            ),
          ],
        );
      },
    );
  }

  Widget _formField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: muted),
          filled: true,
          fillColor: const Color(0xFF080B12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void showBranchDetails(InventoryBranch branch) {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
                  Text(
                    branch.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(branch.code, style: const TextStyle(color: muted)),
                  const SizedBox(height: 20),
                  _detailRow('City', branch.city),
                  _detailRow('Address', branch.address),
                  _detailRow('Phone', branch.phone),
                  _detailRow('Email', branch.email),
                  _detailRow('Manager', branch.manager),
                  _detailRow(
                    'Status',
                    branch.active ? 'Active' : 'Inactive',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            showBranchForm(branch: branch);
                          },
                          child: const Text('Edit Branch'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            ref
                                .read(inventoryProvider)
                                .toggleBranchStatus(branch.id);
                            Navigator.pop(sheetContext);
                            setState(() {});
                          },
                          child: Text(
                            branch.active ? 'Deactivate' : 'Activate',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(title, style: const TextStyle(color: muted)),
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

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: blue, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final branches = inventory.branches;
    final visibleBranches = getFilteredBranches(branches);

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        foregroundColor: Colors.white,
        title: const Text('Branches'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showBranchForm(),
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Branch'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      'Total Branches',
                      branches.length.toString(),
                      Icons.business,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      'Active Branches',
                      inventory.activeBranchCount.toString(),
                      Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InventoryListToolbar(
                searchController: searchController,
                searchHint: 'Search branch, code, city, manager...',
                onSearchChanged: (value) {
                  setState(() => searchText = value);
                },
                sortOptions: const {
                  'name_az': 'Name: A–Z',
                  'name_za': 'Name: Z–A',
                  'city_az': 'City: A–Z',
                  'city_za': 'City: Z–A',
                  'active_first': 'Active first',
                  'inactive_first': 'Inactive first',
                },
                selectedSort: selectedSort,
                onSortChanged: (value) {
                  setState(() => selectedSort = value);
                },
                filterOptions: const {
                  'all': 'All branches',
                  'active': 'Active only',
                  'inactive': 'Inactive only',
                },
                selectedFilter: selectedFilter,
                onFilterChanged: (value) {
                  setState(() => selectedFilter = value);
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: visibleBranches.isEmpty
                  ? Center(
                      child: Text(
                        'No branches found.',
                        style: const TextStyle(color: muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      itemCount: visibleBranches.length,
                      itemBuilder: (context, index) {
                        final branch = visibleBranches[index];

                        return Card(
                          color: panel,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            onTap: () => showBranchDetails(branch),
                            leading: CircleAvatar(
                              backgroundColor: blue.withValues(alpha: 0.15),
                              child: const Icon(Icons.store, color: blue),
                            ),
                            title: Text(
                              branch.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${branch.code} • ${branch.city}',
                                style: const TextStyle(color: muted),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: branch.active
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  branch.active ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: branch.active
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
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
    );
  }
}
