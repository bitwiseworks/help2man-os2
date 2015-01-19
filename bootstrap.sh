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

run make -f bootstrap.mak maint-prep

# Cleanup

run rm -rf autom4te.cache
run rm -f bootstrap.mak
