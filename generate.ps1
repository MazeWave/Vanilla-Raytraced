param (
	[string]$vanilla = $( Read-Host "Vanilla minecraft pack (Downloadable at https://aka.ms/resourcepacktemplate)" ),
	[string]$path = "./Vanilla Raytraced"
)
$host.ui.rawui.windowtitle="Generate"

$files = Get-ChildItem $vanilla\textures -Include *.png,*.tga,*.jpg,*.jpeg -Recurse -File
foreach ($file in $files) {
	$withoutExt = $file.FullName.Replace($vanilla, $path).Replace($file.Extension, "")
	$pathRelative = $path + $withoutExt
	
	if ((Test-Path -Path $($pathRelative + "_mer.png")) -or (Test-Path -Path $($pathRelative + "_normal.png"))) {
		if (Test-Path -Path $($pathRelative + ".png")) {
			$texture_set = "{`n`t""format_version"": ""1.16.100""`n`t""minecraft:texture_set"": {"
			$texture_set += "`n`t`t""color"": """ + $file.Basename + ""","
			if (Test-Path -Path $($pathRelative+ "_mer.png")) { $texture_set += "`n`t`t""metalness_emissive_roughness"": """ + $file.Basename + "_mer""" }
			if ((Test-Path -Path $($pathRelative + "_mer.png")) -and (Test-Path -Path $($pathRelative + "_normal.png"))) { $texture_set += "," }
			if (Test-Path -Path $($pathRelative+ "_normal.png")) { $texture_set += "`n`t`t""normal"": """ + $file.Basename + "_normal""" }
			$texture_set += "`n`t}`n}"
			Set-Content -Path $($pathRelative + ".texture_set.json") -Value $texture_set
			
			Write-Host $pathRelative -NoNewline;
			Write-Host " (Done)" -ForegroundColor Green;
		} else { 
			Write-Host $pathRelative -NoNewline;
			Write-Host " (Ignored): No color file" -ForegroundColor Red;
		}
	} else { 
		Write-Host $pathRelative -NoNewline;
		Write-Host " (Ignored): No mer or normal file" -ForegroundColor Yellow;
	}
}