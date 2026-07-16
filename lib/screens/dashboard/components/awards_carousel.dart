// lib/screens/dashboard/components/awards_carousel.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/user/user_awards_model.dart';
import 'package:retroachievements_library/screens/dashboard/widgets/award_item.dart';

class AwardsCarousel extends StatefulWidget {
  final List<UserAward> awards;

  const AwardsCarousel({super.key, required this.awards});

  @override
  State<AwardsCarousel> createState() => _AwardsCarouselState();
}

class _AwardsCarouselState extends State<AwardsCarousel> {
  final ScrollController _awardsScrollController = ScrollController();

  @override
  void dispose() {
    _awardsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sort the awards by date - most recent first
    final sortedAwards = List.from(widget.awards);
    sortedAwards.sort((a, b) {
      final aDate = DateTime.parse(a.awardedAt);
      final bDate = DateTime.parse(b.awardedAt);
      return bDate.compareTo(
        aDate,
      ); // Reverse the comparison for descending order (newest first)
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Awards',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Add navigation buttons for mouse users
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _awardsScrollController.animateTo(
                      _awardsScrollController.offset - 150,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _awardsScrollController.animateTo(
                      _awardsScrollController.offset + 150,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            controller: _awardsScrollController,
            scrollDirection: Axis.horizontal,
            itemCount: sortedAwards.length,
            itemBuilder: (context, index) {
              final award = sortedAwards[index];
              return AwardItem(award: award);
            },
          ),
        ),
      ],
    );
  }
}
