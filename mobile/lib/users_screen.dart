
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final Color blue = const Color(0xFF5798FF);
  final Color panel = const Color(0xFF121D2D);
  final Color muted = const Color(0xFF91A4BE);

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> users = [
    {
      'name': 'Administrator',
      'email': 'admin@example.com',
      'phone': '9800000001',
      'role': 'Administrator',
      'branch': 'All Branches',
      'active': true,
    },
    {
      'name': 'Ram Sharma',
      'email': 'ram@example.com',
      'phone': '9800000002',
      'role': 'Manager',
      'branch': 'Main Branch',
      'active': true,
    },
    {
      'name': 'Sita Thapa',
      'email': 'sita@example.com',
      'phone': '9800000003',
      'role': 'Staff',
      'branch': 'Pokhara Branch',
      'active': true,
    },
  ];

  String filter = 'All';

  final List<String> roles = [
    'Administrator',
    'Manager',
    'Staff',
    'Accountant',
    'Salesperson',
    'Stock Manager',
  ];

  List<Map<String, dynamic>> get filteredUsers {
    return users.where((user) {
      final query = searchController.text.toLowerCase();

      final matchesSearch =
          user['name'].toString().toLowerCase().contains(query) ||
          user['email'].toString().toLowerCase().contains(query) ||
          user['role'].toString().toLowerCase().contains(query);

      final matchesFilter = filter == 'All' ||
          (filter == 'Active' && user['active'] == true) ||
          (filter == 'Inactive' && user['active'] == false);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showUserForm({Map<String, dynamic>? user}) {
    final nameController =
        TextEditingController(text: user?['name'] ?? '');
    final emailController =
        TextEditingController(text: user?['email'] ?? '');
    final phoneController =
        TextEditingController(text: user?['phone'] ?? '');

    String selectedRole = user?['role'] ?? 'Staff';
    String selectedBranch = user?['branch'] ?? 'Main Branch';

    final branchOptions = [
      'All Branches',
      'Main Branch',
      'Pokhara Branch',
      'Lalitpur Branch',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: panel,
              title: Text(
                user == null ? 'Add User' : 'Edit User',
                style: const TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _formField(nameController, 'Full Name *'),
                      _formField(emailController, 'Email Address *'),
                      _formField(phoneController, 'Phone Number'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        dropdownColor: panel,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dropdownDecoration('User Role'),
                        items: roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedRole = value);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: selectedBranch,
                        dropdownColor: panel,
                        style: const TextStyle(color: Colors.white),
                        decoration: _dropdownDecoration('Assigned Branch'),
                        items: branchOptions.map((branch) {
                          return DropdownMenuItem(
                            value: branch,
                            child: Text(branch),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() => selectedBranch = value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Password and account activation will be handled when authentication is implemented.',
                        style: TextStyle(color: muted, fontSize: 12),
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
                    final email = emailController.text.trim();

                    if (name.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Name and email are required.'),
                        ),
                      );
                      return;
                    }

                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid email address.'),
                        ),
                      );
                      return;
                    }

                    final duplicate = users.any((item) =>
                        item['email'].toString().toLowerCase() ==
                            email.toLowerCase() &&
                        item != user);

                    if (duplicate) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('This email is already registered.'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      final data = {
                        'name': name,
                        'email': email,
                        'phone': phoneController.text.trim(),
                        'role': selectedRole,
                        'branch': selectedBranch,
                        'active': user?['active'] ?? true,
                      };

                      if (user == null) {
                        users.add(data);
                      } else {
                        final index = users.indexOf(user);
                        users[index] = data;
                      }
                    });

                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          user == null
                              ? 'User added successfully.'
                              : 'User updated successfully.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Save User'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: muted),
      filled: true,
      fillColor: const Color(0xFF080B12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _formField(TextEditingController controller, String label) {
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

  void showUserDetails(Map<String, dynamic> user) {
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
                user['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(user['email'], style: TextStyle(color: muted)),
              const SizedBox(height: 22),
              _detailRow('Phone', user['phone']),
              _detailRow('Role', user['role']),
              _detailRow('Branch', user['branch']),
              _detailRow(
                'Status',
                user['active'] ? 'Active' : 'Inactive',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        showUserForm(user: user);
                      },
                      child: const Text('Edit User'),
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
                          user['active'] = !user['active'];
                        });
                        Navigator.pop(sheetContext);
                      },
                      child: Text(
                        user['active'] ? 'Deactivate' : 'Activate',
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
            width: 85,
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
        users.where((user) => user['active'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        foregroundColor: Colors.white,
        title: const Text('Users'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showUserForm(),
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add User'),
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
                      'Total Users',
                      users.length.toString(),
                      Icons.people_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryCard(
                      'Active Users',
                      activeCount.toString(),
                      Icons.verified_user_outlined,
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
                  hintText: 'Search users...',
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
              child: filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        'No users found.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final active = user['active'] == true;

                        return Card(
                          color: panel,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(14),
                            onTap: () => showUserDetails(user),
                            leading: CircleAvatar(
                              backgroundColor: blue.withValues(alpha: 0.15),
                              child: Icon(Icons.person, color: blue),
                            ),
                            title: Text(
                              user['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${user['role']} • ${user['branch']}',
                                style: TextStyle(color: muted),
                              ),
                            ),
                            trailing: Icon(
                              Icons.circle,
                              size: 11,
                              color: active
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
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
          Text(title, style: TextStyle(color: muted, fontSize: 12)),
        ],
      ),
    );
  }
}
