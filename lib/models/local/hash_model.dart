/// Mapping of console IDs to their appropriate hashing configurations
class ConsoleHashMethods {
  // Private constructor to prevent instantiation
  ConsoleHashMethods._();

  static final Map<int, List<String>> consoleFileExtensions = {
    // Mega Drive
    1: ['.bin', '.md', '.smd', '.gen'],
    //N64
    2: ['.n64', '.z64', '.v64', '.ndd'],
    // SNES/Super Famicom
    3: ['.sfc', '.smc', '.swc', '.fig'],
    // Game Boy
    4: ['.gb', '.gbc'],
    // Game Boy Advance
    5: ['.gba'],
    // Game Boy Color
    6: ['.gb', '.gbc'],
    // NES/Famicom
    7: ['.nes', '.fds'],
    // PC Engine/TurboGrafx-16
    8: ['.pce', '.sgx'],
    //Sega CD
    9: ['.chd', '.iso', '.cue'],
    // 32X
    10: ['.bin', '.32x'],
    // Master System
    11: ['.bin', '.sms'],
    //Playstation
    12: ['.cue', '.chd', '.iso'],
    // Atari Lynx
    13: ['.lnx'],
    // NeoGeo Pocket
    14: ['.ngp', '.ngc'],
    // Game Gear
    15: ['.gg', '.bin'],
    //GameCube
    16: ['.iso', '.rvz', '.cue'],
    // Atari Jaguar
    17: ['.j64'],
    //NDS
    18: ['.nds', '.dsi', '.ids'],
    // Wii
    19: ['.iso', '.wbfs', '.rvz', '.gcm', '.cci', '.ciso', '.gcz', '.chd', '.cue'],
    //PS2
    21: ['.bin', '.chd', '.iso', '.img', '.cue'],
    // Magnavox
    23: ['.bin', '.iso', '.chd'],
    // Pokemon Mini
    24: ['.eep', '.min'],
    // Atari 2600
    25: ['.bin', '.a26'],
    //Arcade
    27: ['.zip', '.7z'],
    // Virtual Boy
    28: ['.vb'],
    //MSX
    29: ['.rom', '.dsk'],
    // SG-1000
    33: ['.sg'],
    //Amstrad CPC
    37: ['.dsk', '.bin'],
    //Apple II
    38: ['.dsk', '.woz', '.nib'],
    //Saturn
    39: ['.chd', '.cue', '.iso'],
    //DREAMCAST
    40: ['.chd', '.gdi', '.cue', '.cdi'],
    //PSP
    41: ['.cue', '.iso', '.chd'],
    // 3DO
    43: ['.cue', '.chd', '.iso'],
    // ColecoVision
    44: ['.col', '.bin'],
    // Intellivision
    45: ['.int', '.bin'],
    // Vectrex
    46: ['.vec'],
    //NEC PC-8000
    47: ['.d88'],
    //PC-FX
    49: ['.iso', '.cue', '.img', '.chd', '.bin'],
    // Atari 7800
    51: ['.a78'],
    // Wonderswan
    53: ['.bin', '.ws', '.wsc'],
    //Neo Geo CD
    56: ['.chd', '.cue', '.bin', '.iso', '.img'],
    // Fairchild
    57: ['.bin'],
    // Watara
    63: ['.sv'],
    // Mega Duck
    69: ['.md2', '.md1'],
    // Arduboy
    71: ['.hex'],
    // WASM-4
    72: ['.wasm'],
    //Arcadia 2001
    73: ['.bin'],
    //Interton VC4000
    74: ['.bin'],
    //Elektor TV
    75: ['.bin', '.pgm', '.tvc'],
    //PCE CD
    76: ['.img', '.chd', '.cue', '.iso'],
    //Jaguar CD
    77: ['.bin', '.cue', '.cdi', '.chd'],
    //DSi
    78: ['.nds', '.dsi', '.ids'],
    //Uzebox
    80: ['.bin', '.uze', '.hex'],
    //FDS - Famicom Disk System
    81: ['.fds', '.nes'],
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
