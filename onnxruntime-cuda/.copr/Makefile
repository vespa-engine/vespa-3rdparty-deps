# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=1
MINOR=13
PATCH=1
RELEASE=1

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
PKGNAME=vespa-onnxruntime-cuda
PKGNV=$(PKGNAME)-$(VERSION)
SPECFILE=$(SPECDIR)/$(PKGNAME).spec
VERSION=$(MAJOR).$(MINOR).$(PATCH)
SRCBASE=$(TOP)/../src

outdir ?= $(TOP)

SEDCMD = s/_TMPL_VER_MAJOR/$(MAJOR)/;s/_TMPL_VER_MINOR/$(MINOR)/;s/_TMPL_VER_PATCH/$(PATCH)/;s/_TMPL_VER_RELEASE/$(RELEASE)/

srpm:
	rpm -q rpmdevtools || dnf install -y rpmdevtools
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	tar --transform 's/[.]/$(PKGNV)/' -C $(SRCBASE) -czf $(SOURCEDIR)/$(PKGNV).tar.gz .
	cat $(TOP)/../$(PKGNAME).spec.tmpl | sed "$(SEDCMD)" > $(SPECFILE)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)

clean:
	-rm -rf $(RPMTOPDIR)
	-rm -f $(TOP)/*.rpm

.PHONY: srpm clean
