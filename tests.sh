#!/bin/sh

HOME="$(mktemp -d)"       # this shouldn't write anything, but just in case
SELF=$(readlink -f "${0}")
TESTLIBDIR=$(dirname "${SELF}")/test_lib
REFERENCE_SH='dash'
TEST_OPTS="-lna"
export LC_ALL="POSIX"

if command -v busybox > /dev/null; then
    BusyBox(){
        busybox sh "${@}"
    }
    BusyBox_version() {
        busybox | head -1 | cut -d' ' -f2
    }
fi;

if command -v bash > /dev/null; then
    posix_compliant_bash(){
        bash -posix "${@}"
    }
fi;

bash_version() {
    bash "${TESTLIBDIR}/version.bash"
}
ksh_version() {
    ksh "${TESTLIBDIR}/version.ksh" | cut -d' ' -f2,3
}
mksh_version() {
    mksh "${TESTLIBDIR}/version.ksh" | cut -d' ' -f1,3
}
posix_compliant_bash_version() {
    bash --posix "${TESTLIBDIR}/version.bash"
}
yash_version(){
    yash "${TESTLIBDIR}/version.yash"
}

main() {
    reflog="${HOME}/ref.log"
    ${REFERENCE_SH} conf.sh ${TEST_OPTS} 2>/dev/null > "${reflog}"
    for shell in bash BusyBox dash ksh mksh posix_compliant_bash yash; do
        if command -v "${shell}" > /dev/null; then
            shell_version="${shell}_version"
            if command -v "${shell_version}" > /dev/null ; then
                shellver=$("${shell}_version")
            fi
            echo "** Testing ${shell}..."
            shlog="${HOME}/${shell}.log"
            ${shell} conf.sh ${TEST_OPTS} 2>/dev/null > "${shlog}"
            if diff -q "${shlog}" "${reflog}"; then
                echo "Passed: ${shell} ${shellver}"
            else
                echo "Failed: ${shell}"
            fi
            shellver=""
        else
            echo "** Skipped: ${shell} (not found)."
        fi;
    done;
    rm -rf "${HOME}"
}

main
