<h1 align="center">rules_conda</h1>

<div align="center">

[![Running tests](https://github.com/spietras/rules_conda/actions/workflows/test.yml/badge.svg)](https://github.com/spietras/rules_conda/actions/workflows/test.yml)
[![Deploying docs](https://github.com/spietras/rules_conda/actions/workflows/docs.yml/badge.svg)](https://github.com/spietras/rules_conda/actions/workflows/docs.yml)

</div>

---

Rules for creating conda environments in Bazel 💚

For more info see [the docs](https://spietras.github.io/rules_conda) or [the example](https://github.com/spietras/rules_conda/tree/main/example).

## Requirements

`rules_conda` don't have any strict requirements by themselves.

Just make sure you are able to use [`conda`](https://docs.conda.io/en/latest/miniconda.html#system-requirements).

## Quickstart

Add this to your `WORKSPACE` file:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_conda",
    sha256 = "9793f86162ec5cfb32a1f1f13f5bf776e2c06b243c4f1ee314b9ec870144220d",
    url = "https://github.com/spietras/rules_conda/releases/download/0.1.0/rules_conda-0.1.0.zip"
)

load("@rules_conda//:defs.bzl", "conda_create", "load_conda", "register_toolchain")

load_conda(quiet = False)

conda_create(
    name = "py3_env",
    environment = "@//:environment.yml",
    quiet = False,
)

register_toolchain(py3_env = "py3_env")
```

After that, all Python targets will use the environment specified in `register_toolchain`.

See below for more advanced example.

## Advanced example

This example shows all possibilities of `rules_conda`:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_conda",
    sha256 = "9793f86162ec5cfb32a1f1f13f5bf776e2c06b243c4f1ee314b9ec870144220d",
    url = "https://github.com/spietras/rules_conda/releases/download/0.1.0/rules_conda-0.1.0.zip",
)

load("@rules_conda//:defs.bzl", "conda_create", "load_conda", "register_toolchain")

load_conda(
    conda_version = "4.10.3",  # version of conda to download, default is 4.10.3
    installer = "miniforge",  # which conda installer to download, either miniconda or miniforge, default is miniconda
    install_mamba = True,  # whether to install mamba, which is a faster drop-in replacement for conda, default is False
    mamba_version = "0.17.0",  # version of mamba to install, default is 0.17.0
    quiet = False,  # True if conda output should be hidden, default is True
    timeout = 600,  # how many seconds each execute action can take, default is 3600
)

conda_create(
    name = "py3_env",  # name of the environment
    environment = "@//:py3_environment.yml",  # label pointing to environment configuration file
    use_mamba = True,  # Whether to use mamba to create the conda environment. If this is True, install_mamba must also be True	False
    clean = False,  # True if conda cache should be cleaned (less space taken, but slower subsequent builds), default is False
    quiet = False,  # True if conda output should be hidden	True, default is True
    timeout = 600,  # how many seconds each execute action can take, default is 3600
)

conda_create(
    name = "py2_env",  # name of the environment
    environment = "@//:py2_environment.yml",  # label pointing to environment configuration file
)

register_toolchain(
    py2_env = "py2_env",  # python2 is optional
    py3_env = "py3_env",
)
```

## Who should use this?

These rules allow you to download and install `conda`, create `conda` environments and register Python toolchain from environments.
This means you can achieve truly reproducible and hermetic local Python environments.

Pros:

- easy to use
- no existing `conda` installation necessary
- no global `conda` installation, no global `PATH` modifications
- virtually impossible to corrupt your environment by mistake as it always reflects your `environment.yml`
- all Python targets will implicitly have access to the whole environment (the one registered in toolchain)

Cons:

- every time you update your environment configuration in `environment.yml`, the whole environment will be recreated from scratch (but cached package data can be reused)
- on Windows you need to add environment location to `PATH` or set `CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1` during runtime, so DLLs can be loaded properly (more on that [here](https://spietras.github.io/rules_conda/usage/issues/#path-issue))

So I think these rules suit you if:

- you want to use Bazel (e.g. you fell into Python monorepo trap)
- you want to use `conda` for Python environment management
- you don't want to set up your Python environment manually or want your Python targets to _just work_ on clean systems
- you are okay with environments being recreated every time something changes
