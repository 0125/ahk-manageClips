class class_reviewFolder {
    __New(input) {
        this.folder := input
        this.changes := [] ; store changes to be able to restore them

        If (folderExist(this.folder)) {
            this.recycleDeletedFiles() ; recycle files marked for deletion
            this.review() ; review folder
        }
        else {
            msgbox, 64, , % A_ThisFunc ": Specified folder does not exist"
            folderselection()
            return
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
            folderselection()
            return
        }

        guiReview("show")
        this.playNextFile() ; select a file and play it
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
            If (folderEmpty(settings.sourceFolder))
                FileRecycle, % settings.sourceFolder
            folderselection()
            return
        }
        this.file := this.files.pop()

        SplitPath, % this.file, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        guiReview(OutNameNoExt)
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
        newPath := OutDir "\deleted." OutFileName
        FileMove, % this.file, % newPath
        this.changes.push({newPath: newPath, oldPath: this.file}) ; store changes

        this.playNextFile() ; select a file and play it
    }

    undo() {
        ; check if a change is available for undoing
        If !(this.changes.length()) {
            msgbox, 64, , % A_ThisFunc ": Nothing to undo"
            return
        }

        vlcPlayback("stop")

        change := this.changes.pop() ; get last change

        ; undo change
        FileMove, % change.newPath, % change.oldPath
        If (ErrorLevel) {
            msgbox, 64, , % A_ThisFunc ": FileMove ErrorLeveL: " ErrorLevel
            return
        }

        this.files.push(this.file) ; add current file back to the file list
        this.files.push(change.oldPath) ; add undone file to the file list
        this.playNextFile() ; select restored file and play it
    }

    playFile() {
        Run, % settings.vlcExe A_Space """" this.file """" ; play file in vlc
        sleep 150 ; wait till vlc has it opened
        vlcForward() ; forward the clip
    }

    ; input = new file name
    keepFile(input) {
        SplitPath, % this.file, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        vlcPlayback("stop")
        newPath := settings.destinationFolder "\" input "." OutExtension
        FileMove, % this.file, % newPath
        this.changes.push({newPath: newPath, oldPath: this.file}) ; store changes
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

    debugMethod() {
        msgbox % json.dump(this.files,,2)
    }
}