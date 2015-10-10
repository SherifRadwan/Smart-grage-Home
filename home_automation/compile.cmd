@echo off
cls
zmac -z home_automation.asm
cd zout
copy home_automation.cim, rom.bin
cd ..
echo Done.