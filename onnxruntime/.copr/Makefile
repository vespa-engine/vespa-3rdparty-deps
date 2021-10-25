# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.
TOP = $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

# Version
MAJOR=1
MINOR=7
PATCH=1
RELEASE=2

RPMTOPDIR=$(TOP)/rpmbuild
SOURCEDIR=$(RPMTOPDIR)/SOURCES
SPECDIR=$(RPMTOPDIR)/SPECS
SPECFILE=$(SPECDIR)/vespa-onnxruntime.spec
VERSION=$(MAJOR).$(MINOR).$(PATCH)
SRCTMPBASE=$(TOP)/tmp
SRCTMP_VENDOR=$(SRCTMPBASE)/onnxruntime
SRCTMP=$(SRCTMPBASE)/vespa-onnxruntime-$(VERSION)

srpm:
	dnf install -y rpmdevtools
	dnf install -y git
	mkdir -p $(SPECDIR) $(SOURCEDIR)
	rm -rf $(SRCTMPBASE)
	mkdir -p $(SRCTMPBASE)
	cd $(SRCTMPBASE) && git clone https://github.com/microsoft/onnxruntime.git onnxruntime
	cd $(SRCTMP_VENDOR) && git checkout v$(VERSION)
ifdef SUBMODULE_CHECKOUT_SCRIPT
	cd $(SRCTMP_VENDOR) && $(SUBMODULE_CHECKOUT_SCRIPT)
else
	cd $(SRCTMP_VENDOR) && git submodule sync --recursive
	cd $(SRCTMP_VENDOR) && git submodule update --init --recursive
endif
	mkdir -p $(SRCTMP)
	cd $(SRCTMP_VENDOR) && git archive --format=tar HEAD | tar -C $(SRCTMP) -xf -
	set -e; cd $(SRCTMP_VENDOR) && git submodule status --recursive | cut -d ' ' -f 3 | while read sm_path; do mkdir -p $(SRCTMP)/$$sm_path; ( cd $$sm_path && git archive --format=tar HEAD | tar -C $(SRCTMP)/$$sm_path -xf -); done
	tar -C $(SRCTMPBASE) -czf $(SOURCEDIR)/vespa-onnxruntime-$(VERSION).tar.gz vespa-onnxruntime-$(VERSION)
	rm -rf $(SRCTMPBASE)
	cat vespa-onnxruntime.spec.tmpl | sed "s/_TMPL_VER_MAJOR/$(MAJOR)/" | sed "s/_TMPL_VER_MINOR/$(MINOR)/" | sed "s/_TMPL_VER_PATCH/$(PATCH)/" | sed "s/_TMPL_VER_RELEASE/$(RELEASE)/" > $(SPECFILE)
	cp -a *.diff $(SOURCEDIR)
	rpmbuild -bs --define "_topdir $(RPMTOPDIR)" $(SPECFILE)
	cp -a $(RPMTOPDIR)/SRPMS/* $(outdir)
clean:
	-rm -rf $(RPMTOPDIR)

.PHONY: srpm clean
