# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=1
MINOR=13
PATCH=1
RELEASE=4
PKGNAME=vespa-onnxruntime

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/$(PKGNAME).spec
VERSION=$(MAJOR).$(MINOR).$(PATCH)
SRCTMPBASE=$(TOP)/tmp
SRCTMP_VENDOR=$(SRCTMPBASE)/onnxruntime
PKGNV=$(PKGNAME)-$(VERSION)
SRCTMP=$(SRCTMPBASE)/$(PKGNV)

outdir ?= $(TOP)

SEDCMD = s/_TMPL_VER_MAJOR/$(MAJOR)/;s/_TMPL_VER_MINOR/$(MINOR)/;s/_TMPL_VER_PATCH/$(PATCH)/;s/_TMPL_VER_RELEASE/$(RELEASE)/

srpm:
	rpm -q rpmdevtools || dnf install -y rpmdevtools
	rpm -q git || dnf install -y git
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	mkdir -p $(SRCTMPBASE)
	cd $(SRCTMPBASE) && (cd onnxruntime && git fetch -p) || git clone https://github.com/microsoft/onnxruntime.git onnxruntime
	cd $(SRCTMP_VENDOR) && git checkout v$(VERSION) && git clean -fxd
ifdef SUBMODULE_CHECKOUT_SCRIPT
	cd $(SRCTMP_VENDOR) && $(SUBMODULE_CHECKOUT_SCRIPT)
else
	cd $(SRCTMP_VENDOR) && git submodule sync --recursive
	cd $(SRCTMP_VENDOR) && git submodule update --init --recursive
endif
	rm -rf $(SRCTMP)
	mkdir -p $(SRCTMP)
	cd $(SRCTMP_VENDOR) && git archive --format=tar HEAD | tar -C $(SRCTMP) -xf -
	set -e; cd $(SRCTMP_VENDOR) && git submodule status --recursive | cut -d ' ' -f 3 | while read sm_path; do mkdir -p $(SRCTMP)/$$sm_path; ( cd $$sm_path && git archive --format=tar HEAD | tar -C $(SRCTMP)/$$sm_path -xf -); done
	tar -C $(SRCTMPBASE) -czf $(SOURCEDIR)/$(PKGNV).tar.gz $(PKGNV)
	cat $(PKGNAME).spec.tmpl | sed "$(SEDCMD)" > $(SPECFILE)
	cp -a *.diff $(SOURCEDIR)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)

clean:
	-rm -rf $(RPMTOPDIR) $(SRCTMPBASE) $(TOP)/*.rpm

.PHONY: srpm clean
