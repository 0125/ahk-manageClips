class fileHandlerClass {

    __New() {
        ; get list of files
        this.fileList := []
        loop, files, % settings.sourceRootDir "\*.mp4", FR
            this.fileList.push(A_LoopFileFullPath)

        ; create object for storing changes so they can be undone
        this.changes := []

        ; check if files are available
        this._checkFilesAvailable()
    }

    Get() {
        ; check if files are available
        this._checkFilesAvailable()
        
        ; get the next file
        this.file := this.fileList.pop()

        return this.file
    }

    Delete() {
        ; build path to rename file to
        SplitPath, % this.file, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        newPath := OutDir "\" OutFileName ".deleted"

        ; schedule file for deletion by renaming it
    FileMove, % this.file, % newPath

        ; save change
        this.changes.push({oldPath: this.file, newPath: newPath})
    }

    Save(input) { ; input = new file name
        ; get destination folder
        SplitPath, % this.file, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        SlashedPath := StrSplit(OutDir, "\")
        destinationFolder := SlashedPath[SlashedPath.length()] ; get destination folder
        FileCreateDir, % settings.destinationRootDir "\" destinationFolder

        ; build destination path
        newPath := settings.destinationRootDir "\" destinationFolder "\" input "." OutExtension

        ; save file
        FileMove, % this.file, % newPath, 0
        If (ErrorLevel) {
            msgbox, 64, , % A_ThisFunc ": FileMove error! `n`nProbable reasons: `n`n- Target save path '" newPath "' already exists `n`n - Strange characters were used. Prohibited: \ / : * ? "" < > |"
            return false
        }

        ; save change
        this.changes.push({oldPath: this.file, newPath: newPath})
        return true
    }

    Undo() {
        ; check if any changes were made
        If !(this.changes.length()) {
            msgbox, 64, , % A_ThisFunc ": Nothing to undo!"
            return false
        }

        ; add current file back to review list
        this.fileList.push(this.file)

        ; get latest change
        input := this.changes.pop()

        ; undo the change
        FileMove % input.newPath, % input.oldPath

        ; add restored file back to review list
        this.fileList.push(input.oldPath)
        return true
    }

    _checkFilesAvailable() {
        If !(this.fileList.length()) {
            msgbox, 64, , % A_ThisFunc ": No mp4 files found in source root!`n`nReloading.."
            reload
            return
        }
    }
}