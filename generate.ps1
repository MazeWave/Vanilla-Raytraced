#Init
param (
	[string]$vanilla = $( Read-Host "Vanilla minecraft pack (Downloadable at https://aka.ms/resourcepacktemplate)" ),
	[string]$pack = "./Vanilla Raytraced",
	[string]$temp = "./.temp"
)
$host.ui.rawui.windowtitle="Generate"

#---------------------#
#     Temp folder     #
#---------------------#
Write-Host "`nCreating temp folder" -NoNewline
Copy-Item -Path $pack -Destination $($temp + "/pack") -Recurse -Force
Write-Host " (Done)" -ForegroundColor Green

#---------------------#
#     List of tex     #
#---------------------#
Write-Host  "`nList textures" -NoNewline
$files = Get-ChildItem $vanilla\textures -Include *.png,*.tga,*.jpg,*.jpeg -Recurse -File
Write-Host $(" (" + $files.Length + " files found)")

#---------------------#
#     Texture Set     #
#---------------------#
Write-Host  "`nGenerating texture set files"
foreach ($file in $files) {
	$tempRelative = $file.FullName.Replace((Get-Item $vanilla).FullName, $temp + "/pack").Replace($file.Extension, "")
	Write-Host "`t" $tempRelative -NoNewline;
	
	if ((Test-Path -Path $($tempRelative + "_mer.png")) -or (Test-Path -Path $($tempRelative + "_normal.png"))) {
		if (Test-Path -Path $($tempRelative + ".png")) {
			$texture_set = "{`n`t""format_version"": ""1.16.100""`n`t""minecraft:texture_set"": {"
			$texture_set += "`n`t`t""color"": """ + $file.Basename + ""","
			if (Test-Path -Path $($tempRelative+ "_mer.png")) { $texture_set += "`n`t`t""metalness_emissive_roughness"": """ + $file.Basename + "_mer""" }
			if ((Test-Path -Path $($tempRelative + "_mer.png")) -and (Test-Path -Path $($tempRelative + "_normal.png"))) { $texture_set += "," }
			if (Test-Path -Path $($tempRelative+ "_normal.png")) { $texture_set += "`n`t`t""normal"": """ + $file.Basename + "_normal""" }
			$texture_set += "`n`t}`n}"
			Set-Content -Path $($tempRelative + ".texture_set.json") -Value $texture_set
			
			Write-Host " (Done)" -ForegroundColor Green
		} else { Write-Host " (Ignored): No color file" -ForegroundColor Red }
	} else { Write-Host " (Ignored): No mer or normal file" -ForegroundColor Yellow }
}

#---------------------#
#       .Mcpack       #
#---------------------#
Write-Host  "`nGenerating the .mcpack" -NoNewline
New-Item -Path $($temp + "/export") -ItemType Directory -Force | Out-Null
Compress-Archive -Path $($temp + "/pack/*") -DestinationPath $($temp + "/export/Vanilla Raytraced.zip") -Force
Move-Item -Path $($temp + "/export/Vanilla Raytraced.zip") -Destination $($temp + "/export/Vanilla Raytraced.mcpack") -Force
Write-Host " (Done)" -ForegroundColor Green

#Done
$host.ui.rawui.windowtitle="Generate (Done)"
