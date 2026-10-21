@echo off
chcp 65001 > nul
rem Windows를 켤 때 둘 AI 서버가 창 없이 자동으로 켜지게 등록하고, 지금 바로 켬
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Startup') + '\dul-ai-server.lnk'); $s.TargetPath = 'wscript.exe'; $q = [char]34; $s.Arguments = $q + (Resolve-Path 'start_ai_hidden.vbs').Path + $q; $s.WorkingDirectory = (Get-Location).Path; $s.Save()"
wscript.exe "%~dp0start_ai_hidden.vbs"
echo 등록했어요. 이제 컴퓨터를 켜면 AI 서버가 자동으로 켜져요.
echo 10초쯤 뒤 브라우저에서 http://localhost:8000 을 여세요. 끄려면 autostart_off.bat
pause
