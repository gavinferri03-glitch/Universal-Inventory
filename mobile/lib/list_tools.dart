
import 'package:flutter/material.dart';

class InventoryListToolbar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchHint;
  final ValueChanged<String> onSearchChanged;

  final Map<String, String> sortOptions;
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  final Map<String, String> filterOptions;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const InventoryListToolbar({
    super.key,
    required this.searchController,
    required this.searchHint,
    required this.onSearchChanged,
    required this.sortOptions,
    required this.selectedSort,
    required this.onSortChanged,
    required this.filterOptions,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const Color blue = Color(0xFF5798FF);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: searchHint,
            hintStyle: const TextStyle(color: muted),
            prefixIcon: const Icon(
              Icons.search,
              color: blue,
            ),
            suffixIcon: searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: muted,
                    ),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  ),
            filled: true,
            fillColor: panel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: PopupMenuButton<String>(
                onSelected: onSortChanged,
                color: panel,
                itemBuilder: (context) {
                  return sortOptions.entries.map((entry) {
                    return PopupMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          if (entry.key == selectedSort)
                            const Icon(
                              Icons.check,
                              color: blue,
                              size: 18,
                            )
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.sort),
                  label: const Text('Sort'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blue,
                    disabledForegroundColor: blue,
                    side: const BorderSide(color: blue),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: PopupMenuButton<String>(
                onSelected: onFilterChanged,
                color: panel,
                itemBuilder: (context) {
                  return filterOptions.entries.map((entry) {
                    return PopupMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          if (entry.key == selectedFilter)
                            const Icon(
                              Icons.check,
                              color: blue,
                              size: 18,
                            )
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(
                    Icons.filter_list,
                  ),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: blue,
                    disabledForegroundColor: blue,
                    side: const BorderSide(color: blue),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Sort: ${sortOptions[selectedSort] ?? selectedSort}  •  '
            'Filter: ${filterOptions[selectedFilter] ?? selectedFilter}',
            style: const TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
