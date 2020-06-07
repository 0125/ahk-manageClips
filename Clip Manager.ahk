; misc
    #SingleInstance, force
    #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
    OnExit("ExitFunc")
    FileCreateDir, %A_ScriptDir%\res
    FileInstall, D:\Programming and projects\ahk-clips-manager\res\MediaInfo.dll, %A_ScriptDir%\res\MediaInfo.dll
    FileInstall, D:\Programming and projects\ahk-clips-manager\res\cleanSourceDirectory.ahk, %A_ScriptDir%\res\cleanSourceDirectory.ahk
    DllCall( "LoadLibrary", Str, A_ScriptDir "\res\MediaInfo.dll" ) ; mediainfo.dll needs to be the same version as autohotkey, 64 or 32 bit
    If (A_IsCompiled) {
        Menu, Tray, NoStandard ; remove default compiled tray menu
        Menu, Tray, Add, Reload, btnReloadScript ; remove default compiled tray menu
        Menu, Tray, Add, Exit, btnExitScript ; remove default compiled tray menu
    }

; global vars
    global settings := {}
    FileRead, Input, % A_ScriptDir "\settings.json"
    If (Input) and !(Input = "{}") and !(Input = """" """") ; double quotes
        settings := json.load(Input)
    global manageGui := new class_manageGui("Clip Manager")
    global vlc := new class_vlc
    global file := new class_FileHandler
    global stats := new class_stats

; autoexec
    pathGui := new class_pathGui("Please choose clip folders")
    pathGui.Setup() ; prompt user for source and destination folders
    manageGui.Setup()
    file.LoadClips() ; get clip list from specified source path
    vlc.Play() ; play the first clip

    ; workaround for vlc bug, sometimes mixes up the file received by 'run x'. throws 'Errors' dialog
    loop, {
        WinWait, Errors
        WinClose, Errors
        manageGui.Play() ; playing the clip again fixes it
    }
return

; menu buttons
    dummyHandler:
    return

    btnExitScript:
        exitapp
    return

    btnReloadScript:
        reload
    return

; global hotkeys
    ~^s::reload

; includes
    #Include, <json>
    #Include, <class gui>
    #Include, %A_ScriptDir%\inc
    #Include, class FileHandler.ahk
    #Include, class manageGui.ahk
    #Include, class pathGui.ahk
    #Include, class stats.ahk
    #Include, class trackTime.ahk
    #Include, class vlc.ahk
    #Include, functions.ahk