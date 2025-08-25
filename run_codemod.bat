@echo off
setlocal

set PROJECT=%~dp0
REM Default to current directory; allow parameter
if not "%1"=="" set PROJECT=%1

REM Try dart on PATH
where dart >nul 2>nul
if %ERRORLEVEL%==0 (
  echo Using: dart on PATH
  dart run tool\apply_palette_codemod.dart "%PROJECT%"
  goto :eof
)

REM Try flutter's bundled dart
set FLUTTER_DART=%USERPROFILE%\Desktop\flutter\bin\cache\dart-sdk\bin\dart.exe
if exist "%FLUTTER_DART%" (
  echo Using: %FLUTTER_DART%
  "%FLUTTER_DART%" run tool\apply_palette_codemod.dart "%PROJECT%"
  goto :eof
)

echo Could not find 'dart'. Please ensure Flutter is installed and add Dart to PATH, or edit this .bat to your Flutter path.
exit /b 1
