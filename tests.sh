#!/bin/sh

HOME="$(mktemp -d)"       # this shouldn't write anything, but just in case
REF_SH='bash'
TEST_OPTS="-lna"

main() {
    reflog="${HOME}/ref.log"
    ${REF_SH} conf.sh ${TEST_OPTS} 2>/dev/null > "${reflog}"
    for shell in bash dash ksh mksh yash; do
        if command -v ${shell} > /dev/null; then
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
