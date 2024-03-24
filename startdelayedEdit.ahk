/*
 *********************************************************************************
 * 
 * startdelayedEdit.ahk
 * 
 * all files are UTF-8 no BOM encoded
 * 
 * Version -> appVersion
 * 
 * Copyright (c) 2021 jvr.de. All rights reserved.
 *
 * Licens -> Licenses.txt
 * 
 *********************************************************************************
*/

/*
 *********************************************************************************
 * Just opens startdelayed in editmode
  *********************************************************************************
*/

#Requires AutoHotkey v1.0

#NoEnv
#Warn
#SingleInstance force

appname := "startdelayed"
extension := ".exe"

bit := (A_PtrSize=8 ? "64" : "32")

if (!A_IsUnicode)
  bit := "A" . bit

bitName := (bit="64" ? "" : bit)

toStart := appname  . bitName . extension


run, %toStart% editmode

exitApp


