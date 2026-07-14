// lib/screens/consoles/components/consoles_filters.dart

import 'package:flutter/material.dart';
import 'package:retroachievements_organizer/constants/constants.dart';

class ConsolesFilters extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  
  

  const ConsolesFilters({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    
    
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        TextField(
          controller: searchController,
          style: const TextStyle(color: AppColors.textLight),
          decoration: InputDecoration(
            hintText: 'Search consoles...',
            hintStyle: const TextStyle(color: AppColors.textSubtle),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            suffixIcon: searchController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSubtle),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.cardBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: onSearchChanged,
        ),
        
      ],
    );
  }
}
