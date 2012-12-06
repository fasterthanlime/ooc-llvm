
OOC_FILES := $(wildcard samples/*.ooc)
TESTS := $(patsubst samples/%.ooc,samples/%,$(OOC_FILES))

all: $(TESTS)

samples/%: samples/%.ooc
	rock -v $(OOCFLAGS) $< -o=$@

clean:
	rm -rf *_tmp .libs $(TESTS)

.PHONY: clean test
