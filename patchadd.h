#ifdef HAVE_CONFIG_H
#include <config.h>
#endif
#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif
#ifdef HAVE_INTTYPES_H
#include <inttypes.h>
#endif
#ifdef HAVE_LIMITS_H
#include <limits.h>
#endif
#ifdef HAVE_MEMORY_H
#include <memory.h>
#endif
#ifdef HAVE_STDINT_H
#include <stdint.h>
#endif
#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif
#ifdef HAVE_STRINGS_H
#include <strings.h>
#endif
#ifdef HAVE_STRING_H
#include <string.h>
#endif
#ifdef HAVE_SYS_STAT_H
#include <sys/stat.h>
#endif
#ifdef HAVE_FETCH_H
#include <fetch.h>
#endif

#define MK_VERSION(x,y)	(x << 16 | y)

/***************************************************************************
 * Data structures
 **************************************************************************/

/**
 * All of the global information associated with a patch.
 */
struct binpatch
{
	char *		name;
};

/***************************************************************************
 * Prototypes
 **************************************************************************/

/* The global fetchIO handle for use in the parsers. */
extern fetchIO *fio;

/* The version of the file currently being parsed. */
extern char *patchfile_version;

/* Convert string to version number. */
extern int32_t strvers(const char *str);

/***************************************************************************
 * Program wide definitions.
 ***************************************************************************
 * XXX: Some of these defines will ultimately end up in a config file.
 */

/**
 * The name of the file which is supposed to contain the patch
 * directory index.
 */
#ifndef PATCHLIST_NAME
#define	PATCHLIST_NAME	"patchindex"
#endif
#ifndef PATCHLIST_DB
#define	PATCHLIST_DB	"patchindex.db"
#endif

/**
 * The file name of the database of installed packages.
 */
#ifndef INSTALLED_DB
#define	INSTALLED_DB	"installed.db"
#endif

/**
 * The directory containing the patch index database as well as the
 * installed patch list.
 */
#ifndef DB_DIR
#define	DB_DIR	"/var/db/patches"
#endif

/**
 * The base URL where patches can be found.
 */
#ifndef PATCHSITE_URL
#define PATCHSITE_URL	"ftp://ftp.netbsd.org/pub/NetBSD/misc/tonnerre/binpatches/"
#endif

/**
 * The maximum supported version.
 */
#ifndef VERSION_SUPPORTED
#define VERSION_SUPPORTED MK_VERSION(0, 1)
#endif
