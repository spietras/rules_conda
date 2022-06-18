@echo off

setlocal ENABLEDELAYEDEXPANSION

@rem Globals

set "CACHE_DIR=!LOCALAPPDATA!\bazelisk"
set "BIN_DIR=!CACHE_DIR!\bin"
set "BAZELISK_PATH=!BIN_DIR!\bazelisk.exe"
set "TMP_ERROR_FILE=!TEMP!\bazelw_error.tmp"

@rem this allows proper DLL loading, because the environment is not in PATH
@rem requires new Python versions
@rem see https://docs.conda.io/projects/conda/en/latest/user-guide/troubleshooting.html#mkl-library
set "CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1"

@rem Utils

goto after

:log
    echo %~1
goto :eof

:logError
    call :log "Error: %~1"
goto :eof

:after

@rem Setup

if not exist "!BAZELISK_PATH!" ( set setup=1 )
if not "!BAZELW_UPDATE!" == "" ( set setup=1 )

if defined setup (
    if not exist "!BIN_DIR!" (
        md "!BIN_DIR!" >NUL 2>&1
        if not !ERRORLEVEL! == 0  (
            call :logError "Can't create !BIN_DIR!"
            set "EXITCODE=1"
            goto end
        )
    )

    set "ARCH=!PROCESSOR_ARCHITECTURE!"
    if "!PROCESSOR_ARCHITECTURE!" == "AMD64" ( set "ARCH=amd64" )
    if "!PROCESSOR_ARCHITEW6432!" == "AMD64" ( set "ARCH=amd64" )
    if "!PROCESSOR_ARCHITECTURE!" == "ARM64" ( set "ARCH=arm64" )
    if "!PROCESSOR_ARCHITEW6432!" == "ARM64" ( set "ARCH=arm64" )

    set "BASE_URL=https://github.com/bazelbuild/bazelisk/releases/latest/download"
    set "FILENAME=bazelisk-windows-!ARCH!.exe"
    set "BAZELISK_URL=!BASE_URL!/!FILENAME!"

    curl -o "!BAZELISK_PATH!" -fsSL "!BAZELISK_URL!" >"!TMP_ERROR_FILE!" 2>&1

    if not !ERRORLEVEL! == 0  (
        for /F "delims=" %%A in (!TMP_ERROR_FILE!) do (
            call :logError "Can't download !BAZELISK_URL! to !BAZELISK_PATH!. %%A"
        )
        set "EXITCODE=2"
        goto end
    )
)

@rem Execute

call "!BAZELISK_PATH!" %*
set "EXITCODE=!ERRORLEVEL!"

:end
endlocal & exit /b %EXITCODE%
