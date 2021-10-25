# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=20210801
MAJOR_LONG=2021-08-01
RELEASE=2

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/vespa-re2.spec

srpm:
	dnf install -y rpmdevtools
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	cat vespa-re2.spec.tmpl | sed "s/_TMPL_VER_MAJOR$$/$(MAJOR)/" | sed "s/_TMPL_VER_MAJOR_LONG/$(MAJOR_LONG)/" | sed "s/_TMPL_VER_RELEASE/$(RELEASE)/" > $(SPECFILE)
	spectool -g -C $(SOURCEDIR) $(SPECFILE)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)
clean:
	-rm -rf $(RPMTOPDIR)

.PHONY: srpm clean
