# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=0
MINOR=3
PATCH=27
RELEASE=2

# Note:
#
# Version above must be kept in sync with _vespa_openblas_version in
# rpm spec files for vespa-build-dependencies, vespa-jllama,
# vespa-jllama-cuda and vespa.

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/vespa-openblas.spec

outdir ?= $(TOP)

srpm:
	rpm -q rpmdevtools || dnf install -y rpmdevtools
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	cat vespa-openblas.spec.tmpl | sed "s/_TMPL_VER_MAJOR/$(MAJOR)/" | sed "s/_TMPL_VER_MINOR/$(MINOR)/" | sed "s/_TMPL_VER_PATCH/$(PATCH)/" | sed "s/_TMPL_VER_RELEASE/$(RELEASE)/" > $(SPECFILE)
	spectool -g -C $(SOURCEDIR) $(SPECFILE)
	cp -a *.diff $(SOURCEDIR)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)
clean:
	-rm -rf $(RPMTOPDIR)

.PHONY: srpm clean
