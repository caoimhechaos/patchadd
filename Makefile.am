bin_PROGRAMS=	fetchpatchlist
fetchpatchlist_SOURCES=	fetchpatchlist.c lib/dbc.c lib/patchlist.y lib/patchlist.l lib/version.c
fetchpatchlist_YFLAGS=	-d

SUBDIRS=	provider

CLEANFILES=	__db.* log.* patchindex.db *~ fetchpatchlist-patchlist.c
CLEANFILES+=	fetchpatchlist-patchlist.h patchlist.c
