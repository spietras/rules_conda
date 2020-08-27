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


def execute_waitable_windows(rctx, args, tmp_script="tmp.bat", **kwargs):
    rctx.file(
        tmp_script,
        content = """start /wait "" {}""".format(" ".join([str(a) for a in args]))
    )
    result = rctx.execute([rctx.path(tmp_script)], **kwargs)
    rctx.delete(tmp_script)
    return result


def windowsify(path):
    return str(path).replace("/", "\\")