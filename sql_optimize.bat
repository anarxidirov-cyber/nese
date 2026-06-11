@echo off
title SQL Server FPro Optimizasiya
color 0A
echo ================================================
echo   SQL Server FPro Optimizasiya
echo ================================================
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo XETA: Administrator kimi ishledin!
    pause
    exit /b 1
)

:: ============================================
:: ADIM 1: RAM-i yoxla ve deyeri sec
:: ============================================
echo [1/6] RAM yoxlanilir...
for /f "tokens=2 delims==" %%a in ('wmic computersystem get TotalPhysicalMemory /value') do set RAMBYTES=%%a
set /a RAMGB=%RAMBYTES:~0,-9%

echo     Umumi RAM: %RAMGB% GB

if %RAMGB% GEQ 16 (
    set MINMEM=2048
    echo     Secilen min server memory: 2048 MB  [16+ GB RAM]
) else if %RAMGB% GEQ 8 (
    set MINMEM=1024
    echo     Secilen min server memory: 1024 MB  [8 GB RAM]
) else (
    set MINMEM=512
    echo     Secilen min server memory: 512 MB   [8 GB-dan az RAM]
)
echo.

:: ============================================
:: ADIM 2: SQL Server instance adini tap
:: ============================================
echo [2/6] SQL Server instance yoxlanilir...
set SQLINSTANCE=.
for /f "tokens=1" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL" /v MSSQLSERVER 2^>nul') do (
    set SQLINSTANCE=.
)
for /f "tokens=3" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL" 2^>nul ^| findstr /i "MSSQL"') do (
    set INSTANCENAME=%%i
)
if defined INSTANCENAME (
    if not "%INSTANCENAME%"=="MSSQLSERVER" (
        set SQLINSTANCE=.\%INSTANCENAME%
    )
)
echo     SQL Instance: %SQLINSTANCE%
echo.

:: ============================================
:: ADIM 3: Hazirki ayarlari goster
:: ============================================
echo [3/6] Hazirki SQL yaddas ayarlari ve kes veziyyeti...
echo.
sqlcmd -S %SQLINSTANCE% -E -Q "
PRINT '--- Min/Max Server Memory ---';
SELECT name, value_in_use AS current_value, description
FROM sys.configurations
WHERE name IN ('min server memory (MB)', 'max server memory (MB)');

PRINT '';
PRINT '--- Hazirki RAM istifadesi ---';
SELECT
    physical_memory_in_use_kb/1024 AS memory_used_mb,
    page_fault_count,
    memory_utilization_percentage
FROM sys.dm_os_process_memory;

PRINT '';
PRINT '--- Kes veziyyeti (baza uzre MB) ---';
SELECT
    ISNULL(DB_NAME(database_id), 'ResourceDB') AS baza_adi,
    COUNT(*)*8/1024 AS kes_mb
FROM sys.dm_os_buffer_descriptors
GROUP BY database_id
ORDER BY kes_mb DESC;
" -W
echo.

:: ============================================
:: ADIM 4: min server memory tetbiq et
:: ============================================
echo [4/6] min server memory = %MINMEM% MB tetbiq edilir...
sqlcmd -S %SQLINSTANCE% -E -Q "
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'min server memory (MB)', %MINMEM%; RECONFIGURE;
PRINT 'Tetbiq edildi.';
" -W
echo.

:: ============================================
:: ADIM 5: Yoxla
:: ============================================
echo [5/6] Deyerin tetbiq olunduğu yoxlanilir...
sqlcmd -S %SQLINSTANCE% -E -Q "
SELECT name, value_in_use AS tetbiq_olunan_deyar
FROM sys.configurations
WHERE name = 'min server memory (MB)';
" -W
echo.

:: ============================================
:: ADIM 6: FPro bazasini tap ve kesi isit
:: ============================================
echo [6/6] FPro bazasi axtarilir ve kes isidilir...
sqlcmd -S %SQLINSTANCE% -E -Q "
DECLARE @db NVARCHAR(128);
SELECT TOP 1 @db = name FROM sys.databases
WHERE name LIKE 'FProSolution%' OR name LIKE 'FPro%'
ORDER BY name;

IF @db IS NULL
BEGIN
    PRINT 'XETA: FPro bazasi tapilmadi!';
    SELECT name FROM sys.databases ORDER BY name;
    RETURN;
END

PRINT 'Tapildi: ' + @db;
PRINT 'Kes isidilir...';

DECLARE @sql NVARCHAR(MAX);

-- Cedveller
DECLARE @tables TABLE (t NVARCHAR(128));
INSERT INTO @tables VALUES
    ('sm_kontr_sat'), ('sm_kontr_sat_el'), ('sm_kmd'), ('sm_kmx'),
    ('sm_sobeler_med'), ('sm_sobeler_med_el'), ('sm_mal_sil'),
    ('sm_mal_say'), ('sm_goods'), ('sm_kontra');

DECLARE @t NVARCHAR(128), @cnt BIGINT;
DECLARE cur CURSOR FOR SELECT t FROM @tables;
OPEN cur;
FETCH NEXT FROM cur INTO @t;
WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        SET @sql = N'SELECT @c = COUNT_BIG(*) FROM [' + @db + '].dbo.[' + @t + ']';
        EXEC sp_executesql @sql, N'@c BIGINT OUTPUT', @c = @cnt OUTPUT;
        PRINT '  ' + @t + ': ' + CAST(@cnt AS NVARCHAR) + ' setur';
    END TRY
    BEGIN CATCH
        PRINT '  ' + @t + ': tapilmadi (kecildi)';
    END CATCH
    FETCH NEXT FROM cur INTO @t;
END
CLOSE cur; DEALLOCATE cur;

-- View-lar
DECLARE @views TABLE (v NVARCHAR(128));
INSERT INTO @views VALUES ('sm_kas_qal'), ('sm_kontr_qal'), ('sm_sob_qal');
DECLARE @v NVARCHAR(128);
DECLARE vcur CURSOR FOR SELECT v FROM @views;
OPEN vcur;
FETCH NEXT FROM vcur INTO @v;
WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        SET @sql = N'SELECT @c = COUNT_BIG(*) FROM [' + @db + '].dbo.[' + @v + ']';
        EXEC sp_executesql @sql, N'@c BIGINT OUTPUT', @c = @cnt OUTPUT;
        PRINT '  VIEW ' + @v + ': ' + CAST(@cnt AS NVARCHAR) + ' setur';
    END TRY
    BEGIN CATCH
        PRINT '  VIEW ' + @v + ': tapilmadi (kecildi)';
    END CATCH
    FETCH NEXT FROM vcur INTO @v;
END
CLOSE vcur; DEALLOCATE vcur;

PRINT '';
PRINT '--- Son kes veziyyeti (' + @db + ') ---';
SELECT COUNT(*)*8/1024 AS kes_mb
FROM sys.dm_os_buffer_descriptors
WHERE database_id = DB_ID(@db);
" -W -t 300
echo.

echo ================================================
echo   TAMAM! Butun addimlar tamamlandi.
echo ================================================
pause
