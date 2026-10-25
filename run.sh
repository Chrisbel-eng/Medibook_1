#!/usr/bin/env bash
# Starts MediBook. Needs ./out (run build.sh first), config/db.properties and lib/mysql-connector-j-*.jar
cd "$(dirname "$0")"
exec java -cp "out:lib/*" medibook.Main
