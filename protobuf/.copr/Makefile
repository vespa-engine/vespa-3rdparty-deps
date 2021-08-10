# Copyright 2019 Oath Inc. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=3
MINOR=14
PATCH=0
RELEASE=1

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/vespa-protobuf.spec

srpm:
	dnf install -y rpmdevtools
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	cat vespa-protobuf.spec.tmpl | sed "s/_TMPL_VER_MAJOR/$(MAJOR)/" | sed "s/_TMPL_VER_MINOR/$(MINOR)/" | sed "s/_TMPL_VER_PATCH/$(PATCH)/" | sed "s/_TMPL_VER_RELEASE/$(RELEASE)/" > $(SPECFILE)
	spectool -g -C $(SOURCEDIR) $(SPECFILE)
	cp -a *.diff $(SOURCEDIR)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)
clean:
	-rm -rf $(RPMTOPDIR)

.PHONY: srpm clean
