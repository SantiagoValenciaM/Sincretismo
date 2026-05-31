; Sincretismo — Inno Setup Installer Script
; Compilar con: Inno Setup 6  (https://jrsoftware.org/isinfo.php)
; Genera: SincretismoSetup.exe

#define AppName      "Sincretismo"
#define AppVersion   "1.0"
#define AppPublisher "Bullyies — TEC"
#define AppExeName   "Sincretismo.exe"

[Setup]
AppId={{A3F2E1B4-7C9D-4E5F-8A2B-1D3C6E0F9B8A}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher={#AppPublisher}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=SincretismoSetup
SetupIconFile=
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesAllowed=x86_64
ArchitecturesInstallIn64BitMode=x86_64

; No mostrar licencia (juego universitario)
DisableDirPage=no
DisableReadyMemo=yes
DisableReadyPage=no

[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "Crear acceso directo en el {cm:DesktopName}"; GroupDescription: "Iconos adicionales:"

[Files]
; EXE principal (PCK embebido — código compilado, no legible)
Source: "{#AppExeName}"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#AppName}";         Filename: "{app}\{#AppExeName}"
Name: "{group}\Desinstalar {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}";   Filename: "{app}\{#AppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExeName}"; Description: "Iniciar {#AppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
