#SingleInstance, force

OnExit("ExitFunc")
global g_debug := false
global settings := []
global g__review := false                               ; holds class instance for saving moving scheduled deleted files to recycle bin on script close
global g__guiReview := false                            ; holds class instance for saving position
global g__guiStats  := false                            ; holds class instance for saving position
global g__stats  := false                               ; holds class instance for saving stats when script closes
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