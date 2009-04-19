#!/bin/sh
#
# (c) 2008, Tonnerre Lombard <tonnerre@NetBSD.org>,
#	    The NetBSD Foundation. All rights reserved.
#
# Redistribution and use  in source and binary forms,  with or without
# modification, are  permitted provided that  the following conditions
# are met:
#
# * Redistributions  of source  code must  retain the  above copyright
#   notice, this list of conditions and the following disclaimer.
# * Redistributions in binary form  must reproduce the above copyright
#   notice, this  list of conditions  and the following  disclaimer in
#   the  documentation  and/or   other  materials  provided  with  the
#   distribution.
# * Neither the name of the The NetBSD  Foundation nor the name of its
#   contributors may  be used to  endorse or promote  products derived
#   from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED  BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A  PARTICULAR PURPOSE ARE DISCLAIMED. IN  NO EVENT SHALL
# THE  COPYRIGHT  OWNER OR  CONTRIBUTORS  BE  LIABLE  FOR ANY  DIRECT,
# INDIRECT, INCIDENTAL,  SPECIAL, EXEMPLARY, OR  CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT  NOT LIMITED TO, PROCUREMENT OF  SUBSTITUTE GOODS OR
# SERVICES; LOSS  OF USE, DATA, OR PROFITS;  OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY  THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT  LIABILITY,  OR  TORT  (INCLUDING  NEGLIGENCE  OR  OTHERWISE)
# ARISING IN ANY WAY OUT OF  THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#
# $patchadd$
#

## Basic definitions

PREFIX="/usr/pkg"
LOCALSTATEDIR="/var"
DBDIR="${LOCALSTATEDIR}/db/patches"
BASENAME="/usr/bin/basename"

## Actual code

usage() {
	echo "$0 <patch-id>" 1>&2
	exit 1
}

if [ -z "$@" ]
then
	for patch in ${DBDIR}/*
	do
		[ -d "${patch}" ] || continue
		if [ -f "${patch}/+INFO" ]
		then
			COMMENT=`awk -F= '/^COMMENT=/ { print $2 }' "${patch}/+INFO"`
			NAME=`awk -F= '/^NAME=/ { print $2 }' "${patch}/+INFO"`
			echo "${NAME}	${COMMENT}"
		else
			NAME=`"${BASENAME}" "${patch}"`
			echo "${NAME}	(no information available)"
		fi
	done
else
	for patch in $@
	do
		# Check if the patch is actually installed. In the C version,
		# there will even be locking...
		if [ ! -f "${DBDIR}/${patch}/+COMMENT" ]
		then
			echo "Patch ${patch} is not installed." 1>&2
			continue
		fi

		echo "Information for ${patch}:"
		echo
		echo "Comment:"
		cat "${DBDIR}/${patch}/+COMMENT"

		if [ ! -f "${DBDIR}/${patch}/+CONTENTS" ]
		then
			echo "Warning: Patch ${patch} does not contain backout information." 1>&2
			continue
		fi

		echo
		echo "Short comment:"
		awk -F= '/^COMMENT=/ { print $2 }' "${DBDIR}/${patch}/+INFO"
		echo
		echo "Files:"
		echo
		awk '{ print $1 }' "${DBDIR}/${patch}/+CONTENTS"
	done
fi

exit 0