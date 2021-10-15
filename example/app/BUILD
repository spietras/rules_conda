load("@rules_python//python:defs.bzl", "py_binary")

alias(
    name = "app",
    actual = "main",
)

py_binary(
    name = "main",
    srcs = glob(["**/*.py"]),
)
