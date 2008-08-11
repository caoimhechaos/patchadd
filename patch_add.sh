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
# $patchadd: patch_add.sh,v 1.3 2008/08/10 22:24:49 tonnerre Exp $
#

## Basic definitions

PREFIX="/usr/pkg"
LOCALSTATEDIR="/var"
DBDIR="${LOCALSTATEDIR}/db/patches"
SPOOLDIR="${LOCALSTATEDIR}/spool/patches"
ARCH=`uname -m`
VERS=`uname -r`
PATCHSITE="ftp://ftp.netbsd.org/pub/NetBSD/misc/tonnerre/binpatches/${ARCH}/${VERS}"
FETCH="/usr/bin/ftp"
OPENSSL="/usr/bin/openssl"
TAR="/bin/tar"
OSABI=`uname -s`
BSPATCH="/usr/pkg/bin/bspatch"
BASENAME="/usr/bin/basename"
CP="/bin/cp"
MV="/bin/mv"
RM="/bin/rm"
PAX="/bin/pax"
MKDIR="/bin/mkdir"

## Actual code

usage() {
	echo "$0 [-dfr] <patch-id>" 1>&2
	echo 1>&2
	echo "    -d" 1>&2
	echo "\tOnly download the patches, don't install them." 1>&2
	echo "    -f" 1>&2
	echo "\tForce installation even if sanity checks fail." 1>&2
	echo "    -r" 1>&2
	echo "\tDon't save the backout information for the patch." 1>&2
	exit 1
}

fetch() {
	echo "Fetching $1 ..." 1>&2
	"${MKDIR}" -p "${SPOOLDIR}"
	(cd "${SPOOLDIR}" && "${FETCH}" "$1")
}

args=`getopt dfr $*`
[ $? -eq 0 ] || usage

set -- $args

DOWNLOAD=0
BACKOUT=1
FORCE=0
PATCHES=""

while [ $# -gt 0 ]
do
	case "$1" in
		-d)
			DOWNLOAD=1
			;;
		-f)
			FORCE=1
			;;
		-r)
			BACKOUT=0
			;;
		--)
			shift; break
			;;
	esac
	shift
done

for patch in $@
do
	[ -f "${SPOOLDIR}/${patch}.tbz.sig" ] || fetch "${PATCHSITE}/${patch}.tbz.sig"
	"${OPENSSL}" smime -verify -content "${SPOOLDIR}/${patch}.tbz"	\
		-in "${SPOOLDIR}/${patch}.tbz.sig" -inform PEM -signer	\
		"${SPOOLDIR}/testkey.pem" -noverify >> /dev/null ||	\
		fetch "${PATCHSITE}/${patch}.tbz"

	if ! "${OPENSSL}" smime -verify -content "${SPOOLDIR}/${patch}.tbz" \
		-in "${SPOOLDIR}/${patch}.tbz.sig" -inform PEM -signer	\
		"${DBDIR}/testkey.pem" -noverify >> /dev/null
	then
		echo "Unable to fetch ${patch}" 1>&2
		continue
	fi

	if [ "${DOWNLOAD}" = 1 ]
	then
		echo "${patch} downloaded successfully." 1>&2
		continue
	fi

	TMPDIR=`mktemp -d -t patchadd-XXXXXX`
	(cd "${TMPDIR}" && "${TAR}" jxpf "${SPOOLDIR}/${patch}.tbz")

	# Now check the +INFO file so we don't install stupidities
	PATCHABI=`grep ^ABI= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`
	PATCHOS=`grep ^OS_VERSION= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`
	PATCHARCH=`grep ^MACHINE_ARCH= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`
	PATCHTOOLS=`grep ^PATCHTOOLS= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`
	PATCHNAME=`grep ^NAME= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`
	PATCHDEPS=`grep ^DEPENDS= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`

	if [ "${PATCHABI}" != "${OSABI}" ]
	then
		echo "Patch ABI mismatch: ${OSABI}, should be ${PATCHABI}." 1>&2
		[ "${FORCE}" = 1 ] || "${RM}" -fr "${TMPDIR}"
		[ "${FORCE}" = 1 ] || continue
	fi
	if [ "${PATCHOS}" != "${VERS}" ]
	then
		echo "Patch OS version mismatch: ${VERS}, should be ${PATCHOS}." 1>&2
		[ "${FORCE}" = 1 ] || "${RM}" -fr "${TMPDIR}"
		[ "${FORCE}" = 1 ] || continue
	fi
	if [ "${PATCHARCH}" != "${ARCH}" ]
	then
		echo "Patch OS version mismatch: ${ARCH}, should be ${PATCHARCH}." 1>&2
		[ "${FORCE}" = 1 ] || "${RM}" -fr "${TMPDIR}"
		[ "${FORCE}" = 1 ] || continue
	fi
	if [ "${PATCHTOOLS}" != "0.1" ]
	then
		echo "Patch tools version mismatch: 0.1, should be ${PATCHTOOLS}." 1>&2
		[ "${FORCE}" = 1 ] || "${RM}" -fr "${TMPDIR}"
		[ "${FORCE}" = 1 ] || continue
	fi

	# Check if the patch is actually installed. In the C version, there
	# will even be locking...
	if [ -f "${DBDIR}/${PATCHNAME}/+COMMENT" ]
	then
		echo "Patch ${PATCHNAME} already installed." 1>&2
		"${RM}" -fr "${TMPDIR}"
		continue
	fi

	if [ "${patch}" != "${PATCHNAME}" ]
	then
		"${MV}" "${SPOOLDIR}/${patch}.tbz.sig" "${SPOOLDIR}/${PATCHNAME}.tbz.sig"
		"${MV}" "${SPOOLDIR}/${patch}.tbz" "${SPOOLDIR}/${PATCHNAME}.tbz"
	fi

	PATCHES="${PATCHES} ${PATCHDEPS} ${PATCHNAME}"
	"${RM}" -fr "${TMPDIR}"
