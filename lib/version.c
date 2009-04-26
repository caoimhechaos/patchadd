#include <patchadd.h>
#include <dbc.h>

int32_t strvers(const char *str)
{
	char *p;
	int32_t retlower;
	int32_t retval;

	if ((p = index(str, '.')))
	{
		*p = '\0';
		retval = atol(str) << 16;
		retlower = atol(p + 1);

		retval |= retlower;
	}
	else
		retval = atol(str) << 16;

	return retval;
}
