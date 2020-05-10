class class_pathGui extends gui {
    Setup() {
        ; events
        this.Events["_BtnManage"] := this.Save.Bind(this)
        this.Events["_BtnBrowseSource"] := this.BrowseSource.Bind(this)
        this.Events["_BtnBrowseDestination"] := this.BrowseDestination.Bind(this)
        this.Events["_BtnClose"] := this.Close.Bind(this)
        this.Events["_HotkeyEnter"] := this.Save.Bind(this)

        ; properties
        this.Margin(5, 5)
        this.Options("+LabelinputGui_")

        ; controls
        this.Add("Text", "w300", "Source")
        this.Add("Edit", "w300 section", settings.clipSourcePath)
        this.Add("Button", "x+5 ys-1 w25 ginputGui_BrowseSource", "Browse")

        this.Add("Text", "x5 w300", "Destination")
        this.Add("Edit", "w300 section", settings.clipDestinationPath)
        this.Add("Button", "x+5 ys-1 w50 ginputGui_BrowseDestination", "Browse")

        this.Add("Button", "x5 w355 ginputGui_BtnHandler", "Manage")

        ; hotkeys
		hotkey, IfWinActive, % "ahk_id " this.hwnd
        hotkey, enter, inputGui_HotkeyEnter
        hotkey, IfWinActive

        ; show
        this.Show()
        WinWaitClose, % this.ahkid
        return
    }

    Save() {
        source := this.GetText("Edit1")
        destination := this.GetText("Edit2")

        If !(FolderExist(source)) {
            msgbox, 4160, , Source folder does not exist!
            return
        }
        If !(FolderExist(destination)) {
            msgbox, 4160, , Destination folder does not exist!
            return
        }

        settings.clipSourcePath := source
        settings.clipDestinationPath := destination

        this.Destroy()
    }

    Close() {
        exitapp
    }

    BrowseSource() {
        FileSelectFolder, OutputVar, , 3
        If !(OutputVar)
            return

        this.SetText("Edit1", OutputVar)
    }

    BrowseDestination() {
        FileSelectFolder, OutputVar, , 3
        If !(OutputVar)
            return

        this.SetText("Edit2", OutputVar)
    }
}

inputGui_BtnHandler:
    ; get active button text without spaces
    ControlGetFocus, OutputControl, A
    ControlGetText, OutputControlText, % OutputControl, A
    OutputControlText := StrReplace(OutputControlText, A_Space)

    ; call the class's method
    for a, b in class_pathGui.Instances 
		if (a = A_Gui+0)
			b["Events"]["_Btn" OutputControlText].Call()
return

inputGui_Close:
	; call the class's method
    for a, b in class_pathGui.Instances 
		if (a = WinExist("A")+0) ; if instance gui hwnd is identical to currently active window hwnd
			b["Events"]["_BtnClose"].Call()
return

inputGui_HotkeyEnter:
	; call the class's method
    for a, b in class_pathGui.Instances 
		if (a = WinExist("A")+0) ; if instance gui hwnd is identical to currently active window hwnd
			b["Events"]["_HotkeyEnter"].Call()
return

inputGui_BrowseSource:
	; call the class's method
    for a, b in class_pathGui.Instances 
		if (a = WinExist("A")+0) ; if instance gui hwnd is identical to currently active window hwnd
			b["Events"]["_BtnBrowseSource"].Call()
return

inputGui_BrowseDestination:
	; call the class's method
    for a, b in class_pathGui.Instances 
		if (a = WinExist("A")+0) ; if instance gui hwnd is identical to currently active window hwnd
			b["Events"]["_BtnBrowseDestination"].Call()
return