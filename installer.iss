#define MyAppName "RetroAchievements Library"
#define MyAppVersion "1.1.0"
#define MyAppPublisher "RetroAchievements Library"
#define MyAppExeName "retroachievements_library.exe"
#define BuildOutputDir "build\windows\x64\runner\Release"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{5F7C0BA0-9E11-40F1-8B41-2BAF7EE368D8}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; Output installer to the project root directory
OutputDir=.
OutputBaseFilename=RALibrary_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\app_icon.ico
VersionInfoVersion={#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BuildOutputDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BuildOutputDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "windows\runner\resources\app_icon.ico"; DestDir: "{app}"; Flags: ignoreversion
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
var
  UninstallKey: string;
begin
  Result := True;
  
  UninstallKey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{5F7C0BA0-9E11-40F1-8B41-2BAF7EE368D8}_is1';
  
  if RegKeyExists(HKLM, UninstallKey) or RegKeyExists(HKCU, UninstallKey) then
  begin
    if MsgBox('A previous version of {#MyAppName} is already installed.' + #13#10 + 'Do you want to overwrite the installation?', mbConfirmation, MB_YESNO) = IDNO then
    begin
      Result := False;
    end;
  end;
end;
