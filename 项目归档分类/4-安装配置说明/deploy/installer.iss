; ══════════════════════════════════════════════════════════════
; 星辰健康管理系统 - Inno Setup 安装脚本
; 编译方法：用 Inno Setup 6 打开此文件 → 点击 Compile
; 下载地址：https://jrsoftware.org/isdl.php
; ══════════════════════════════════════════════════════════════

#define MyAppName "星辰健康管理系统"
#define MyAppVersion "3.9.2"
#define MyAppPublisher "XingChen"

; !! 重要：将下面路径改为你实际运行 build-all.bat 后生成的 package 目录 !!
#define SourceDir "E:\计算机设计大赛\xingcheng_jiankang_v2.0\健康管理系统\deploy\package"

[Setup]
AppId={{A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\XingChen
DefaultGroupName={#MyAppName}
OutputDir=.\output
OutputBaseFilename=星辰健康管理系统_安装包_v{#MyAppVersion}
Compression=lzma2/ultra64
SolidCompression=yes
SetupIconFile=
WizardStyle=modern
PrivilegesRequired=admin
DisableProgramGroupPage=yes
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Messages]
WelcomeLabel2=这将在您的计算机上安装 [name] v{#MyAppVersion}。%n%n本系统需要 MySQL 8.0 作为数据库（需提前安装）。%n%nJDK 17、Redis、Nginx 已内置，无需额外安装。

[Files]
; 后端
Source: "{#SourceDir}\backend\*"; DestDir: "{app}\backend"; Flags: ignoreversion recursesubdirs

; 管理后台前端
Source: "{#SourceDir}\admin-ui\*"; DestDir: "{app}\admin-ui"; Flags: ignoreversion recursesubdirs

; 用户端前端
Source: "{#SourceDir}\user-ui\*"; DestDir: "{app}\user-ui"; Flags: ignoreversion recursesubdirs

; 便携版 JDK 17
Source: "{#SourceDir}\jdk\*"; DestDir: "{app}\jdk"; Flags: ignoreversion recursesubdirs

; 便携版 Redis
Source: "{#SourceDir}\redis\*"; DestDir: "{app}\redis"; Flags: ignoreversion recursesubdirs

; 便携版 Nginx（含配置）
Source: "{#SourceDir}\nginx\*"; DestDir: "{app}\nginx"; Flags: ignoreversion recursesubdirs

; SQL 初始化脚本
Source: "{#SourceDir}\sql\*"; DestDir: "{app}\sql"; Flags: ignoreversion recursesubdirs

; 启动/停止脚本
Source: "{#SourceDir}\start.bat"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#SourceDir}\stop.bat"; DestDir: "{app}"; Flags: ignoreversion

[Dirs]
; 创建上传文件目录
Name: "D:\xingchen\uploadPath"

[Icons]
; 桌面快捷方式
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\start.bat"; IconFilename: "{sys}\shell32.dll"; IconIndex: 21; Comment: "启动星辰健康管理系统"
Name: "{autodesktop}\停止星辰系统"; Filename: "{app}\stop.bat"; IconFilename: "{sys}\shell32.dll"; IconIndex: 131; Comment: "停止所有服务"

; 开始菜单
Name: "{group}\启动 {#MyAppName}"; Filename: "{app}\start.bat"
Name: "{group}\停止 {#MyAppName}"; Filename: "{app}\stop.bat"
Name: "{group}\卸载 {#MyAppName}"; Filename: "{uninstallexe}"

[Run]
; 安装完成后可选择立即启动
Filename: "{app}\start.bat"; Description: "立即启动系统"; Flags: nowait postinstall skipifsilent shellexec

[UninstallRun]
; 卸载前先停止服务
Filename: "{app}\stop.bat"; Flags: runhidden waituntilterminated

[Code]
// 安装前检查 MySQL 是否已安装
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  Result := True;
  if not Exec('sc', 'query MySQL80', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    if MsgBox('未检测到 MySQL 80 服务。'#13#10 +
              '本系统需要 MySQL 8.0 作为数据库。'#13#10#13#10 +
              '是否仍然继续安装？'#13#10 +
              '（安装后需要手动安装 MySQL 并导入 sql 目录下的脚本）',
              mbConfirmation, MB_YESNO) = IDNO then
      Result := False;
  end;
end;
