@echo off
cls
zmac -z car_parking.asm
cd zout
copy car_parking.cim, rom.bin
cd ..
echo Done.