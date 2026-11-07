
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_data.dart';
import 'notifications_data.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends ConsumerState<NotificationScreen> {
  static const Color blue = Color(0xFF5798FF);
  static const Color green = Color(0xFF45C99A);
  static const Color background = Color(0xFF080B12);
  static const Color panel = Color(0xFF121D2D);
  static const Color muted = Color(0xFF91A4BE);

  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final center = inventory.notificationCenter;

    final notifications = center.notifications.where((item) {
      switch (selectedFilter) {
        case 'Unread':
          return !item.isRead;
        case 'Inventory':
          return item.category == NotificationCategory.inventory ||
              item.category == NotificationCategory.stock;
        case 'Sales':
          return item.category == NotificationCategory.sales;
        case 'System':
          return item.category == NotificationCategory.system ||
              item.category == NotificationCategory.suppliers;
        default:
          return true;
      }
    }).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (center.unreadCount > 0)
            IconButton(
              tooltip: 'Mark all as read',
              onPressed: () {
                center.markAllAsRead();
              },
              icon: const Icon(
                Icons.done_all,
                color: green,
              ),
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            color: panel,
            onSelected: (value) {
              if (value == 'clear') {
                _confirmClearAll(center);
              } else if (value == 'read') {
                center.markAllAsRead();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read',
                child: Text('Mark all as read'),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Clear all notifications'),
              ),
            ],
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stay up to date',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${center.unreadCount} unread notifications',
                          style: const TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: blue.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          color: blue,
                          size: 18,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${center.unreadCount}',
                          style: const TextStyle(
                            color: blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 43,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  'All',
                  'Unread',
                  'Inventory',
                  'Sales',
                  'System',
                ].map((filter) {
                  final selected = selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.only(right: 9),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => selectedFilter = filter);
                      },
                      selectedColor: blue,
                      backgroundColor: panel,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: selected ? blue : const Color(0xFF26364D),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 15),

            Expanded(
              child: notifications.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 25),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];

                        return _notificationCard(
                          notification,
                          center,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationCard(
    AppNotification notification,
    NotificationCenter center,
  ) {
    final icon = _notificationIcon(notification);
    final color = _notificationColor(notification);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFF743B46),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        center.remove(notification.id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        decoration: BoxDecoration(
          color: notification.isRead
              ? panel
              : const Color(0xFF18283D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead
                ? const Color(0xFF26364D)
                : blue.withValues(alpha: 0.45),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 9,
          ),
          onTap: () => _showDetails(notification, center),
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: notification.isRead
                        ? FontWeight.w500
                        : FontWeight.bold,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_categoryName(notification.category)}  •  ${_formatDate(notification.date)}',
                  style: const TextStyle(
                    color: Color(0xFF71849E),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: muted,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 85,
              height: 85,
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: muted,
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No notifications',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedFilter == 'All'
                  ? 'You are all caught up. New updates will appear here.'
                  : 'There are no notifications in this category.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(
    AppNotification notification,
    NotificationCenter center,
  ) {
    center.markAsRead(notification.id);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: Row(
          children: [
            Icon(
              _notificationIcon(notification),
              color: _notificationColor(notification),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: const TextStyle(
                color: muted,
                height: 1.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Category: ${_categoryName(notification.category)}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 7),
            Text(
              'Date: ${_formatDate(notification.date)}',
              style: const TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
            if (notification.relatedId != null) ...[
              const SizedBox(height: 7),
              Text(
                'Reference: ${notification.relatedId}',
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              center.remove(notification.id);
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFFF6B6B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(NotificationCenter center) {
    if (!center.hasNotifications) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: const Text('Clear all notifications?'),
        content: const Text(
          'This will permanently clear all notifications currently stored in the app.',
          style: TextStyle(color: muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              center.clearAll();
              Navigator.pop(dialogContext);
            },
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }

  IconData _notificationIcon(AppNotification notification) {
    switch (notification.title) {
      case 'Low Stock':
        return Icons.warning_amber_rounded;
      case 'Out of Stock':
        return Icons.remove_shopping_cart_outlined;
      case 'Stock In':
        return Icons.inventory_2_outlined;
      case 'Stock Out':
        return Icons.output_outlined;
      case 'Branch Transfer':
        return Icons.swap_horiz;
      case 'New Sale':
        return Icons.shopping_cart_outlined;
      case 'Payment Due':
      case 'Overdue Payment':
        return Icons.payment_outlined;
      case 'Sales Return':
        return Icons.assignment_return_outlined;
      case 'Stock Adjustment':
        return Icons.tune;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _notificationColor(AppNotification notification) {
    switch (notification.category) {
      case NotificationCategory.inventory:
        return const Color(0xFFFFB454);
      case NotificationCategory.stock:
        return blue;
      case NotificationCategory.sales:
        return green;
      case NotificationCategory.suppliers:
        return const Color(0xFFB58AFF);
      case NotificationCategory.system:
        return muted;
    }
  }

  String _categoryName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.inventory:
        return 'Inventory';
      case NotificationCategory.stock:
        return 'Stock';
      case NotificationCategory.sales:
        return 'Sales';
      case NotificationCategory.suppliers:
        return 'Suppliers';
      case NotificationCategory.system:
        return 'System';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today, ${_formatTime(date)}';
    }

    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday, ${_formatTime(date)}';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}
