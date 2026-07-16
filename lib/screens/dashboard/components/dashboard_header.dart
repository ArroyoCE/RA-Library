// lib/screens/dashboard/components/dashboard_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:retroachievements_library/constants/constants.dart';

class DashboardHeader extends ConsumerWidget {
  final DateTime? lastUpdated;
  final Function() onRefresh;

  const DashboardHeader({
    super.key,
    required this.lastUpdated,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String formattedDate =
        lastUpdated != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(lastUpdated!)
            : DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    return Row(
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        // Refresh button
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.primary),
          onPressed: onRefresh,
          tooltip: 'Refresh dashboard data',
        ),
        // Last updated timestamp
        Text(
          'Last updated: $formattedDate',
          style: const TextStyle(color: AppColors.textSubtle, fontSize: 12),
        ),
      ],
    );
  }
}
