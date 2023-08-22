# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=0
MINOR=0
PATCH=20230223
RELEASE=1

GO_TAG=go1.19.12

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/vespa-wireguard-go.spec

SUB1=s/_TMPL_VER_MAJOR/$(MAJOR)/
SUB2=s/_TMPL_VER_MINOR/$(MINOR)/
SUB3=s/_TMPL_VER_PATCH/$(PATCH)/
SUB4=s/_TMPL_VER_RELEASE/$(RELEASE)/
SUB5=s/_TMPL_GO_TAG/$(GO_TAG)/
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
