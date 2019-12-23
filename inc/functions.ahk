ExitFunc(ExitReason, ExitCode) {
    guiReview("savePos")
    guiFolderSelect("savePos")

    If (settings.vlcExe) ; if vlc path isnt available the rest isnt either, prevents saving empty file during debbuging
        saveSettings()
}

loadSettings() {
    ; load object from file
    If (FileExist(settingsFile)) {
        FileRead, OutputVar, % settingsFile
        OutputObj := json.load(OutputVar,,2)
        If (IsObject(OutputObj))
            settings := json.load(OutputVar,,2)
    }

    ; get required variables if not available
    If !(settings.vlcExe){
        FileSelectFile, SelectedFile, 3, , Select VLC executable, dd (*.exe)
        if !(SelectedFile) or !InStr(SelectedFile, "vlc.exe") {
            msgbox, 64, , % A_ThisFunc ": VLC executable was not specified`n`nClosing.."
            exitapp
        }
        settings.vlcExe := SelectedFile
    }
}

saveSettings() {
    FileDelete, % settingsFile
    FileAppend, % json.dump(settings,,2), % settingsFile
}

folderEmpty(input) {
    If !folderExist(input) {
        msgbox, 64, , % A_ThisFunc ": Folder does not exist"
        return
    }

    input := RTrim(input, "\")

    Loop, Files, % input "\*.*", FR ; recurse files and directories to see if anything exists in this folder
        return false ; if any files were looped inside the specified folder, its not empty
    return true
}

folderselection() {
    ; source
    g_guiFolderSelect_Mode := "source"
    SelectedFolder := guiFolderSelect("source")
    SplitPath, SelectedFolder, OutFileName, OutDir
    settings.sourceRoot := OutDir

    If !(getDirectoryMp4Count(SelectedFolder)) {
        Loop, Files, % SelectedFolder "\*.*", FR ; recurse files and directories to see if anything exists in this folder
            foundMatch := A_LoopFileFullPath 
        
        If !(folderEmpty(SelectedFolder))
            msgbox, 64, , % A_ThisFunc ": Selected folder does not contain mp4 recordings" ; dont delete folder since it contains files
        else {
            msgbox, 68, , % A_ThisFunc ": Selected folder is completely empty`n`nDelete folder?" ; ask to delete folder because its empty
            IfMsgBox, Yes
                FileRecycle, % SelectedFolder
        }
        folderselection()
    }

    settings.sourceFolder := SelectedFolder

    ; destination
    g_guiFolderSelect_Mode := "destination"
    SelectedFolder := guiFolderSelect("destination")

    SplitPath, SelectedFolder, OutFileName, OutDir
    settings.DestinationRoot := OutDir
    settings.DestinationFolder := SelectedFolder

    review := new class_reviewFolder(settings.sourceFolder)
}

/*
vlc skips:
shift + right           3 seconds
right                   10 seconds
ctrl + right            60 seconds
ctrl + alt + right      300 seconds
*/
vlcForward() {
    If !(settings.forwardSeconds)
        return

    remainingSeconds := settings.forwardSeconds

    ; calculate skips
    loop, {
        If (remainingSeconds - 300 < 0) ; check if skipping this amount of seconds goes below 0
            break
        remainingSeconds -= 300
        300skip++
    }

    loop, {
        If (remainingSeconds - 60 < 0) ; check if skipping this amount of seconds goes below 0
            break
        remainingSeconds -= 60
        60skip++
    }

    loop, {
        If (remainingSeconds - 10 < 0) ; check if skipping this amount of seconds goes below 0
            break
        remainingSeconds -= 10
        10skip++
    }

    ; execute skips
    loop, % 300skip
        vlcPlayback("300skip")

    loop, % 60skip
        vlcPlayback("60skip")

    loop, % 10skip
        vlcPlayback("10skip")
}

vlcPlayback(input) {
    If (input = "stop")
        KeyStrokes = s
    If (input = "300skip")
        KeyStrokes = ^!{right}
    If (input = "60skip")
        KeyStrokes = ^{right}
    If (input = "10skip")
        KeyStrokes = {right}

    ControlSend , Control, % KeyStrokes, ahk_exe vlc.exe

    If (input = "stop") { ; wait until vlc has fully closed the file because files cant be modified while open
        loop, {
            WinGetTitle, vlcWindowTitle, ahk_exe vlc.exe
            sleep 10
        } until !(InStr(vlcWindowTitle, "-"))
    }
}

getTreeViewSelectedFullPath(guiFolderSelect_Root, SelectedItemText, EventInfo) {
    TV_GetText(SelectedItemText, EventInfo)
    ParentID := EventInfo
    Loop  ; Build the full path to the selected folder.
    {
        ParentID := TV_GetParent(ParentID)
        if not ParentID  ; No more ancestors.
            break
        TV_GetText(ParentText, ParentID)
        SelectedItemText := ParentText "\" SelectedItemText
    }
    SelectedFullPath := guiFolderSelect_Root "\" SelectedItemText
    return SelectedFullPath
}

AddSubFoldersToTree(Folder, ParentItemID = 0, selectItem = "")
{
    ; This function adds to the TreeView all subfolders in the specified folder.
    ; It also calls itself recursively to gather nested folders to any depth.
    Loop %Folder%\*.*, 2  ; Retrieve all of Folder's sub-folders.
    {
        If (A_LoopFileName = selectItem)
            AddSubFoldersToTree(A_LoopFileFullPath, TV_Add(A_LoopFilename, ParentItemID, "Icon4 Expand Select"))
        else
            AddSubFoldersToTree(A_LoopFileFullPath, TV_Add(A_LoopFilename, ParentItemID, "Icon4 Expand"))
    }
}

folderContainsFileType(folder, fileType) {
    Loop, Files, % folder "\*." fileType
    {
        return true
    }
    return false
}

folderExist(input) {
    if InStr(FileExist(input), "D")
        return true
    return false
}

getDirectoryMp4Count(input, recurse:="") {
    If (recurse)
        Loop, Files, % input "\*.mp4", R
            count++
    else
        Loop, Files, % input "\*.mp4"
            count++
    return count
}