/*
 *********************************************************************************
 * 
 * startdelayed.ahk
 * 
 * Version -> appVersion
 * 
 * License GNU GENERAL PUBLIC LICENSE -> license.txt
 *
 * © 2021 jvr.de
 * 
 *********************************************************************************
*/

/*
 *********************************************************************************
 * Main view element is the ListView LV1.
 * Upon a click guiMainListViewClick() is called.
  *********************************************************************************
*/

;  All *.ahk files are UTF-8-BOM encoded, all *.ini files are UTF-16 LE-BOM encoded

; #Requires AutoHotkey v1

#NoEnv
#Warn
#SingleInstance force
#Persistent

#InstallKeybdHook
#InstallMouseHook
#UseHook On

#Include %A_ScriptDir%

FileEncoding, UTF-8

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

SetTitleMatchMode, 2
DetectHiddenWindows, On
SetTitleMatchMode, slow

wrkDir := A_ScriptDir . "\"

appName := "Startdelayed"
appnameLower := "startdelayed"
extension := ".exe"
appVersion := "0.019"

bit := (A_PtrSize=8 ? "64" : "32")
bitName := (bit="64" ? " (64)" : " (32)")

app := appName . " " . appVersion . bitName 


sessionName := ""
currentNotepadId := ""

configFile := appnameLower . "_" . A_ComputerName . ".ini"
localAppDir :=  A_AppData . "\" . appnameLower . "\"
localConfigFile := localAppDir . configFile

directoriesFile := "stddirectories_" . A_ComputerName . ".txt"
localDirectoriesFile := localAppDir . directoriesFile

shortcutsFile  := "stdshortcuts_" . A_ComputerName . ".txt"
localShortcutsFile := localAppDir . shortcutsFile

syncAppDataRead3()


dpiScaleDefault := 96
dpiScale := dpiScaleDefault

if ((0 + A_ScreenDPI == 0) || (A_ScreenDPI == 96))
  dpiCorrect := 1
else
  dpiCorrect := A_ScreenDPI / dpiScale

windowPosXDefault := 0
windowPosYDefault := 0
clientWidthDefault := 800
clientHeightDefault := 600

windowPosX := windowPosXDefault
windowPosY := windowPosYDefault
clientWidth := clientWidthDefault
clientHeight := clientHeightDefault


localVersionFileDefault := "version.txt"
serverURLDefault := "https://github.com/jvr-ks/"
serverURLExtensionDefault := "/raw/main/"

localVersionFile := localVersionFileDefault
serverURL := serverURLDefault
serverURLExtension := serverURLExtensionDefault

updateServer := serverURL . appnameLower . serverURLExtension

GroupAdd,anyshell,ahk_class ConsoleWindowClass
GroupAdd,anyshell,ahk_class mintty

shortcutsArr := {}

showActiveTitle := true

directoriesArr := []

;--- Gui parameter ---
borderLeft := 2
borderRight := 2
borderTop := 40 ; reserve statusbar space

fontDefault := "Segoe UI"
font := fontDefault

fontsizeDefault := 10
fontsize := fontsizeDefault

Loop % A_Args.Length()
{
  if(eq(A_Args[A_index],"remove"))
    exitApp
    
  if(eq(A_Args[A_index],"editmode")){
    prepare()
    readGuiParam()
    mainWindow(1)
  }
    
  if(eq(A_Args[A_index],"stopall")){
    prepare()
    stopall()
  }
}

if (A_Args.Length() == 0){
  prepare()
  startall()
}


return

