# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=14
MINOR=2
PATCH=1
RELEASE=2
PKGNAME=vespa-toolset

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/$(PKGNAME)-$(MAJOR).spec
VERSION=$(MAJOR).$(MINOR).$(PATCH)
PKGNV=$(PKGNAME)-$(VERSION)

outdir ?= $(TOP)

SEDCMD = s/_TMPL_VER_MAJOR/$(MAJOR)/;s/_TMPL_VER_MINOR/$(MINOR)/;s/_TMPL_VER_PATCH/$(PATCH)/;s/_TMPL_VER_RELEASE/$(RELEASE)/

srpm:
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	cat $(PKGNAME).spec.tmpl | sed "$(SEDCMD)" > $(SPECFILE)
	cp -a patch.gthr-default.h.diff patch.stl_vector.h.diff $(SOURCEDIR)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)

clean:
	-rm -rf $(RPMTOPDIR) $(TOP)/*.rpm

.PHONY: srpm clean
