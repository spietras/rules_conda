import sys

import pytest


def test_correct_pytest_version():
    assert pytest.__version__ == "6.2.2"


if __name__ == "__main__":
    sys.exit(pytest.main([__file__] + sys.argv[1:]))
