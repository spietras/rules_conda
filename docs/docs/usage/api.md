# API

## `load_conda`

!!! quote ""

    Downloads `conda`.

    **Parameters:**

    | Name            | Description                                                                                | Default                |
    | --------------- | ------------------------------------------------------------------------------------------ | ---------------------- |
    | `installer`     | Which `conda` installer to download, either `miniconda` or `miniforge`                     | `miniconda`            |
    | `install_mamba` | Whether to install mamba, which is a faster drop-in replacement for conda                  | `miniconda`            |
    | `version`       | Version of `conda` to download                                                             | `4.10.3`               |
    | `quiet`         | `True` if `conda` output should be hidden                                                  | `True`                 |
    | `timeout`       | How many seconds each execute action can take                                              | `3600`                 |

## `conda_create`

!!! quote ""

    Creates a `conda` environment.

    **Parameters:**

    | Name          | Description                                                                                                  | Default                |
    | ------------- | ------------------------------------------------------------------------------------------------------------ | ---------------------- |
    | `environment` | label pointing to environment configuration file (typically named `environment.yml`)                         |                        |
    | `name`        | Name of the environment                                                                                      | `my_env`               |
    | `quiet`       | `True` if `conda` output should be hidden                                                                    | `True`                 |
    | `timeout`     | How many seconds each execute action can take                                                                | `3600`                 |
    | `clean`       | `True` if `conda` cache should be cleaned (less space taken, but slower subsequent builds)                   | `False`                |
    | `use_mamba`   | Whether to use mamba to create the conda environment. If this is `True`, `install_mamba` must also be `True` | `False`                |

## `register_toolchain`

!!! quote ""

    Register python toolchain from `conda` environment for all python targets to use.
    Main environment is used in python3 toolchain. Optionally you can specify another one to use in python2 toolchain.

    **Parameters:**

    | Name          | Description                                                                                | Default                |
    | ------------- | ------------------------------------------------------------------------------------------ | ---------------------- |
    | `py3_env`     | Name of the environment to use                                                             |                        |
    | `py2_env`     | Name of the python2 environment to use (optional)                                          | `None`                 |
