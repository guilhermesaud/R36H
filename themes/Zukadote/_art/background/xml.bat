@echo off
for %%F in (*.xml) do powershell -Command "(Get-Content %%F) -replace '<path>\./\.\./_art/wallpapers/.*?\.png</path>', '<path>./../_art/wallpapers/%%~nF.png</path>' | Set-Content %%F"
echo Alterações concluídas!
pause
