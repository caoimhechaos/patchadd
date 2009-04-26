#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.63])
AC_INIT([patchadd], [0.01-durchstich], [caoimhechaos@protonmail.com])
AM_INIT_AUTOMAKE(patchadd, 0.1-durchstich)
AC_CONFIG_SRCDIR([fetchpatchlist.c])
AC_CONFIG_HEADERS([config.h])

# Checks for programs.
AC_PROG_CC
AC_PROG_AWK
AC_PROG_INSTALL
AC_PROG_LEX
AC_PROG_YACC
AC_PATH_PROG([FTP], [ftp], [])
AC_PATH_PROG([WGET], [wget], [])
AC_PATH_PROG([CURL], [curl], [])

if test x"$FTP" = x
then
	if test x"$WGET" = x
	then
		if test x"$CURL"
		then
			AC_ERROR([No supported fetch program found.])
		else
			FETCH="$CURL -O"
		fi
	else
		FETCH="$WGET"
	fi
else
	FETCH="$FTP"
fi
AC_SUBST(FETCH)

AC_PATH_PROG([OPENSSL], [openssl], [])
if test x"$OPENSSL" = x
then
	AC_ERROR([OpenSSL is required.])
fi

AC_PATH_PROGS([TAR], [tar star gtar minitar], [])
if test x"$TAR" = x
then
	AC_ERROR([Some type of tar is required.])
fi

AC_PATH_PROG([BSPATCH], [bspatch], [])
if test x"$BSPATCH" = x
then
	AC_ERROR([bspatch is required.])
fi

AC_PATH_PROG([BASENAME], [basename], [])
if test x"$BASENAME" = x
then
	AC_ERROR([basename is required.])
fi

AC_PATH_PROG([CP], [cp], [])
if test x"$CP" = x
then
	AC_ERROR([cp is required.])
fi

AC_PATH_PROG([MV], [mv], [])
if test x"$MV" = x
then
	AC_ERROR([mv is required.])
fi

AC_PATH_PROG([RM], [rm], [])
if test x"$RM" = x
then
	AC_ERROR([rm is required.])
fi

AC_PATH_PROG([PAX], [pax], [])
if test x"$PAX" = x
then
	AC_ERROR([pax is required.])
fi

AC_PATH_PROG([CMD_MKDIR], [mkdir], [])
if test x"$CMD_MKDIR" = x
then
	AC_ERROR([mkdir is required.])
fi
AC_SUBST(CMD_MKDIR)

# Checks for libraries.
AC_SEARCH_LIBS([db_create], [db-4 db4 db])
AC_SEARCH_LIBS([fetchGet], [fetch])
AC_CHECK_LIB([l], [main], [LIBS="$LIBS -ll"])
AC_CHECK_LIB([y], [main], [LIBS="$LIBS -ly"])

# Checks for header files.
AC_CHECK_HEADERS([limits.h stdlib.h unistd.h fetch.h db4/db4.h db4/db.h db4.h db.h])

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.
AC_CHECK_FUNCS([getcwd uname])

AC_CONFIG_FILES([Makefile patch_add patch_delete patch_info])
AC_OUTPUT
