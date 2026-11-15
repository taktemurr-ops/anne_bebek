# Run at Flutter project root, in PowerShell. Makes no source-file deletions.
$ErrorActionPreference = 'Stop'
if (-not (Test-Path 'pubspec.yaml')) { throw 'Run this script from the Flutter project root.' }
if (-not (Test-Path '.git')) { throw 'Git repository not initialized. Run git init first.' }
Write-Host '1/3: Removing generated paths from Git index (not from disk)...'
$tracked = @(git ls-files --cached | Where-Object {
  $_ -match '(^|/)(build|\.dart_tool|\.gradle|Pods|coverage|\.idea|\.pub-cache|\.pub|\.symlinks|ephemeral)/' -or
  $_ -match '(^|/)(local\.properties|key\.properties|Generated\.xcconfig|flutter_export_environment\.sh)$' -or
  $_ -match '\.(jks|keystore)$' -or
  $_ -match '^\.flutter-plugins(-dependencies)?$'
})
foreach ($file in $tracked) { git rm --cached --quiet --ignore-unmatch -- $file; if ($LASTEXITCODE -ne 0) { throw "git rm failed: $file" } }
Write-Host "Index cleanup complete: $($tracked.Count) generated/local paths."
Write-Host '2/3: Applying line-ending rules to tracked source files...'
git add --renormalize .
if ($LASTEXITCODE -ne 0) { throw 'git add --renormalize failed' }
Write-Host '3/3: Staging project source...'
git add .
if ($LASTEXITCODE -ne 0) { throw 'git add failed' }
Write-Host 'Done. Review with: git status --short'
Write-Host 'Then commit from VS Code or: git commit -m "Fix Flutter Git tracking and line endings"'
