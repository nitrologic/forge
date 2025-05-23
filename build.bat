@echo off
setlocal EnableDelayedExpansion

set DIR=rc3
set COMPILE_ARGS=--allow-run --allow-env --allow-net --allow-read --allow-write
set CORE=README.md LICENSE forge.md welcome.txt accounts.json modelrates.json
set EXTRAS=isolation\readme.txt isolation\test.js foundry\notice.txt
set DEPENDENCIES=%CORE% %EXTRAS%

if not exist "forge.js" (
	echo Error: forge.js not found.
	exit /b 1
)

deno cache forge.js
if errorlevel 1 (
	echo Error: Failed to cache dependencies.
	exit /b 1
)

deno compile %COMPILE_ARGS% --output %DIR%\forge.exe forge.js
if errorlevel 1 (
	echo Error: Failed to compile forge.js.
	exit /b 1
)

if not exist "%DIR%\forge.exe" (
	echo Error: forge.exe not created.
	exit /b 1
)

set MISSING=0
for %%F in (%DEPENDENCIES%) do (
	if exist "%%F" (
		set TARGET=%DIR%\%%F
		xcopy /Y /-I /F "%%F" "%DIR%\%%F" && (
			echo   Copied %%F
		) || (
			echo   Failed to copy %%F
			set /a MISSING+=1
		)
	) else (
		echo   %%F not found
		set /a MISSING+=1
	)
)

if !MISSING! gtr 0 (
	echo "Failure, please check dependencies."
	exit /b 1
)

echo Forge %DIR% build completed.

rem upx --best %DIR%\forge.exe

exit /b 0
