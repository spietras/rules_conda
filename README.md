# rules_conda

Rules for creating conda environments in Bazel :green_heart:

## Requirements:

Linux:
- ```glibc``` (```Bazel``` dependency)
- any ```python``` (```rules_python``` dependency)

## Who should use this?

These rules download and install conda, create conda environments and register python toolchain from environments.

Pros:
- easy to use
- no local ```conda``` installation necessary
- no dependencies on ```conda``` side
- you can install packages from ```conda``` and from ```pip```
- all python targets will have access to the whole environment (the one registered in toolchain)

Cons:
- every time you update you environment configuration in ```environment.yml```, the whole environment will be recreated from scratch
- currently works only on 64-bit machines

So I think these rules suit you if you don't use a lot of third-party dependencies and are okay with environments being recreated every time something changes.

## TODO

- test on Windows
- support 32-bit machines
