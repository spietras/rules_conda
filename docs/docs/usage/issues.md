# Issues

## `PATH` issue

With usual `conda` usage, you should `activate` you environment before doing anything. Activating an environment prepends some paths to `PATH` variable. This is crucial on Windows, because some `conda` packages need to load DLLs, which are stored in `conda` environments and the path to them must be in `PATH` variable for Windows to properly load them. On Linux, it somehow works without having to modify `PATH`.

But here comes the issue: at this moment, I'm not aware of any way to either `activate` an environment before launching Python targets or adding anything to `PATH` automatically by Bazel.

So the user has to do something to resolve the `PATH` issue. There are two ways:

- Modify `PATH`

    Before running the target, set the `PATH` to include the path to `your_env/Library/bin`. For example:

    ```cmd
    cmd /C "set PATH={full path to workspace}\bazel-{name}\external\{env_name}\{env_name}\Library\bin;%PATH%&& bazel run {target}"
    ```

- Use `CONDA_DLL_SEARCH_MODIFICATION_ENABLE`

    It originally stems from another issue, but Python from `conda` has the ability to automatically insert the correct entries to `PATH`. This is controlled by setting the `CONDA_DLL_SEARCH_MODIFICATION_ENABLE` to `1`.

    So you can for example do:

    ```cmd
    cmd /C "set CONDA_DLL_SEARCH_MODIFICATION_ENABLE=1&& bazel run {target}"
    ```

    This method only works with newer Python builds. More information [here](https://docs.conda.io/projects/conda/en/latest/user-guide/troubleshooting.html#mkl-library).

In the future I hope that either `conda` (or Python, or Windows DLL loading, whatever is responsible for that) will change to work without activation or it will be possible to set environmetal variables inside Bazel.
