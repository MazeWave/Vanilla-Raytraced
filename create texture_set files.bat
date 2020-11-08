@echo off

set /P vanilla="Vanilla minecraft pack (Downloadable at https://aka.ms/resourcepacktemplate): "
set path=Vanilla^ Raytraced

setlocal enabledelayedexpansion
for /d /r %vanilla%\textures %%d in (*) do (
	set B=%%d
	set folder=!B:%vanilla%\=!
		
	for /f %%f in ('dir /b %%d') do (
		echo !folder!\%%~nf
		
		set "TRUE="
		IF EXIST "%path%\!folder!\%%~nf_mer.png" set TRUE=1
		IF EXIST "%path%\!folder!\%%~nf_normal.png" set TRUE=1
		
		IF defined TRUE (	
			IF EXIST "%path%\!folder!\%%~nf.png" (
				(
					echo {
					echo   "format_version": "1.16.100",
					echo   "minecraft:texture_set": {
					echo     "color": "%%~nf",
					IF EXIST "%path%\!folder!\%%~nf_mer.png" echo     "metalness_emissive_roughness": "%%~nf_mer"
					IF EXIST "%path%\!folder!\%%~nf_mer.png" IF EXIST "%path%\!folder!\%%~nf_normal.png" echo     ,
					IF EXIST "%path%\!folder!\%%~nf_normal.png" echo     "normal": "%%~nf_normal"
					echo   }
					echo }
				) > "%path%\!folder!\%%~nf.texture_set.json"
			) else (
				echo Error: There is no color file at %path%\!folder!\%%~nf.png
				pause
			)
		)
	)
)
pause