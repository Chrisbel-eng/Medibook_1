   @echo off
   cd /d "%~dp0"
   if exist out rmdir /s /q out
   mkdir out
   javac -encoding UTF-8 -sourcepath src\main\java -d out src\main\java\medibook\Main.java src\main\java\medibook\tools\AddDoctor.java
   if errorlevel 1 (
     echo BUILD FAILED
     exit /b 1
   )
   copy /y src\main\resources\* out\ > nul
   echo Build OK