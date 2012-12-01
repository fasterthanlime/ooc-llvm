all: test exte

test:
	rock -v $(OOCFLAGS) samples/test.ooc -o=samples/test

exte:
	rock -v $(OOCFLAGS) samples/exte.ooc -o=samples/exte

clean:
	rm -rf *_tmp .libs samples/test samples/exte

.PHONY: clean test
