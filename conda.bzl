load(":utils.bzl", "CONDA_EXT_MAP", "EXECUTE_TIMEOUT", "INSTALLER_SCRIPT_EXT_MAP", "execute_waitable_windows", "get_arch", "get_os", "windowsify")

# CONDA CONFIGURATION
CONDA_MAJOR = "3"
CONDA_MINOR = "py39_4.10.3"
CONDA_SHA = {
    "Windows": {
        "x86_64": "b33797064593ab2229a0135dc69001bea05cb56a20c2f243b1231213642e260a",
        "x86": "24f438e57ff2ef1ce1e93050d4e9d13f5050955f759f448d84a4018d3cd12d6b",
    },
    "MacOSX": {
        "x86_64": "786de9721f43e2c7d2803144c635f5f6e4823483536dc141ccd82dbb927cd508",
    },
    "Linux": {
        "x86_64": "1ea2f885b4dbc3098662845560bc64271eb17085387a70c2ba3f29fff6f8d52f",
        "aarch64": "4879820a10718743f945d88ef142c3a4b30dfc8e448d1ca08e019586374b773f",
        "ppc64le": "362705630a9e85faf29c471faa8b0a48eabfe2bf87c52e4c180825f9215d313c",
        "s390x": "1faed9abecf4a4ddd4e0d8891fc2cdaa3394c51e877af14ad6b9d4aadb4e90d8",
    },
}
CONDA_INSTALLER_NAME_TEMPLATE = "Miniconda{major}-{minor}-{os}-{arch}{ext}"
CONDA_BASE_URL = "https://repo.anaconda.com/miniconda/"
CONDA_INSTALLER_FLAGS = {
    "Windows": ["/InstallationType=JustMe", "/AddToPath=0", "/RegisterPython=0", "/S", "/D={}"],
    "MacOSX": ["-b", "-f", "-p", "{}"],
    "Linux": ["-b", "-f", "-p", "{}"],
}

MINIFORGE_MAJOR = "3"
MINIFORGE_MINOR = "4.10.3-7"
MINIFORGE_SHA = {
    "Windows": {
        "x86_64": "e3b1e7c5a02315c90bbb20d27614e00183ba8247594c57fb1f0484ccf5f9471c",
    },
    "MacOSX": {
        "x86_64": "a25c1b381b20873ed856ce675a7a2ccf48f1d6782a5cdce9f06496e6ffa7883f",
        "arm64": "3cd1f11743f936ba522709eb7a173930c299ac681671a909b664222329a56290",
    },
    "Linux": {
        "x86_64": "4de9b7dcc9b2761136f4a7a42a8b2ea06ae2ebc61d865c9fca0db3d6c90b569d",
        "aarch64": "d597961defe8c7889f3e924d0dc7624fab2c8845abccdd8ffa8da8018ff3dc6e",
        "ppc64le": "8825827240c0d06413876055bf3a04d8704f0e5ac773692a352502862dce7aa5",
    },
}

# TODO(jiawen): It's trivial to replace "Miniforge" with "Mambaforge".
MINIFORGE_INSTALLER_NAME_TEMPLATE = "{minor}/Miniforge{major}-{minor}-{os}-{arch}{ext}"
MINIFORGE_BASE_URL = "https://github.com/conda-forge/miniforge/releases/download/"
MINIFORGE_INSTALLER_FLAGS = CONDA_INSTALLER_FLAGS

INSTALLER_DIR = "installer"

CONDA_BUILD_FILE_TEMPLATE = """# This file was automatically generated by rules_conda

exports_files(['{conda}'])
"""

def _get_installer_flags(rctx, dir):
    os = get_os(rctx)
    flags = CONDA_INSTALLER_FLAGS[os]

    # insert directory
    dir = rctx.path(dir)
    if os == "Windows":
        dir = windowsify(dir)
    return flags[:-1] + [flags[-1].format(dir)]

