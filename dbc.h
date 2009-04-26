#if defined(HAVE_DB4_DB4_H)
#include <db4/db4.h>
#elif defined(HAVE_DB4_DB_H)
#include <db4/db.h>
#elif defined(HAVE_DB4_H)
#include <db4.h>
#elif defined(HAVE_DB_H)	/* This may be the wrong libdb */
#include <db.h>
#else
#error "Could not determine libdb4 include!"
#endif


/**
 * A connection handle for abstract access to the patch database.
 */
struct db_connection
{
	DB_ENV *env;
	DB_TXN *tid;
	DB *p; 
};

extern int dbc_open(char *dbname, struct db_connection *dbc);
extern void dbc_abort(struct db_connection *dbc);
extern void dbc_done(struct db_connection *dbc);
extern int dbc_sync(struct db_connection *dbc, struct binpatch *patch);

static inline int
dbc_open_fetchlist(struct db_connection *dbc)
{
	return dbc_open(PATCHLIST_DB, dbc);
}

static inline int
dbc_open_installed(struct db_connection *dbc)
{
	return dbc_open(INSTALLED_DB, dbc);
}
