# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=1
MINOR=3
PATCH=2
RELEASE=1
PKGNAME=vespa-build-dependencies

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/$(PKGNAME).spec
VERSION=$(MAJOR).$(MINOR).$(PATCH)

outdir ?= $(TOP)

SEDCMD = s/_TMPL_VER_MAJOR/$(MAJOR)/;s/_TMPL_VER_MINOR/$(MINOR)/;s/_TMPL_VER_PATCH/$(PATCH)/;s/_TMPL_VER_RELEASE/$(RELEASE)/

srpm:
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	cat $(PKGNAME).spec.tmpl | sed "$(SEDCMD)" > $(SPECFILE)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)

clean:
	-rm -rf $(RPMTOPDIR) $(TOP)/*.rpm

.PHONY: srpm clean
