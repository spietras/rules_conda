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
I recommend that you first set everything up so that it works with your local python.
After that works you can move to using `rules_conda` for creating environments automatically.

To use `rules_conda` you need to add that to your `WORKSPACE` file:

```python
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

This will download `conda`, create your environment and register it so that all python targets can use it by default.

Now if you configured everything correctly, you can run:

```sh
bazel run main
```

This will run `main.py` inside the created environment.

If environment configuration doesn't change then subsequent runs will simply reuse the environment.
Otherwise the environment will be recreated from scratch, so that it always reflects the configuration.
However, if you set the `clean` flag to `False` in `conda_create` then the downloaded package data will be reused so you don't need to download everything everytime.

Also see [here](https://github.com/spietras/rules_conda/tree/main/example) for a complete example with all the code available.
