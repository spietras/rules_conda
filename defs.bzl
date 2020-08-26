load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load(":conda.bzl", "load_conda_rule")
load(":env.bzl", "conda_create_rule")
load(":toolchain.bzl", "toolchain_rule")

CONDA_REPO_NAME = "conda"
CONDA_DIR = "conda"
DEFAULT_ENV_NAME = "my_env"
DEFAULT_TOOLCHAIN_REPO_NAME = "conda_tools"
DEFAULT_TOOLCHAIN_NAME = "python_toolchain"

# download and install conda
def load_conda(**kwargs):

    maybe(
        load_conda_rule,
        CONDA_REPO_NAME,
        conda_dir = CONDA_DIR,
        **kwargs
    )

# create conda environment
def conda_create(name = DEFAULT_ENV_NAME, **kwargs):

    conda = "@{}//:{}/condabin/conda".format(CONDA_REPO_NAME, CONDA_DIR)

    maybe(
        conda_create_rule,
        name,
        conda = conda,
        **kwargs
    )

# register python toolchain from environments
def register_toolchain(py3_env, py2_env=None, name=DEFAULT_TOOLCHAIN_REPO_NAME, toolchain_name=DEFAULT_TOOLCHAIN_NAME, **kwargs):
    py2_runtime = "@{}//:python_runtime".format(py2_env) if py2_env else None
    py3_runtime = "@{}//:python_runtime".format(py3_env)

    maybe(
        toolchain_rule,
        name,
        py2_runtime = py2_runtime,
        py3_runtime = py3_runtime,
        toolchain_name = toolchain_name,
        **kwargs
    )

    native.register_toolchains("@{}//:{}".format(name, toolchain_name))
