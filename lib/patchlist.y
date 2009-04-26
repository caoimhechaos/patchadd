%{
/*
 * (c) 2007, Tonnerre Lombard <tonnerre@bsdprojects.net>,
 *           BSD projects network. All rights reserved.
 *
 * Redistribution and use in source  and binary forms, with or without
 * modification, are permitted  provided that the following conditions
 * are met:
 *
 * * Redistributions of  source code  must retain the  above copyright
 *   notice, this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright
 *   notice, this  list of conditions and the  following disclaimer in
 *   the  documentation  and/or  other  materials  provided  with  the
 *   distribution.
 * * Neither the name of the BSD  projects network nor the name of its
 *   contributors may  be used to endorse or  promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS"  AND ANY EXPRESS  OR IMPLIED WARRANTIES  OF MERCHANTABILITY
 * AND FITNESS  FOR A PARTICULAR  PURPOSE ARE DISCLAIMED. IN  NO EVENT
 * SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL,  EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED  TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE,  DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT  LIABILITY,  OR  TORT  (INCLUDING NEGLIGENCE  OR  OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Patch list parser.
 */

#include <config.h>
#include <patchadd.h>
#include <dbc.h>
%}

%union {
	unsigned char *strval;
}

%token T_VERSION BEGINPATCH ENDPATCH EQUALS

%token <strval> QSTRING
%%
content:	version patchlist;

version:	T_VERSION QSTRING
		{ if (strvers($2) > VERSION_SUPPORTED) yyerror("Patch version not supported"); };

patchlist:	/* empty */
		| patchlist patch;

patch:		BEGINPATCH QSTRING patchdefs ENDPATCH
		{ patch_commit($2); free($2); };

patchdefs:	/* empty */
		| patchdefs patchdef;

patchdef:	QSTRING EQUALS QSTRING { patch_set($1, $3); };
%%
