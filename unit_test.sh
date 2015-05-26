#!/bin/sh

oneTimeSetUp() {
    . ./conf.sh
    testdir=$(mktemp -d)
    BASEDIR=$(dirname "$0")
    SRCDIR="${BASEDIR}/src"
    MODBASE="${BASEDIR}/modules"
}

oneTimeTearDown() {
    rm -rf "${testdir}"
}

testRcmdDryrun() {
    faketestcmd="$(DRYRUN=1 rcmd fake test command)"
    assertEquals "${faketestcmd}" "D: fake test command"
}

testConfDryrun() {
    testcmd="$(DRYRUN=1 HOME="${testdir}" conf a b)"
    assertEquals "${testcmd}" "D: install -m 0600 -D ./src/a ${testdir}/.b"
}

. shunit2-2.1.6/src/shunit2
