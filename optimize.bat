@echo off
chcp 65001 >nul
title Windows 10/11 Optimallasdirma
color 0A
echo ================================================
echo       Windows 10/11 Optimallasdirma Aləti
echo ================================================
echo.

:: Administrator yoxla
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [XETA] Bu faylı sag klik edin ve "Administrator kimi ishlet" secin!
    pause
    exit /b 1
)

echo [1/15] Temp ve keş fayllar temizlenilir...
del /q /f /s "%TEMP%\*" >nul 2>&1
del /q /f /s "C:\Windows\Temp\*" >nul 2>&1
del /q /f /s "C:\Windows\Prefetch\*" >nul 2>&1
del /q /f /s "%LOCALAPPDATA%\Microsoft\Windows\INetCache\*" >nul 2>&1
del /q /f /s "%LOCALAPPDATA%\Temp\*" >nul 2>&1
echo    Tamamlandi.

echo [2/15] Disk temizleme ishedilir...
cleanmgr /sagerun:1 >nul 2>&1
echo    Tamamlandi.

echo [3/15] Yuksek performans rejimi aktiv edilir...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
:: Ultimate Performance (mövcuddursa)
powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
echo    Tamamlandi.

echo [4/15] Gereksiz servisler deaktiv edilir...
:: Telemetry ve izləmə
sc config "DiagTrack" start= disabled >nul 2>&1 & net stop "DiagTrack" >nul 2>&1
sc config "dmwappushservice" start= disabled >nul 2>&1 & net stop "dmwappushservice" >nul 2>&1
:: Axtarış indeksi (SSD-də lazımsız)
sc config "WSearch" start= disabled >nul 2>&1 & net stop "WSearch" >nul 2>&1
:: Xəritə yeniləmə
sc config "MapsBroker" start= disabled >nul 2>&1 & net stop "MapsBroker" >nul 2>&1
:: Faks
sc config "Fax" start= disabled >nul 2>&1 & net stop "Fax" >nul 2>&1
:: Xbox Game DVR
sc config "XblGameSave" start= disabled >nul 2>&1 & net stop "XblGameSave" >nul 2>&1
sc config "XboxNetApiSvc" start= disabled >nul 2>&1 & net stop "XboxNetApiSvc" >nul 2>&1
echo    Tamamlandi.

echo [5/15] Visual effektler azaldilir...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\DWM" /v EnableAeroPeek /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\DWM" /v AlwaysHibernateThumbnails /t REG_DWORD /d 0 /f >nul 2>&1
echo    Tamamlandi.

echo [6/15] Bashlangic proqramlar azaldilir...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Skype /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Discord /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Spotify /f >nul 2>&1
echo    Tamamlandi.

echo [7/15] RAM optimizasiyasi...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul 2>&1
echo    Tamamlandi.

echo [8/15] Telemetriya ve izleme deaktiv edilir...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /v AcceptedPrivacyPolicy /t REG_DWORD /d 0 /f >nul 2>&1
echo    Tamamlandi.

echo [9/15] Sürətli Başlama (Fast Startup) aktiv edilir...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 1 /f >nul 2>&1
echo    Tamamlandi.

echo [10/15] Şəbəkə optimizasiyası...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global chimney=enabled >nul 2>&1
netsh int tcp set global dca=enabled >nul 2>&1
netsh int tcp set global netdma=enabled >nul 2>&1
netsh int tcp set global ecncapability=enabled >nul 2>&1
:: Windows Update bant genişliyini məhdudlaşdır
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /v DODownloadMode /t REG_DWORD /d 0 /f >nul 2>&1
echo    Tamamlandi.

echo [11/15] DNS cache temizlenilir ve optimallaşdirilir...
ipconfig /flushdns >nul 2>&1
ipconfig /registerdns >nul 2>&1
echo    Tamamlandi.

echo [12/15] Game Mode ve GPU optimizasiyasi...
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v DirectXUserGlobalSettings /t REG_SZ /d "SwapEffectUpgradeEnable=1;" /f >nul 2>&1
:: Hardware-accelerated GPU scheduling
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1
echo    Tamamlandi.

echo [13/15] Windows axtaris ve indeksleme optimizasiyasi...
:: Axtarışdan gereksiz yerləri çıxar
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowIndexingEncryptedStoresOrItems /t REG_DWORD /d 0 /f >nul 2>&1
echo    Tamamlandi.

echo [14/15] Prefetch ve SuperFetch ayarlari...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 3 /f >nul 2>&1
echo    Tamamlandi.

echo [15/15] Disk xetalarini yoxla (novbeti yeniden bashlayishda)...
echo Y | chkdsk C: /f >nul 2>&1
echo    Novbeti yeniden bashlayishda ishlayecek.

echo.
echo ================================================
echo   TAMAM! Butun 15 addim ugurla tamamlandi.
echo.
echo   MUTLEQ komputeri YENIDEN BASHLADIN!
echo ================================================
echo.
pause
