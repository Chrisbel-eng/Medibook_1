@echo off
rem Starts MediBook. Needs .\out (run build.bat first), config\db.properties and lib\mysql-connector-j-*.jar
cd /d "%~dp0"
java -cp "out;lib/*" medibook.Main
