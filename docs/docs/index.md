# rules_conda

Rules for creating conda environments in Bazel 💚

See [here](usage/example.md) for usage example.

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
- on Windows you need to add environment location to `PATH` or set `CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1` during runtime, so DLLs can be loaded properly (more on that [here](usage/issues.md#path-issue))

So I think these rules suit you if:

- you want to use Bazel (e.g. you fell into Python monorepo trap)
- you want to use `conda` for Python environment management
- you don't want to set up your Python environment manually or want your Python targets to _just work_ on clean systems
- you are okay with environments being recreated every time something changes

## Requirements

`rules_conda` don't have any strict requirements by themselves.

Just make sure you are able to use [`conda`](https://docs.conda.io/en/latest/miniconda.html#system-requirements).
