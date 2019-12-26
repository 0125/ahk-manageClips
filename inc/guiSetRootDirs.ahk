; input = prompt
guiSetRootDirs() {
    ; properties
    Gui, New, +hwndhwnd
    Gui % hwnd ":+labelguiSetRootDirs_On"
    editWidth := 350
    btnWidth := 50
    margin := 5
    totalWidth := editWidth + btnWidth + (margin * 4)

    ; controls
    Gui % hwnd ":Add", GroupBox, % "w" totalWidth " h120", Select root folders
    Gui % hwnd ":Add", text, % "xp+" 9 " yp+" 20, Source
    Gui % hwnd ":Add", edit, % "w" editWidth " section", % settings.sourceRoot
    Gui % hwnd ":Add", button, % "x+" margin " ys-1 w" btnWidth " gguiSetRootDirs_BtnBrowseEdit1", Browse
    Gui % hwnd ":Add", text, xs, Destination
    Gui % hwnd ":Add", edit, % "w" editWidth " section", % settings.destinationRoot
    Gui % hwnd ":Add", button, % "x+" margin " ys-1 w" btnWidth " gguiSetRootDirs_BtnBrowseEdit2", Browse
    Gui % hwnd ":Add", button, % "x" 10 " w" totalWidth " gguiSetRootDirs_BtnSubmit", Save

    ; hotkeys
    hotkey, IfWinActive, % "ahk_id " hwnd
    hotkey, enter, guiSetRootDirs_BtnSubmit
    hotkey, IfWinActive

    ; show
    Gui % hwnd ":Show"
    ControlFocus, , % "ahk_id " hwnd ; unfocus edit field
    WinWaitClose, % "ahk_id " hwnd
    return
}

guiSetRootDirs_BtnBrowseEdit1:
    WinGetTitle, Title, A
    FileSelectFolder, Output, , , % Title
    If !FolderExist(Output)
        return
    
    GuiControl % WinExist("A") ":", Edit1, % Output
    ControlSend, Edit1, ^{end}, % "ahk_id " WinExist("A")
return

guiSetRootDirs_BtnBrowseEdit2:
    WinGetTitle, Title, A
    FileSelectFolder, Output, , , % Title
    If !FolderExist(Output)
        return
    
    GuiControl % WinExist("A") ":", Edit2, % Output
    ControlSend, Edit2, ^{end}, % "ahk_id " WinExist("A")
return

guiSetRootDirs_BtnSubmit:
    Output := ControlGetText("Edit1", "ahk_id " WinActive("A"))
    If !FolderExist(Output) {
        msgbox, 64, , % A_ThisLabel ": Source folder does not exist"
        return
    }
    settings.sourceRoot := RTrim(Output, "\")

    Output := ControlGetText("Edit2", "ahk_id " WinActive("A"))
    If !FolderExist(Output) {
        msgbox, 64, , % A_ThisLabel ": Destination folder does not exist"
        return
    }
    settings.destinationRoot := RTrim(Output, "\")

    Gui % WinActive("A") ":Destroy"
return

guiSetRootDirs_OnClose:
    exitapp
return