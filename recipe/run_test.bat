@echo on

:: Check for QGIS executable
if not exist "%LIBRARY_PREFIX%\bin\qgis-bin.exe" exit /b 1

:: Check Python API
set PYTHONPATH=%LIBRARY_PREFIX%\python;%PYTHONPATH%

%PYTHON% -c "import qgis.core"
if errorlevel 1 exit /b 1
%PYTHON% -c "import qgis.gui"
if errorlevel 1 exit /b 1
%PYTHON% -c "import qgis.utils"
if errorlevel 1 exit /b 1
