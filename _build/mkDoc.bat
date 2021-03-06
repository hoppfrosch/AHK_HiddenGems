@echo off
echo.
echo Creating documentation....
echo.

SET WORK=MKDOC_TEMP
mkdir %WORK%
COPY ..\HiddenGems.txt %WORK%
REM ----- LIBS -----------
mkdir %WORK%\lib
copy ..\lib\HiddenGems.ahk %WORK%\lib
mkdir %WORK%\lib\HiddenGems
copy ..\lib\HiddenGems\glob.ahk %WORK%\lib\HiddenGems
copy ..\lib\HiddenGems\GUID.ahk %WORK%\lib\HiddenGems
mkdir %WORK%\lib\HiddenGems\System
copy ..\lib\HiddenGems\System\GetBinaryType.ahk %WORK%\lib\HiddenGems\System
REM ----- SCRIPTS --------
MKDIR %WORK%\scripts
copy ..\scripts\WallpaperChanger\InterfaceLiftWallpaperChanger.ahk %WORK%\scripts
REM ----- CONCEPTS -------
mkdir %WORK%\concepts
copy ..\concepts\ThrowWindow\ThrowWindow.ahk %WORK%\concepts
copy ..\concepts\EasyGlide\EasyGlide.ahk %WORK%\concepts
copy ..\concepts\ShapedWindow\Window_DonutShaped.ahk %WORK%\concepts
copy ..\concepts\CutOut\CutOut_Static.ahk %WORK%\concepts


::path to the natural doc folder
SET NDPATH=d:\Usr\programme\NaturalDocs\

pushd %WORK%

::project root path
SET ROOT=%CD%

::documentation folder
SET DOC=_doc

mkdir "%ROOT%\%DOC%\_ndProj" 2>nul
pushd "%NDPATH%"
if exist "%ROOT%\images" SET IMG=-img "%ROOT%\images"

call NaturalDocs.exe -i "%ROOT%" -o HTML "%ROOT%\%DOC%" -p "%ROOT%\%DOC%\_ndProj" %IMG%

popd

if "%1" == "s" (
echo Merging html files ...
mkdocs
rmdir /Q /S _doc
echo Done.
echo.
)

popd

ECHO Publish documentation to gh-page branch ...
pushd ..\..\AHK_HiddenGems_gh_pages
rmdir /S /Q styles
rmdir /S /Q search
rmdir /S /Q other
rmdir /S /Q menu
rmdir /S /Q files
rmdir /S /Q _ndProj
DEL index.html
xcopy /E /Y %ROOT%\%DOC% .
popd
rmdir /S /Q %WORK%
