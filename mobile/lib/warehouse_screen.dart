
import 'package:flutter/material.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color orange = Color(0xFFFFB454);

  final TextEditingController searchController = TextEditingController();

  final List<_Warehouse> warehouses = [
    _Warehouse(
      name: 'Main Warehouse',
      code: 'WH-001',
      location: 'Kathmandu',
      manager: 'Store Manager',
      capacity: 80,
      status: 'Active',
    ),
    _Warehouse(
      name: 'Secondary Warehouse',
      code: 'WH-002',
      location: 'Pokhara',
      manager: 'Inventory Manager',
      capacity: 55,
      status: 'Active',
    ),
    _Warehouse(
      name: 'Retail Store',
      code: 'WH-003',
      location: 'Lalitpur',
      manager: 'Branch Manager',
      capacity: 35,
      status: 'Active',
    ),
  ];

  String selectedFilter = 'All';

  List<_Warehouse> get filteredWarehouses {
    return warehouses.where((warehouse) {
      final query = searchController.text.toLowerCase();

      final matchesSearch =
          warehouse.name.toLowerCase().contains(query) ||
          warehouse.code.toLowerCase().contains(query) ||
          warehouse.location.toLowerCase().contains(query);

      final matchesFilter = selectedFilter == 'All' ||
          warehouse.status == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get activeCount =>
      warehouses.where((item) => item.status == 'Active').length;

  int get inactiveCount =>
      warehouses.where((item) => item.status == 'Inactive').length;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080B12),
        title: const Text(
          'Warehouses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showInfo,
            icon: const Icon(Icons.info_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWarehouse,
        backgroundColor: blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Warehouse'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage your storage locations',
                style: TextStyle(
                  color: Color(0xFF91A4BE),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Warehouse Overview',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 22),

              // SUMMARY

              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Total Warehouses',
                      value: warehouses.length.toString(),
                      icon: Icons.warehouse_outlined,
                      color: blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Active',
                      value: activeCount.toString(),
                      icon: Icons.check_circle_outline,
                      color: green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _SummaryCard(
                title: 'Inactive Warehouses',
                value: inactiveCount.toString(),
                icon: Icons.pause_circle_outline,
                color: orange,
                wide: true,
              ),

              const SizedBox(height: 28),

              // SEARCH

              const Text(
                'Find Warehouse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search name, code or location...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF71849E),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF91A4BE),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF121D2D),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF26364D),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF26364D),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // WAREHOUSE LIST

              const Text(
                'Your Warehouses',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: ['All', 'Active', 'Inactive'].map((filter) {
                  final selected = selectedFilter == filter;

                  return ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    selectedColor: blue.withValues(alpha: 0.2),
                    backgroundColor: const Color(0xFF121D2D),
                    side: BorderSide(
                      color: selected
                          ? blue
                          : const Color(0xFF26364D),
                    ),
                    labelStyle: TextStyle(
                      color: selected ? blue : Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              if (filteredWarehouses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'No warehouses found.',
                      style: TextStyle(
                        color: Color(0xFF91A4BE),
                      ),
                    ),
                  ),
                )
              else
                ...filteredWarehouses.map(
                  (warehouse) => _WarehouseCard(
                    warehouse: warehouse,
                    onTap: () => _showWarehouseDetails(warehouse),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addWarehouse() {
    _showWarehouseForm();
  }

  Future<void> _showWarehouseForm() async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final locationController = TextEditingController();
    final managerController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<_Warehouse>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121D2D),
          title: const Text(
            'Add Warehouse',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _formField(nameController, 'Warehouse Name'),
                  const SizedBox(height: 12),
                  _formField(codeController, 'Warehouse Code'),
                  const SizedBox(height: 12),
                  _formField(locationController, 'Location'),
                  const SizedBox(height: 12),
                  _formField(managerController, 'Manager Name'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final warehouse = _Warehouse(
                  name: nameController.text.trim(),
                  code: codeController.text.trim(),
                  location: locationController.text.trim(),
                  manager: managerController.text.trim(),
                  capacity: 0,
                  status: 'Active',
                );

                Navigator.pop(dialogContext, warehouse);
              },
              child: const Text('Save Warehouse'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    codeController.dispose();
    locationController.dispose();
    managerController.dispose();

    if (!mounted || result == null) return;

    final duplicateCode = warehouses.any(
      (item) => item.code.toLowerCase() == result.code.toLowerCase(),
    );

    if (duplicateCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This warehouse code already exists.'),
        ),
      );
      return;
    }

    setState(() {
      warehouses.add(result);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Warehouse added successfully.'),
      ),
    );
  }

  Widget _formField(
    TextEditingController controller,
    String label,
  ) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF91A4BE),
        ),
        filled: true,
        fillColor: const Color(0xFF080B12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF26364D),
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  void _showWarehouseDetails(_Warehouse warehouse) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121D2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                warehouse.name,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _detailRow('Warehouse Code', warehouse.code),
              _detailRow('Location', warehouse.location),
              _detailRow('Manager', warehouse.manager),
              _detailRow(
                'Capacity Used',
                '${warehouse.capacity}%',
              ),
              _detailRow('Status', warehouse.status),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _toggleStatus(warehouse);
                      },
                      child: Text(
                        warehouse.status == 'Active'
                            ? 'Deactivate'
                            : 'Activate',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF91A4BE),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleStatus(_Warehouse warehouse) {
    setState(() {
      warehouse.status =
          warehouse.status == 'Active' ? 'Inactive' : 'Active';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${warehouse.name} is now ${warehouse.status}.',
        ),
      ),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121D2D),
        title: const Text('Warehouse Management'),
        content: const Text(
          'Create and manage storage locations, '
          'assign managers and control warehouse status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _Warehouse {
  _Warehouse({
    required this.name,
    required this.code,
    required this.location,
    required this.manager,
    required this.capacity,
    required this.status,
  });

  final String name;
  final String code;
  final String location;
  final String manager;
  final int capacity;
  String status;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.wide = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: wide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121D2D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF26364D),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF91A4BE),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarehouseCard extends StatelessWidget {
  const _WarehouseCard({
    required this.warehouse,
    required this.onTap,
  });

  final _Warehouse warehouse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = warehouse.status == 'Active';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121D2D),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF26364D),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5798FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.warehouse_outlined,
                    color: Color(0xFF5798FF),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        warehouse.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        warehouse.code,
                        style: const TextStyle(
                          color: Color(0xFF91A4BE),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: (active
                            ? const Color(0xFF45C99A)
                            : const Color(0xFFFFB454))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    warehouse.status,
                    style: TextStyle(
                      color: active
                          ? const Color(0xFF45C99A)
                          : const Color(0xFFFFB454),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF91A4BE),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    warehouse.location,
                    style: const TextStyle(
                      color: Color(0xFF91A4BE),
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(
                  Icons.person_outline,
                  color: Color(0xFF91A4BE),
                  size: 16,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    warehouse.manager,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF91A4BE),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Storage Capacity Used',
                  style: TextStyle(
                    color: Color(0xFF91A4BE),
                    fontSize: 11,
                  ),
                ),
                Text(
                  '${warehouse.capacity}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 9),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: warehouse.capacity / 100,
                minHeight: 7,
                backgroundColor: const Color(0xFF26364D),
                valueColor: AlwaysStoppedAnimation<Color>(
                  warehouse.capacity >= 80
                      ? const Color(0xFFFFB454)
                      : const Color(0xFF5798FF),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    color: Color(0xFF5798FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF5798FF),
                  size: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
