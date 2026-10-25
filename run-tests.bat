@echo off
cd /d "%~dp0"
if not exist out-test mkdir out-test
dir /s /b src\test\java\*.java > tests.txt
javac -encoding UTF-8 -cp out -d out-test @tests.txt
del tests.txt
java -cp "out;out-test" LogicTest
java -cp "out;out-test" FlowTest
