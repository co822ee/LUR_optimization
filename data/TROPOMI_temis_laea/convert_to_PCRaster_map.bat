@echo off
for %%i in (*.grd) do gdal_translate -ot Float32 -of PCRaster -mo PCRASTER_VALUESCALE=VS_SCALAR %%i %%i.map

REM get-childitem *.map | foreach {rename-item $_ $_.name.replace(".grd","")}
REM get-childitem *.xml | foreach {rename-item $_ $_.name.replace(".grd","")}
powershell.exe -EncodedCommand ZwBlAHQALQBjAGgAaQBsAGQAaQB0AGUAbQAgACoALgBtAGEAcAAgAHwAIABmAG8AcgBlAGEAYwBoACAAewByAGUAbgBhAG0AZQAtAGkAdABlAG0AIAAkAF8AIAAkAF8ALgBuAGEAbQBlAC4AcgBlAHAAbABhAGMAZQAoACIALgBnAHIAZAAiACwAIgAiACkAfQAKAGcAZQB0AC0AYwBoAGkAbABkAGkAdABlAG0AIAAqAC4AeABtAGwAIAB8ACAAZgBvAHIAZQBhAGMAaAAgAHsAcgBlAG4AYQBtAGUALQBpAHQAZQBtACAAJABfACAAJABfAC4AbgBhAG0AZQAuAHIAZQBwAGwAYQBjAGUAKAAiAC4AZwByAGQAIgAsACIAIgApAH0A 
pause

