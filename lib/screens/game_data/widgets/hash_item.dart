// lib/screens/game_data/widgets/hash_item.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class HashItem extends StatelessWidget {
  final Map<String, dynamic> hash;
  final bool isAvailable;
  final String? localRomName;

  const HashItem({
    super.key,
    required this.hash,
    required this.isAvailable,
    this.localRomName,
  });

  @override
  Widget build(BuildContext context) {
    final String md5Hash = hash['MD5'] ?? '';
    final String name = hash['Name'] ?? 'Unknown ROM';
    final List<dynamic> labels = hash['Labels'] ?? [];
    final String patchUrl = hash['PatchUrl'] ?? '';

    return Card(
      color: AppColors.cardBackground,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Availability indicator
            Row(
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.cancel,
                  color: isAvailable ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAvailable
                        ? 'Available in your library'
                        : 'Not available in your library',
                    style: TextStyle(
                      color: isAvailable ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ROM name
            Text(
              'ROM Name: $name',
              style: const TextStyle(color: AppColors.textLight),
            ),

            const SizedBox(height: 4),

            // MD5 hash
            Text(
              'MD5: $md5Hash',
              style: const TextStyle(color: AppColors.textSubtle, fontSize: 12),
            ),

            // Local ROM name if available
            if (isAvailable && localRomName != null) ...[
              const SizedBox(height: 8),
              Text(
                'Local ROM: $localRomName',
                style: const TextStyle(color: AppColors.success, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Labels if available
            if (labels.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    labels.map<Widget>((label) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Text(
                          label.toString(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],

            // Patch URL if available
            if (patchUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _launchURL(context, patchUrl),
                child: const Row(
                  children: [
                    Icon(Icons.download, color: AppColors.info, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Download Patch',
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Method to launch URL - using url_launcher
  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $urlString'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
