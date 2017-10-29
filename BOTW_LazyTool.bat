@echo off 
TITLE BOTW Lazy Tool
setlocal ENABLEDELAYEDEXPANSION
rem Take the cmd-line, remove all until the first parameter
set "params=!cmdcmdline:~0,-1!"
set "params=!params:*" =!"
set count=0

rem Split the parameters on spaces but respect the quotes
for %%G IN (!params!) do (
  set /a count+=1
  set "file_!count!=%%~G"
  SET /A fileCount=!count!
)
ECHO Filecount is !count!

REM If there's greater than two files, assume no use of BFRES_Vertex.py, go straight to encoding/decoding
IF %fileCount% GTR 2 (
	GOTO encDec
) ELSE  (
	REM If there's only one file, again assume no use of BFRES_Vertex.py, go straight to encoding/decoding
	IF %fileCount% EQU 1 (
		GOTO encDec
	) ELSE (
		GOTO encTest
  )
)

REM If there are two files, check to see if either are csv files. If not, assume encoding/decoding
:encTest
ECHO !file_1!|find ".csv" >nul
IF errorlevel 1 (
    REM Is not a CSV file! Continues to check other file.
) ELSE (
	GOTO vertexMipsEnc
)  
ECHO !file_2!|find ".csv" >nul
IF errorlevel 1 (
    REM Is not a CSV file! Continues to check other file.
) ELSE (
	GOTO vertexMipsEnc
)  
GOTO encDec


:vertexMipsEnc
ECHO !file_1!|find ".csv" >nul
IF errorlevel 1 (
    REM Not the csv file!
	set csvPath=!file_2!
	set bfresPath=!file_1!
	FOR %%i IN ("!file_1!") DO (
	  set bfresName=%%~ni
	)
) ELSE (
    REM Is the csv file!
    SET csvPath=!file_1!
	SET bfresPath=!file_2!
	FOR %%i IN ("!file_2!") DO (
	  set bfresName=%%~ni
	)
)
REM Print Bfres and CSV names
ECHO CSV: %csvPath%
ECHO BFRES: %bfresPath%
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
REM Executes the specified script + bfres and csv in the current directory.
"%~dp0\BFRES_Vertex.py" "%bfresPath%" "%csvPath%"
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
	ECHO Press any key initialize Auto-Mips
)
PAUSE>nul
ECHO.

REM Executes the specified script + bfres in the current directory.
"%~dp0\BOTW-AutoMips.py" "%bfresPath%"
ECHO.
ECHO.
ECHO Press any key to run Yaz0Enc
PAUSE>nul

REM If file already exists with the name it will be written to, delete it
REM -Possibility for having a system to rename the old file to .old(x) so no files are accidentally lost/deleted
IF EXIST "%~dp0\%bfresName%.sbfres" DEL "%bfresName%.sbfres"

REM Executes Yaz0Encoder
"%~dp0\yaz0enc.exe" "%bfresPath%"

REM Renames output file to .sbfres
REN "%bfresName%.bfres.yaz0" "%bfresName%.sbfres"

GOTO exit

REM Runs a loop to encode/decode multiple files
:encDec
SET /A loopNum=1
:loop
REM Reads first four bytes of file
SET /p encTest=< !file_%loopNum%!
ECHO encTest Result: %encTest%

REM Get just the name of the file
FOR %%i IN ("!file_%loopNum%!") DO (
	  SET fileName=%%~ni
	)
	
REM If first for bytes are Yaz0, delete old file, run Yaz0Dec, and rename
IF "%encTest:~0,4%"=="Yaz0" (
	IF EXIST "%~dp0\%fileName%.bfres" DEL "%fileName%.bfres"
	"%~dp0\yaz0dec.exe" "!file_%loopNum%!"
	REN "%fileName%.sbfres 0.rarc" "%fileName%.bfres"
	
REM If first for bytes are FRES, delete old file, run Yaz0Enc, and rename
) ELSE IF "%encTest:~0,4%"=="FRES" (
	IF EXIST "%~dp0\%fileName%.sbfres" DEL "%fileName%.sbfres"
	"%~dp0\yaz0enc.exe" "!file_%loopNum%!"
	REN "%fileName%.bfres.yaz0" "%fileName%.sbfres"

)

REM If it's gone through all the files, just exit. If not, go back to the start of the loop.
if %loopNum%==%fileCount% GOTO exit
SET /A loopNum=loopNum+1
GOTO loop
)
:exit
ECHO.
ECHO All done^^!  Press any key to exit.
PAUSE>nul
