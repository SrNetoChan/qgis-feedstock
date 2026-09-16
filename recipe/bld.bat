echo on
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

set BUILDCONF=Release

:: qmake's own qt.conf/mkspecs resolution isn't finding win32-msvc when
:: invoked by sip-build (error: "Could not find qmake spec 'win32-msvc'"),
:: even though qt6-main's installed qt6.conf (HostData) correctly points at
:: a prefix-relocated Library\lib\qt6 containing mkspecs\win32-msvc. Setting
:: QT_CONF_PATH alone did not fix this in a previous attempt, so also set
:: QMAKESPEC directly to the mkspec directory, which bypasses qt.conf
:: resolution entirely. https://doc.qt.io/qt-6/qmake-environment-reference.html
set "QT_CONF_PATH=%PREFIX%\qt6.conf"
set "QMAKESPEC=%PREFIX%\Library\lib\qt6\mkspecs\win32-msvc"

echo QT_CONF_PATH=%QT_CONF_PATH%
if exist "%QT_CONF_PATH%" (type "%QT_CONF_PATH%") else (echo QT_CONF_PATH file NOT FOUND)
echo QMAKESPEC=%QMAKESPEC%
if exist "%QMAKESPEC%" (echo QMAKESPEC dir exists) else (echo QMAKESPEC dir NOT FOUND)

:: Workaround for this lib being required but not set in cmake
:: (Seems maybe it used to be?)
set _LINK_=Ws2_32.lib

cmake -G Ninja ^
    -D CMAKE_BUILD_TYPE=%BUILDCONF% ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -D PYTHON_EXECUTABLE=%PYTHON% ^
    -D PYTHON3_EXECUTABLE=%PYTHON% ^
    -D Python3_EXECUTABLE=%PYTHON% ^
    -D Python_EXECUTABLE=%PYTHON% ^
    -D PYUIC_PROGRAM=%PREFIX%\pyuic6.bat ^
    -D PYRCC_PROGRAM=%PREFIX%\pyrcc6.bat ^
    -D WITH_GUI=TRUE ^
    -D ENABLE_TESTS=FALSE ^
    -D WITH_BINDINGS=TRUE ^
    -D WITH_3D=TRUE ^
    -D WITH_DESKTOP=TRUE ^
    -D WITH_SERVER=FALSE ^
    -D WITH_CUSTOM_WIDGETS=TRUE ^
    -D WITH_GRASS=FALSE ^
    -D WITH_STAGED_PLUGINS=TRUE ^
    -D WITH_QSPATIALITE=FALSE ^
    -D EXPAT_INCLUDE_DIR=%LIBRARY_INC% ^
    -D EXPAT_LIBRARY=%LIBRARY_LIB%\expat.lib ^
    -D WITH_QTWEBENGINE=TRUE ^
    -D QGIS_INSTALL_SYS_LIBS=FALSE ^
    -D WITH_PDAL=TRUE ^
    -D WITH_EPT=TRUE ^
    -D LazPerf_INCLUDE_DIR=%LIBRARY_INC% ^
    ..
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1

:: Copy activate/deactivate scripts
set "ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d"
set "DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d"
mkdir %ACTIVATE_DIR%
mkdir %DEACTIVATE_DIR%

:: For batch
copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\qgis-activate.bat
if errorlevel 1 exit 1
copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\qgis-deactivate.bat
if errorlevel 1 exit 1

:: For Cygwin
copy %RECIPE_DIR%\scripts\activate.sh %ACTIVATE_DIR%\qgis-activate.sh
if errorlevel 1 exit 1
copy %RECIPE_DIR%\scripts\deactivate.sh %DEACTIVATE_DIR%\qgis-deactivate.sh
if errorlevel 1 exit 1
