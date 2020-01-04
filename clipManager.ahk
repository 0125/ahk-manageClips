/*
todo:
    optional features
        - stats: session & total stats and the option to reset all stats. class & class gui
        guiReview: 
            - contextmenu/button/other option to open source or destination root
            - grey out undo button when there is nothing to undo needs to receive information from vlc class which could be done by making it global
*/

; mediainfo.dll needs to be the same version as autohotkey, 64 or 32 bit
#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
OnExit("ExitFunc")
DllCall( "LoadLibrary", Str, A_ScriptDir "\MediaInfo.dll" )
global g_debug := false
global g_recycleScriptPath := A_ScriptDir "\recycleClips.ahk"
global settings := []
loadSettings()
global review := new reviewClass
return

#Include, <JSON>
#Include, <CommandFunctions>
#Include, %A_ScriptDir%\inc
#Include, class fileHandler.ahk
#Include, class gui.ahk
#Include, class guiReview.ahk
#Include, class review.ahk
#Include, class vlc.ahk
#Include, functions.ahk
#Include, guiSetRootDirs.ahk

~^s::reload