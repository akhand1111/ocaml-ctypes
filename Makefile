CFLAGS=-fPIC -O3 -Wall
PATH := .:$(PATH)

all: build

setup.ml: _oasis
	oasis setup

setup.data: setup.ml
	ocaml setup.ml -configure --enable-tests

build: setup.data setup.ml ctestlib
	ocaml setup.ml -build

install: setup.data setup.ml
	ocaml setup.ml -install

test: setup.ml build ctestlib generated_stubs
	ocaml setup.ml -test -verbose

distclean: setup.ml
	ocaml setup.ml -distclean
	rm -f tests/clib/test_functions.so tests/clib/test_functions.o

clean: setup.ml
	ocaml setup.ml -clean
	rm -f tests/clib/test_functions.so tests/clib/test_functions.o

doc: setup.ml setup.data
	ocaml setup.ml -doc

ctestlib: tests/clib/test_functions.so

tests/clib/test_functions.so: tests/clib/test_functions.o
	cd tests/clib && cc -O3 -shared -o test_functions.so test_functions.o

generated_stubs: stubtests/generated_stubs.ml 

stubtests/generated_stubs.ml: stub_generator
	$< > $@

stub_generator: stubtests/stub_generator.c
	$(CC) -I. -std=c99 -pedantic -Wall -o $@ $<

stubtests/stub_generator.c: generate_stubs.native
	$< > $@

generate_stubs.native: 
	ocamlbuild stubtests/generate_stubs.native

.PHONY:	generate_stubs.native
