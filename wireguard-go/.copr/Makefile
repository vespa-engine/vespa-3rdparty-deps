# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=0
MINOR=0
PATCH=20250522
RELEASE=2
GITREF=f333402bd9cbe0f3eeb02507bd14e23d7d639280

# The actual name for the generated package
PKGNAME=vespa-wireguard-go

outdir ?= $(TOP)
RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/$(PKGNAME).spec

SUB1=s/_TMPL_VER_MAJOR/$(MAJOR)/
SUB2=s/_TMPL_VER_MINOR/$(MINOR)/
SUB3=s/_TMPL_VER_PATCH/$(PATCH)/
SUB4=s/_TMPL_VER_RELEASE/$(RELEASE)/
SUB5=s/_TMPL_GITREF/$(GITREF)/
SEDCMD=$(SUB1);$(SUB2);$(SUB3);$(SUB4);$(SUB5)

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
