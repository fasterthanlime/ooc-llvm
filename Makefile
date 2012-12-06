
OOC_FILES := $(wildcard samples/*.ooc)
TESTS := $(patsubst samples/%.ooc,samples/%,$(OOC_FILES))

all: tests

tests: $(TESTS)

samples/%: samples/%.ooc
	rock -v $(OOCFLAGS) $< -o=$@

clean:
	rm -rf *_tmp .libs $(TESTS)

run-tests: tests
	@for test in $(TESTS);\
	do \
	  $$test; \
	done

.PHONY: clean
