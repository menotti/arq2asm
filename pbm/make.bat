cl filtro_windows.c

for /f %%f in ('dir /b in\') do filtro_windows < in\%%f > out\%%f
