@echo off
setlocal

:: Define the output directory for debug info
set DEBUG_INFO_DIR=build/debug_info

:: Create the debug info directory if it doesn't exist
if not exist %DEBUG_INFO_DIR% (
    mkdir %DEBUG_INFO_DIR%
)

:: Prompt the user to choose between APK and AAB
echo Choose build type:
echo 1. APK
echo 2. AAB
set /p buildType="Enter 1 or 2: "

if "%buildType%" == "1" (
    echo Building APK...
    flutter build apk --split-per-abi --obfuscate --split-debug-info=%DEBUG_INFO_DIR%
) else if "%buildType%" == "2" (
    echo Building AAB...
    flutter build appbundle --obfuscate --split-debug-info=%DEBUG_INFO_DIR%
) else (
    echo Invalid choice. The script will exit.
    exit /b 1
)

endlocal
