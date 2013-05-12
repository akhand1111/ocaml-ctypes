OCAMLMAKEFILE = OCamlMakefile

-include Makefile.config

SOURCE_FILES := ffi_raw.ml unsigned.mli unsigned.ml dl.mli dl.ml \
		ffi.mli ffi.ml unsigned_stubs.c ffi_stubs.c dl_stubs.c

SOURCES = $(SOURCE_FILES:%=src/%)
RESULT  = ctypes

include $(OCAMLMAKEFILE)

autoconf:
	aclocal -I m4
	autoconf
