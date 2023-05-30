@rem compile.bat

@echo off

SET appname=startdelayed

set autohotkeyExe=C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe
set autohotkeyCompilerPath=C:\Program Files\AutoHotkey\Compiler\

call %appname%.exe remove
call %appname%32.exe remove

call "%autohotkeyExe%" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 64-bit.bin"
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%32.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 32-bit.bin"

SET appname=startdelayedEdit
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 64-bit.bin"
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%32.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 32-bit.bin"


SET appname=startdelayedStopall
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 64-bit.bin"
call "%autohotkeyExe%" /in %appname%.ahk /out %appname%32.exe /icon %appname%.ico /bin "%autohotkeyCompilerPath%Unicode 32-bit.bin"


timeout /t 3

