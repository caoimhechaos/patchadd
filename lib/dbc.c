#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <string.h>
#include <memory.h>
#include <patchadd.h>
#include <dbc.h>

/**
 * Open the database and return a handle to it. This method prints its
 * errors all by itself and returns 1 on failure and 0 on success.
 */
int dbc_open(char *dbname, struct db_connection *dbc)
{
	int db_err;

	/**
	 * Power up the database. This operation is slightly elaborate since
	 * we want transaction safety.
	 */
	if ((db_err = db_env_create(&dbc->env, 0)))
	{
		fprintf(stderr, "Error creating environment handle: %s\n",
			db_strerror(db_err));
		return 1;
	}

	if ((db_err = dbc->env->open(dbc->env, DB_DIR,
		DB_INIT_LOCK | DB_INIT_LOG | DB_INIT_MPOOL | DB_INIT_TXN |
		DB_CREATE, 0644)))
	{
		fprintf(stderr, "Error opening environment handle: %s\n",
			db_strerror(db_err));
		return 1;
	}

	if ((db_err = dbc->env->txn_begin(dbc->env, NULL, &dbc->tid,
		DB_READ_COMMITTED | DB_TXN_WAIT)))
	{
		fprintf(stderr, "Error creating transaction: %s\n",
			db_strerror(db_err));
		dbc->env->close(dbc->env, 0);
		return 1;
	}

	if ((db_err = db_create(&dbc->p, dbc->env, 0)))
	{
		fprintf(stderr, "Error creating database handle: %s\n",
			db_strerror(db_err));
		dbc->tid->abort(dbc->tid);
		dbc->env->close(dbc->env, 0);
		return 1;
	}

	if ((db_err = dbc->p->open(dbc->p, dbc->tid, dbname, NULL,
		DB_HASH, DB_CREATE, 0644)))
	{
		fprintf(stderr, "Error opening database: %s\n",
			db_strerror(db_err));
		dbc->tid->abort(dbc->tid);
		dbc->env->close(dbc->env, 0);
		return 1;
	}

	return 0;
}

/**
 * Abort the transaction.
 */
void dbc_abort(struct db_connection *dbc)
{
	dbc->p->close(dbc->p, 0);
	dbc->tid->abort(dbc->tid);
	dbc->env->close(dbc->env, 0);
}

/**
 * All work is done, commit the transaction.
 */
void dbc_done(struct db_connection *dbc)
{
	int db_err;
	dbc->p->close(dbc->p, 0);
	dbc->tid->commit(dbc->tid, DB_TXN_SYNC);
	dbc->env->close(dbc->env, 0);
}

/**
 * Sync the given patch to the database.
 */
int dbc_sync(struct db_connection *dbc, struct binpatch *patch)
{
	/* FIXME: STUB! */
	return 1;
}
