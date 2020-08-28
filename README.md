# rules_conda

Rules for creating conda environments in Bazel :green_heart:

## Requirements

```rules_conda``` don't have any strict requirements by themselves.

Remember that some packages (e.g. ```dlib```) are actually being compiled during installation and sometimes they need your local tools to compile (e.g. ```g++```).

## Who should use this?

These rules allow you to download and install conda, create conda environments and register Python toolchain from environments.

Pros:
- easy to use
- no previous ```conda``` installation necessary
- no dependencies on ```conda``` side
- no global ```conda``` installation, no global ```PATH``` modifications
- you can install packages from ```conda``` and from ```pip```
- all Python targets will have access to the whole environment (the one registered in toolchain)

Cons:
- every time you update your environment configuration in ```environment.yml```, the whole environment will be recreated from scratch
- currently works only on 64-bit machines
- on Windows you need to add environment location to ```PATH``` or set ```CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1``` during runtime, so DLLs can be loaded properly (more on that below) 

So I think these rules suit you if:
- you want to use ```Bazel``` (e.g. for local package management)
- you don't want to set up your Python environment manually or want your Python targets to _just work_ on clean systems
- you don't use a lot of third-party dependencies
- you are okay with environments being recreated every time something changes

## ```PATH``` issue

With usual ```conda``` usage, you should ```activate``` you environment before doing anything. Activating an environment prepends some paths to ```PATH``` variable. This is crucial on Windows, because some ```conda``` packages need to load DLLs, which are stored in ```conda``` environments and the path to them must be in ```PATH``` variable for Windows to properly load them. On Linux, it somehow works without having to modify ```PATH```.

But here comes the issue: at this moment, I'm not aware of any way to either ```activate``` an environment before launching Python targets or adding anything to ```PATH``` automatically by ```Bazel```.

So the user has to do something to resolve the ```PATH``` issue. There are two ways:

- Modify ```PATH```

	Before running the target, set the ```PATH``` to include the path to ```your_env/Library/bin```. For example:

	```
	cmd /C "set PATH={full path to workspace}\bazel-{name}\external\{env_name}\{env_name}\Library\bin;%PATH%&& bazelw run {target}"
	```

	Since we are running with ```bazelw``` you can instead put the variable setting there. You can also set the variable directly in your Python script.

- Use ```CONDA_DLL_SEARCH_MODIFICATION_ENABLE```

	It originally stems from another issue, but Python from ```conda``` has the ability to automatically insert the correct entries to ```PATH```. This is controlled by setting the ```CONDA_DLL_SEARCH_MODIFICATION_ENABLE``` to ```1```.

	So you can for example do:

	```
	cmd /C "set CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1&& bazelw run {target}"
	```

	Since we are running with ```bazelw``` you can instead put the variable setting there. That's how it's done in the example. You can also set the variable directly in your Python script.

	This method only works with newer Python builds. More information [here](https://docs.conda.io/projects/conda/en/latest/user-guide/troubleshooting.html#mkl-library).

In the future I hope that either ```conda``` (or Python, or Windows DLL loading, whatever is responsible for that) will change to work without activation or it will be possible to set environmetal variables inside ```Bazel```.

## TODO

- support 32-bit machines
- add usage example to README
- release first package
- change example to download package from github, instead of using local workspace
