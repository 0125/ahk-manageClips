/*
todo:
    - do last:
        - gather remaining features from current design document and github
        - cleanup, anything that can be cleaned up :P
        - update design document
*/
scriptRequirementsInfo=
(
Script requirements:
- Have vlc installed

VLC settings:
- Loop single file
- Allow only one instance
- (optional) Do not resize interface to video size
)

#SingleInstance, Force
OnExit("ExitFunc")
global settings := [] ; settings object
global settingsFile := A_ScriptDir "\settings.json" ; settings file
global review ; holds class_review
global g_guiFolderSelect_Mode ; source or destination
global g_guiFolderSelect_TreeviewSelectedFullPath ; full path of currently selected treeview item
global g_debug := false ; enable debugging options

If (g_debug) {
    Gosub, debug
    ; msgbox end of script
    return
}

msgbox, 64, , % scriptRequirementsInfo
loadSettings()
folderSelection()
return

debug:
    loadSettings()

    settings.vlcExe := "D:\Apps\VLC\vlc.exe"
    settings.sourceRoot := "D:\Downloads\workfolderVlcManager"
    settings.sourceFolder := "D:\Downloads\workfolderVlcManager\Battlefield 4"
    settings.destinationRoot := "D:\Downloads\workfolderVlcManager\Sorted"
    settings.destinationFolder := "D:\Downloads\workfolderVlcManager\Sorted\BF4"
    settings.forwardSeconds := "50"

    g_guiFolderSelect_Mode := "destination"
    guiFolderSelect("source")
    ; guiReview("show")
    ; guiReview("some text")
    ; review := new class_reviewFolder(settings.sourceFolder)
return

~^s::reload

f1::review.debugMethod()

#Include, <JSON>
#Include, %A_ScriptDir%\inc
#Include, functions.ahk
#Include, guiReview.ahk
#Include, guiFolderSelect.ahk
#Include, class_reviewFolder.ahk