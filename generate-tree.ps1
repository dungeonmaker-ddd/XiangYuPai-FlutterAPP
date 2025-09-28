# PowerShell script: Generate src and assets directory tree structure
# Usage: .\generate-tree.ps1

# Generate directory tree for src and assets folders without files in the deepest level folders
# First generate src tree
tree lib /A | findstr /v /r /c:"^|   |   |   |   " > temp_src_tree.txt

# Then generate assets tree
tree assets /A | findstr /v /r /c:"^|   |   |   |   " > temp_assets_tree.txt

# Combine both trees
Get-Content temp_src_tree.txt, temp_assets_tree.txt | Out-File temp_tree.txt

# Read the generated file content
$content = Get-Content temp_tree.txt

# Add header information before content
$header = @"
---
alwaysApply: true
---
"@

# Combine header and content
$finalContent = $header + "`r`n" + ($content -join "`r`n")

# Write final file to .cursor/rules/ directory
$finalContent | Out-File -FilePath ".cursor/rules/project.mdc" -Encoding UTF8

# Clean up temporary files
Remove-Item temp_tree.txt, temp_src_tree.txt, temp_assets_tree.txt

Write-Host "Directory tree has been generated to .cursor/rules/project.mdc file" -ForegroundColor Green
Write-Host "Including both src and assets directories without files in deepest level folders" -ForegroundColor Yellow
