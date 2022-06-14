# Example usage

Let's say you want to write some python code.

The simplest structure would be something like this:

```
BUILD
environment.yml
main.py
WORKSPACE
```

First get familiar with [`rules_python`](https://github.com/bazelbuild/rules_python).
You should uses these rules to configure your Python project to work with Bazel.
I recommend that you first set everything up so that it works with your local Python.
After that works you can move to using `rules_conda` for creating environments automatically.

To use `rules_conda` you need to add that to your `WORKSPACE` file and put appropriate values taken from chosen [release](https://github.com/spietras/rules_conda/releases/latest):

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_conda",
    sha256 = "...",  # copy from release
    url = "...",  # copy from release
)

load("@rules_conda//:defs.bzl", "conda_create", "load_conda", "register_toolchain")

load_conda(quiet = False)

conda_create(
    name = "env",
    environment = "@//:environment.yml",
    quiet = False,
)

register_toolchain(env = "env")
```

This will download `conda`, create your environment and register it so that all Python targets can use it by default.

Now if you configured everything correctly, you can run:

```sh
bazel run main
```

This will run `main.py` inside the created environment.

If environment configuration doesn't change then subsequent runs will simply reuse the environment.
Otherwise the environment will be recreated from scratch, so that it always reflects the configuration.
However, if the `clean` flag is set to `False` (the default) in `conda_create` then the downloaded package data will be reused so you don't need to download everything everytime.

Also see [here](https://github.com/spietras/rules_conda/tree/main/example) for a complete example with all the code available.

## Advanced example

This example shows all possibilities of `rules_conda`:

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_conda",
    sha256 = "...",  # copy from release
    url = "...",  # copy from release
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
    name = "env",  # name of the environment
    environment = "@//:environment.yml",  # label pointing to environment configuration file
    use_mamba = True,  # Whether to use mamba to create the conda environment. If this is True, install_mamba must also be True
    clean = False,  # True if conda cache should be cleaned (less space taken, but slower subsequent builds), default is False
    quiet = False,  # True if conda output should be hidden	True, default is True
    timeout = 600,  # how many seconds each execute action can take, default is 3600
)

register_toolchain(env = "env")
```
