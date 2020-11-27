# rules_conda

Rules for creating ```conda``` environments in Bazel :green_heart:

## Requirements

```rules_conda``` don't have any strict requirements by themselves.

Remember that some packages (e.g. ```dlib```) are actually being compiled during installation and sometimes they need your local tools to compile (e.g. ```g++```).

## Usage

Add this to your ```WORKSPACE``` file:

```Starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_conda",
    sha256 = "6c05d098ea82c172cd83d99c5fc892a488ffbf5f64ab3b2a32ab642c2a264e31",
    url = "https://github.com/spietras/rules_conda/releases/download/0.0.4/rules_conda-0.0.4.zip"
)

load("@rules_conda//:defs.bzl", "load_conda", "conda_create", "register_toolchain")

# download and install conda
load_conda(
    version = "4.8.4",  # optional, defaults to 4.8.4
    quiet = False  # print output
)

# create environment with python2
conda_create(
    name = "py2_env",
    environment = "@//third_party/conda:py2_environment.yml",  # label pointing to environment.yml file
    quiet = False,
    timeout = 600  # each execute action can take up to 600 seconds
)

# create environment with python3
conda_create(
    name = "py3_env",
    environment = "@//third_party/conda:py3_environment.yml",  # label pointing to environment.yml file
    quiet = False,
    timeout = 600
)

# register pythons from environment as toolchain
register_toolchain(
    py2_env = "py2_env", # python2 is optional
    py3_env = "py3_env"
)
```

After that, all Python targets will use the environments specified in ```register_toolchain```.

## Who should use this?

These rules allow you to download and install ```conda```, create ```conda``` environments and register Python toolchain from environments.

Pros:
- easy to use
- no previous ```conda``` installation necessary
- no dependencies on ```conda``` side
- no global ```conda``` installation, no global ```PATH``` modifications
- you can install packages from ```conda``` and from ```pip```
- all Python targets will have access to the whole environment (the one registered in toolchain)

Cons:
- every time you update your environment configuration in ```environment.yml```, the whole environment will be recreated from scratch
- on Windows you need to add environment location to ```PATH``` or set ```CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1``` during runtime, so DLLs can be loaded properly (more on that below) 

So I think these rules suit you if:
- you want to use Bazel (e.g. for local package management)
- you want to use ```conda``` for third-party Python package management
- you don't want to set up your Python environment manually or want your Python targets to _just work_ on clean systems
- you don't use a lot of third-party dependencies
- you are okay with environments being recreated every time something changes

## ```PATH``` issue

With usual ```conda``` usage, you should ```activate``` you environment before doing anything. Activating an environment prepends some paths to ```PATH``` variable. This is crucial on Windows, because some ```conda``` packages need to load DLLs, which are stored in ```conda``` environments and the path to them must be in ```PATH``` variable for Windows to properly load them. On Linux, it somehow works without having to modify ```PATH```.

But here comes the issue: at this moment, I'm not aware of any way to either ```activate``` an environment before launching Python targets or adding anything to ```PATH``` automatically by Bazel.

So the user has to do something to resolve the ```PATH``` issue. There are two ways:

- Modify ```PATH```

	Before running the target, set the ```PATH``` to include the path to ```your_env/Library/bin```. For example:

	```cmd
	cmd /C "set PATH={full path to workspace}\bazel-{name}\external\{env_name}\{env_name}\Library\bin;%PATH%&& bazelw run {target}"
	```

	Since we are running with ```bazelw``` you can instead put the variable setting there. You can also set the variable directly in your Python script.

- Use ```CONDA_DLL_SEARCH_MODIFICATION_ENABLE```

	It originally stems from another issue, but Python from ```conda``` has the ability to automatically insert the correct entries to ```PATH```. This is controlled by setting the ```CONDA_DLL_SEARCH_MODIFICATION_ENABLE``` to ```1```.

	So you can for example do:

	```cmd
	cmd /C "set CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1&& bazelw run {target}"
	```

	Since we are running with ```bazelw``` you can instead put the variable setting there. That's how it's done in the example. You can also set the variable directly in your Python script.

	This method only works with newer Python builds. More information [here](https://docs.conda.io/projects/conda/en/latest/user-guide/troubleshooting.html#mkl-library).

In the future I hope that either ```conda``` (or Python, or Windows DLL loading, whatever is responsible for that) will change to work without activation or it will be possible to set environmetal variables inside Bazel.

## TODO

- don't recreate environments from scratch when configuration changes
