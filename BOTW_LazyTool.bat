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

REM If no files are given (User probably just opened .bat)
if "!file_1!"=="" (
	ECHO You must drop files onto the .bat for this program to work!
	ECHO Press any key to exit...
	PAUSE>nul
	exit
)

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
	ECHO If you'd like to go to the download page, type "uhhok"
	ECHO Otherwise, either press enter to continue to Yaz0Enc, or just exit.
	ECHO.
	SET /P input=
	IF "!input!"=="" (
		REM Just continue to Yaz0Enc
		GOTO justYaz0it
	)
	IF "!input!"=="uhhok" (
		START "" https://github.com/CEObrainz/Botw-AutoMipping
		exit
	)
) ELSE (
	REM Waits for user to initialize the Auto-Mips script.
	ECHO Press enter to initialize Auto-Mips, or type "skip" to go to Yaz0Enc
	SET /P input=
	IF "!input!"=="" (
		REM Just continue to Auto-Mips
		GOTO autoMips
	)
	IF "!input!"=="skip" (
		GOTO justYaz0it
	)
)
PAUSE>nul
ECHO.
:autoMips
REM Executes the specified script + bfres in the current directory.
"%~dp0\BOTW-AutoMips.py" "%bfresPath%"
ECHO.
ECHO.
ECHO Press any key to run Yaz0Enc
PAUSE>nul
:justYaz0it
REM If there's already a file named .sbfres, check for more old copies
IF EXIST "%~dp0%bfresName%.sbfres" (
	IF NOT EXIST "%~dp0%bfresName%.sbfres.old" (
		GOTO oneOldSbfresAuto
	)
	SET /A renLoopNum=1
	REM Loops through to search for old ones
	:checkOldSbfresAuto
	IF EXIST "%~dp0%bfresName%.sbfres.old%renLoopNum%" (
		SET /A renLoopNum=renLoopNum+1
		GOTO checkOldSbfresAuto
	)
	REM Renames starting from highest to lowest
	:renLoopSbfresAuto
	IF NOT "%renLoopNum%"=="1"	(
		SET /A renLoopNew=renLoopNum-1
		REN "%bfresName%.sbfres.old%renLoopNew%" "%bfresName%.sbfres.old%renLoopNum%"
		SET /A renLoopNum=renLoopNum-1
		GOTO renLoopSbfresAuto
	)
	:oneOldSbfresAuto
	REM Finally, rename old file to .old
	REN "%bfresName%.sbfres" "%bfresName%.sbfres.old"
)
REM Runs file through the program
"%~dp0yaz0enc.exe" "%bfresPath%"
REM Renames to final format
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
	REM For sbfres files
	IF "!file_%loopNum%:~-6%!"=="sbfres" (
		REM If there's already a file named .bfres, check for more old copies
		IF EXIST "%~dp0%fileName%.bfres" (
			IF NOT EXIST "%~dp0%fileName%.bfres.old" (
				GOTO oneOldBfres
			)
			SET /A renLoopNum=1
			REM Loops through to search for old ones
			:checkOldBfres
			IF EXIST "%~dp0%fileName%.bfres.old%renLoopNum%" (
				SET /A renLoopNum=renLoopNum+1
				GOTO checkOldBfres
			)
			REM Renames starting from highest to lowest
			:renLoopBfres
			IF NOT "%renLoopNum%"=="1"	(
				SET /A renLoopNew=renLoopNum-1
				REN "%fileName%.bfres.old%renLoopNew%" "%fileName%.bfres.old%renLoopNum%"
				SET /A renLoopNum=renLoopNum-1
				GOTO renLoopBfres
			)
			:oneOldBfres
			REM Finally, rename old file to .old
			REN "%fileName%.bfres" "%fileName%.bfres.old"
		)
		REM Runs file through the program
		"%~dp0yaz0dec.exe" "!file_%loopNum%!"
		REM Renames to final format
		REN "%fileName%.sbfres 0.rarc" "%fileName%.bfres"
		GOTO exit
	)
	REM For sbitemico files
	IF "!file_%loopNum%:~-9%!"=="sbitemico" (
		REM If there's already a file named .sbitemico, check for more old copies
		IF EXIST "%~dp0%fileName%.sbitemico.bfres" (
			IF NOT EXIST "%~dp0%fileName%.sbitemico.bfres.old" (
				GOTO oneOldSbitemicoBfres
			)
			SET /A renLoopNum=1
			REM Loops through to search for old ones
			:checkOldSbitemicoBfres
			IF EXIST "%~dp0%fileName%.sbitemico.bfres.old%renLoopNum%" (
				SET /A renLoopNum=renLoopNum+1
				GOTO checkOldSbitemicoBfres
			)
			REM Renames starting from highest to lowest
			:renLoopSbitemicoBfres
			IF NOT "%renLoopNum%"=="1"	(
				SET /A renLoopNew=renLoopNum-1
				REN "%fileName%.sbitemico.bfres.old%renLoopNew%" "%fileName%.sbitemico.bfres.old%renLoopNum%"
				SET /A renLoopNum=renLoopNum-1
				GOTO renLoopSbitemicoBfres
			)
			:oneOldSbitemicoBfres
			REM Finally, rename old file to .old
			REN "%fileName%.sbitemico.bfres" "%fileName%.sbitemico.bfres.old"
		)
		REM Runs file through the program
		"%~dp0yaz0dec.exe" "!file_%loopNum%!"
		REM Renames to final format
		REN "%fileName%.sbitemico 0.rarc" "%fileName%.sbitemico.bfres"
		GOTO exit
	)
