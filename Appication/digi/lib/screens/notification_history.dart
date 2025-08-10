import 'package:flutter/material.dart';

class NotificationHistoryScreen extends StatefulWidget {
  final List<Map<String, String>> notifications;

  const NotificationHistoryScreen({Key? key, required this.notifications})
      : super(key: key);

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  String _selectedFilter = 'All'; // All, Mobile App, Terminal

  @override
  Widget build(BuildContext context) {
    // Filter notifications based on selected filter
    List<Map<String, String>> filteredNotifications;
    if (_selectedFilter == 'All') {
      filteredNotifications = widget.notifications;
    } else if (_selectedFilter == 'Mobile App') {
      filteredNotifications = widget.notifications.where((notification) {
        final device = notification['device'] ?? '';
        return device == 'Mobile App';
      }).toList();
    } else if (_selectedFilter == 'Terminal') {
      filteredNotifications = widget.notifications.where((notification) {
        final device = notification['device'] ?? '';
        // Any device that's not 'Mobile App' is considered terminal
        return device != 'Mobile App' && device.isNotEmpty;
      }).toList();
    } else {
      filteredNotifications = widget.notifications;
    }

    // Debug logging to see what devices we have
    if (widget.notifications.isNotEmpty) {
      print("=== Notification History Debug ===");
      print("Selected filter: $_selectedFilter");
      print("Total notifications: ${widget.notifications.length}");
      print("Filtered notifications: ${filteredNotifications.length}");
      for (var notification in widget.notifications) {
        print(
            "Device: '${notification['device']}', Title: '${notification['title']}'");
      }
      print("=== End Debug ===");
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Toggle filter at the top
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', Icons.notifications),
                  const SizedBox(width: 8),
                  _buildFilterChip('Mobile App', Icons.smartphone),
                  const SizedBox(width: 8),
                  _buildFilterChip('Terminal', Icons.computer),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          // Notifications list
          Expanded(
            child: Container(
              color: Colors.white,
              child: filteredNotifications.isEmpty
                  ? Center(
                      child: Text(
                        _selectedFilter == 'All'
                            ? 'No notifications yet'
                            : 'No $_selectedFilter notifications',
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = filteredNotifications[index];
                        // Get device and type information
                        final device = notification['device'] ?? '';
                        final amount = notification['amount'] ?? '';

                        // Determine which icon to show based on device
                        String deviceIcon;
                        if (device == 'Mobile App') {
                          deviceIcon =
                              'assets/icons/smartphone.png'; // Mobile phone icon
                        } else {
                          deviceIcon =
                              'assets/icons/terminal.png'; // Terminal icon for terminal transactions
                        }

                        // Try to parse details from the body string if possible
                        final body = notification['body'] ?? '';
                        String time = '';
                        final timeMatch =
                            RegExp(r'Time: ([^|]+)').firstMatch(body);
                        if (timeMatch != null)
                          time = timeMatch.group(1)?.trim() ?? '';

                        return ListTile(
                          tileColor: Colors.white,
                          leading: CircleAvatar(
                            backgroundColor:
                                const Color.fromARGB(0, 196, 25, 25),
                            radius: 20,
                            child: Image.asset(
                              deviceIcon,
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain, // Make sure icon shows fully
                            ),
                          ),
                          title: Text(
                            notification['title'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (amount.isNotEmpty)
                                Text(
                                  'Amount: \$$amount',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              if (device.isNotEmpty)
                                Container(
                                  margin: EdgeInsets.only(top: 4),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    device == 'Mobile App'
                                        ? '📱 Mobile App'
                                        : '💻 Terminal',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[600]),
                                  ),
                                ),
                              if (time.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Time: $time',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
