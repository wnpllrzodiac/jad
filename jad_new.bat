::功能:     利用bat反编译jar包生成源码jar包
::作者:     seavers
::博客:     http://seavers.iteye.com/
::版本:     1.7


::打开/关闭命令行显示
REM @echo OFF

::::::::::::::::::::::::::::解析并设置变量::::::::::::::::::


::查找jad文件的路径, 这里取的jad.exe, 表示从PATH中查找,如果想手工指定,需在这里修改
set JAD_PATH=jad.exe

::设置解压出的class文件存放的位置(相对路径)
set CLASS_PATH=bin

::设置反编译后的java文件存放的位置(相对路径)
set JAVA_PATH=src

::检查JAD文件是否存在bat所在目录下,
if exist "%~dp0jad.exe" set JAD_PATH=%~dp0jad.exe

::判断参数个数,如果没有文件参数,则报错,这里也可以使用%~f1,也可以用%1,没有关系,之后要去掉引号
if ""%1""=="""" (set /P JAR_PATH=请输入要反编译的JAR包的路径...) else (set JAR_PATH=%~f1)
if '%JAR_PATH:~0,1%%JAR_PATH:~0,1%'=='""' set JAR_PATH=%JAR_PATH:~1,-1%

::获取源代码存放的路径,这里取JAR包所在路径,然后去掉".jar"作为文件夹路径, 这里的LOCATION不能带引号,因为下面还要追加字符)
if ""%2""=="""" (set LOCATION=%JAR_PATH:~0,-4%) else (set LOCATION=%~f2)

::::::::::::::::::::开始执行程序:::::::::::::::::::::::::::::::

::获取WinRAR.exe的路径,设置在临时变量rarpath中
for /f "usebackq delims=" %%i in (`ftype WinRAR`) do set RARPATH=%%i

::对rarpath进行解析,去掉前面7个节符,去掉后面5个字符,得到WinRAR执行路径
::路径大致是这样的形式  Winrar="C:\Program Files\WinRAR\WinRAR.exe" "%1"
set RAREXE=%RARPATH:~7,-5%

::调用WinRAR命令,解压文件到指定目录的bin目录下
%RAREXE% x "%JAR_PATH%" "%LOCATION%\%CLASS_PATH%\"

::遍历整个bin目录,取所有class文件,调用jad.exe反编译出源码,非class的拷贝到src目录下
::打开变量延迟功能
setlocal EnableDelayedExpansion
for /r "%LOCATION%\bin" %%i in (*.*) do if '%%~xi'=='.class' ("%JAD_PATH%"  -o -r -sjava -ff -b -nonlb -space -t -8 -d"%LOCATION%\%JAVA_PATH%" "%%~si") else (set TEMP_PATH=%%i & echo f|xcopy "%%i" "!TEMP_PATH:%LOCATION%\bin=%LOCATION%\src!")
endlocal EnableDelayedExpansion

::将产生的java文件压缩成源码文件
%RAREXE% a -ep1 -r "%LOCATION%-src.zip" "%LOCATION%\%JAVA_PATH%\*.*"


::::::::::::::::::程序结束, 显示运行结果::::::::::::::::::::::
echo *********************************************
echo 程序运行结束
echo 解析的JAR包的路径为 %JAR_PATH%
echo 解压缩工具WinRAR.exe的路径为 %RAREXE%
echo 反编译工具JAD.exe的路径为 %JAD_PATH%
echo 解析后的文件的根路径为 %LOCATION%
echo 解析后的class文件存放在 %LOCATION%\%CLASS_PATH%
echo 解析后的java文件存放在 %LOCATION%\%JAVA_PATH%
echo 压缩后的java文件存放在 %LOCATION%-src.zip
echo *********************************************
pause


