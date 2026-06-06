@echo off
title Windows Optimallasdirma
color 0A
echo ================================================
echo       Windows 10/11 Optimallasdirma
echo ================================================
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo XETA: Sag klik - "Administrator kimi ishlet" secin!
    pause
    exit /b 1
)

echo [1/15] Temp fayllar temizlenilir...
del /q /f /s "%TEMP%\*" >nul 2>&1
del /q /f /s "C:\Windows\Temp\*" >nul 2>&1
del /q /f /s "C:\Windows\Prefetch\*" >nul 2>&1
del /q /f /s "%LOCALAPPDATA%\Microsoft\Windows\INetCache\*" >nul 2>&1
del /q /f /s "%LOCALAPPDATA%\Temp\*" >nul 2>&1

echo [2/15] Disk temizleme...
cleanmgr /sagerun:1 >nul 2>&1

echo [3/15] Yuksek performans rejimi...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1

echo [4/15] Gerezsiz servisler deaktiv edilir...
sc config "DiagTrack" start= disabled >nul 2>&1
net stop "DiagTrack" >nul 2>&1
sc config "dmwappushservice" start= disabled >nul 2>&1
net stop "dmwappushservice" >nul 2>&1
sc config "WSearch" start= disabled >nul 2>&1
net stop "WSearch" >nul 2>&1
sc config "MapsBroker" start= disabled >nul 2>&1
net stop "MapsBroker" >nul 2>&1
sc config "Fax" start= disabled >nul 2>&1
net stop "Fax" >nul 2>&1
sc config "XblGameSave" start= disabled >nul 2>&1
net stop "XblGameSave" >nul 2>&1
sc config "XboxNetApiSvc" start= disabled >nul 2>&1
net stop "XboxNetApiSvc" >nul 2>&1

echo [5/15] Visual effektler azaldilir...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\DWM" /v EnableAeroPeek /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\DWM" /v AlwaysHibernateThumbnails /t REG_DWORD /d 0 /f >nul 2>&1

echo [6/15] Bashlangic proqramlar azaldilir...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Skype /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Discord /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Spotify /f >nul 2>&1

echo [7/15] RAM optimizasiyasi...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul 2>&1

echo [8/15] Telemetriya deaktiv edilir...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f >nul 2>&1

echo [9/15] Suretli Bashlama aktiv edilir...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 1 /f >nul 2>&1

echo [10/15] Sebeke optimizasiyasi...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global chimney=enabled >nul 2>&1
netsh int tcp set global ecncapability=enabled >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f >nul 2>&1

echo [11/15] DNS cache temizlenilir...
ipconfig /flushdns >nul 2>&1
ipconfig /registerdns >nul 2>&1

echo [12/15] Game Mode ve GPU optimizasiyasi...
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1

echo [13/15] Axtaris indeksi optimizasiyasi...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowIndexingEncryptedStoresOrItems /t REG_DWORD /d 0 /f >nul 2>&1

echo [14/15] Prefetch ayarlari...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 3 /f >nul 2>&1

echo [15/15] Disk xetalarini yoxla...
echo Y | chkdsk C: /f >nul 2>&1

echo.
echo ================================================
echo   TAMAM! Butun 15 addim ugurla tamamlandi.
echo   Komputeri YENIDEN BASHLADIN!
echo ================================================
echo.
pause
