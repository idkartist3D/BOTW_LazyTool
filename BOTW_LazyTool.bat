@echo off
title BOTW Lazy Tool
setlocal ENABLEDELAYEDEXPANSION
REM Take the cmd-line, remove all until the first parameter
set "params=!cmdcmdline:~0,-1!"
set "params=!params:*" =!"
set count=0

REM Split the parameters on spaces but respect the quotes
for %%G IN (!params!) do (
  set /a count+=1
  set "file_!count!=%%~G"
  rem echo !count! %%~G
)

REM list the parameters
echo !file_1!|find ".csv" >nul
if errorlevel 1 (
    REM Not the csv file!
	set csvPath=!file_2!
	set bfresPath=!file_1!
) else (
    REM Is the csv file!
    set csvPath=!file_1!
	set bfresPath=!file_2!
)
REM If no files are given (User probably just opened .bat)
if "!file_1!"=="" (
	ECHO Ya need to drag the bfres and csv onto the .bat^^!
	ECHO Press any key to exit...
	PAUSE>nul
	exit
)
REM If no second file was given
if "!file_2!"=="" (
	ECHO Ya need to drag in both files^^!
	ECHO Press any key to exit...
	PAUSE>nul
	exit
)
REM If a third file was given
if NOT "!file_3!"=="" (
	ECHO More than two files detected. The universe will now end.
	ECHO Press any key to become the singularity...
	PAUSE>nul
	exit
)

REM Print 
ECHO CSV: %~nx1
ECHO BFRES: %~nx2
ECHO.
REM If no BFRES_Vertex.py script exists
IF NOT EXIST "%~dp0\BFRES_Vertex.py" (
	ECHO No BFRES_Vertex.py script found^^!
	ECHO Make sure it's located in the same directory as this program.
	ECHO If you don't have it, press any key to go to the download page.
	PAUSE>nul
	START "" https://gamebanana.com/tools/6132
	exit
) else (
	ECHO Initializing BFRES_Vertex...
)
ECHO.
goto runScripts

:runScripts
REM Executes the specified script + bfres and csv in the current directory.
python "%~dp0\BFRES_Vertex.py" "%bfresPath%" "%csvPath%"
ECHO.
ECHO.

REM If no BOTW_AutoMips.py script exists
IF NOT EXIST "%~dp0\BOTW-AutoMips.py" (
	ECHO No BOTW-AutoMips.py script found^^!
	ECHO Make sure it's located in the same directory as this program.
	ECHO If you don't have it, press any key to go to the download page.
	PAUSE>nul
	START "" https://github.com/CEObrainz/Botw-AutoMipping
	exit
) ELSE (
	REM Waits for user to initialize the Auto-Mips script.
	ECHO Press any key initialize Auto-Mips, or just close the window to uhh... not
)
PAUSE>nul
ECHO.
REM Executes the specified script + bfres in the current directory.
python "%~dp0\BOTW-AutoMips.py" "%bfresPath%"
ECHO.
ECHO.
ECHO All done^^! Hooray for not having to type things^^! ^^^^^-^^^^
ECHO Press any key to exit...
PAUSE>nul
"%~dp0\yaz0enc.exe" "%bfresPath%"
ECHO Press any key to exit...
PAUSE>nul

REM Shitily thrown together by IdkArtist3D
