@rem compile.bat

@echo off


set autohotkeyExe=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe
set autohotkeyCompilerPath=C:\Program Files\AutoHotkey\Compiler\

SET appname=startdelayed
call %appname%.exe remove
call %appname%32.exe remove

echo compile %appname%
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 64-bit.bin"
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%32.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 32-bit.bin"


SET appname=startdelayedEdit
echo compile %appname%
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 64-bit.bin"
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%32.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 32-bit.bin"


SET appname=startdelayedStopall
echo compile %appname%
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 64-bit.bin"
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%32.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 32-bit.bin"


timeout /t 3

