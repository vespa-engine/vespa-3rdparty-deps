# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR_LONG=2025-11-05
RELEASE=4
MAJOR = $(subst -,,$(MAJOR_LONG))

# Note:
#
# Version above must be kept in sync with _vespa_re2_version in rpm
# spec files for vespa-grpc, vespa-opentelemetry-cpp,
# vespa-build-dependencies and vespa.

PKGNAME=vespa-re2
RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/$(PKGNAME).spec
SEDCMD = s/_TMPL_VER_MAJOR_LONG/$(MAJOR_LONG)/;s/_TMPL_VER_MAJOR/$(MAJOR)/;s/_TMPL_VER_RELEASE/$(RELEASE)/

outdir ?= $(TOP)

srpm:
	rpm -q rpmdevtools || dnf install -y rpmdevtools
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	cat $(PKGNAME).spec.tmpl | sed "$(SEDCMD)" > $(SPECFILE)
	spectool -g -C $(SOURCEDIR) $(SPECFILE)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)

clean:
	-rm -rf $(RPMTOPDIR)

.PHONY: srpm clean
