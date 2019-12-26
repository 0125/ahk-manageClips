#SingleInstance, force
#NoEnv

OnExit("ExitFunc")
global g_debug := false
global settings := []
loadSettings()
startReviewing()
return

#Include, <JSON>
#Include, <CommandFunctions>
#Include, %A_ScriptDir%\inc
#Include, class_Review.ahk
#Include, class_guiReview.ahk
#Include, class_vlc.ahk
#Include, guiSetRootDirs.ahk
#Include, subroutines.ahk
#Include, functions.ahk

~^s::reload