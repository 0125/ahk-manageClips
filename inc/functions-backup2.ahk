class class_reviewFolder {
    __New(input) {
        this.folder := input
        this.deletedFiles := [] ; store deleted files to be able to restore them

        If (folderExist(this.folder)) {
            this.recycleDeletedFiles() ; recycle files marked for deletion
            this.review() ; review folder
        }
    }

    review() {
        ; search folder for list of files to review
        this.files := []
        Loop, Files, % this.folder "\*.mp4"
            this.files.push(A_LoopFileFullPath)

        ; check if any files were found
        If !(this.files.length()) {
            msgbox, 64, , % A_ThisFunc ": Specified folder does not contain any mp4 files"
            return
        }

        this.playNextFile() ; select a file and play it
        guiReview("show")
    }

    playNextFile() {
        this.selectNextFile() ; take a file to review from the file list
        this.playFile() ; play file in vlc
    }

    selectNextFile() {
        this.file := "" ; deselect current file
        
        ; check if a file is available
        If !(this.files.length()) {
            msgbox, 64, , % A_ThisFunc ": No files remaining in folder"
            guiReview("close") ; close review gui
            this.recycleDeletedFiles() ; recycle files marked for deletion
            reload
            return
        }
        this.file := this.files.pop()
    }

    deleteFile() {
        ; check if a file is available for deletion
        If !FileExist(this.file) {
            msgbox, 64, , % A_ThisFunc ": No file selected"
            return
        }

        vlcPlayback("stop")

        ; rename file to schedule it for deletion
        SplitPath, % this.file, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        deletedFilename := OutDir "\deleted." OutFileName
        FileMove, % this.file, % deletedFilename
        this.deletedFiles.push(deletedFilename) ; store deleted file to be able to restore it

        this.playNextFile() ; select a file and play it
    }

    undoDeleteFile() {
        ; check if a file is available for undeletion
        If !(this.deletedFiles.length()) {
            msgbox, 64, , % A_ThisFunc ": No deleted files available"
            return
        }

        deletedFile := this.deletedFiles.pop() ; get last deleted file
        SplitPath, % deletedFile, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        restoredFile := OutDir "\" LTrim(OutFileName, "deleted.")
        FileMove, % deletedFile, % restoredFile ; restore file name
        this.files.push(restoredFile) ; add restored file to the file list
        this.playNextFile() ; select restored file and play it
    }

    playFile() {
        Run, % settings.vlcExe A_Space """" this.file """" ; play file in vlc
    }

    ; input = new file name
    keepFile(input) {
        SplitPath, % this.file, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        vlcPlayback("stop")
        FileMove, % this.file, % settings.destinationFolder "\" input "." OutExtension
        this.playNextFile() ; select next file and play it
    }

    recycleDeletedFiles() {
        Loop, Files, % this.folder "\*.mp4"
            If InStr(A_LoopFileFullPath, "deleted.")
                FileRecycle, % A_LoopFileFullPath
    }

    __Delete() {
        this.recycleDeletedFiles() ; recycle files marked for deletion
    }
}

guiReview(input := "") {
    static _guiReview, newFilename

    If !(_guiReview) or (input = "show") or (input = "") { ; setup gui for the first time
        ; properties
        gui guiReview: new
        gui guiReview: +labelguiReview_ +hwnd_guiReview

        ; controls
        gui guiReview: add, edit, w350 vnewFilename
        hotkey, IfWinActive, % "ahk_id " _guiReview
        hotkey, enter, guiReview_Keep
        hotkey, IfWinActive
        gui guiReview: add, button, w60 gguiReview_Play, Play
        gui guiReview: add, button, w60 gguiReview_Delete, Delete
        gui guiReview: add, button, w60 gguiReview_UndoDelete, Undo

        ; show
        gui guiReview: show
        return
    }

    If (input = "close") {
        gui guiReview: Destroy
    }

    guiReview_Play:
        review.playFile()
    return

    guiReview_Keep:
        gui guiReview: Submit, NoHide
        review.keepFile(newFilename)
        GuiControl guiReview:, Edit1, ; clear edit control
    return

    guiReview_Delete:
        review.deleteFile()
    return

    guiReview_UndoDelete:
        review.undoDeleteFile()
    return
}

vlcPlayback(input) {
    If (input = "stop")
        KeyStrokes = s

    ControlSend , Control, % KeyStrokes, ahk_exe vlc.exe

    If (input = "stop") { ; wait until vlc has fully closed the file because files cant be modified while open
        loop, {
            WinGetTitle, vlcWindowTitle, ahk_exe vlc.exe
            sleep 10
        } until !(InStr(vlcWindowTitle, "-"))
    }
}

guiFolderSelect(input) {
    static
    
    ; properties
    gui guiFolderSelect: Default ; set as default gui to be used by gui commands such as TV_Add
    gui guiFolderSelect: +hwnd_guiFolderSelect +labelguiFolderSelect_On
    
    margin := 10
    controlMaxWidth := 400

    ; controls
    gui guiFolderSelect: add, text, w350, Root folder
    gui guiFolderSelect: add, edit, % "w" controlMaxWidth-55 " vguiFolderSelect_TreeviewRoot section", E:\Videos\Game clips\Unsorted\1 sort these games
    gui guiFolderSelect: add, button, x+5 ys-1 gTestLabel w50, Browse

    guiFolderSelect_TreeviewImageListID := IL_Create(5)
    Loop 5 
        IL_Add(guiFolderSelect_TreeviewImageListID, "shell32.dll", A_Index)

    gui guiFolderSelect: add, text, w350 x%margin%, Source folder
    gui guiFolderSelect: add, treeview, w%controlMaxWidth% h350 AltSubmit gguiFolderSelect_Treeview ImageList%guiFolderSelect_TreeviewImageListID%
    Gosub guiFolderSelect_Treeview_Refresh

    ; show
    gui guiFolderSelect: show, ,  % input
    WinWaitClose, % "ahk_id" _guiFolderSelect
    return output

    guiFolderSelect_Treeview:
        TV_GetText(SelectedItemText, A_EventInfo)

        If (A_GuiEvent = "Normal") { ; left click
            ; msgbox Normal
        }
        If (A_GuiEvent = "DoubleClick") { ; right click
            output := getTreeViewSelectedFullPath(guiFolderSelect_TreeviewRoot, SelectedItemText, A_EventInfo)
            gui guiFolderSelect: Submit
            ; msgbox DoubleClick
        }
        If (A_GuiEvent = "RightClick") { ; right click
            ; msgbox RightClick
        }
    return

    guiFolderSelect_Treeview_Refresh:
        gui guiFolderSelect: Submit, NoHide

        If !folderExist(guiFolderSelect_TreeviewRoot)
            return

        TV_Delete() ; empty treeview
        AddSubFoldersToTree(guiFolderSelect_TreeviewRoot) ; populate treeview
    return

    TestLabel:
        Gosub guiFolderSelect_Treeview_Refresh
    return
}

getTreeViewSelectedFullPath(guiFolderSelect_TreeviewRoot, SelectedItemText, EventInfo) {
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
    SelectedFullPath := guiFolderSelect_TreeviewRoot "\" SelectedItemText
    return SelectedFullPath
}

AddSubFoldersToTree(Folder, ParentItemID = 0)
{
    ; This function adds to the TreeView all subfolders in the specified folder.
    ; It also calls itself recursively to gather nested folders to any depth.
    Loop %Folder%\*.*, 2  ; Retrieve all of Folder's sub-folders.
        AddSubFoldersToTree(A_LoopFileFullPath, TV_Add(A_LoopFilename, ParentItemID, "Icon4 Expand"))
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