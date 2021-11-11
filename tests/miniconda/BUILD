load("@rules_python//python:defs.bzl", "py_test")

py_test(
    name = "test",
    size = "small",
    srcs = ["test.py"],
)

# Only passes when tested with
# --extra_toolchains=@test2//:test2_env_toolchain
py_test(
    name = "test2",
    size = "small",
    srcs = ["test2.py"],
    tags = ["manual"],
)
