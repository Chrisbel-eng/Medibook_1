#!/usr/bin/env bash
# Runs the self-contained tests (no MySQL needed). Requires build.sh to have been run.
set -e
cd "$(dirname "$0")"
mkdir -p out-test
javac -encoding UTF-8 -cp out -d out-test $(find src/test/java -name '*.java')
java -cp out:out-test LogicTest
java -cp out:out-test FlowTest
