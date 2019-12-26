ExitFunc(ExitReason, ExitCode) {
    saveSettings()
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

startReviewing() {
    If !(g_debug)
        guiSetRootDirs()

    startReview := new class_review

    If (g_debug) {
        msgbox end of script
    }
}