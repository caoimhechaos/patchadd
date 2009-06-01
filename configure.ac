#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.63])
AC_INIT([patchadd], [0.1], [caoimhechaos@protonmail.com])
AM_INIT_AUTOMAKE(patchadd, 0.1)
AC_CONFIG_SRCDIR([fetchpatchlist.c])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC
AC_PROG_AWK
AC_PROG_INSTALL
AC_PROG_LEX
AC_PROG_YACC

# Checks for libraries.
AC_SEARCH_LIBS([db_create], [db-4 db4 db])
AC_SEARCH_LIBS([fetchGet], [fetch])
AC_SEARCH_LIBS([netpgp_init], [netpgp])
AC_CHECK_LIB([l], [main], [LIBS="$LIBS -ll"])
AC_CHECK_LIB([y], [main], [LIBS="$LIBS -ly"])

# Checks for header files.
AC_CHECK_HEADERS([limits.h stdlib.h unistd.h fetch.h db4/db4.h db4/db.h db4.h db.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CHECK_FUNCS([getcwd uname])

AC_CONFIG_FILES([Makefile provider/Makefile])
AC_OUTPUT
