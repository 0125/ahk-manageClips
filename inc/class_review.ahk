; reviews a folder
class class_review {
    __New() {
        ; get list of all files to review
        this.files := []
        this.fileChanges := [] ; keep track of file changes so they can be undone
        loop, files, % settings.sourceRoot "\*.*", D
        {
            loop, files, % A_LoopFileFullPath "\*.mp4", F
                this.files.push(A_LoopFileFullPath)
        }
        
        ; check if video files are available
        If !(this.files.length()) {
            msgbox, 64, , % A_ThisFunc ": No mp4 files found in root"
            startReviewing()
            return
        }

        ; setup classes
        this.vlc := new class_vlc(this)
        this.guiReview := new class_guiReview(this)
        g__guiReview := this.guiReview ; holds class instance for saving position
        this.Stats := new class_stats(this.files.length())

        ; start reviewing the first file
        this._PlayNextFile()
    }

    SetGuiReviewOwner() {
        this.guiReview.SetGuiOwner(this.vlc.hwnd)
    }

    ShowStatsGui() {
        this.Stats.ShowGui()
    }

    Play() {
        this.vlc.play(this.file)

        this.vlc.ForwardPlayback()
    }

    SaveAs() {
        this.vlc.CloseFile(this.file)
        FileSelectFile, SelectedFile, S3, , Save As, MP4 (*.mp4)
        if (SelectedFile = "")
            return
        FileCopy, % this.file, % SelectedFile ".mp4"

        this.Play()
    }

    Save() {
        this.vlc.CloseFile(this.file) ; close file
        
        SplitPath, % this.file, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

        destinationFile := this.guiReview.getNewFileName()
        destinationFolder := SubStr(OutDir, InStr(OutDir, "\", , 0) + 1) ; destination folder is identical to source folder
        newPath := settings.destinationRoot "\" destinationFolder "\" destinationFile ".mp4"

        FileCreateDir, % settings.destinationRoot "\" destinationFolder ; create destination folder if it doesnt already exist

        this.fileChanges.push({oldPath: this.file, newPath: newPath})
        this.Stats.AddAction() ; register positive action
        FileMove, % this.file, % newPath

        this._PlayNextFile()
    }

    Delete() {
        this.vlc.CloseFile(this.file) ; close file
        
        SplitPath, % this.file, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

        newPath := OutDir "\" OutNameNoExt ".deleted"
        this.fileChanges.push({oldPath: this.file, newPath: newPath})
        this.Stats.AddAction() ; register positive action
        FileMove, % this.file, % newPath

        this._PlayNextFile()
    }

    Undo() {
        If !(this.fileChanges.length()) {
            msgbox, 64, , % A_ThisFunc ": Nothing to undo"
            return
        }
        input := this.fileChanges.pop()
        FileMove, % input.newPath, % input.oldPath

        this.Stats.RemoveAction() ; register negative action

        this._PlayNextFile()
    }

    _PlayNextFile() {
        this._getNextFile()
        this.Play()
    }

    _getNextFile() {
        this.file := this.files.pop()

        this.guiReview.Update(this.file)
    }
}