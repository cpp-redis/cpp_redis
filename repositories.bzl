load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

cpp_redis_repositories:
  """Add external dependencies to the workspace."""
  maybe(
    http_archive,
    name = "tacopie",
    urls = ["https://github.com/cylix/tacopie/archive/6b060c7f7e158e60d634c14e412aa78d4041f237.tar.gz"],
    strip_prefix = "tacopie-6b060c7f7e158e60d634c14e412aa78d4041f237",
    sha256 = "6e123b274480476d1a9bab675623519ccd3108ee93a0515823a70a471a93aff8",
  )
