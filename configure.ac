AC_INIT(ocaml-ctypes,1.0.0)
AC_COPYRIGHT(Copyright 2013 Jeremy Yallop)

AC_PREREQ([2.69])
AC_CONFIG_SRCDIR([src/dl_stubs.c])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])
AC_CANONICAL_HOST

dnl The system-installed libffi in Mountain Lion MacOS X doesn't include libffi_prep_closure.
dnl We check for Homebrew and fixup PKG_CONFIG to work by default.
dnl TODO a MacPorts check also
case $host in
*-*-darwin*)
  AC_PATH_PROG([HOMEBREW], [brew])
  if test "$HOMEBREW" != "" ; then
    FFI_VERSIONS=`$HOMEBREW ls libffi --versions`
    if test "$FFI_VERSIONS" = "" ; then
      AC_MSG_ERROR([You must 'brew install libffi' to get a more uptodate version than the system installed one.])
    else
      LIBFFI_PKGCONFIG_HINT=`echo $FFI_VERSIONS | awk '{print $NF}'`
      echo appending Homebrew libffi-${LIBFFI_PKGCONFIG_HINT} to PKG_CONFIG_PATH...
      PKG_CONFIG_PATH=/usr/local/Cellar/libffi/$LIBFFI_PKGCONFIG_HINT/lib/pkgconfig:$PKG_CONFIG_PATH
      export PKG_CONFIG_PATH
    fi
  fi
  ;;
*)
  ;;
esac

# Checks for programs.
AC_PROG_CC

# Checks for header files.
AC_CHECK_HEADERS([inttypes.h limits.h stddef.h stdint.h stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_INT16_T
AC_TYPE_INT32_T
AC_TYPE_INT64_T
AC_TYPE_INT8_T
AC_TYPE_SIZE_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT64_T
AC_TYPE_UINT8_T

# Checks for library functions.
AC_FUNC_ALLOCA
AC_FUNC_MALLOC
AC_FUNC_REALLOC

EFL_CHECK_DLOPEN

AC_PROG_OCAML
if test "$OCAMLC" = "no"; then
   AC_MSG_ERROR([You must install the OCaml compiler])
fi

AC_ARG_ENABLE([version_check],
  AS_HELP_STRING([--disable-version-check],
                 [Do not check OCaml version])
)

# Check that OCaml version is greater or equal to 3.12.1
AS_IF([test "x${enable_version_check}" != "xno"], [
  AX_COMPARE_VERSION(
    [$OCAMLVERSION], [lt], [3.12.1],
    AC_MSG_ERROR([Your version of OCaml: $OCAMLVERSION is not supported]))
])

dnl check for libffi

PKG_CHECK_MODULES([libffi], [libffi])
AC_DEFUN([FFI_CHECK_CLOSURE],
[
   AC_MSG_CHECKING([for ffi_prep_closure in libffi])
   CFLAGS_save="${CFLAGS}"
   CFLAGS="${CFLAGS} $libffi_CFLAGS"
   LIBS_save="${LIBS}"
   LIBS="${LIBS} -lffi $libffi_LIBS"
   AC_LINK_IFELSE(
      [AC_LANG_PROGRAM(
          [[
#include <ffi/ffi.h>
          ]],
          [[
ffi_prep_closure(NULL, NULL, NULL, NULL);
          ]])],
      [_ffi_have_closure="yes"],
      [_ffi_have_closure="no"])
   CFLAGS="${CFLAGS_save}"
   LIBS="${LIBS_save}"
   AC_MSG_RESULT([${_ffi_have_closure}])
])
FFI_CHECK_CLOSURE

AC_CONFIG_FILES(
  Makefile.config
)
AC_OUTPUT
