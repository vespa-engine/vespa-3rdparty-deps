# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

VERSION = 1.13.1
LIBDIR = /opt/vespa-deps/lib64
NATDIR = ai/onnxruntime/native/linux-x64
PROVLIB = libonnxruntime_providers_cuda.so

install: sofiles
	mkdir -p $(DESTDIR)$(LIBDIR)
	install -v $(NATDIR)/$(PROVLIB) $(DESTDIR)$(LIBDIR)

sofiles:
	mvn dependency:copy -Dartifact=com.microsoft.onnxruntime:onnxruntime_gpu:$(VERSION):jar -Dproject.basedir=.
	rm -rf ai
	unzip target/dependency/onnxruntime_gpu-$(VERSION).jar $(NATDIR)/\*
