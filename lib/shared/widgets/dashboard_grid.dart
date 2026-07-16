// Widget lưới chức năng dùng cho Dashboard của các vai trò (Staff, Manager, Admin).
// DashboardItem định nghĩa icon, tiêu đề và callback; DashboardGrid render lưới 2 cột.
import 'package:flutter/material.dart';

/// Một mục chức năng trên dashboard.
class DashboardItem {
  const DashboardItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Lưới các mục chức năng dùng chung cho dashboard của từng role.
class DashboardGrid extends StatelessWidget {
  const DashboardGrid({super.key, required this.items});

  final List<DashboardItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: items.map((item) {
        return Card(
          child: InkWell(
            onTap: item.onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon,
                    size: 40, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
