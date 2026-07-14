// lib/repositories/local_data_repository.dart

import 'package:retroachievements_organizer/models/consoles/all_console_model.dart';

abstract class LocalDataRepository {
  Future<List<Console>> getLocalConsolesFolders();
  bool isConsoleSupported(int consoleId);
  List<int> getSupportedConsoleIds();

  Future<Map<String, String>> hashFilesInFolders(int consoleId, List<String> folders, {bool skipExisting = false, Function(int current, int total)? progressCallback});
  Future<void> saveLocalHashes(int consoleId, Map<String, String> hashes);
  Future<Map<String, String>> getLocalHashes(int consoleId);
  List<String> getFileExtensionsForConsole(int consoleId);
  Future<Map<int, List<String>>> getConsoleFolders();
  Future<void> saveConsoleFolders(int consoleId, List<String> folders);
  Future<void> saveHashStats(int consoleId, int matchedGames, int matchedHashes);
  Future<Map<String, dynamic>?> getHashStats(int consoleId);
  Future<void> saveConsoleTotals(int consoleId, int totalGames, int totalHashes);
  Future<Map<String, dynamic>?> getConsoleTotals(int consoleId);

  

}

