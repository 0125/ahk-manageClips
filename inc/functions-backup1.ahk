guiReviewRecordings(input) {
    static currentRecordingFullPath, currentRecordingFileName, newFileName, deletedFiles
    
    deletedFiles := [] ; keep track of deleted files so they can be restored or deleted
    ; get list of files to review
    recordings := []
    Loop, Files, % input "\*.mp4"
        recordings.push(A_LoopFileFullPath)
    
    sourceRootMp4Count := getDirectoryMp4Count(settings.sourceRoot, "recurse")
    sourceFolderMp4Count := recordings.length()
    
    ; properties
    gui guiReviewRecordings: +labelguiReviewRecordings_ +hwnd_guiReviewRecordings

    ; controls
    gui guiReviewRecordings: add, edit, w350 vnewFileName gguiReviewRecordings_Keep
    hotkey, IfWinActive, % "ahk_id " _guiReviewRecordings
    hotkey, enter, guiReviewRecordings_Keep
    hotkey, IfWinActive
    gui guiReviewRecordings: add, button, w60 gguiReviewRecordings_Play, Play
    gui guiReviewRecordings: add, button, w60 gguiReviewRecordings_Delete, Delete
    gui guiReviewRecordings: add, button, w60, Undo

    ; show
    gui guiReviewRecordings: show

    Gosub guiReviewRecordings_RecycleFiles
    Gosub guiReviewRecordings_NextRecording
    return

    guiReviewRecordings_NextRecording: ; play the next file
        currentRecordingFullPath := recordings.pop()
        SplitPath, % currentRecordingFullPath, OutFileName, OutDir, OutExtension, currentRecordingFileName, OutDrive
        GuiControl guiReviewRecordings: -g, newFileName ; prevent GuiControl from triggering g label
        GuiControl guiReviewRecordings:, newFileName, % currentRecordingFileName ; set edit control to current file name
        GuiControl guiReviewRecordings: +g, newFileName ; prevent GuiControl from triggering g label
        Gosub guiReviewRecordings_Play
    return
    
    guiReviewRecordings_Keep:
        gui guiReviewRecordings: Submit, NoHide
        If (newFileName = currentRecordingFileName) {
            msgbox, 64, , New file name is identical to the old one
            return
        }
    return

    guiReviewRecordings_Play:
        Run, % settings.vlcFolder "\vlc.exe """ currentRecordingFullPath """" ; run vlc

        If (_vlc = "") {
            WinWait, ahk_exe vlc.exe ; wait till vlc is open
            _vlc := WinExist("ahk_exe vlc.exe") ; get vlc handle
            gui guiReviewRecordings: +Owner%_vlc% ; set gui as owner of vlc so it stays on top
            WinActivate, % "ahk_id " _guiReviewRecordings ; put gui infront of vlc
        }
    return

    guiReviewRecordings_Delete:
        vlcPlayback("stop")

        SplitPath, % currentRecordingFullPath, OutFileName, OutDir, OutExtension, OutFileNameNoExt, OutDrive
        deletedFileName := OutDir "\deleted." OutFileNameNoExt "." OutExtension

        deletedFiles.push(deletedFileName)

        msgbox % json.dump(deletedFiles,,2)

        loop, { ; keep trying to rename file until its fully closed by vlc
            FileMove, % currentRecordingFullPath, % deletedFileName
            sleep 5
        } Until ErrorLevel = false

        msgbox end of delete
    return

    guiReviewRecordings_RecycleFiles:
        Loop, Files, % settings.sourceFolder "\*.mp4"
            If InStr(A_LoopFileFullPath, "deleted.")
                FileRecycle, % A_LoopFileFullPath
    return
}