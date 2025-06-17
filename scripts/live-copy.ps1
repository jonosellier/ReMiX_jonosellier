param (
	[Parameter(Mandatory = $true)]
	[string]$inputDir,
	[Parameter(Mandatory = $true)]
	[string]$outputDir
)

if (!(Test-Path $inputDir)) {
	Write-Error "Input directory '$inputDir' does not exist."
	exit 1
}

if (!(Test-Path $outputDir)) {
	New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$fsw = New-Object System.IO.FileSystemWatcher $inputDir -Property @{
	IncludeSubdirectories = $true
	EnableRaisingEvents   = $true
}

$action = {
	Write-Host "Change detected. Copying files..."
	robocopy $using:inputDir $using:outputDir /MIR /Z /NP /R:1 /W:1 | Out-Null
	Write-Host "Copy complete."
}

$handlers = @()
$handlers += Register-ObjectEvent $fsw Changed -Action $action
$handlers += Register-ObjectEvent $fsw Created -Action $action
$handlers += Register-ObjectEvent $fsw Deleted -Action $action
$handlers += Register-ObjectEvent $fsw Renamed -Action $action

Write-Host "Watching '$inputDir' for changes. Press Ctrl+C to exit."
while ($true) { Start-Sleep -Seconds 1 }

# Cleanup on exit (optional)
# $handlers | ForEach-Object { Unregister-Event -SourceIdentifier $_.Name }
# $fsw.Dispose()

