
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'inventory_data.dart';
import 'list_tools.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
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

  final List<String> roles = [
    'Administrator',
    'Manager',
    'Staff',
    'Accountant',
    'Salesperson',
    'Stock Manager',
  ];

  String searchText = '';
  String selectedSort = 'name_az';
  String selectedFilter = 'all';

  final Map<String, String> sortOptions = {
    'name_az': 'Name: A–Z',
    'name_za': 'Name: Z–A',
    'role_az': 'Role: A–Z',
    'role_za': 'Role: Z–A',
    'branch_az': 'Branch: A–Z',
    'branch_za': 'Branch: Z–A',
    'newest': 'Newest first',
    'oldest': 'Oldest first',
  };

  final Map<String, String> filterOptions = {
    'all': 'All users',
    'active': 'Active users',
    'inactive': 'Inactive users',
    'administrator': 'Administrators',
    'manager': 'Managers',
    'staff': 'Staff',
    'accountant': 'Accountants',
    'salesperson': 'Salespersons',
    'stock_manager': 'Stock Managers',
  };

  List<Map<String, dynamic>> get filteredUsers {
    final query = searchText.trim().toLowerCase();

    final result = users.where((user) {
      final matchesSearch = query.isEmpty ||
          [
            user['name'],
            user['email'],
            user['phone'],
            user['role'],
            user['branch'],
          ].any((value) =>
              value.toString().toLowerCase().contains(query));

      final active = user['active'] == true;
      final role = user['role'].toString().toLowerCase();

      bool matchesFilter;

      switch (selectedFilter) {
        case 'active':
          matchesFilter = active;
          break;
        case 'inactive':
          matchesFilter = !active;
          break;
        case 'administrator':
          matchesFilter = role == 'administrator';
          break;
        case 'manager':
          matchesFilter = role == 'manager';
          break;
        case 'staff':
          matchesFilter = role == 'staff';
          break;
        case 'accountant':
          matchesFilter = role == 'accountant';
          break;
        case 'salesperson':
          matchesFilter = role == 'salesperson';
          break;
        case 'stock_manager':
          matchesFilter = role == 'stock manager';
          break;
        default:
          matchesFilter = true;
      }

      return matchesSearch && matchesFilter;
    }).toList();

    switch (selectedSort) {
      case 'name_az':
        result.sort((a, b) => a['name']
            .toString()
            .toLowerCase()
            .compareTo(b['name'].toString().toLowerCase()));
        break;
      case 'name_za':
        result.sort((a, b) => b['name']
            .toString()
            .toLowerCase()
            .compareTo(a['name'].toString().toLowerCase()));
        break;
      case 'role_az':
        result.sort((a, b) => a['role']
            .toString()
            .toLowerCase()
            .compareTo(b['role'].toString().toLowerCase()));
        break;
      case 'role_za':
        result.sort((a, b) => b['role']
            .toString()
            .toLowerCase()
            .compareTo(a['role'].toString().toLowerCase()));
        break;
      case 'branch_az':
        result.sort((a, b) => a['branch']
            .toString()
            .toLowerCase()
            .compareTo(b['branch'].toString().toLowerCase()));
        break;
      case 'branch_za':
        result.sort((a, b) => b['branch']
            .toString()
            .toLowerCase()
            .compareTo(a['branch'].toString().toLowerCase()));
        break;
      case 'newest':
        result.sort((a, b) =>
            users.indexOf(b).compareTo(users.indexOf(a)));
        break;
      case 'oldest':
        result.sort((a, b) =>
            users.indexOf(a).compareTo(users.indexOf(b)));
        break;
    }

    return result;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

  Widget _formField(
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
        decoration: _decoration(label),
      ),
    );
  }

  void showUserForm({Map<String, dynamic>? user}) {
    final nameController =
        TextEditingController(text: user?['name'] ?? '');
    final emailController =
        TextEditingController(text: user?['email'] ?? '');
    final phoneController =
        TextEditingController(text: user?['phone'] ?? '');

    final inventory = ref.read(inventoryProvider);

    final branchOptions = [
      'All Branches',
      ...inventory.branches
          .where((branch) => branch.active)
          .map((branch) => branch.name),
    ];

    String selectedRole = user?['role'] ?? 'Staff';
    String selectedBranch = user?['branch'] ?? 'All Branches';

    if (!branchOptions.contains(selectedBranch)) {
      selectedBranch = 'All Branches';
    }

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
                      _formField(
                        emailController,
                        'Email Address *',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _formField(
                        phoneController,
                        'Phone Number',
                        keyboardType: TextInputType.phone,
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        dropdownColor: panel,
                        style: const TextStyle(color: Colors.white),
                        decoration: _decoration('User Role'),
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
                        decoration: _decoration('Assigned Branch'),
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
                        'Only active branches are available for assignment.',
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
                  child: Text(user == null ? 'Add User' : 'Update User'),
                ),
              ],
            );
          },
        );
      },
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
          child: SafeArea(
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
                const Divider(height: 28, color: Colors.white12),
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
              ],
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
            width: 100,
            child: Text(title, style: TextStyle(color: muted)),
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
            const SizedBox(height: 12),
            Text(
              value.toString(),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(inventoryProvider);

    final activeCount =
        users.where((user) => user['active'] == true).length;

    final visibleUsers = filteredUsers;

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
                  _summaryCard(
                    'Total Users',
                    users.length,
                    Icons.people_outline,
                  ),
                  const SizedBox(width: 12),
                  _summaryCard(
                    'Active Users',
                    activeCount,
                    Icons.verified_user_outlined,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InventoryListToolbar(
                searchController: searchController,
                searchHint: 'Search name, email, phone, role or branch...',
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
            const SizedBox(height: 12),
            Expanded(
              child: visibleUsers.isEmpty
                  ? Center(
                      child: Text(
                        'No users found.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                      itemCount: visibleUsers.length,
                      itemBuilder: (context, index) {
                        final user = visibleUsers[index];
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
                              backgroundColor: blue.withOpacity(0.15),
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
                                '${user['role']} • ${user['branch']}\n${user['email']}',
                                style: TextStyle(color: muted),
                              ),
                            ),
                            isThreeLine: true,
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
}
