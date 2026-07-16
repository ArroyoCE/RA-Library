// lib/screens/games/widgets/folders_display.dart
import 'package:flutter/material.dart';
import 'package:retroachievements_library/constants/constants.dart';

class FoldersDisplayWidget extends StatefulWidget {
  final List<String> folders;
  final VoidCallback onAddFolder;
  final bool isHashingInProgress;

  const FoldersDisplayWidget({
    super.key,
    required this.folders,
    required this.onAddFolder,
    required this.isHashingInProgress,
  });

  @override
  State<FoldersDisplayWidget> createState() => _FoldersDisplayWidgetState();
}

class _FoldersDisplayWidgetState extends State<FoldersDisplayWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Linked ROM Folders:',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    if (widget.folders.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        tooltip: _isExpanded ? 'Collapse' : 'Expand',
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        color: AppColors.primary,
                      ),
                      onPressed:
                          widget.isHashingInProgress
                              ? null
                              : widget.onAddFolder,
                      tooltip: 'Add Folder',
                    ),
                  ],
                ),
              ],
            ),

            // Preview of first folder or empty message
            if (widget.folders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No folders linked to this Console',
                  style: TextStyle(
                    color: AppColors.textSubtle,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else if (!_isExpanded)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.folder,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.folders.first,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.folders.length > 1)
                      Text(
                        '+${widget.folders.length - 1} more',
                        style: const TextStyle(
                          color: AppColors.textSubtle,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),

            // Expanded folder list
            if (_isExpanded && widget.folders.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.folders.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    margin: EdgeInsets.only(
                      bottom: 4,
                      top: index == 0 ? 4 : 0,
                    ), // Remove the 'const' here
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.folder,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.folders[index],
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
