load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load(":conda.bzl", "load_conda_rule")
load(":env.bzl", "conda_create_rule")
load(":toolchain.bzl", "toolchain_rule")

CONDA_REPO_NAME = "conda"
CONDA_DIR = "conda"
DEFAULT_CONDA_VERSION = "4.10.3"
DEFAULT_TOOLCHAIN_REPO_NAME = "conda_tools"
DEFAULT_TOOLCHAIN_NAME = "python_toolchain"
DEFAULT_MAMBA_VERSION = "0.17.0"

# download and install conda
def load_conda(conda_version = DEFAULT_CONDA_VERSION, mamba_version = DEFAULT_MAMBA_VERSION, **kwargs):
    maybe(
        load_conda_rule,
        CONDA_REPO_NAME,
        conda_dir = CONDA_DIR,
        conda_version = conda_version,
        mamba_version = mamba_version,
        **kwargs
    )

# create conda environment
def conda_create(name, **kwargs):
    maybe(
        conda_create_rule,
        name,
        conda_repo = CONDA_REPO_NAME,
        conda_dir = CONDA_DIR,
        **kwargs
    )

# register python toolchain from environments
def register_toolchain(env, name = DEFAULT_TOOLCHAIN_REPO_NAME, toolchain_name = DEFAULT_TOOLCHAIN_NAME, **kwargs):
    runtime = "@{}//:python_runtime".format(env)

    maybe(
        toolchain_rule,
        name,
        runtime = runtime,
        toolchain_name = toolchain_name,
        **kwargs
    )

    native.register_toolchains("@{}//:{}".format(name, toolchain_name))
