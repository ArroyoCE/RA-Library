/// Mapping of console IDs to their appropriate hashing configurations
class ConsoleHashMethods {
  // Private constructor to prevent instantiation
  ConsoleHashMethods._();

  static final Map<int, List<String>> consoleFileExtensions = {
    // Mega Drive
    1: ['.bin', '.md', '.smd', '.gen', '.zip'],
    //N64
    2: ['.n64', '.z64', '.v64', '.ndd', '.zip'],
    // SNES/Super Famicom
    3: ['.sfc', '.smc', '.swc', '.fig', '.zip'],
    // Game Boy
    4: ['.gb', '.gbc', '.zip'],
    // Game Boy Advance
    5: ['.gba', '.zip'],
    // Game Boy Color
    6: ['.gb', '.gbc', '.zip'],
    // NES/Famicom
    7: ['.nes', '.fds', '.zip'],
    // PC Engine/TurboGrafx-16
    8: ['.pce', '.sgx', '.zip'],
    //Sega CD
    9: ['.chd', '.iso', '.cue'],
    // 32X
    10: ['.bin', '.32x', '.zip'],
    // Master System
    11: ['.bin', '.sms', '.zip'],
    //Playstation
    12: ['.cue', '.chd', '.iso'],
    // Atari Lynx
    13: ['.lnx', '.zip'],
    // NeoGeo Pocket
    14: ['.ngp', '.ngc', '.zip'],
    // Game Gear
    15: ['.gg', '.bin', '.zip'],
    //GameCube
    16: ['.iso', '.rvz', '.cue'],
    // Atari Jaguar
    17: ['.j64', '.zip'],
    //NDS
    18: ['.nds', '.dsi', '.ids', '.zip'],
    // Wii
    19: ['.iso', '.wbfs', '.rvz', '.gcm', '.cci', '.ciso', '.gcz', '.chd', '.cue', '.wad'],
    //PS2
    21: ['.bin', '.chd', '.iso', '.img', '.cue'],
    // Magnavox
    23: ['.bin', '.zip'],
    // Pokemon Mini
    24: ['.eep', '.min', '.zip'],
    // Atari 2600
    25: ['.bin', '.a26', '.zip'],
    //Arcade
    27: ['.zip', '.7z'],
    // Virtual Boy
    28: ['.vb', '.zip'],
    //MSX
    29: ['.rom', '.dsk', '.zip'],
    // SG-1000
    33: ['.sg', '.zip'],
    //Amstrad CPC
    37: ['.dsk', '.bin', '.zip'],
    //Apple II
    38: ['.dsk', '.woz', '.nib', '.zip'],
    //Saturn
    39: ['.chd', '.cue', '.iso'],
    //Dreamcast
    40: ['.chd', '.gdi', '.cue', '.cdi'],
    //PSP
    41: ['.cue', '.iso', '.chd'],
    // 3DO
    43: ['.cue', '.chd', '.iso'],
    // ColecoVision
    44: ['.col', '.bin', '.zip'],
    // Intellivision
    45: ['.int', '.bin', '.zip'],
    // Vectrex
    46: ['.vec', '.zip'],
    //NEC PC-8000
    47: ['.d88', '.zip'],
    //PC-FX
    49: ['.iso', '.cue', '.img', '.chd', '.bin'],
    // Atari 7800
    51: ['.a78', '.zip'],
    // Wonderswan
    53: ['.bin', '.ws', '.wsc', '.zip'],
    //Neo Geo CD
    56: ['.chd', '.cue', '.bin', '.iso', '.img'],
    // Fairchild
    57: ['.bin', '.zip'],
    // Watara
    63: ['.sv', '.zip'],
    // Mega Duck
    69: ['.md2', '.md1', '.zip'],
    // Arduboy
    71: ['.hex', '.zip'],
    // WASM-4
    72: ['.wasm', '.zip'],
    //Arcadia 2001
    73: ['.bin', '.zip'],
    //Interton VC4000
    74: ['.bin', '.zip'],
    //Elektor TV
    75: ['.bin', '.pgm', '.tvc', '.zip'],
    //PCE CD
    76: ['.img', '.chd', '.cue', '.iso'],
    //Jaguar CD
    77: ['.bin', '.cue', '.cdi', '.chd'],
    //DSi
    78: ['.nds', '.dsi', '.ids', '.zip'],
    //Uzebox
    80: ['.bin', '.uze', '.hex', '.zip'],
    //FDS - Famicom Disk System
    81: ['.fds', '.nes', '.zip'],
  };

  /// Get supported file extensions for a console
  static List<String> getFileExtensionsForConsole(int consoleId) {
    return consoleFileExtensions[consoleId] ??
        ['.bin']; // Default to .bin if not found
  }

  /// Check if a console is supported based on file extension mapping
  static bool isConsoleSupported(int consoleId) {
    return consoleFileExtensions.containsKey(consoleId);
  }

  /// Get a list of all supported console IDs
  static List<int> get supportedConsoleIds {
    return consoleFileExtensions.keys.toList();
  }
}
