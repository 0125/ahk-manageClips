class class_FileHandler {
    LoadClips() {
        If !(FolderExist(settings.clipSourcePath)) {
            msgbox, 4160, , % A_ThisFunc ": Source folder does not exist!`n`nCurrently unhandled, closing.."
            exitapp
        }
        
        this.changes := {}

        ; get clips list
        this.clips := {}
        Loop, Files, % settings.clipSourcePath "\*.mp4", FR ; loop all files including subfolders
            this.clips.push(A_LoopFileFullPath)

        this._NextClip()
    }

    _NextClip() {
        If (this.clips.length() = 0) {
            msgbox, 4160, , % A_ThisFunc ": Finished reviewing!"
            reload
            pause ; prevent thread from continuing
        }
        
        this.clip := this.clips.pop()

        If !(FileExist(this.clip))
            msgbox, 4160, , % A_ThisFunc ": Currently selected clip does not exist!"

        ; update manage gui
        SplitPath, % this.clip, OutFileName, OutDir, OutExtension, OutNameNoExt
        manageGui.SetText("edit1", OutNameNoExt)
        manageGui.SelectText("Edit1")
        _manageGui := manageGui.hwnd
        If (this.changes.length())
            GuiControl %_manageGui%: Enable, Undo
        else
            GuiControl %_manageGui%: Disable, Undo
        manageGui.SetDefault() ; set default gui for SB_SetText
        SB_SetText("Remaining:`t`t" this.clips.length() + 1, 1)
        return
    }

    Save() {
        vlc.Stop()

        SplitPath, % this.clip, clipOutFileName, clipOutDir, clipOutExtension, clipOutNameNoExt

        ; get game folder
        game := StrReplace(this.clip, settings.clipSourcePath "\")
        game := SubStr(game, 1, InStr(game, "\") - 1)
        FileCreateDir, % settings.clipDestinationPath "\" game

        newPath := settings.clipDestinationPath "\" game "\" manageGui.GetText("Edit1") "." clipOutExtension

        FileMove, % this.clip, % newPath, 0
        If (ErrorLevel) {
            msgbox, 4160, , % A_ThisFunc ": FileMove error! `n`nPossible reasons: `n`n- Target save path '" newPath "' already exists `n`n- File name is too long`n`n- Strange characters were used, prohibited: \ / : * ? "" < > |"
            return false
        }

        this.changes.push({oldPath:this.clip, newPath:newPath})

        stats.Add()
        this._NextClip()
        return true
    }

    Delete() {
        If !FileExist(this.clip)
            return false

        vlc.Stop()

        SplitPath, % this.clip, OutFileName, OutDir, OutExtension, OutNameNoExt
        newPath := OutDir "\" OutFileName ".deleted"
        FileMove, % this.clip, % newPath, 0

        this.changes.push({oldPath:this.clip, newPath:newPath})

        stats.Add()
        this._NextClip()
        return true
    }

    Undo() {
        ; if no changes available
        If !(this.changes.length())
            return false

        vlc.Stop()

        change := this.changes.pop()
        
        FileMove, % change.newPath, % change.oldPath
        
        this.clips.push(this.clip) ; re-add currently selected clip back to queue
        this.clips.push(change.oldPath) ; re-add undone cip back to queue

        stats.Del()
        this._NextClip() ; pick next clip from the queue, aka the one just re-added
        return true
    }
}