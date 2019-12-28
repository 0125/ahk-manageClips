ExitFunc(ExitReason, ExitCode) {
    g__guiReview.SavePos()
    g__review.RecycleFiles()
    g__guiStats.SavePos()
    g__Stats.SaveStats()
    
    saveSettings()
    class_vlc._Kill()
}

loadSettings() {
    ; load object from file
    If (FileExist(A_ScriptDir "\settings.json")) {
        FileRead, OutputVar, % A_ScriptDir "\settings.json"
        OutputObj := json.load(OutputVar,,2)
        If (IsObject(OutputObj))
            settings := json.load(OutputVar,,2)
    }

    If !(settings.vlcExePath)
        setVlcPath()

    If !(settings.totalSecondsElapsed) ; += expression doesnt work with empty variables so set to 0 if not available
        settings.totalSecondsElapsed := 0
    If !(settings.totalHandledFiles) ; += expression doesnt work with empty variables so set to 0 if not available
        settings.totalHandledFiles := 0
}

saveSettings() {
    FileDelete, % A_ScriptDir "\settings.json"
    FileAppend, % json.dump(settings,,2), % A_ScriptDir "\settings.json"
}

setVlcPath() {
    FileSelectFile, SelectedFile, 3, , Open a file, Executables (*.exe)
    if (SelectedFile = "")
        exitapp
    if !(InStr(SelectedFile, "vlc.exe")) {
        msgbox, 64, , % A_ThisFunc ": Incorrect file specified, select vlc.exe"
        setVlcPath()
        return
    }
    settings.vlcExePath := SelectedFile
}

FormatTimeSeconds(input) {
    If input is not Integer
    {
        msgbox, 64, , % A_ThisFunc ": Incorrect input format. Input is not integer`n`nClosing.."
        exitapp
    }
    
    ; format amount of seconds for displaying
    displayTime := g_nullTimeStamp
    EnvAdd, displayTime, input, Seconds
    FormatTime, OutputVar , % displayTime, HH:mm:ss
    return OutputVar
}

startReviewing() {
    If (g_debug) {
        ; myStats := new class_Stats(50)
        startReview := new class_review
        ; msgbox end of script
        return
    }


    guiSetRootDirs()
    startReview := new class_review
}