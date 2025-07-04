# Updating 3rd party dependencies

The 3rd party packages are installed with prefix <code>/opt/vespa-deps</code>, thus the libraries are put in a nonstandard location. As long as the library names are not changed, the package should not provide the shared library. Otherwise, we could end up missing the OS provided version of a package due to the vespa 3rdparty version of the package being incorrectly installed instead.

    $ rpm -q --provides libzstd
    libzstd = 1.4.4-1.el8
    libzstd(x86-64) = 1.4.4-1.el8
    libzstd.so.1()(64bit)
    $ rpm -q --provides vespa-libzstd
    vespa-libzstd = 1.5.6-1.el8
    vespa-libzstd(x86-64) = 1.5.6-1.el8

The following fragment from [vespa-zstd.spec.tmpl](zstd/vespa-zstd.spec.tmpl) is used to filter away all shared libraries from the automatically generated list of provides when building the rpm:

    # Don't provide shared library or pkgconfig
    %global __provides_exclude ^(lib.*\\.so\\.[0-9.]*\\(\\)\\(64bit\\)|pkgconfig\\(.*)$

Similarly, vespa and the 3rd party packages must also require the 3rdparty packages but not the shared libraries they contain:

    # Exclude automated requires for libraries in /opt/vespa-deps/lib64.
    %global __requires_exclude ^libzstd\\.so\\.[0-9.]*\\([A-Za-z._0-9]*\\)\\(64bit\\)$

Due to depending on the 3rd party package and not the libraries, the dependencies must often be pinned to a specific version. We currently don't have a good solution of specifying the version in one location. We currently use notes in <code>.copr/Makefile</code>, e.g. for gtest:

```
# Version
MAJOR=1
MINOR=16
PATCH=0
RELEASE=1

# Note:
#
# Version above must be kept in sync with _vespa_gtest_version in rpm
# spec files for vespa-abseil-cpp, vespa-protobuf,
# vespa-build-dependencies and vespa.
```

We also define a version macro in the specs file for each relevant package:

    $ git grep '%global .*_gtest_version'
    abseil-cpp/vespa-abseil-cpp.spec.tmpl:%global _vespa_gtest_version 1.16.0
    build-dependencies/vespa-build-dependencies.spec.tmpl:%global _vespa_gtest_version 1.16.0
    protobuf/vespa-protobuf.spec.tmpl:%global _vespa_gtest_version 1.16.0

A specific version macros should be defined to the same value in all spec files and be in sync with the values in the corresponding <code>.copr/Makefile</code>.

When building a new version of a package, all packages that depend on a pinned version of the package must also be rebuilt. If the version number is not increased then the <code>RELEASE</code> value should be increased instead. This might imply more strict version pinning that also includes the release, e.g. <code>1.16.0-1%{?dist}</code>. Since the build-dependencies package has no upstream, we always bump the version.

## Changing vespa rpm spec to use new 3rd party dependencies

The <code>[dist/vespa.spec](https://github.com/vespa-engine/vespa/blob/master/dist/vespa.spec)</code> file in the <code>[vespa](https://github.com/vespa-engine/vespa)</code> repo also contains version macros that should be in sync. Don't forget to update <code>_vespa_build_depencencies_version</code> (which is not present as a version macro in vespa-3rdparty-deps repo).

## Changing references to vespa rpm spec in <code>docker-image-dev</code> repo

Various files in the <code>[docker-image-dev](https://github.com/vespa-engine/docker-image-dev)</code> repo contain `VESPA_SRC_REF` with a checksum for a specific git commit in the <code>[vespa](https://github.com/vespa-engine/vespa)</code> repo. The value is used when building vespa build images to download a specific version of <code>vespa.spec</code> and use it to get the proper dependencies pre-installed.
