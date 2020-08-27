import os
# on Windows, this allows proper DLL loading, because the environment is not in PATH
# requires new Python versions
# see https://docs.conda.io/projects/conda/en/latest/user-guide/troubleshooting.html#mkl-library
os.environ["CONDA_DLL_SEARCH_MODIFICATION_ENABLE"] = "1"

import numpy as np
import scipy as sc
import somepackage as sp

if __name__ == '__main__':
    print("Numpy: {}".format(np.__version__))
    print("Scipy: {}".format(sc.__version__))
    print("Somepackage: {}".format(sp.__version__))
