﻿$version = '6.1.0'

$toolsDir       = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$progDir        = "$toolsDir\octave"

$osBitness      = Get-OSArchitectureWidth

$packageArgs = @{
    PackageName     = 'octave.portable'
    UnzipLocation   = $toolsDir
    Url             = 'https://ftp.gnu.org/gnu/octave/windows/octave-6.1.0-w32.7z'
    Url64           = 'https://ftp.gnu.org/gnu/octave/windows/octave-6.1.0-w64.7z'
    Checksum        = 'c8d94ac9049ffb1605ed4ff3058b4d23a9430705c8f59791013e63fc78b018bf'
    Checksum64      = '174c5d56b6845ab0e69a860eaed3f9502569bf4686e05fcce1550e97774a769a'
    ChecksumType    = 'sha256'
    ChecksumType64  = 'sha256'
}
Install-ChocolateyZipPackage @packageArgs

# Rename unzipped folder
If (Test-Path "$toolsDir\octave-$version-w$osBitness") {
    Rename-Item -Path "$toolsDir\octave-$version-w$osBitness" -NewName "octave"
}
If (Test-Path "$toolsDir\octave-$version") {
    Rename-Item -Path "$toolsDir\octave-$version" -NewName "octave"
}

# Don't create shims for any executables
$files = Get-ChildItem "$toolsDir" -include *.exe -exclude "octave-cli.exe" -recurse
foreach ($file in $files) {
    New-Item "$file.ignore" -type file -force | Out-Null
}
# Link batch
Install-BinFile -Name "octave" -Path "$progDir\bin\octave-cli.exe"

# Create desktop shortcut
$desktop = $([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory))
$link = Join-Path $desktop "Octave.lnk"
if (!(Test-Path $link)) {
    Install-ChocolateyShortcut -ShortcutFilePath "$link" -TargetPath "$progDir\octave.vbs" -WorkingDirectory "$progDir" -Arguments '--force-gui' -IconLocation "$progDir\share\octave\$version\imagelib\octave-logo.ico"
}
