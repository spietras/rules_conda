# rules_conda

Rules for creating conda environments in Bazel :green_heart:

## Requirements:

```rules_conda``` don't have any strict requirements by themselves

Note that to run the example on Linux you need:
- ```glibc``` (```Bazel``` dependency)
- any ```python``` (```rules_python``` dependency)

## Who should use this?

These rules allow you to download and install conda, create conda environments and register Python toolchain from environments.

Pros:
- easy to use
- no previous ```conda``` installation necessary
- no dependencies on ```conda``` side
- no global ```conda``` installation, no ```PATH``` modifications
- you can install packages from ```conda``` and from ```pip```
- all Python targets will have access to the whole environment (the one registered in toolchain)

Cons:
- every time you update you environment configuration in ```environment.yml```, the whole environment will be recreated from scratch
- currently works only on 64-bit machines
- on Windows you need to add environment location to ```PATH``` or set ```CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1``` during runtime, so DLLs can be loaded properly (I need to think about some workaround) 

So I think these rules suit you if:
- you want to use ```Bazel``` (e.g. for local package managment)
- you don't want to set up your Python environment manually or want your Python targets to _just work_ on clean systems
- you don't use a lot of third-party dependencies
- you are okay with environments being recreated every time something changes

## TODO

- think about getting environment on PATH automatically during runtime
- support 32-bit machines
- refactor example to have better structure
- release first package
