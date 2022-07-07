# Copyright 2019 Oath Inc. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=7
MINOR=4
PATCH=2
VERSION=$(MAJOR).$(MINOR).$(PATCH)
RELEASE=1

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/vespa-gradle.spec

SUB1=s/_TMPL_VER_MAJOR/$(MAJOR)/
SUB2=s/_TMPL_VER_MINOR/$(MINOR)/
SUB3=s/_TMPL_VER_PATCH/$(PATCH)/
SUB4=s/_TMPL_VER_RELEASE/$(RELEASE)/
SEDSUBS=$(SUB1);$(SUB2);$(SUB3);$(SUB4)

srpm:
	rpm -q rpmdevtools || dnf install -y rpmdevtools
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	sed 's/_TMPL_VERSION/$(VERSION)/' < script.sh > $(SOURCEDIR)/script.sh
	chmod 755 $(SOURCEDIR)/script.sh
	cat vespa-gradle.spec.tmpl | sed "$(SEDSUBS)" > $(SPECFILE)
	spectool -g -C $(SOURCEDIR) $(SPECFILE)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)

clean:
	-rm -rf $(RPMTOPDIR)

.PHONY: srpm clean
