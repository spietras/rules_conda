# rules_conda example

Simple Python app demonstrating usage of `rules_conda`

## Requirements

Linux:

- [`glibc`](https://stackoverflow.com/a/47191900/12861599)
- [any `python`](https://github.com/bazelbuild/bazel/issues/544#issuecomment-495307020)
- [any C compiler (like `gcc`)](https://github.com/bazelbuild/bazel/issues/8751)

Windows:

- [`Microsoft Visual C++ Redistributable`](https://docs.microsoft.com/en-US/cpp/windows/latest-supported-vc-redist)
- [`Developer Mode`](https://docs.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development) enabled

## Usage

If you have Bazel installed, just run:

```sh
bazel run app
```

If you don't have Bazel installed, you can use [`bazelw`](https://github.com/spietras/rules_conda/tree/main/scripts/bazelw):

```sh
../scripts/bazelw run app
```
