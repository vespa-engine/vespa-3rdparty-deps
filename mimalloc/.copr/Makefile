# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=2
MINOR=2
PATCH=4
RELEASE=3

# Note:
#
# Version above must be kept in sync with _vespa_mimalloc_version in
# rpm spec files for vespa-build-dependencies and vespa.

# The actual name for the generated (base) package
PKGNAME=vespa-mimalloc

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/$(PKGNAME).spec
VERSION=$(MAJOR).$(MINOR).$(PATCH)
SEDCMD = s/_TMPL_VER_MAJOR/$(MAJOR)/;s/_TMPL_VER_MINOR/$(MINOR)/;s/_TMPL_VER_PATCH/$(PATCH)/;s/_TMPL_VER_RELEASE/$(RELEASE)/

outdir ?= $(TOP)

srpm:
	rpm -q rpmdevtools || dnf install -y rpmdevtools
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	cat $(PKGNAME).spec.tmpl | sed "$(SEDCMD)" > $(SPECFILE)
	spectool -g -C $(SOURCEDIR) $(SPECFILE)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)

clean:
	-rm -rf $(RPMTOPDIR) $(TOP)/*.rpm

.PHONY: srpm clean
