@echo off
title Windows 10 Optimallasdirma
echo ================================
echo   Windows 10 Optimallasdirma
echo ================================
echo.

:: Administrator yoxla
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo XETA: Bu faylı sag klik edin ve "Administrator kimi ishlet" secin!
    pause
    exit
)

echo [1/10] Temp fayllar temizlenilir...
del /q /f /s %TEMP%\* >nul 2>&1
del /q /f /s C:\Windows\Temp\* >nul 2>&1
del /q /f /s C:\Windows\Prefetch\* >nul 2>&1

echo [2/10] Disk temizleme ishedilir...
cleanmgr /sagerun:1 >nul 2>&1

echo [3/10] Yuksek performans rejimi aktiv edilir...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1

echo [4/10] Gereksiz servisler deaktiv edilir...
sc config "SysMain" start= disabled >nul 2>&1
net stop "SysMain" >nul 2>&1
sc config "WSearch" start= disabled >nul 2>&1
net stop "WSearch" >nul 2>&1
sc config "DiagTrack" start= disabled >nul 2>&1
net stop "DiagTrack" >nul 2>&1
sc config "dmwappushservice" start= disabled >nul 2>&1
net stop "dmwappushservice" >nul 2>&1
sc config "MapsBroker" start= disabled >nul 2>&1
net stop "MapsBroker" >nul 2>&1
sc config "PrintSpooler" start= disabled >nul 2>&1
net stop "PrintSpooler" >nul 2>&1

echo [5/10] Visual effektler azaldilir...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul 2>&1

echo [6/10] Bashlangic proqramlar azaldilir...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v SecurityHealth /f >nul 2>&1

echo [7/10] RAM optimizasiyasi...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v ClearPageFileAtShutdown /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul 2>&1

echo [8/10] Sehre effektleri ve animasiyalar soenduerueluer...
reg add "HKCU\Software\Microsoft\Windows\DWM" /v EnableAeroPeek /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\DWM" /v AlwaysHibernateThumbnails /t REG_DWORD /d 0 /f >nul 2>&1

echo [9/10] DNS cache temizlenilir...
ipconfig /flushdns >nul 2>&1

echo [10/10] Disk xetalarini yoxla (fonda)...
echo Disk yoxlamasi novbeti yeniden bashlayishda isher.
chkdsk C: /f /r /x >nul 2>&1

echo.
echo ================================
echo   TAMAM! Butun addimlar bitti.
echo   Komputeri YENIDEN BASHLAYIN!
echo ================================
pause
