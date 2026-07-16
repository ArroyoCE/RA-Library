// lib/screens/games/dialogs/folder_management_dialog.dart
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:retroachievements_library/constants/constants.dart';
import 'package:retroachievements_library/models/local/hash_model.dart';

class FolderManagementDialog extends StatefulWidget {
  final int consoleId;
  final String consoleName;
  final List<String> initialFolders;
  final Function(List<String>) onSave;

  const FolderManagementDialog({
    super.key,
    required this.consoleId,
    required this.consoleName,
    required this.initialFolders,
    required this.onSave,
  });

  @override
  State<FolderManagementDialog> createState() => _FolderManagementDialogState();
}

class _FolderManagementDialogState extends State<FolderManagementDialog> {
  late List<String> _folders;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _folders = List.from(widget.initialFolders);
  }

  Future<void> _addFolder() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory != null && !_folders.contains(selectedDirectory)) {
        setState(() {
          _folders.add(selectedDirectory);
        });
      }
    } catch (e) {
      debugPrint('Error selecting folder: $e');
      // Show error in dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting folder: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeFolder(int index) {
    setState(() {
      _folders.removeAt(index);
    });
  }

  Future<void> _saveAndHash() async {
    setState(() {
      _isSaving = true;
    });

    // Call the onSave callback which will now handle the hashing
    widget.onSave(_folders);

    // Close the dialog
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> supportedExtensions =
        ConsoleHashMethods.getFileExtensionsForConsole(widget.consoleId);

    return AlertDialog(
      backgroundColor: AppColors.cardBackground,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manage ROM Folders for ${widget.consoleName}',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Supported Extensions: ${supportedExtensions.join(", ")}',
            style: const TextStyle(color: AppColors.info, fontSize: 12),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add folder button
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle),
              label: const Text('Add Folder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textDark,
              ),
              onPressed: _addFolder,
            ),

            const SizedBox(height: 16),

            // Folder list
            const Text(
              'Current folders:',
              style: TextStyle(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child:
                  _folders.isEmpty
                      ? const Center(
                        child: Text(
                          'No folders added yet',
                          style: TextStyle(color: AppColors.textSubtle),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _folders.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: AppColors.darkBackground,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(
                                Icons.folder,
                                color: AppColors.primary,
                              ),
                              title: Text(
                                _folders[index],
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppColors.error,
                                ),
                                onPressed: () => _removeFolder(index),
                                tooltip: 'Remove folder',
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textLight),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textDark,
          ),
          onPressed: _isSaving ? null : _saveAndHash,
          child:
              _isSaving
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textDark,
                      ),
                    ),
                  )
                  : const Text('Save & Hash'),
        ),
      ],
    );
  }
}
