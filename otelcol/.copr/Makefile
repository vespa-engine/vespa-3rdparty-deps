# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=0
MINOR=98
PATCH=0
VERSION=$(MAJOR).$(MINOR)
RELEASE=3

SNAM=otelcol
VNAM=vespa-$(SNAM)

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/$(VNAM).spec

outdir ?= $(TOP)

SUB1=s/_TMPL_VER_MAJOR/$(MAJOR)/
SUB2=s/_TMPL_VER_MINOR/$(MINOR)/
SUB3=s/_TMPL_VER_PATCH/$(PATCH)/
SUB4=s/_TMPL_VER_RELEASE/$(RELEASE)/
SEDSUBS=$(SUB1);$(SUB2);$(SUB3);$(SUB4)

srpm:
	rpm -q rpmdevtools || dnf install -y rpmdevtools
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	cp builder-config.yaml $(SOURCEDIR)
	cat $(VNAM).spec.tmpl | sed "$(SEDSUBS)" > $(SPECFILE)
	spectool -g -C $(SOURCEDIR) $(SPECFILE)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)

clean:
	-rm -rf $(RPMTOPDIR)

.PHONY: srpm clean
