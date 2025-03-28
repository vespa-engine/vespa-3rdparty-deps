# Updating 3rd party dependencies

The 3rd party packages are installed with prefix <code>/opt/vespa-deps</code>, thus the libraries are put in a nonstandard location. As long as the library names are not changed, the package should not provide the shared library. Otherwise, we could end up missing the OS provided version of a package due to the vespa 3rdparty version of the package being incorrectly installed instead.

    $ rpm -q --provides libzstd
    libzstd = 1.4.4-1.el8
    libzstd(x86-64) = 1.4.4-1.el8
    libzstd.so.1()(64bit)
    $ rpm -q --provides vespa-libzstd
    vespa-libzstd = 1.5.6-1.el8
    vespa-libzstd(x86-64) = 1.5.6-1.el8

The following fragment from [vespa-zstd.spec](zstd/vespa-zstd.spec) is used to filter away all shared libraries from the automatically generated list of provides when building the rpm:

    # Don't provide shared library or pkgconfig
    %global __provides_exclude ^(lib.*\\.so\\.[0-9.]*\\(\\)\\(64bit\\)|pkgconfig\\(.*)$

Similarly, vespa and the 3rd party packages must also require the 3rdparty packages but not the shared libraries they contains:

    # Exclude automated requires for libraries in /opt/vespa-deps/lib64.
    %global __requires_exclude ^libzstd\\.so\\.[0-9.]*\\([A-Za-z._0-9]*\\)\\(64bit\\)$

Due to depending on the 3rd party package and not the libraries, the dependencies must often be pinned to a specific version. We currently don't have a good solution of specifying the version in one location. We currently use notes in .copr/Makefile, e.g. for gtest:

    # Note:
    #
    # Version above must be kept in sync with _vespa_gtest_version in rpm
    # spec files for vespa-abseil-cpp, vespa-protobuf,
    # vespa-build-dependencies and vespa.

And we also define a version macro in the specs file for each relevant package:

    $ git grep '%global .*_gtest_version'
    abseil-cpp/vespa-abseil-cpp.spec.tmpl:%global _vespa_gtest_version 1.16.0
    build-dependencies/vespa-build-dependencies.spec.tmpl:%global _vespa_gtest_version 1.16.0
    protobuf/vespa-protobuf.spec.tmpl:%global _vespa_gtest_version 1.16.0