# download conda installer
def _download_conda(rctx):
    rctx.report_progress("Downloading conda installer")
    os = get_os(rctx)
    arch = get_arch(rctx)
    ext = INSTALLER_SCRIPT_EXT_MAP[os]

    if rctx.attr.installer == "miniconda":
        url = CONDA_BASE_URL + CONDA_INSTALLER_NAME_TEMPLATE.format(major = CONDA_MAJOR, minor = CONDA_MINOR, os = os, arch = arch, ext = ext)
        sha = CONDA_SHA
    elif rctx.attr.installer == "miniforge":
        url = MINIFORGE_BASE_URL + MINIFORGE_INSTALLER_NAME_TEMPLATE.format(major = MINIFORGE_MAJOR, minor = MINIFORGE_MINOR, os = os, arch = arch, ext = ext)
        sha = MINIFORGE_SHA
    else:
        fail("installer must be either miniconda or miniforge")

    output = "{}/install{}".format(INSTALLER_DIR, ext)

    # download from url to output
    rctx.download(
        url = url,
        output = output,
        sha256 = sha[os][arch],
        executable = True,
    )
    return output

# install conda locally
def _install_conda(rctx, installer):
    rctx.report_progress("Installing conda")
    os = get_os(rctx)
    installer_flags = _get_installer_flags(rctx, rctx.attr.conda_dir)
    args = [rctx.path(installer)] + installer_flags

    # execute installer with flags adjusted to OS
    if os == "Windows":
        # TODO: fix always returning 0
        # it seems that either miniconda installer returns 0 even on failure or the wrapper does something wrong
        # also stdout and stderr are always empty
        result = execute_waitable_windows(rctx, args, quiet = rctx.attr.quiet, environment = {"CONDA_DLL_SEARCH_MODIFICATION_ENABLE": ""}, timeout = rctx.attr.timeout)
    else:
        result = rctx.execute(args, quiet = rctx.attr.quiet, timeout = rctx.attr.timeout)

    if result.return_code:
        fail("Failure installing conda.\nstdout: {}\nstderr: {}".format(result.stdout, result.stderr))
    return "{}/condabin/conda{}".format(rctx.attr.conda_dir, CONDA_EXT_MAP[os])

# use conda to update itself
def _update_conda(rctx, executable):
    conda_with_version = "conda={}".format(rctx.attr.version)
    args = [rctx.path(executable), "install", conda_with_version, "-y"]

    # update conda itself
    result = rctx.execute(args, quiet = rctx.attr.quiet, working_directory = rctx.attr.conda_dir, timeout = rctx.attr.timeout)
    if result.return_code:
        fail("Failure updating conda.\nstdout: {}\nstderr: {}".format(result.stdout, result.stderr))

# create BUILD file with exposed conda binary
def _create_conda_build_file(rctx, executable):
    conda = "{}/{}".format(rctx.attr.conda_dir, executable)
    rctx.file(
        "BUILD",
        content = CONDA_BUILD_FILE_TEMPLATE.format(conda = conda),
    )

def _load_conda_impl(rctx):
    installer = _download_conda(rctx)
    executable = _install_conda(rctx, installer)
    _update_conda(rctx, executable)
    _create_conda_build_file(rctx, executable)

load_conda_rule = repository_rule(
    _load_conda_impl,
    attrs = {
        "conda_dir": attr.string(mandatory = True),
        "version": attr.string(
            mandatory = True,
            doc = "Conda version to install",
        ),
        "quiet": attr.bool(
            default = True,
            doc = "False if conda output should be shown",
        ),
        "timeout": attr.int(
            default = EXECUTE_TIMEOUT,
            doc = "Timeout in seconds for each execute action",
        ),
        "installer": attr.string(
            default = "miniconda",
            doc = 'Installer to use, either "miniconda" or "miniforge". Note that miniconda and miniforge have different OS/arch support.',
        ),
    },
)
