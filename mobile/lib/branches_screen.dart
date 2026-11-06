
import 'package:flutter/material.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  final Color blue = const Color(0xFF5798FF);
  final Color panel = const Color(0xFF121D2D);
  final Color muted = const Color(0xFF91A4BE);

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> branches = [
    {
      'name': 'Main Branch',
      'code': 'BR-001',
      'city': 'Kathmandu',
      'address': 'New Road, Kathmandu',
      'phone': '9800000001',
      'email': 'kathmandu@example.com',
      'manager': 'Branch Manager',
      'active': true,
    },
    {
      'name': 'Pokhara Branch',
      'code': 'BR-002',
      'city': 'Pokhara',
      'address': 'Lakeside, Pokhara',
      'phone': '9800000002',
      'email': 'pokhara@example.com',
      'manager': 'Branch Manager',
      'active': true,
    },
    {
      'name': 'Lalitpur Branch',
      'code': 'BR-003',
      'city': 'Lalitpur',
      'address': 'Jawalakhel, Lalitpur',
      'phone': '9800000003',
      'email': 'lalitpur@example.com',
      'manager': 'Branch Manager',
      'active': false,
    },
  ];

  String filter = 'All';

  List<Map<String, dynamic>> get filteredBranches {
    return branches.where((branch) {
      final query = searchController.text.toLowerCase();

      final matchesSearch =
          branch['name'].toString().toLowerCase().contains(query) ||
          branch['code'].toString().toLowerCase().contains(query) ||
          branch['city'].toString().toLowerCase().contains(query);

      final matchesFilter = filter == 'All' ||
          (filter == 'Active' && branch['active'] == true) ||
          (filter == 'Inactive' && branch['active'] == false);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showBranchForm({Map<String, dynamic>? branch}) {
    final nameController =
        TextEditingController(text: branch?['name'] ?? '');
    final codeController =
        TextEditingController(text: branch?['code'] ?? '');
    final cityController =
        TextEditingController(text: branch?['city'] ?? '');
    final addressController =
        TextEditingController(text: branch?['address'] ?? '');
    final phoneController =
        TextEditingController(text: branch?['phone'] ?? '');
    final emailController =
        TextEditingController(text: branch?['email'] ?? '');
    final managerController =
        TextEditingController(text: branch?['manager'] ?? '');

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
                  _formField(codeController, 'Branch Code *'),
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
                if (nameController.text.trim().isEmpty ||
                    codeController.text.trim().isEmpty ||
                    cityController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all required fields.'),
                    ),
                  );
                  return;
                }

                final code = codeController.text.trim().toLowerCase();

                final duplicate = branches.any((item) =>
                    item['code'].toString().toLowerCase() == code &&
                    item != branch);

                if (duplicate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('This branch code already exists.'),
                    ),
                  );
                  return;
                }

                setState(() {
                  final data = {
                    'name': nameController.text.trim(),
                    'code': codeController.text.trim(),
                    'city': cityController.text.trim(),
                    'address': addressController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'email': emailController.text.trim(),
                    'manager': managerController.text.trim(),
                    'active': branch?['active'] ?? true,
                  };

                  if (branch == null) {
                    branches.add(data);
                  } else {
                    final index = branches.indexOf(branch);
                    branches[index] = data;
                  }
                });

                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      branch == null
                          ? 'Branch added successfully.'
                          : 'Branch updated successfully.',
                    ),
                  ),
                );
              },
              child: const Text('Save Branch'),
            ),
          ],
        );
      },
    );
  }

  Widget _formField(
    TextEditingController controller,
    String label,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: muted),
          filled: true,
          fillColor: const Color(0xFF080B12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void showBranchDetails(Map<String, dynamic> branch) {
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                branch['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(branch['code'], style: TextStyle(color: muted)),
              const SizedBox(height: 20),
              _detailRow('City', branch['city']),
              _detailRow('Address', branch['address']),
              _detailRow('Phone', branch['phone']),
              _detailRow('Email', branch['email']),
              _detailRow('Manager', branch['manager']),
              _detailRow(
                'Status',
                branch['active'] ? 'Active' : 'Inactive',
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
                        setState(() {
                          branch['active'] = !branch['active'];
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: Text(
                        branch['active'] ? 'Deactivate' : 'Activate',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
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
            child: Text(title, style: TextStyle(color: muted)),
          ),
          Expanded(
            child: Text(
              value.toString().isEmpty ? '-' : value.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount =
        branches.where((branch) => branch['active'] == true).length;

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
                      activeCount.toString(),
                      Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search branches...',
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
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['All', 'Active', 'Inactive'].map((item) {
                  final selected = filter == item;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(item),
                      selected: selected,
                      onSelected: (_) => setState(() => filter = item),
                      selectedColor: blue,
                      backgroundColor: panel,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : muted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredBranches.isEmpty
                  ? Center(
                      child: Text(
                        'No branches found.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      itemCount: filteredBranches.length,
                      itemBuilder: (context, index) {
                        final branch = filteredBranches[index];
                        final active = branch['active'] == true;

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
                              child: Icon(
                                Icons.store,
                                color: blue,
                              ),
                            ),
                            title: Text(
                              branch['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${branch['code']} • ${branch['city']}',
                                style: TextStyle(color: muted),
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: active
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  active ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: active
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
          Text(
            title,
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
