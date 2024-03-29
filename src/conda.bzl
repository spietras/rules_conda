load(":utils.bzl", "CONDA_EXT_MAP", "EXECUTE_TIMEOUT", "INSTALLER_SCRIPT_EXT_MAP", "execute_waitable_windows", "get_arch", "get_os", "windowsify")

# CONDA CONFIGURATION
CONDA_MAJOR = "3"
CONDA_MINOR = "py39_4.12.0"
CONDA_SHA = {
    "Windows": {
        "x86_64": "1acbc2e8277ddd54a5f724896c7edee112d068529588d944702966c867e7e9cc",
        "x86": "4fb64e6c9c28b88beab16994bfba4829110ea3145baa60bda5344174ab65d462",
    },
    "MacOSX": {
        "x86_64": "007bae6f18dc7b6f2ca6209b5a0c9bd2f283154152f82becf787aac709a51633",
        "arm64": "4bd112168cc33f8a4a60d3ef7e72b52a85972d588cd065be803eb21d73b625ef",
    },
    "Linux": {
        "x86_64": "78f39f9bae971ec1ae7969f0516017f2413f17796670f7040725dd83fcff5689",
        "aarch64": "5f4f865812101fdc747cea5b820806f678bb50fe0a61f19dc8aa369c52c4e513",
        "ppc64le": "1fe3305d0ccc9e55b336b051ae12d82f33af408af4b560625674fa7ad915102b",
        "s390x": "ff6fdad3068ab5b15939c6f422ac329fa005d56ee0876c985e22e622d930e424",
    },
}
CONDA_INSTALLER_NAME_TEMPLATE = "Miniconda{major}-{minor}-{os}-{arch}{ext}"
CONDA_BASE_URL = "https://repo.anaconda.com/miniconda/"

MINIFORGE_MAJOR = "3"
MINIFORGE_MINOR = "4.12.0-2"
MINIFORGE_SHA = {
    "Windows": {
        "x86_64": "39c71fa902188edaf8c90a9868e6b76fb9d3f08c4d5c48c8077054b8e0aa5417",
    },
    "MacOSX": {
        "x86_64": "37007407ab504fb8bd3af68ff821c0819ad2f016087b9c45f1e95a910c92531e",
        "arm64": "24181b1a42c6bb9704e28ac4ecb234f3c86d882a7db408948692bc5792a2f713",
    },
    "Linux": {
        "x86_64": "e8bd60572d1bdcd9fc16114f423653c95e02f0be1393383f77fba17cf8acb10e",
        "aarch64": "507c9763942821d7541b5a1b1130545e4c19416cc0473054faa10fee435aa9fa",
        "ppc64le": "447d1729353189ba732e951b598d5b9ea4ab46296db4523ac34a775150a60199",
    },
}

MINIFORGE_INSTALLER_NAME_TEMPLATE = "{minor}/Miniforge{major}-{minor}-{os}-{arch}{ext}"
MINIFORGE_BASE_URL = "https://github.com/conda-forge/miniforge/releases/download/"

INSTALLER_DIR = "installer"
INSTALLER_FLAGS = {
    "Windows": ["/InstallationType=JustMe", "/AddToPath=0", "/RegisterPython=0", "/S", "/D={}"],
    "MacOSX": ["-b", "-f", "-p", "{}"],
    "Linux": ["-b", "-f", "-p", "{}"],
}

CONDA_BUILD_FILE_TEMPLATE = """# This file was automatically generated by rules_conda

exports_files(['{conda}'])
"""

def _get_installer_flags(rctx, dir):
    os = get_os(rctx)
    flags = INSTALLER_FLAGS[os]

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
        fail("Installer must be either miniconda or miniforge.")

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

def _install_mamba(rctx, executable):
    rctx.report_progress("Installing mamba")
    mamba_with_version = "mamba={}".format(rctx.attr.mamba_version)

    # `-n base` is necessary so that mamba is installed to the conda in the bazel cache.
    # If we omit `-n base`, then mamba can get installed to the user's environment i.e. ~/anaconda3 which breaks
    # the hermetic nature of the build.
    args = [rctx.path(executable), "install", "-n", "base", "-c", "conda-forge", mamba_with_version, "-y"]
    result = rctx.execute(args, quiet = rctx.attr.quiet, working_directory = rctx.attr.conda_dir, timeout = rctx.attr.timeout)
    if result.return_code:
        fail("Failure when installing mamba.\nstdout: {}\nstderr: {}".format(result.stdout, result.stderr))

# use conda to update itself
def _update_conda(rctx, executable):
    conda_with_version = "conda={}".format(rctx.attr.conda_version)
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
    conda_executable = _install_conda(rctx, installer)
    _update_conda(rctx, conda_executable)
    if rctx.attr.install_mamba:
        _install_mamba(rctx, conda_executable)
    _create_conda_build_file(rctx, conda_executable)

load_conda_rule = repository_rule(
    _load_conda_impl,
    attrs = {
        "conda_dir": attr.string(mandatory = True),
        "conda_version": attr.string(
            mandatory = True,
            doc = "Conda version to install",
        ),
        "installer": attr.string(
            default = "miniconda",
            doc = 'Installer to use, either "miniconda" or "miniforge". Note that miniconda and miniforge have different OS/arch support.',
        ),
        "install_mamba": attr.bool(
            default = False,
            doc = "False if mamba should not be installed",
        ),
        "mamba_version": attr.string(
            mandatory = True,
            doc = "Mamba version to install",
        ),
        "quiet": attr.bool(
            default = True,
            doc = "False if conda output should be shown",
        ),
        "timeout": attr.int(
            default = EXECUTE_TIMEOUT,
            doc = "Timeout in seconds for each execute action",
        ),
    },
)