;------------------------------ syncAppDataRead3 ------------------------------
syncAppDataRead3(){
  global localAppDir, configFile, localConfigFile, directoriesFile, localDirectoriesFile, shortcutsFile, localShortcutsFile
  
  if (!(FileExist(configFile))){
    if ((FileExist(localConfigFile))){
      FileCopy, %localConfigFile%, %configFile%, 1
    } else {
      ; create default
      createDefaultConfig(configFile)
    }
  }
  
  if (!(FileExist(directoriesFile))){
    if ((FileExist(localDirectoriesFile))){
      FileCopy, %localDirectoriesFile%, %directoriesFile%, 1
    } else {
      ; use "stddirectoriesDEMO.txt"
      FileCopy, stddirectoriesDEMO.txt, %directoriesFile%, 1
      msgbox, File "%directoriesFile%" not found`, using content of "stddirectoriesDEMO.txt"
    }
  }
  
  if (!(FileExist(shortcutsFile))){
    if ((FileExist(localShortcutsFile))){
      FileCopy, %localShortcutsFile%, %shortcutsFile%, 1
    } else {
      FileCopy, stdshortcutsDEMO.txt, %shortcutsFile%, 1
      msgbox, File "%shortcutsFile%" not found`, using content of "stdshortcutsDEMO.txt"
    }
  }

  return 
}
;----------------------------- syncAppDataWrite3 -----------------------------
syncAppDataWrite3(){
  global localAppDir, configFile, directoriesFile, shortcutsFile
  
  if (!(FileExist(localAppDir))){
    try {
      FileCreateDir, %localAppDir%
    } catch e {
      msgbox, Could not create directory: %localAppDir% (%e%)
    }
  }
  
  ; save configFile
  if (FileExist(configFile)){
    if ((FileExist(localAppDir))){
      FileCopy, %configFile%, %localAppDir%*.*, 1
    }
  }
  
  ; save directoriesFile
  if (FileExist(directoriesFile)){
    if ((FileExist(localAppDir))){
      FileCopy, %directoriesFile%, %localAppDir%*.*, 1
    }
  }
  
  ; save shortcutsFile
  if (FileExist(shortcutsFile)){
    if ((FileExist(localAppDir))){
      FileCopy, %shortcutsFile%, %localAppDir%*.*, 1
    }
  }
  
  return 
}
;-------------------------------- openDataDir --------------------------------
openDataDir(){
  global localAppDir, appnameLower

  if (FileExist(localAppDir)){
    run, Explorer %localAppDir%
  } else {
    msgbox, 0x1021, Question, Directory %localAppDir% is not accessible`, create it?
    IfMsgBox Ok
    {
      if (!(FileExist(localAppDir))){
        try {
          FileCreateDir, %localAppDir%
          sleep, 1000
          restart()
        } catch e {
          msgbox, Could not create directory: %localAppDir% (%e%)
        }
      }
    }
  }
  
  return
}
;---------------------------------- WM_MOVE ----------------------------------
WM_MOVE(wParam, lParam){
  global hMain, windowPosX, windowPosY
  
  WinGetPos, windowPosX, windowPosY,,, ahk_id %hMain%
  
  return
}
;-------------------------------- mainWindow --------------------------------
mainWindow(showMe) {
  global hMain, Text1, bit
  global windowPosX, windowPosY, clientWidth, clientHeight  
  global directoriesFile, shortcutsFile, configFile
  global app, appName, appVersion  
  global menuHotkey, exithotkey
  global directoriesArr, LV1, Errormessage
  global font, fontsize
  global borderLeft, borderRight
    
  Menu, Tray, UseErrorLevel

  Menu, MainMenuSetup, DeleteAll
  Menu, MainMenuTools, DeleteAll
  Menu, MainMenuHelp, DeleteAll
  Menu, MainMenuUpdate, DeleteAll
  
  
  Menu, MainMenuSetup, Add, Edit Directories-file: "%directoriesFile%", editDirectoriesFile
  Menu, MainMenuSetup, Add, Edit Shortcuts-file: "%shortcutsFile%", editShortcutsFile
  Menu, MainMenuSetup, Add, Edit Configuration-file: "%configFile%", editConfigFile
  Menu, MainMenuSetup, Add
  Menu, MainMenuSetup, Add, Open Data-backup-directory, openDataDir
 
  Menu, MainMenuTools, Add, Open Autostartfolder %A_UserName%, openAutostartFolderUser
  Menu, MainMenuTools, Add, Open Autostartfolder admin, openAutostartFolderAdmin
  Menu, MainMenuTools, Add, Open God mode, openGodMode
  
  Menu, MainMenuHelp, Add,Short-help offline,htmlViewerOffline
  Menu, MainMenuHelp, Add,Short-help online,htmlViewerOnline
  Menu, MainMenuHelp, Add,README online, htmlViewerOnlineReadme
  Menu, MainMenuHelp, Add,Open Github,openGithubPage
  
  Menu, MainMenuUpdate, Add,Check if new version is available, startCheckUpdate
  Menu, MainMenuUpdate, Add,Start updater, startUpdate
  
  Menu, MainMenu, Add,⏹ Startall, startall
  Menu, MainMenu, Add,🟡 Stopall, stopall
  Menu, MainMenu, Add,⚙ Setup,:MainMenuSetup
  Menu, MainMenu, Add,🧰 Tools,:MainMenuTools
  Menu, MainMenu, Add,🞦 Update,:MainMenuUpdate
  Menu, MainMenu, Add,🛈 Help,:MainMenuHelp
 
  Menu, MainMenu, Add, 🗙 Exit the app, exit 
  
  Gui, guiMain:New, +OwnDialogs +LastFound MaximizeBox hwndhMain +Resize, %app%`

  Gui, Margin, 6, 4
  Gui, guiMain:Font, s%fontsize%, %font%

  lv1Width := clientWidth - borderLeft - borderRight
  
  ; -NoSortHdr  -LV0x10
  Gui, guiMain:Add, ListView, x5 r20 w%lv1Width% GguiMainListViewClick vLV1 hwndhLV1 Grid AltSubmit -Multi, |Name|Dir|StartCmd|StopCmd|Modifier|Delay (msec)
  
  for index, element in directoriesArr
  {
    elementArr := StrSplit(element,",")
    if (elementArr.Length() < 4){
      n := 4 - elementArr.Length()
      
      Loop, %n%
        elementArr.push("_")
    }
      
    row := LV_Add("",Format("{:02}", index),elementArr[1],elementArr[2],elementArr[3],elementArr[4],elementArr[5],elementArr[6])
  }
  
  Gui, guiMain:Menu, MainMenu
  
  gui, guiMain:Add, StatusBar
  
  partSize := round(clientWidth / 2) - 50
  SB_SetParts(partSize, partSize)
    
  LV_ModifyCol()
  LV_ModifyCol(1,"AutoHdr Integer")
  LV_ModifyCol(2,"AutoHdr Text") ; Name
  LV_ModifyCol(3,"AutoHdr Text") ; Pfad
  LV_ModifyCol(4,"AutoHdr Text") ; Start Command
  LV_ModifyCol(5,"AutoHdr Text") ; Stop Command
  LV_ModifyCol(6,"AutoHdr Text") ; Modifier
  LV_ModifyCol(7,"AutoHdr Text") ; DelayAfter

  if (showMe){
    showWindow()
    showStatusBar()
  }
  
  OnMessage(0x03,"WM_MOVE")
  
  return
}
;------------------------------ guiMainGuiSize ------------------------------
guiMainGuiSize(){
  global hMain, windowPosX, windowPosY, clientWidth, clientHeight
  global windowPosXDefault, windowPosYDefault, clientWidthDefault, clientHeightDefault
  global borderLeft, borderRight, borderTop, LV1

  if (A_EventInfo != 1) {
    ; not minimized
    
    clientWidth := A_GuiWidth
    clientHeight := A_GuiHeight
    
    width := clientWidth - borderLeft - borderRight
    height := clientHeight - borderTop
    
    guicontrol, guiMain:move, LV1, x%borderLeft% w%width% h%height%
    
    partSize := round(clientWidth / 2) - 50
    SB_SetParts(partSize, partSize)
  }
  
  return
}
;----------------------------- startCheckUpdate -----------------------------
startCheckUpdate(){

  checkUpdate()
  showWindow()

  return
}
;-------------------------------- startUpdate --------------------------------
startUpdate(){
  global wrkdir, appname, bitName, extension

  updaterExeVersion := "updater" . bitName . extension
  
  if(FileExist(updaterExeVersion)){
    msgbox,Starting "Updater" now!
    run, %updaterExeVersion% runMode
    exit()
  } else {
    msgbox, Updater not found, using old update mechanism!
  }
  
  showWindow()

  return
}
;---------------------------------- prepare ----------------------------------
prepare() {
  readConfig()
  readDirectories()
  readShortcuts()
  
  return
}
;-------------------------------- iniReadSave --------------------------------
iniReadSave(name, section, defaultValue){
  global configFile
  
  r := ""
  IniRead, r, %configFile%, %section%, %name%, %defaultValue%
  if (r == "" || r == "ERROR")
    r := defaultValue
    
  return r
}
;-------------------------------- readConfig --------------------------------
readConfig(){
  global configFile
  global fontDefault, font, fontsizeDefault, fontsize
  global app, appName, showActiveTitle

  font := iniReadSave("font", "config", fontDefault)
  fontsize := iniReadSave("fontsize", "config", fontsizeDefault)

  emptyDefault := "-"

  showActiveTitleRead := iniReadSave("showActiveTitleRead", "config", "yes")
  satr := StrLower(showActiveTitleRead)
  if (InStr(satr,"n") > 0 || InStr(satr,"f") > 0  || satr == "0"){
    showActiveTitle := false
  }
  
  return
}
;------------------------------- createDefaultConfig -------------------------------
createDefaultConfig(fn){
  
  content := "
(
[config]
font=""Segoe UI""
fontsize=10

[gui]
windowPosX=0
windowPosY=0
clientWidth=579
clientHeight=300
)"

  FileAppend, %content%, %fn%, UTF-8

  return
}
;------------------------------- readGuiParam -------------------------------
readGuiParam(){
  global configFile, windowPosX, windowPosY, clientWidth, clientHeight
  global windowPosXDefault, windowPosYDefault, clientWidthDefault, clientHeightDefault
  global dpiCorrect, dpiScale
  
  windowPosX := iniReadSave("windowPosX", "gui", 0)
  windowPosY := iniReadSave("windowPosY", "gui", 0)
  clientWidth := iniReadSave("clientWidth", "gui", clientWidthDefault)
  clientHeight := iniReadSave("clientHeight", "gui", clientHeightDefault)
    
  windowPosX := max(windowPosX,-50)
  windowPosY := max(windowPosY,-50)
  
  return
}
;------------------------------ readDirectories ------------------------------
readDirectories(){
  global directoriesFile, directoriesArr, appname

  directoriesArr := []

  if(FileExist(directoriesFile)){
    Loop, read, %directoriesFile%
    {
      if (A_LoopReadLine != "") {
        directoriesArr.Push(A_LoopReadLine)
      }
    }
  } else {
    msgbox, SEVERE ERROR`, file "%directoriesFile%" not found`, exiting %appname%
    exit()
  }
  
  return
}

;------------------------------- readShortcuts -------------------------------
readShortcuts(){
  global shortcutsArr, shortcutsFile
  
  shortcutsArr := {}

  Loop, read, %shortcutsFile%
  {
    LineNumber := A_Index
    shortcutName := ""
    shortcutReplace := ""
    
    if (A_LoopReadLine != "") {
      Loop, parse, A_LoopReadLine, %A_Tab%`,
      {  
        if(A_Index == 1)
          shortcutName := A_LoopField
          
        if(A_Index == 2)
          shortcutReplace := A_LoopField
      }
      shortcutsArr[shortcutName] := shortcutReplace
    }
  }
  
  return
}
;-------------------------------- showWindow --------------------------------
showWindow(){
  global windowPosX, windowPosY, clientWidth, clientHeight
  
  Gui, guiMain:Show, x%windowPosX% y%windowPosY% w%clientWidth% h%clientHeight%
  
  return
}
;-------------------------------- hideWindow --------------------------------
hideWindow(){

  Gui,guiMain:Hide

  return
}
;-------------------------------- refreshGui --------------------------------
refreshGui(){
  global directoriesArr

  LV_Delete()
  
  for index, element in directoriesArr
  {
    elementArr := StrSplit(element,",")
    if (elementArr.Length() < 6){
      n := 6 - elementArr.Length()
      
      Loop, %n%
        elementArr.push("_")
    }
      
    row := LV_Add("",Format("{:02}", index),elementArr[1],elementArr[2],elementArr[3],elementArr[4],elementArr[5],elementArr[6])
  }
  
  return
}
;-------------------------------- saveGuiData -------------------------------
saveGuiData(){
  global hMain, configFile, windowPosX, windowPosY, clientWidth, clientHeight
  
  ; force to UTF-8 if new file
  FileAppend,,%configFile%, UTF-8
  
  IniWrite, %windowPosX%, %configFile%, gui, windowPosX
  IniWrite, %windowPosY%, %configFile%, gui, windowPosY
  
  IniWrite, %clientWidth%, %configFile%, gui, clientWidth
  IniWrite, %clientHeight%, %configFile%, gui, clientHeight
  
  syncAppDataWrite3()

  return
}
;-------------------------------- guiMainListViewClick --------------------------------
guiMainListViewClick(){
  global hMain
  
  if (A_GuiEvent = "normal"){
    LV_GetText(rowSelected, A_EventInfo)
    runInDirSelect(rowSelected)
  }
  
  return
}
;--------------------------------- runInDirSelect ---------------------------------
runInDirSelect(lineNumber) {
  global hMain, directoriesFile, directoriesArr

  directorieEntryArr := []
  
  ; SetCapsLockState, off

  if (lineNumber != 0){
    ks := getKeyboardState()

    switch ks
    {
    case 0:
      ; no additional key pressed -> run StartCmd
      runInDirAction(lineNumber, 0, 1)
      entry := StrSplit(directoriesArr[lineNumber],",")
      showHintColored(hMain, "StartCmd """ . entry[3] . """ executed!", 3000, "cFFFFFF" , "a900ff",, 10)

    case 4:
      ;*** Ctrl *** -> run StopCmd
      runInDirAction(lineNumber, 1, 1)
      entry := StrSplit(directoriesArr[lineNumber],",")
      showHintColored(hMain, "StopCmd """ . entry[4] . """ executed!", 3000, "cFFFFFF" , "a900ff",, 10)
      
    case 8:
      ;*** Shift = edit ***
      s := directoriesArr[lineNumber]
      
      setTimer,unselect,-100
      InputBox,inp,Edit command,,,,100,,,,,%s%
      
      if (ErrorLevel){
        showHintColored(hMain, "Canceled!",2000)
        return
      } else {
        ;save new command
        directoriesArr[lineNumber] := inp
        
        content := ""
        
        l := directoriesArr.Length()
        
        Loop, % l
        {
          content := content . directoriesArr[A_Index] . "`n"
        }

        FileDelete, %directoriesFile%
        FileAppend, %content%, %directoriesFile%, UTF-8
      
        showWindow()
        refreshGui()
      }
 
    }
  }
  
  return
}
;--------------------------------- unselect ---------------------------------
unselect(){
  sendinput {left}
}
;------------------------------ runInDirAction ------------------------------
runInDirAction(i,useonly, manual := 0){
  global hMain, directoriesArr

  directorieEntryArr := StrSplit(directoriesArr[i],",")
  
  path := cvtPath(directorieEntryArr[2],"")
  
  modifierSource := StrLower(directorieEntryArr[5])
  
  if (manual || !InStr(modifierSource,"inactive")){
  
    delayAfterCommand := 0
    
    if (directorieEntryArr[6] != "")
      delayAfterCommand := 0 + directorieEntryArr[6]

    command := ""
    
    if (useonly == 0)
      command := directorieEntryArr[3]
      
    if (useonly == 1)
      command := directorieEntryArr[4]
     
    command := StrReplace(command, ",", "`,")
    
    ;msgbox, command:`n%command%`npath:`n%path%

    if (InStr(modifierSource,"comspec")){
      if (InStr(modifierSource,"admin")){
        if (path != ""){
          run, *RunAs %ComSpec% /k
          WinWait,Ahk_exe cmd.exe,,20
          t := "cd " . path
          controlsend,,{text}%t%, ahk_exe cmd.exe
          controlsend,,{ENTER}, ahk_exe cmd.exe
          sleep, 1000
          controlsend,,{text}%command%, ahk_exe cmd.exe
          controlsend,,{ENTER}, ahk_exe cmd.exe
        } else {
          run, *RunAs %ComSpec% /k "%command%", %path%
        }
      } else {
        ; an empty path is ignored
        run, %ComSpec% /k "%command%", %path%
      }
    } else {
      if (InStr(modifierSource,"wsl")){
        user := A_UserName
        if (InStr(modifierSource,"admin"))
          user := "root"

        DetectHiddenText, On
        wslexe := "C:\Windows\System32\wsl.exe"
        run, %wslexe% -u %user%,, max
        WinWait,%wslexe%,,20
        sleep, 2000
        if (!WinExist("Ahk_exe wsl.exe")){
          msgbox, SEVERE Error`, WSL not found!
          return
        }
        
        if (path != ""){
          pathLinux := RegExReplace(path,"\\","/")
          pathLinux := RegExReplace(pathLinux,"i)(.+):","/mnt/$L1")
          t := "cd " . pathLinux
          controlsend,,%t%,%wslexe% 
          controlsend,,{ENTER},%wslexe%
          sleep, 1000
        }
        controlsend,,%command%,%wslexe%
        controlsend,,{ENTER},%wslexe%
      } else {
        if (InStr(modifierSource,"admin")){
          run, *RunAs %command%, %path%
        } else {
          run, %command%, %path%
        }
      }
    }
      
    sleep, %delayAfterCommand%
  }
  
  return
}
;--------------------------------- startall ---------------------------------
startall(){
  global directoriesArr, app
  
  l := directoriesArr.Count()
  
  loop, %l%
  {
    runInDirAction(A_Index, 0, 0)
  }
  msg := app . ": Startall finished!"
  tipTop(msg, 1, 4000)
  sleep, 4000

  ExitApp
}

