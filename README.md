# Startdelayed  
  
## Status: Alpha version
Usable, but parts are underconstruction.  

**The purpose of Startdelayed is to start other (persistent) apps at Windows boot-time.**  
  
#### Latest changes: 
  
Version (>=)| Change
------------ | -------------
0.001 | Start of dev. 2023/05/14

 
#### Known issues / bugs 
Issue / Bug | Type | fixed in version
------------ | ------------- | -------------
 Only even entries are editable |  Bug | 0.005

  
#### Download  
Via Updater is the preferred method!  
Portable, run from any directory, but running from a subdirectory of the windows programm-directories   
(C:\Program Files, C:\Program Files (x86) etc.)  
requires admin-rights and is not recommended!  
**Installation-directory (is created by the Updater) must be writable by the app!** 
  
To download **Startdelayed** from Github please use:  
  
Windows, 64bit: [updater.exe](https://github.com/jvr-ks/startdelayed/raw/main/updater.exe)  
Windows, 32bit: [updater.exe](https://github.com/jvr-ks/startdelayed/raw/main/updater32.exe)  
  
**Be sure to use only one of the \*.exe at a time!**  

(Updater viruscheck please look at the [Updater repository](https://github.com/jvr-ks/updater)) 
  
* From time to time there are some false positiv virus detections  
[Virusscan](#virusscan) at Virustotal see below.  

##### Demo-data:  
At the first start of "startDelayed" the file "stddirectoriesDEMO.txt" is copied to a new file  
"stddirectories_COMPUTERNAME.txt" and this file is used then.  
 

#### App-start  

Startdelayed has three modes:  
- Execution-modes (no startparameter = run all StartCmds or startparameter stopall  = run all StopCmds),  
- Edit-mode.  
  
There are two a helper apps to start startdelayed in the edit-mode: **"startdelayedEdit.exe"**   
or to stop all started apps: **"startdelayedStopall.exe"**.  
(A stop is always required to update the apps via a network copy).  

Otherwise the functionality is selected by the start parameters:  
  
64 bit Windows:
**startdelayed.exe**  runs all StartCmds (top to down)
**startdelayed.exe stopall** runs all StopCmds (top to down)
**startdelayed.exe editmode** opens the gui-window
  
32 bit Windows:  
use **startdelayed32.exe ...** instead   
  
Start with Windows:  
* To create a shortcut of "startdelayed.exe" in the windows-autostart folder ("shell:startup"),  
run the simple Powershell script:  
"create_startdelayed_exe_link_with_in_autostartfolder.bat".   

#### Edit-mode  
Mouse-click an entry: executes the "StartCmd",  
Ctrl + Mouse-click an entry: executes the "StopCmd",  
Shift + Mouse-click an entry: edit the entry.  \*1)
  
Each entry consists of comma-separated-values (CSV),  
NAME, \[running directory] ,command, \[modifier, \[delay after running the command (milliseconds)],  
saved in the \[Directories-file].  
  
Environment-variables (like "%SystemRoot%") are **NOT** usable insíde the Start/Stop-Cmd!  

\*1) Use it to correct tipos only, otherwise use \[Setup] ->  \[Edit ...] or use an external editor
   
#### Configuration  
Configuration is done by a few files,  
file encoding is: **UTF-8 (no BOM)** besides the \[Configuration-file] (UTF-16).  
Use [Notepad\+\+](https://notepad-plus-plus.org/), Atom, Scite or any other editor to edit the files:   
  
\[Directories-file] **"stddirectories_<ComputerName>.txt"**,  
\[Configuration-file] **"startdelayed_<ComputerName>.ini"** 
\[Shortcuts-file] **"stdshortcuts.txt"**,   
  
#### Configuration-files backup / autorestore
If the directory "C:\Users\<UserName>\AppData\Roaming\startdelayed\" is usable,
the app saves a copy of the Configuration-files (those with *_<ComputerName> filename only) to this backup-directory.  
If the Configuration-file is missing,  
an attempt is made to restore the file from the backup directory.  
Otherwise a new Configuration-file is created, containing default-values. 


#### \[Directories-file] **"stddirectories.txt"**:  
contains on each line separated by a comma:  
  
Name | Dir | StartCmd | StopCmd | Modifier
------------ | ------------- | ------------- | -------------  
The name of the entry | the working directory | Command to start the app | Command to stop the app | Modifier
 
#### \[Configuration-file]:  
The default \[Configuration-file] filename is "startdelayed_COMPUTERNAME.ini".    
The file is created with default values.  
  
#### \[Shortcuts-file] **"stdshortcuts.txt"**:   
The format of shortcuts is: \[shortcut-key].  
Shortcuts can be used to shorten long directory-names inside the \[Directories-file]!  
The \[Shortcuts-file] can contain an unlimited number of \[shortcut-key], \[value] definition pairs.  
\[shortcut-key] must be alphanumeric (no symbols or special characters allowed).  
  
#### Modifier:  
  
**inactive**
This \[Directories-file] entry is inactivated,  
but can still be executed by clicking the entry in the list if running the edit-mode!e.  
  
**comspec**  
executes inside a command-shell, can be combined with "admin".  
  
**admin**  
executes as an administrator, but to use it, startdelayed.exe must be run as an admin too!  
  
**wsl**  
Start in WSL as current user.    

**wsladmin**  
Start in WSL as Admin.   

**Examples of \[Directories-file] entries:**  
(The file "stddirectories_JVRENVY.txt" im currently using)  
```  
sbt_console_select,[_ahk]\sbt_console_select,sbt_console_select.exe hidewindow,sbt_console_select.exe remove,,3000
clipboardresize,[_ahk]\clipboardresize,clipboardresize.exe,clipboardresize.exe remove,,3000
cmdlinedev,[_ahk]\cmdlinedev,cmdlinedev.exe,cmdlinedev.exe remove,,3000
titleliner,[_ahk]\titleliner,titleliner.exe,titleliner.exe remove,,3000
skatstube,[_ahk]\skatstube,skatstube.exe,skatstube.exe remove,,3000
aottext,[_ahk]\aottext,aottext.exe,aottext.exe remove,,3000
Disk overview,,shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D},, inactive
God mode,,shell:::{ED7BA470-8E54-465E-825C-99712043E01C},, inactive
Autostart folder user,,shell:startup,, inactive
Dir c:\,c:\,dir,, comspec inactive
TEST WSL,[_ahk]\aottext,ls -l,, wsl inactive,30000
TEST WSL ADMIN,[_ahk]\aottext,ls -l,, wsladmin inactive,30000
```
 
  
#### Sourcecode: [Autohotkey format](https://www.autohotkey.com)  
* "startdelayed.ahk"  
  
#### Requirements  
* Windows 10 or later only.  
  
#### Sourcecode  
Github URL [github](https://github.com/jvr-ks/startdelayed).  
  
#### Hotkeys  
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/startdelayed/blob/main/hotkeys.md)  
  
#### License: MIT  
Permission is hereby granted, free of charge,  
to any person obtaining a copy of this software and associated documentation files (the "Software"),  
to deal in the Software without restriction,  
including without limitation the rights to use,  
copy, modify, merge, publish, distribute, sub license, and/or sell copies of the Software,  
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:  
  
The above copyright notice and this permission notice shall be included in all copies  
or substantial portions of the Software.  
  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,  
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,  
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE  
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
Copyright (c) 2020 J. v. Roos

<a name="virusscan"></a>
##### Virusscan at Virustotal 
[Virusscan at Virustotal, startdelayed.exe 64bit-exe, Check here](https://www.virustotal.com/gui/url/5a1af220c848260ad3cc36fa7a757b7faff1ef9c67f53cee3c60aa944d605ac5/detection/u-5a1af220c848260ad3cc36fa7a757b7faff1ef9c67f53cee3c60aa944d605ac5-1685449974
)  
[Virusscan at Virustotal, startdelayed32.exe 32bit-exe, Check here](https://www.virustotal.com/gui/url/b9b964d88776335fd82abd5bed315279efde34efa0866fb29b58fa91f607037f/detection/u-b9b964d88776335fd82abd5bed315279efde34efa0866fb29b58fa91f607037f-1685449974
)  
[Virusscan at Virustotal, startdelayedA32.exe 32bit-exe ANSI, Check here](https://www.virustotal.com/gui/url/ebdeb88c41ba149017b179335cb08624ac98dc698af41f6fcb05dc58fe9d1d70/detection/u-ebdeb88c41ba149017b179335cb08624ac98dc698af41f6fcb05dc58fe9d1d70-1685449975
)  
Use [CTRL] + Click to open in a new window! 
