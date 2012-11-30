OOC?=rock
OOCFLAGS:=$(shell llvm-config --cflags --ldflags --libs core executionengine jit interpreter native) -v --linker=g++ +-DNDEBUG +-D_GNU_SOURCE +-D__STDC_LIMIT_MACROS +-D__STDC_CONSTANT_MACROS +-O3 +-fPIC +-fomit-frame-pointer

all: test exte

test:
	${OOC} $(OOCFLAGS) samples/test.ooc -o=samples/test

exte:
	${OOC} $(OOCFLAGS) samples/exte.ooc -o=samples/exte

clean:
	rm -rf *_tmp .libs samples/test samples/exte

.PHONY: clean test
