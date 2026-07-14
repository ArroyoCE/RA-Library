// lib/services/hashing/native/unified_hash_service.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class UnifiedHashService {
  String? _hashToolPathCache;

  String _getHashToolPath() {
    if (_hashToolPathCache != null) return _hashToolPathCache!;

    final exeDir = path.dirname(Platform.resolvedExecutable);
    
    // In release mode (Windows)
    final releasePath = path.join(exeDir, 'data', 'flutter_assets', 'assets', 'tools', 'hash_tool.exe');
    if (File(releasePath).existsSync()) {
      _hashToolPathCache = releasePath;
      return releasePath;
    }
    
    // In debug mode
    final debugPath = path.join(Directory.current.path, 'assets', 'tools', 'hash_tool.exe');
    if (File(debugPath).existsSync()) {
      _hashToolPathCache = debugPath;
      return debugPath;
    }
    
    // Fallback
    _hashToolPathCache = 'hash_tool.exe';
    return _hashToolPathCache!;
  }

  // Hash a single file using the external hash tool
  Future<String> hashFile(String filePath, int consoleId) async {
    try {
      final toolPath = _getHashToolPath();
      final result = await Process.run(toolPath, [consoleId.toString(), filePath]);
      
      final output = result.stdout.toString().trim();
      if (output.contains('HASH:')) {
        final hashVal = output.split('HASH:')[1].trim();
        return hashVal;
      } else {
        debugPrint('Error generating hash for $filePath. Output: $output');
        return '';
      }
    } catch (e) {
      debugPrint('Exception running hash tool for $filePath: $e');
      return '';
    }
  }

  // Scan a single folder for files matching extensions
  Future<List<String>> _scanSingleFolder(String folder, Set<String> validExtensions) async {
    final List<String> foundFiles = [];
    try {
      final dir = Directory(folder);
      if (!await dir.exists()) {
        debugPrint('Directory does not exist: $folder');
        return foundFiles;
      }
      final Stream<FileSystemEntity> entityStream = dir.list(recursive: true, followLinks: false);
      await for (final entity in entityStream) {
        if (entity is File) {
          final String filePath = entity.path;
          final String extension = path.extension(filePath).toLowerCase();
          if (validExtensions.isEmpty || validExtensions.contains(extension)) {
            foundFiles.add(filePath);
          }
        }
      }
    } catch (e) {
      debugPrint('Error scanning folder $folder: $e');
    }
    return foundFiles;
  }

  // Optimized method to gather files to hash by scanning folders in parallel
  Future<List<String>> _gatherFilesToHash(List<String> folders, Set<String> validExtensions) async {
    final List<Future<List<String>>> folderScans = folders
        .map((folder) => _scanSingleFolder(folder, validExtensions))
        .toList();
    final List<List<String>> results = await Future.wait(folderScans);
    return results.expand((files) => files).toList();
  }

  // Calculate a reasonable number of concurrent hashing operations
  int _calculateConcurrencyLevel() {
    final int cores = Platform.numberOfProcessors;
    return max(2, min(cores * 2, 16)); // Example: Min 2, Max 16, typically 2x cores
  }

  // Hash files found in specified folders, processing with limited concurrency
  Future<Map<String, String>> hashFilesInFolders(
    int consoleId,
    List<String> folders,
    List<String> validExtensions, {
    Function(int current, int total)? progressCallback,
  }) async {
    final Map<String, String> hashes = {};
    final validExtensionsSet = validExtensions
        .map((e) => e.toLowerCase())
        .toSet();

    if (folders.isEmpty) {
        debugPrint('No folders provided to scan.');
        return hashes;
    }

    debugPrint('Starting hash process for console ID: $consoleId');
    debugPrint('Folders to scan: ${folders.join(", ")}');
    debugPrint('Valid extensions: ${validExtensionsSet.join(", ")}');

    final List<String> allFiles = await _gatherFilesToHash(folders, validExtensionsSet);
    final int totalFiles = allFiles.length;
    debugPrint('Found $totalFiles files to hash.');

    if (allFiles.isEmpty) {
      return hashes;
    }

    final int concurrencyLevel = _calculateConcurrencyLevel();
    debugPrint('Using concurrency level: $concurrencyLevel');

    final List<Future<void>> activeTasks = [];
    int processedCount = 0;
    final Stream<String> fileStream = Stream.fromIterable(allFiles);

    await for (final filePath in fileStream) {
        while (activeTasks.length >= concurrencyLevel) {
            await Future.any(activeTasks);
        }

        late final Future<void> task;
        task = hashFile(filePath, consoleId).then((hash) {
            if (hash.isNotEmpty) {
                hashes[filePath] = hash;
            }
        }).catchError((e) {
            debugPrint('Error processing hash future for $filePath: $e');
        }).whenComplete(() {
            processedCount++;
            progressCallback?.call(processedCount, totalFiles);
            activeTasks.remove(task);
        });

        activeTasks.add(task);
    }

    await Future.wait(activeTasks);

    debugPrint('Hashing process completed. Generated ${hashes.length} valid hashes for $processedCount processed files.');
    return hashes;
  }
}