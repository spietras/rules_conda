BUILD_FILE_CONTENT = """# This file was automatically generated by rules_conda
package(default_visibility = ["//visibility:public"])

load("@bazel_tools//tools/python:toolchain.bzl", "py_runtime_pair")

py_runtime_pair(
    name = "runtimes",
    py2_runtime = {py2_runtime},
    py3_runtime = {py3_runtime},
)

toolchain(
    name = "{toolchain_name}",
    toolchain = ":runtimes",
    toolchain_type = "@bazel_tools//tools/python:toolchain_type",
)
"""

def _toolchain_impl(rctx):
    py2_runtime = rctx.attr.py2_runtime
    py3_runtime = rctx.attr.py3_runtime

    # Convert labels to strings to put into `BUILD_FILE_CONTENT`.

    # python2_runtime can be None, in which case the string should be "None".
    py2_runtime_value = '"{}"'.format(py2_runtime) if py2_runtime else "None"
    py3_runtime_value = '"{}"'.format(py3_runtime)

    # create BUILD file with toolchain definition
    rctx.file(
        "BUILD",
        content = BUILD_FILE_CONTENT.format(
            py2_runtime = py2_runtime_value,
            py3_runtime = py3_runtime_value,
            toolchain_name = rctx.attr.toolchain_name,
        ),
    )

toolchain_rule = repository_rule(
    _toolchain_impl,
    attrs = {
        "py2_runtime": attr.label(mandatory = False),
        "py3_runtime": attr.label(mandatory = True),
        "toolchain_name": attr.string(mandatory = True),
    },
)