REM If first for bytes are FRES, delete old file, run Yaz0Enc, and rename
) ELSE IF "%encTest:~0,4%"=="FRES" (
	REM For bfres files
	IF NOT "!file_%loopNum%:~-15%!"=="sbitemico.bfres" (
		REM If there's already a file named .sbfres, check for more old copies
		IF EXIST "%~dp0%fileName%.sbfres" (
			IF NOT EXIST "%~dp0%fileName%.sbfres.old" (
				GOTO oneOldSbfres
			)
			SET /A renLoopNum=1
			REM Loops through to search for old ones
			:checkOldSbfres
			IF EXIST "%~dp0%fileName%.sbfres.old%renLoopNum%" (
				SET /A renLoopNum=renLoopNum+1
				GOTO checkOldSbfres
			)
			REM Renames starting from highest to lowest
			:renLoopSbfres
			IF NOT "%renLoopNum%"=="1"	(
				SET /A renLoopNew=renLoopNum-1
				REN "%fileName%.sbfres.old%renLoopNew%" "%fileName%.sbfres.old%renLoopNum%"
				SET /A renLoopNum=renLoopNum-1
				GOTO renLoopSbfres
			)
			:oneOldSbfres
			REM Finally, rename old file to .old
			REN "%fileName%.sbfres" "%fileName%.sbfres.old"
		)
		REM Runs file through the program
		"%~dp0yaz0enc.exe" "!file_%loopNum%!"
		REM Renames to final format
		REN "%fileName%.bfres.yaz0" "%fileName%.sbfres"
		GOTO exit
	)
	REM For sbitemico.bfres files
	IF "!file_%loopNum%:~-15%!"=="sbitemico.bfres" (
		REM If there's already a file named .sbitemico, check for more old copies
		IF EXIST "%~dp0%fileName%" (
			IF NOT EXIST "%~dp0%fileName%.old" (
				GOTO oneOldSbitemico
			)
			SET /A renLoopNum=1
			REM Loops through to search for old ones
			:checkOldSbitemico
			IF EXIST "%~dp0%fileName%.old%renLoopNum%" (
				SET /A renLoopNum=renLoopNum+1
				GOTO checkOldSbitemico
			)
			REM Renames starting from highest to lowest
			:renLoopSbitemico
			IF NOT "%renLoopNum%"=="1"	(
				SET /A renLoopNew=renLoopNum-1
				REN "%fileName%.old%renLoopNew%" "%fileName%.old%renLoopNum%"
				SET /A renLoopNum=renLoopNum-1
				GOTO renLoopSbitemico
			)
			:oneOldSbitemico
			REM Finally, rename old file to .old
			REN "%fileName%" "%fileName%.old"
		)
		REM Runs file through the program
		"%~dp0yaz0enc.exe" "!file_%loopNum%!"
		REM Renames to final format
		REN "%fileName%.bfres.yaz0" "%fileName%"
		GOTO exit
	)
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
