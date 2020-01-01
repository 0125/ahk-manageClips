class reviewClass {
    __New() {
        ; get source and destination folders
        If (g_debug) {
            ; settings.sourceRootDir := "D:\Downloads\workFolderGameClips\Unsorted"
            ; settings.destinationRootDir := "D:\Downloads\workFolderGameClips\Sorted"

            settings.sourceRootDir := "E:\Videos\Game clips\Unsorted.l4d2"
            settings.destinationRootDir := "E:\Videos\Game clips\Sorted"
        }
        else
            guiSetRootDirs()

        ; setup classes
        this.vlc := new vlcClass
        this.file := new fileHandlerClass
        this.guiReview := new guiReviewClass("Review")
        this.guiReview.Setup()

        ; start reviewing the first clip
        this._PlayNextFile()
    }

    __Delete() {
        ; save gui position
        this.guiReview.SavePos()

        ; move deleted files into the recycle bin,
        ; using a separate script so this one doesnt hang when there is a lot of files
        run % A_AhkPath A_Space g_recycleScriptPath A_Space """" settings.sourceRootDir """"
    }

    Play() {
        ; play clip
        this.vlc.Play(this.clip)
    }

    SaveAs() {
        ; close clip in vlc so it can be modified
        this.vlc.Stop(this.clip)

        ; prompt destination path
        FileSelectFile, SelectedFile, S3, , Save As, Mp4 (*.mp4)
        if (SelectedFile = "")
            return

        ; save file to destination
        FileCopy, % this.clip, % SelectedFile ".mp4"

        ; continue playing current clip
        this.Play()
    }

    Save() {
        ; close clip in vlc so it can be modified
        this.vlc.Stop(this.clip)

        ; use user input to save file
        result := this.file.Save(this.guiReview.GetText())

        ; check if the file was saved successfully
        If !(result)
            return

        ; start reviewing the next file
        this._PlayNextFile()
    }

    Delete() {
        ; close clip in vlc so it can be modified
        this.vlc.Stop(this.clip)
        
        ; delete file
        this.file.Delete()

        ; start reviewing the next file
        this._PlayNextFile()
    }

    Undo() {
        ; close clip in vlc so it can be modified
        this.vlc.Stop(this.clip)
        
        ; undo latest change
        result := this.file.Undo()

        ; continue reviewing
        If (result)
            this._PlayNextFile()
        else
            this.Play()
    }

    _PlayNextFile() {
        this.clip := this.file.Get()
        this.Play()
    }
}