done

[ "${DOWNLOAD}" = 1 ] && exit 0

for patch in ${PATCHES}
do
	TMPDIR=`mktemp -d -t patchadd-XXXXXX`
	(cd "${TMPDIR}" && "${TAR}" jxpf "${SPOOLDIR}/${patch}.tbz")

	# Now check the +INFO file so we don't install stupidities
	PATCHABI=`grep ^ABI= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`
	PATCHOS=`grep ^OS_VERSION= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`
	PATCHARCH=`grep ^MACHINE_ARCH= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`
	PATCHTOOLS=`grep ^PATCHTOOLS= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`
	PATCHNAME=`grep ^NAME= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`
	PATCHDEPS=`grep ^DEPENDS= "${TMPDIR}/+INFO" | awk -F= '{ print $2 }'`

	if [ "${PATCHABI}" != "${OSABI}" ]
	then
		echo "Patch ABI mismatch: ${OSABI}, should be ${PATCHABI}." 1>&2
		[ "${FORCE}" = 1 ] || "${RM}" -fr "${TMPDIR}"
		[ "${FORCE}" = 1 ] || continue
	fi
	if [ "${PATCHOS}" != "${VERS}" ]
	then
		echo "Patch OS version mismatch: ${VERS}, should be ${PATCHOS}." 1>&2
		[ "${FORCE}" = 1 ] || "${RM}" -fr "${TMPDIR}"
		[ "${FORCE}" = 1 ] || continue
	fi
	if [ "${PATCHARCH}" != "${ARCH}" ]
	then
		echo "Patch OS version mismatch: ${ARCH}, should be ${PATCHARCH}." 1>&2
		[ "${FORCE}" = 1 ] || "${RM}" -fr "${TMPDIR}"
		[ "${FORCE}" = 1 ] || continue
	fi
	if [ "${PATCHTOOLS}" != "0.1" ]
	then
		echo "Patch tools version mismatch: 0.1, should be ${PATCHTOOLS}." 1>&2
		[ "${FORCE}" = 1 ] || "${RM}" -fr "${TMPDIR}"
		[ "${FORCE}" = 1 ] || continue
	fi

	# Check if the patch is actually installed. In the C version, there
	# will even be locking...
	if [ -f "${DBDIR}/${PATCHNAME}/+COMMENT" ]
	then
		echo "Patch ${PATCHNAME} already installed." 1>&2
		"${RM}" -fr "${TMPDIR}"
		continue
	fi

	while read BIN PATCH ORIGSUM NEWSUM
	do
		if ! echo "SHA1 (${BIN}) = ${ORIGSUM}" | cksum -c
		then
			if echo "SHA1 (${BIN}) = ${NEWSUM}" | cksum -c
			then
				echo "Warning: File ${BIN} already patched, skipping..." 1>&2
				continue
			fi

			echo "Warning: File ${BIN} not in requested state." 1>&2
		fi

		LOCALFILE=`"${BASENAME}" "${BIN}"`
		"${CP}" "${BIN}" "${TMPDIR}/${LOCALFILE}.orig"
		"${BSPATCH}" "${TMPDIR}/${LOCALFILE}.orig" "${BIN}" "${TMPDIR}/${PATCH}" || echo "Applying patch failed for ${BIN}" 1>&2

		if ! echo "SHA1 (${BIN}) = ${NEWSUM}" | cksum -c
		then
			echo "Warning: File ${BIN} not in desired state after patch." 1>&2
			continue
		fi
	done < "${TMPDIR}/+CONTENTS"

	# Save information required to back out the patch.
	"${MKDIR}" -p "${DBDIR}/${PATCHNAME}"
	[ "${BACKOUT}" = 1 ] && "${PAX}" -rw -pe "${TMPDIR}/." "${DBDIR}/${PATCHNAME}/."
	[ "${BACKOUT}" = 0 ] && "${CP}" "${TMPDIR}/+COMMENT" "${DBDIR}/${PATCHNAME}"
	"${RM}" -fr "${TMPDIR}"
done

exit 0
