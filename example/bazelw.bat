@if "%DEBUG%" == "" @echo off

if "%OS%"=="Windows_NT" setlocal

@rem Globals

set "BAZELISK_DIR=tools/bazelisk"
set "SYSTEM=windows"
set "EXTENSION=.exe"

@rem Extra environmental variables

@rem this allows proper DLL loading, because the environment is not in PATH
@rem requires new Python versions
@rem see https://docs.conda.io/projects/conda/en/latest/user-guide/troubleshooting.html#mkl-library
set "CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1"

@rem Check architecture

set FOUND=0
if "%PROCESSOR_ARCHITECTURE%" == "AMD64" ( set "FOUND=1" & set "ARCH=amd64" )
if "%PROCESSOR_ARCHITEW6432%" == "AMD64" ( set "FOUND=1" & set "ARCH=amd64" )
if "%PROCESSOR_ARCHITECTURE%" == "ARM64" ( set "FOUND=1" & set "ARCH=arm64" )
if "%PROCESSOR_ARCHITEW6432%" == "ARM64" ( set "FOUND=1" & set "ARCH=arm64" )
if "%FOUND%" == 0 ( echo "Unsupported architecture %PROCESSOR_ARCHITECTURE%" & set "EXITCODE=1" & goto end )

set "BAZELISK_EXECUTABLE=%BAZELISK_DIR%/bazelisk-%SYSTEM%-%ARCH%%EXTENSION%"

@rem Check if bazelisk is present

if not exist "%BAZELISK_EXECUTABLE%" ( echo "%BAZELISK_EXECUTABLE% doesn't exist" & set "EXITCODE=2" & goto end )

@rem Execute bazelisk and pass all arguments

"%BAZELISK_DIR%/bazelisk-%SYSTEM%-%ARCH%%EXTENSION%" %*
set "EXITCODE=%ERRORLEVEL%"

:end
if "%OS%"=="Windows_NT" ( endlocal & exit /b "%EXITCODE%" )
exit /b "%EXITCODE%""
