#Init
param (
	[string]$pack = "./Vanilla Raytraced",
	[string]$temp = "./.temp",
	[string]$vanilla = $($temp + "/vanilla")
)
$host.ui.rawui.windowtitle="Generate"
$packAbs = (Get-Item $($temp + "/pack")).FullName;
$vanillaAbs = (Get-Item $vanilla).FullName;

#---------------------#
#     Temp folder     #
#---------------------#
Write-Host "`nCreating temp folder" -NoNewline
if(Test-Path -Path $($temp + "/pack")) { Remove-Item -Path $($temp + "/pack") -Recurse -Force }
Copy-Item -Path $pack -Destination $($temp + "/pack") -Recurse -Force
Write-Host " (Done)" -ForegroundColor Green

#---------------------#
#  Duplicated  Files  #
#---------------------#
Write-Host  "`nFinding duplicate files"
$duplicated = 0;
foreach ($vanillaF in $(Get-ChildItem $vanilla -Recurse -File -Force)) {
	$packFpath = $vanillaF.FullName.Replace($vanillaAbs, $packAbs);
	Write-Host "`t" $vanillaF.FullName.Replace($vanillaAbs, "") -NoNewline;
	if(Test-Path -Path $packFpath){
		$packF = Get-Item $packFpath
		if($(Get-FileHash $vanillaF).Hash -eq $(Get-FileHash $packF).Hash){
			Remove-Item -Path $packFpath -Force
			$duplicated += 1
			Write-Host " (Duplicated)" -ForegroundColor Red
		}
		else { Write-Host " (Not duplicated)" -ForegroundColor Green }
	}
	else { Write-Host " (Missing)" -ForegroundColor Yellow }
}
Write-Host $("Removed " + $duplicated.ToString() + " files") -ForegroundColor Green

#---------------------#
#     Texture Set     #
#---------------------#
Write-Host  "`nList textures" -NoNewline
$files = Get-ChildItem $vanilla\textures -Include *.png,*.tga,*.jpg,*.jpeg -Recurse -File -Force
Write-Host $(" (" + $files.Length + " files found)")
Write-Host  "`nGenerating texture set files"
foreach ($file in $files) {
	$tempRelative = $file.FullName.Replace($vanillaAbs, "").Replace($file.Extension, "")
	Write-Host "`t" $tempRelative -NoNewline;
	$tempRelative = $temp + "/pack" + $tempRelative
	
	if ((Test-Path -Path $($tempRelative + "_mer.png")) -or (Test-Path -Path $($tempRelative + "_normal.png"))) {
		$texture_set = "{`n`t""format_version"": ""1.16.100""`n`t""minecraft:texture_set"": {"
		if (Test-Path -Path $($tempRelative + ".png")) { $texture_set += "`n`t`t""color"": """ + $file.Basename + """," }
		if (Test-Path -Path $($tempRelative+ "_mer.png")) { $texture_set += "`n`t`t""metalness_emissive_roughness"": """ + $file.Basename + "_mer""" }
		if ((Test-Path -Path $($tempRelative + "_mer.png")) -and (Test-Path -Path $($tempRelative + "_normal.png"))) { $texture_set += "," }
		if (Test-Path -Path $($tempRelative+ "_normal.png")) { $texture_set += "`n`t`t""normal"": """ + $file.Basename + "_normal""" }
		$texture_set += "`n`t}`n}"
		Set-Content -Path $($tempRelative + ".texture_set.json") -Value $texture_set
			
		Write-Host " (Done)" -ForegroundColor Green
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