;---------------------------------- stopall ----------------------------------
stopall(){
  global directoriesArr, app

  l := directoriesArr.Count()
  
  loop, %l%
  {
    runInDirAction(A_Index, 1, 0)
  }
  msg := app . ": Stopall finished!"
  tipTop(msg, 1, 4000)
  sleep, 4000
  
  ExitApp
}
;--------------------------- sleepUntilCtrlPressed ---------------------------
sleepUntilCtrlPressed(){
  global hMain, app

  showHintColored(hMain, "[" . app . "] Waiting: If operation has finished, please press [Alt] + [Ctrl]-key to continue!")
  
  KeyWait,Alt,D
  KeyWait,Control,D
  sleep,100
  Gui, hintColored:Destroy
  
  return
}
;------------------------------ openGithubPage ------------------------------
openGithubPage(){
  global appnameLower

  Run https://github.com/jvr-ks/%appnameLower%
  
  return
}
;------------------------------- closeMessage -------------------------------
closeMessage(){
  global FSACTextRed

  if (WinExist("ahk_exe notepad++.exe")){
    msgbox, Notepad++ is already running, please close it first (all instances)!
    return
  }
  GuiControl,guiMain:, FSACTextRed, Please close the editor before proceeding!  !

  return
}
;---------------------------- closeMessageRemove ----------------------------
closeMessageRemove(){
  global FSACTextRed

  GuiControl,guiMain:, FSACTextRed

  return
}

