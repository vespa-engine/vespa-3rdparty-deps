#!/bin/sh
# Copyright Yahoo. Licensed under the terms of the Apache 2.0 license. See LICENSE in the project root.

version=_TMPL_VERSION

gdir=/opt/vespa-deps/lib/gradle-${version}
jdir=/usr/lib/jvm/java-11-openjdk

PATH=${gdir}/bin:${jdir}/bin:${PATH}

export JAVA_OPTS='--add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED
                  --add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED'

mkdir -p $HOME/tmp
exec ${gdir}/bin/gradle -Djava.io.tmpdir=$HOME/tmp "$@"
