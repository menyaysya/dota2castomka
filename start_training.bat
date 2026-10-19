@echo off
rem Carry Lane Academy: launch Dota 2 (tools mode) straight into the trainer on the standard map.
set "DOTA=C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta"
start "" "%DOTA%\game\bin\win64\dota2.exe" -tools -addon carry_lane_academy -novid -console +dota_launch_custom_game carry_lane_academy dota
