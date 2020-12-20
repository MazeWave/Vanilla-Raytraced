param([int]$verbose = 0)

New-Item -ItemType Directory -Force -Path "./.temp/" | Out-Null # We make sure that the temporary folder exists

if(!$(Test-Path -Path "./.temp/vanilla")) { # Download the default pack of Minecraft if not already done
	Invoke-WebRequest -Uri https://aka.ms/resourcepacktemplate -OutFile ./.temp/vanilla.zip
	Expand-Archive -LiteralPath ./.temp/vanilla.zip -DestinationPath ./.temp/vanilla
	Remove-Item -Path ./.temp/vanilla.zip -Force
}

Invoke-WebRequest -Uri https://gist.github.com/06Games/c47e18c3729f3bc26a0518a02ebd03f4/raw/ -OutFile ./.temp/generate.ps1 # Download the generation script
pwsh ./.temp/generate.ps1 -pack "Vanilla Raytraced" -verbose $verbose # Starts the generation of the pack
Remove-Item -Path ./.temp/generate.ps1 -Force # Delete the generation script

pause