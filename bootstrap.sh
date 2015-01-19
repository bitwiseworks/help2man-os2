#!/bin/sh

# This script creates files necessary to configure help2man when the
# source tree is checked out from VCS.
#
# The steps are borrowed from debian/rules (main-prep target) since
# this is where they originate from.
#
# This script requires sed (and also gnu make and some other gnu text utils).

die()
{
    echo "ERROR: $1"
    exit 1
}

run()
{
    "$@"
    local rc=$?
    if test $rc != 0 ; then
        echo "ERROR: The following command failed with error code $rc:"
        echo $@
        exit $rc
    fi
}

DEBIAN_RULES="debian/rules"

test -f "$DEBIAN_RULES" || die "Cannot find '$DEBIAN_RULES'."

run sed -n '/# maintainer pre-release setup/{:a;n;/maint-clean: maint-prep/b;p;ba}' \
    "$DEBIAN_RULES" > bootstrap.mak

run sed \
    -e '/^	\(test `dpkg-parsechangelog\)/d' \
    -e '/^	\(.\/configure\)/d' \
    -e '/^	\($(MAKE)\)/d' \
    -i bootstrap.mak

# OS/2 hot fix on:
# configure.ac runs help2man.PL to get the script vesion. On OS/2 autoconf uses
# ash (sh.exe) as the shell. However, the current version of ash can't properly
# handle the script interprer spec when it is given using the full path. See
# http://trac.netlabs.org/ports/ticket/42 for details. The fix is to temporarily
# hack help2man.PL to remove the path from the interpreter spec.
run mv help2man.PL help2man.PL.orig
run sed -e '1 s/^#!.*\/perl/#!perl/' help2man.PL.orig > help2man.PL

run make -f bootstrap.mak maint-prep

# OS/2 hot fix off:
run mv help2man.PL.orig help2man.PL

# Cleanup

run rm -rf autom4te.cache
run rm -f bootstrap.mak
