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
    sha256 = "c5ad3a077bddff381790d64dd9cc1516b8133c1d695eb3eff4fed04a39dc4522",
    url = "https://github.com/spietras/rules_conda/releases/download/0.0.6/rules_conda-0.0.6.zip"
)

load("@rules_conda//:defs.bzl", "conda_create", "load_conda", "register_toolchain")

load_conda(
    quiet = False,  # use True to hide conda output
    version = "4.10.3",  # optional, defaults to 4.10.3
)

conda_create(
    name = "my_env",
    timeout = 600,  # each execute action can take up to 600 seconds
    clean = False,  # use True if you want to clean conda cache (less space taken, but slower subsequent builds)
    environment = "@//:environment.yml",  # label pointing to environment.yml file
    quiet = False,  # use True to hide conda output
)

register_toolchain(
    py3_env = "my_env",
)
```

After that, all Python targets will use the environments specified in `register_toolchain`.

## Who should use this?

These rules allow you to download and install `conda`, create `conda` environments and register Python toolchain from environments.
This means you can achieve truly reproducible and hermetic local python environments.

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
