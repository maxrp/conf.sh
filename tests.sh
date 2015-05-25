#!/bin/sh

HOME="$(mktemp -d)"       # this shouldn't write anything, but just in case
REFERENCE_SH='dash'
TEST_OPTS="-lna"
export LC_ALL="C"

if command -v busybox > /dev/null; then
    busybox_sh(){
        busybox sh "${@}"
    }
fi;

if command -v bash > /dev/null; then
    posix_compliant_bash(){
        bash -posix "${@}"
    }
fi;


main() {
    reflog="${HOME}/ref.log"
    ${REFERENCE_SH} conf.sh ${TEST_OPTS} 2>/dev/null > "${reflog}"
    for shell in bash busybox_sh dash ksh mksh posix_compliant_bash yash; do
        if command -v "${shell}" > /dev/null; then
            echo "** Testing ${shell}..."
            shlog="${HOME}/${shell}.log"
            ${shell} conf.sh ${TEST_OPTS} 2>/dev/null > "${shlog}"
            if diff -q "${shlog}" "${reflog}"; then
                echo "Passed: ${shell}"
            else
                echo "Failed: ${shell}"
            fi
        else
            echo "** Skipped: ${shell} (not found)."
        fi;
    done;
    rm -rf "${HOME}"
}

main
