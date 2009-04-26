#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/utsname.h>

#include <fetch.h>

#include <patchadd.h>
#include <dbc.h>

fetchIO *fio;
char *patchfile_version = NULL;

int main(int argc, char **argv)
{
	struct db_connection dbc;
	struct utsname u;
	struct url *uo;
	char *url;

	if (dbc_open_fetchlist(&dbc))
		exit(EXIT_FAILURE);

	if (uname(&u))
	{
		perror("uname");
		dbc_abort(&dbc);
		exit(EXIT_FAILURE);
	}

	/* Build patch directory URL. */
	if (asprintf(&url, "%s%s/%s/%s", PATCHSITE_URL, u.machine, u.release,
		PATCHLIST_NAME) < 0)
	{
		perror("asprintf");
		dbc_abort(&dbc);
		exit(EXIT_FAILURE);
	}

	/* Fetch the directory list. */
	uo = fetchParseURL(url);
	if (!uo)
	{
		fprintf(stderr, "Invalid URL: %s", url);
		free(url);
		dbc_abort(&dbc);
		exit(EXIT_FAILURE);
	}

	fio = fetchGet(uo, "");

	/* Reading fio is done by yacc. */
	yyparse();

	fetchIO_close(fio);

	fetchFreeURL(uo);
	free(url);
	dbc_done(&dbc);
	exit(EXIT_SUCCESS);
}
