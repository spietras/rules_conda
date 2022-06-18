@echo off

setlocal ENABLEDELAYEDEXPANSION

set "ROOT_DIR=%~dp0.\.."
set "TESTS_DIR=!ROOT_DIR!\tests"

cd "!TESTS_DIR!"
if not !ERRORLEVEL! == 0  (
    echo "Error: can't cd into !TESTS_DIR!"
    set "EXITCODE=1"
    goto end
)

set /a tests=0
set /a passed=0
set /a failed=0

for /D %%G in ("!TESTS_DIR!\*") do (
    cd "%%G"

    if !ERRORLEVEL! == 0 (
        echo.
        echo Testing %%~nxG...
        echo.

        call ..\..\scripts\bazelw test --test_output=all --test_arg=--verbose --test_arg=-rA ...
        if !ERRORLEVEL! == 0 (
            set /a passed+=1
        ) else (
            set /a failed+=1
        )
        set /a tests+=1

        cd ..
    )
)

set "EXITCODE=0"
if not !failed! == 0 ( set "EXITCODE=2" )

echo.
echo **********************************************
echo.
echo Tests completed. All: !tests!, Passed: !passed!, Failed: !failed!
echo.
echo **********************************************
echo.

:end
endlocal & exit /b %EXITCODE%
