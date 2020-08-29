INSTALLER_SCRIPT_EXT_MAP = {
    "Windows": ".exe",
    "MacOSX": ".sh",
    "Linux": ".sh"
}

CONDA_EXT_MAP = {
    "Windows": ".bat",
    "MacOSX": "",
    "Linux": ""
}

PYTHON_EXT_MAP = {
    "Windows": ".exe",
    "MacOSX": "",
    "Linux": ""
}

def get_os(rctx):
    os_family = rctx.os.name.lower()
    if "windows" in os_family:
        return "Windows"
    if "mac" in os_family:
        return "MacOSX"
    if "linux" in os_family or "unix" in os_family:
        return "Linux"
    fail("Unsupported OS: {}".format(os_family))


def get_arch_windows(rctx):
    arch = rctx.os.environ.get("PROCESSOR_ARCHITECTURE")
    archw = rctx.os.environ.get("PROCESSOR_ARCHITEW6432")
    if arch in ["AMD64"] or archw in ["AMD64"]:
        return "x86_64"
    if arch in ["x86"]:
        return "x86"
    fail("Unsupported architecture: {}".format(arch))


def get_arch_mac(rctx):
    arch = rctx.execute(["uname", "-m"]).stdout.strip("\n")
    if arch in ["x86_64"]:
        return "x86_64"
    fail("Unsupported architecture: {}".format(arch))


def get_arch_linux(rctx):
    arch = rctx.execute(["uname", "-m"]).stdout.strip("\n")
    if arch in ["x86_64"]:
        return "x86_64"
    if arch in ["ppc64le"]:
        return "ppc64le"
    fail("Unsupported architecture: {}".format(arch))


def get_arch(rctx):
    os = get_os(rctx)
    if os == "Windows":
        return get_arch_windows(rctx)
    if os == "MacOSX":
        return get_arch_mac(rctx)
    return get_arch_linux(rctx)


TMP_SCRIPT_TEMPLATE = """
@echo off
if "%OS%"=="Windows_NT" setlocal
{envs}
call {args}
set "EXITCODE=%ERRORLEVEL%"
if "%OS%"=="Windows_NT" ( endlocal & exit /b "%EXITCODE%" )
exit /b "%EXITCODE%""
"""


def execute_waitable_windows(rctx, args, environment={}, tmp_script="tmp.bat", **kwargs):
    rctx.file(
        tmp_script,
        content = TMP_SCRIPT_TEMPLATE.format(envs='\n'.join(["set \"{}={}\"".format(k, v) for k, v in environment.items()]),
                                             args=" ".join([str(a) for a in args]))
    )
    result = rctx.execute([rctx.path(tmp_script)], **kwargs)
    rctx.delete(tmp_script)
    return result


def windowsify(path):
    return str(path).replace("/", "\\")