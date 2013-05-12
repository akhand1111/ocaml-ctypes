OCAMLMAKEFILE = OCamlMakefile

.PHONY: all
all: ncl bcl
	@ :
	
-include Makefile.config

SOURCE_FILES := unsigned.mli unsigned.ml ffi_raw.ml dl.mli dl.ml \
		ffi.mli ffi.ml unsigned_stubs.c ffi_stubs.c dl_stubs.c

SOURCES = $(SOURCE_FILES:%=src/%)
RESULT  = ctypes
PACKS   = unix
LIB_PACK_NAME = ctypes
LIBINSTALL_FILES = src/META ctypes.a ctypes.cmo ctypes.cmx ctypes.cmi ctypes.cmxa ctypes.o ctypes.cma dll*.so libctypes_stubs.a

include $(OCAMLMAKEFILE)

runtop: ctypes.top
	./$< -I src

autoconf:
	aclocal -I m4
	autoconf
