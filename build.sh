#!/usr/bin/env bash
# Compiles MediBook into ./out (requires a JDK 17+ on PATH).
set -e
cd "$(dirname "$0")"
rm -rf out && mkdir -p out
javac -encoding UTF-8 -d out $(find src/main/java -name '*.java')
cp src/main/resources/* out/
echo "Build OK -> ./out"
