/*


*/

#SingleInstance, force

global g_debug := True  ; enables debugging

If g_debug {
    source := "E:\Videos\Game clips\Unsorted\1 sort these games"

    inputRecordingsPath()
    ; msgbox end of script
    return
}
source := inputRecordingsPath()
return

#Include, %A_ScriptDir%\inc
#Include, functions.ahk

~^s::reload