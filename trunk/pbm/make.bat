cmd /c "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall"
cl filtro_windows.cpp
for /f %%f in ('dir /b in\') do filtro_windows < in\%%f > out\%%f