;------------------------------------ ret ------------------------------------
ret() {
  return
}
;---------------------------------- in Lib ----------------------------------
; getKeyboardState

;---------------------------------- cvtPath ----------------------------------
cvtPath(s, path){
  ; handles "\..." as path repetition also and replace "°" with "#" (URL relativ address)
  
  r := s
  pos := 0

  r := StrReplace(r, "[...]", path)
  
  While pos := RegExMatch(r,"O)(\[.*?\])", match, pos+1){
    r := RegExReplace(r, "\" . match.1, shortcut(match.1, path), , 1, pos)
  }

  While pos := RegExMatch(r,"O)(%.+?%)", match, pos+1){
    r := RegExReplace(r, match.1, envVariConvert(match.1), , 1, pos)
  }

  pos := RegExMatch(r,"O)(~.+?~)", match)
  if (pos > 0){
    filename := StrReplace(match.1,"~","")
    filename := path . "\" . filename
    
    if (FileExist(filename)) {
      FileReadLine, firstline, %filename%, 1
        if (eq(firstline,"")){
          msgbox, File is empty: "filename"
          r := ""
        } else {
          r := firstline
        }
    } else {
      msgbox, File not found: %filename%
      r := ""
    }
  }

  r := StrReplace(r, "°", "#")
  
  return r
}
;-------------------------------- resolvePath --------------------------------
resolvePath(p){
  global wrkdir

  r := p
  if (!InStr(p, ":"))
    r := wrkdir . p

  return r
}
;------------------------------ envVariConvert ------------------------------
envVariConvert(s){
  r := s
  if (InStr(s,"%")){
    s := StrReplace(s,"`%","")
    EnvGet, v, %s%
    Transform, r, Deref, %v%
  }

  return r
}
;--------------------------------- shortcut ---------------------------------
shortcut(s, path){
  global shortcutsArr
  
  r := s

  sc := cvtPath(shortcutsArr[r], path)
  if (sc != "")
    r := sc

  return r
}
;-------------------------------- showHintAdd --------------------------------
showHintAdd(s,n := 2000){
  global font
  global fontsize
  
  static sIs := ""
  
  if (s == ""){
    sIs := ""
    rows := 1
    setTimer,showHintAddDestroy, delete
    Gui, hintAdd:Destroy
  } else {
    setTimer,showHintAddDestroy, delete
    sIs .= s

    Gui, hintAdd:Destroy
    Gui, hintAdd:Font, %fontsize%, %font%
    Gui, hintAdd:Add, Text,, %sIs%
    Gui, hintAdd:-Caption
    Gui, hintAdd:+ToolWindow
    Gui, hintAdd:+AlwaysOnTop
    Gui, hintAdd:Show,autosize
    
    sIs .= "`n"
    t := -1 * n
    setTimer,showHintAddDestroy, %t%
  }
  
  return
}

;----------------------------- showHintAddReset -----------------------------
showHintAddReset(){

  showHintAdd("",0)

  return
}
;---------------------------- showHintAddDestroy ----------------------------
showHintAddDestroy(){

  setTimer,showHintAddDestroy, delete
  Gui, hintAdd:Destroy
  
  return
}
;------------------------------ infoBoxGuiClose ------------------------------
infoBoxGuiClose(){

  showWindow()

  return
}
;------------------------------------ eq ------------------------------------
eq(a, b) {
  if (InStr(a, b) && InStr(b, a))
    return 1
  return 0
}
;--------------------------------- StrLower ---------------------------------
StrLower(s){
  r := ""
  StringLower, r, s
  
  return r
}
;---------------------------------- tipTop ----------------------------------
tipTop(msg, n := 1, t := 4000){

  s := StrReplace(msg,"^",",")
  
  toolX := round(A_ScreenWidth / 2)
  toolY := 2

  CoordMode,ToolTip,Screen
  
  toolTip,%s%, toolX, toolY, n
  
  WinGetPos, X,Y,W,H, ahk_class tooltips_class32

  toolX := (A_ScreenWidth / 2) - W / 2
  
  toolTip,%s%, toolX, toolY, n
  
  SetTimer, tipTopCloseAll, delete
  if (t > 0){
    tvalue := -1 * t
    SetTimer,tipTopCloseAll,%tvalue%
  }
  
  return
}
;-------------------------------- tipTopCloseAll --------------------------------
tipTopCloseAll(){
  
  Loop, 20
  {
    ToolTip,,,,%A_Index%
  }
  
  return
}
;----------------------------- checkUpdate -----------------------------
checkUpdate(){
  global hMain, appname, appnameLower, localVersionFile, updateServer

  localVersion := getLocalVersion(localVersionFile)

  remoteVersion := getVersionFromGithubServer(updateServer . localVersionFile)

  if (remoteVersion != "unknown!" && remoteVersion != "error!"){
    if (remoteVersion > localVersion){
      msg1 := "New version available: (" . localVersion . " -> " . remoteVersion . ")`, please use the Updater (updater.exe) to update " . appname . "!"
      showHintColored(hMain, msg1)
      
    } else {
      msg2 := "No new version is available!"
      showHintColored(hMain, msg2)
    }
  } else {
    msg := "Update-check failed: (" . localVersion . " -> " . remoteVersion . ")"
    showHintColored(hMain, msg)
  }

  return
}
;------------------------------ getLocalVersion ------------------------------
getLocalVersion(file){
  
  versionLocal := 0.000
  if (FileExist(file) != ""){
    file := FileOpen(file,"r")
    versionLocal := file.Read()
    file.Close()
  }

  return versionLocal
}
;------------------------ getVersionFromGithubServer ------------------------
getVersionFromGithubServer(url){

  ret := "unknown!"

  whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
  Try
  { 
    whr.Open("GET", url)
    whr.Send()
    status := whr.Status
    if (status == 200){
     ret := whr.ResponseText
    } else {
      msgArr := {}
      msgArr.push("Error while reading actual app version!")
      msgArr.push("Connection to:")
      msgArr.push(url)
      msgArr.push("failed!")
      msgArr.push(" URL -> clipboard")
      msgArr.push("Closing Updater due to an error!")
    
      errorExit(msgArr, url)
    }
  }
  catch e
  {
    ret := "error!"
  }

  return ret
}
;------------------------------- showStatusBar -------------------------------
showStatusBar(hk1 := "", hk2 := ""){
  global configFile, directoriesFile

  if (hk1 != ""){
    SB_SetText(" " . hk1 , 1, 1)
  } else {
    SB_SetText(" " . "Configuration-file: " . configFile , 1, 1)
  }
    
  if (hk2 != ""){
    SB_SetText(" " . hk2 , 2, 1)
  } else {
    SB_SetText(" " . "Directories-file: " . directoriesFile , 2, 1)
  }
  
  memory := "[" . GetProcessMemoryUsage() . " MB]      "
  SB_SetText("`t`t" . memory , 3, 2)

  return
}
;----------------------------- coordsScreenToApp -----------------------------
coordsScreenToApp(n){
  global dpiCorrect
  
  r := 0
  if (dpiCorrect > 0)
    r := round(n / dpiCorrect)

  return r
}
;----------------------------- htmlViewerOffline -----------------------------
htmlViewerOffline(){
  htmlViewer(0)

  return
}
;----------------------------- htmlViewerOnline -----------------------------
htmlViewerOnline(){
  htmlViewer(1)

  return
}
;-------------------------- htmlViewerOnlineReadme --------------------------
htmlViewerOnlineReadme(){
  global appnameLower
  
  htmlViewer(1, "https://xit.jvr.de/" . appnameLower . "_readme.html")

  return
}
;------------------------------- htmlViewer -------------------------------
htmlViewer(forceOnline := 0, url := ""){
  global hMain, winIsShifted
  global hHtmlViewer, clientWidthHtmlViewer, clientHeightHtmlViewer
  global WB
  global appnameLower
  
  clientWidthHtmlViewer := coordsScreenToApp(A_ScreenWidth * 0.6)
  clientHeightHtmlViewer := coordsScreenToApp(A_ScreenHeight * 0.6)

  WinSet, Style, -alwaysOnTop, ahk_id %hMain% 
  winIsShifted := 1
  gui,guiMain:hide

  gui, htmlViewer:destroy
  gui, htmlViewer:New,-0x100000 -0x200000 +alwaysOnTop +resize +E0x08000000 hwndhHtmlViewer,Short Help
  gui, htmlViewer:Add, ActiveX, x0 y0 w%clientWidthHtmlViewer% h%clientHeightHtmlViewer% +VSCROLL +HSCROLL vWB, about:<!DOCTYPE html><meta http-equiv="X-UA-Compatible" content="IE=edge">

  gui, htmlViewer:Add, StatusBar
  SB_SetParts(400,300)
  SB_SetText("Use CTRL + mousewheel to zoom in/out!", 1, 1)

  htmlFile := "shorthelp.html"
  
  if(url == "")
    url := "https://xit.jvr.de/" . appnameLower . "_shorthelp.html"

  failed := 0
  if (!forceOnline){
    if (FileExist(htmlFile)){
      FileEncoding, UTF-8
      FileRead, data, %htmlFile%
      if (!ErrorLevel){
        doc := wb.document
        doc.write(data)
      } else {
        failed := 1
      }
    } else {
      failed := 1
    }
    if (failed){
      WB.Navigate(url)
      SB_SetText("(Local help-file not found, using online version) Use CTRL + mousewheel to zoom in/out!", 1, 1)
    }
  } else {
    WB.Navigate(url)
  }

  gui, htmlViewer:Show, center
  
  GuiControl, -HScroll -VScroll, ahk_id %hHtmlViewer%
  
  return
}
;----------------------------- htmlViewerGuiSize -----------------------------
htmlViewerGuiSize(){
  global hHtmlViewer, clientWidthHtmlViewer, clientHeightHtmlViewer
  global WB

  if (A_EventInfo != 1) {
    statusBarSize := 20
    clientWidthHtmlViewer := A_GuiWidth
    clientHeightHtmlViewer := A_GuiHeight - statusBarSize

    GuiControl, Move, WB, % "w" clientWidthHtmlViewer " h" clientHeightHtmlViewer
  }
  
  return
}
;---------------------------- htmlViewerGuiClose ----------------------------
htmlViewerGuiClose(){
  global hMain, ishidden, winIsShifted

  WinSet, Style, +alwaysOnTop, ahk_id %hMain% 
  winIsShifted := 0
  ishidden := 0
  gui,guiMain:show

  return
}
;------------------------------ showHintColored ------------------------------
showHintColored(handle, s := "", n := 3000, fg := "c00FF00", bg := "c000000", font := "Segoe UI", fontsize := 9){
  global hMain
  
  Gui, hintColored:new, hwndhHintColored +parentGuiMain +ownerGuiMain
  Gui, hintColored:Font, s%fontsize%, %font%
  Gui, hintColored:Font, c%fg%
  Gui, hintColored:Color, %bg%
  Gui, hintColored:Add, Text,, %s%
  Gui, hintColored:-Caption
  Gui, hintColored:+ToolWindow
  Gui, hintColored:+AlwaysOnTop
  Gui, hintColored:Show
  WinCenter(hMain, hHintColored, 1)
  Sleep, n
  Gui, hintColored:Destroy
  
  return
}
;----------------------------- getKeyboardState -----------------------------
getKeyboardState(){
  r := 0
  if (getkeystate("Capslock","T") == 1)
    r := r + 1
    
  if (getkeystate("Alt","P") == 1)
    r := r + 2
    
  if (getkeystate("Ctrl","P") == 1)
    r:= r + 4
    
  if (getkeystate("Shift","P") == 1)
    r:= r + 8
    
  if (getkeystate("LWin","P") == 1)
    r:= r + 16
    
  if (getkeystate("RWin","P") == 1)
    r:= r + 16

  return r
}
;--------------------------------- openShell ---------------------------------
openShell(commands) {
; not used
  shell := ComObjCreate("WScript.Shell")
  exec := shell.Exec(ComSpec " /Q /K echo off")
  exec.StdIn.WriteLine(commands "`nexit") 
  r := exec.StdOut.ReadAll()
  msgbox, %r%
  
  return
}
;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage() {
    PID := DllCall("GetCurrentProcessId")
    size := 440
    VarSetCapacity(pmcex,size,0)
    ret := ""
    
    hProcess := DllCall( "OpenProcess", UInt,0x400|0x0010,Int,0,Ptr,PID, Ptr )
    if (hProcess)
    {
        if (DllCall("psapi.dll\GetProcessMemoryInfo", Ptr, hProcess, Ptr, &pmcex, UInt,size))
            ret := Round(NumGet(pmcex, (A_PtrSize=8 ? "16" : "12"), "UInt") / 1024**2, 2)
        DllCall("CloseHandle", Ptr, hProcess)
    }
    return % ret
}
;-------------------------------- wrkPath --------------------------------
wrkPath(p){
  global wrkdir
  
  r := wrkdir . p
    
  return r
}
;------------------------------- pathToAbsolut -------------------------------
pathToAbsolut(p){
  
  r := p
  if (!InStr(p, ":"))
    r := wrkPath(p)
    
  if (SubStr(r,0,1) != "\")
    r .= "\"
    
  return r
}
;--------------------------------- WinCenter ---------------------------------
; from: https://www.autohotkey.com/board/topic/92757-win-center/
WinCenter(hMain, hChild, Visible := 1) {
    DetectHiddenWindows On
    WinGetPos, X, Y, W, H, ahk_ID %hMain%
    WinGetPos, _X, _Y, _W, _H, ahk_ID %hChild%
    If Visible {
        SysGet, MWA, MonitorWorkArea, % WinMonitor(hMain)
        X := X+(W-_W)//2, X := X < MWALeft ? MWALeft+5 : X, X := (X + _W) > MWARight ? MWARight-_W-5 : X
        Y := Y+(H-_H)//2, Y := Y < MWATop ? MWATop+5 : Y, Y := (Y + _H) > MWABottom ? MWABottom-_H-5 : Y
    } Else X := X+(W-_W)//2, Y := Y+(H-_H)//2
    WinMove, ahk_ID %hChild%,, %X%, %Y%
    WinShow, ahk_ID %hChild%
}
;-------------------------------- WinMonitor --------------------------------
WinMonitor(hwnd, Center := 1) {
    SysGet, MonitorCount, 80
    WinGetPos, X, Y, W, H, ahk_ID %hwnd%
    Center ? (X := X+(W//2), Y := Y+(H//2))
    loop %MonitorCount% {
      SysGet, Mon, Monitor, %A_Index%
      if (X >= MonLeft && X <= MonRight && Y >= MonTop && Y <= MonBottom)
          Return A_Index
    }
}
;---------------------------- editDirectoriesFile ----------------------------
editDirectoriesFile(){
  global editTextFileFilename, directoriesFile
  
  editTextFileFilename:= directoriesFile
  editTextFile()
  
  return
}
;----------------------------- editShortcutsFile -----------------------------
editShortcutsFile(){
  global editTextFileFilename, shortcutsFile
  
  editTextFileFilename:= shortcutsFile
  editTextFile()
  
  return
}
;------------------------------ editConfigFile ------------------------------
editConfigFile(){
  global editTextFileFilename, configFile
  
  editTextFileFilename:= configFile
  editTextFile()
  
  return
}
;------------------------------- editTextFile -------------------------------
; non SCI version
editTextFile(){
  global editTextFileFilename, editTextFileContent, clientWidth, clientHeight
  
  hideWindow()

  if (FileExist(editTextFileFilename)){
    FileRead, editTextFileContent, %editTextFileFilename%
    borderX := 10
    borderY := 50
    
    h := clientHeight - borderY
    w := clientWidth - borderX
    
    gui, editTextFile:new, +resize +AlwaysOnTop,Edit (autosave on close): %editTextFileFilename%
    gui, editTextFile:Font, s9,Segoe UI
    gui, editTextFile:Add, edit, x0 y0 w0 h0
    gui, editTextFile:add, edit, h%h% w%w% VeditTextFileContent,%editTextFileContent%
    
    gui, editTextFile:show, center autosize
  } else {
    msgbox, Error, file not found: %editTextFileFilename% !
  }

  return
}
;--------------------------- editTextFileGuiClose ---------------------------
editTextFileGuiClose(){
  global appname, editTextFileFilename, editTextFileContent
  
  gui, editTextFile:submit, nohide
  
  if (FileExist(editTextFileFilename)){
    FileDelete, %editTextFileFilename%
  }
  
  FileAppend, %editTextFileContent%, %editTextFileFilename%
  
  restartStartdelayedEdit()
  
  return
}
;---------------------------- editTextFileGuiSize ----------------------------
editTextFileGuiSize(){

   if (A_EventInfo != 1) {
    editTextFileWidth := A_GuiWidth
    editTextFileHeight := A_GuiHeight

    borderX := 10
    borderY := 50
    
    w := editTextFileWidth - borderX
    h := editTextFileHeight - borderY

    GuiControl, Move, editTextFileContent, h%h% w%w%
  }

  return
}
;-------------------------- openAutostartFolderUser --------------------------
openAutostartFolderUser(){
  run, shell:startup 
  return
}
;------------------------- openAutostartFolderAdmin -------------------------
openAutostartFolderAdmin(){
  run, explore C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
  return
}

;-------------------------------- openGodMode --------------------------------
openGodMode(){
  run,shell:::{ED7BA470-8E54-465E-825C-99712043E01C}
  
  return
}
;-------------------------- restartStartdelayedEdit --------------------------
restartStartdelayedEdit(){
  ; restarts startdelayedEdit.exe
  
  global hMain, app

  saveGuiData()
  showHintColored(hMain, "startdelayedEdit.exe restart!",3000,"cFF0000","c00FF00")
  
  run, startdelayedEdit.exe

  ExitApp
}
;---------------------------------- restart ----------------------------------
restart(){
  saveGuiData()
  sleep, 2000
  reload
  
  return
}
;--------------------------------- errorExit ---------------------------------
errorExit(theMsgArr, clp := "") {

  msgComplete := ""
  for index, element in theMsgArr
  {
    msgComplete .= element . "`n"
  }
  msgbox,48,ERROR,%msgComplete%

  saveGuiData()
  sleep, 2000

  exit()
}
;----------------------------------- exit -----------------------------------
exit() {
  global hMain, app
  
  saveGuiData()
  sleep, 2000
  
  ExitApp
}
;----------------------------------------------------------------------------
  