#SingleInstance, force
#NoEnv

OnExit("ExitFunc")
global g_debug := true
global settings := []
global g__guiReview           ; holds class instance for saving position
global g__guiStats            ; holds class instance for saving position
global g_nullTimeStamp := A_YYYY A_MM A_DD 00 00 00
loadSettings()
startReviewing()
return

#Include, <JSON>
#Include, <CommandFunctions>
#Include, %A_ScriptDir%\inc
#Include, class_stats.ahk
#Include, class_guiStats.ahk
#Include, class_Review.ahk
#Include, class_guiReview.ahk
#Include, class_vlc.ahk
#Include, guiSetRootDirs.ahk
#Include, subroutines.ahk
#Include, functions.ahk

~^s::reload