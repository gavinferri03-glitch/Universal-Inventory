
import 'package:flutter/material.dart';

class AllocationScreen extends StatefulWidget {
  const AllocationScreen({super.key});

  @override
  State<AllocationScreen> createState() => _AllocationScreenState();
}

class _AllocationScreenState extends State<AllocationScreen> {
  final Color blue = const Color(0xFF5798FF);
  final Color panel = const Color(0xFF121D2D);
  final Color muted = const Color(0xFF91A4BE);

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> allocations = [
    {
      'name': 'Main Store Allocation',
      'code': 'ALC-001',
      'description': 'Allocation for the main store',
      'active': true,
    },
    {
      'name': 'Branch Allocation',
      'code': 'ALC-002',
      'description': 'Allocation for branch locations',
      'active': true,
    },
    {
      'name': 'Project Allocation',
      'code': 'ALC-003',
      'description': 'Allocation for specific projects',
      'active': true,
    },
  ];

  String searchText = '';

  List<Map<String, dynamic>> get filteredAllocations {
    return allocations.where((allocation) {
      final name = allocation['name'].toString().toLowerCase();
      final code = allocation['code'].toString().toLowerCase();

      return name.contains(searchText.toLowerCase()) ||
          code.contains(searchText.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showAllocationDialog({int? index}) {
    final isEditing = index != null;

    final nameController = TextEditingController(
      text: isEditing ? allocations[index]['name'] : '',
    );

    final codeController = TextEditingController(
      text: isEditing ? allocations[index]['code'] : '',
    );

    final descriptionController = TextEditingController(
      text: isEditing ? allocations[index]['description'] : '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panel,
          title: Text(
            isEditing ? 'Edit Allocation' : 'Add Allocation',
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _field(nameController, 'Allocation Name *'),
                const SizedBox(height: 12),
                _field(codeController, 'Allocation Code *'),
                const SizedBox(height: 12),
                _field(
                  descriptionController,
                  'Description',
                  maxLines: 3,
                ),
              ],
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
                final description =
                    descriptionController.text.trim();

                if (name.isEmpty || code.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Allocation name and code are required.',
                      ),
                    ),
                  );
                  return;
                }

                final duplicate = allocations.indexWhere(
                  (allocation) =>
                      allocation['code'].toString().toLowerCase() ==
                          code.toLowerCase() &&
                      (!isEditing || index != allocations.indexOf(allocation)),
                );

                if (duplicate != -1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'This allocation code already exists.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  if (isEditing) {
                    allocations[index] = {
                      ...allocations[index],
                      'name': name,
                      'code': code,
                      'description': description,
                    };
                  } else {
                    allocations.add({
                      'name': name,
                      'code': code,
                      'description': description,
                      'active': true,
                    });
                  }
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEditing
                          ? 'Allocation updated successfully.'
                          : 'Allocation added successfully.',
                    ),
                  ),
                );
              },
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
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
      ),
    );
  }

  void deleteAllocation(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panel,
          title: const Text(
            'Delete Allocation?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this allocation?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  allocations.removeAt(index);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Allocation deleted.'),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
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
              style: TextStyle(color: muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = allocations
        .where((allocation) => allocation['active'] == true)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        foregroundColor: Colors.white,
        title: const Text('Allocation'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAllocationDialog(),
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Allocation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _summaryCard(
                  'Total Allocations',
                  allocations.length,
                  Icons.account_tree_outlined,
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  'Active Allocations',
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
                hintText: 'Search allocations...',
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
              child: filteredAllocations.isEmpty
                  ? Center(
                      child: Text(
                        'No allocations found.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredAllocations.length,
                      itemBuilder: (context, index) {
                        final allocation = filteredAllocations[index];
                        final originalIndex =
                            allocations.indexOf(allocation);
                        final isActive =
                            allocation['active'] == true;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: panel,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                      color: blue.withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.account_tree_outlined,
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
                                          allocation['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          allocation['code'],
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 12,
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
                                        showAllocationDialog(
                                          index: originalIndex,
                                        );
                                      } else if (value == 'toggle') {
                                        setState(() {
                                          allocations[originalIndex]
                                              ['active'] = !isActive;
                                        });
                                      } else if (value == 'delete') {
                                        deleteAllocation(
                                          originalIndex,
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text(
                                          'Edit',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'toggle',
                                        child: Text(
                                          isActive
                                              ? 'Deactivate'
                                              : 'Activate',
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
                              if (allocation['description']
                                  .toString()
                                  .isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Text(
                                  allocation['description'],
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.green.withOpacity(0.15)
                                        : Colors.red.withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
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
    );
  }
}
