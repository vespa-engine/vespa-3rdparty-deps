# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=0
MINOR=0
PATCH=20240802
RELEASE=2
GITREF=12269c2761734b15625017d8565745096325392f

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/vespa-wireguard-go.spec

SUB1=s/_TMPL_VER_MAJOR/$(MAJOR)/
SUB2=s/_TMPL_VER_MINOR/$(MINOR)/
SUB3=s/_TMPL_VER_PATCH/$(PATCH)/
SUB4=s/_TMPL_VER_RELEASE/$(RELEASE)/
SUB5=s/_TMPL_GITREF/$(GITREF)/
SEDSUBS=$(SUB1);$(SUB2);$(SUB3);$(SUB4);$(SUB5)

srpm:
	dnf install -y rpmdevtools
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	cat vespa-wireguard-go.spec.tmpl | sed "$(SEDSUBS)" > $(SPECFILE)
	spectool -g -C $(SOURCEDIR) $(SPECFILE)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* ${outdir}
clean:
	-rm -rf $(RPMTOPDIR)

.PHONY: srpm clean
