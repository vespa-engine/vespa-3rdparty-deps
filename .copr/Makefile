# Copyright Vespa.ai. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

srpm:
	make -f "$(spec)/.copr/Makefile" srpm outdir="$(outdir)" spec="$(spec)"
clean:
	make -f "$(spec)/.copr/Makefile" clean outdir="$(outdir)" spec="$(spec)"

.PHONY: srpm clean
