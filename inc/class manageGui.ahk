class class_manageGui extends gui {
    Setup() {
        ; events
        this.Events["_BtnPlay"] := this.Play.Bind(this)
        this.Events["_BtnDelete"] := this.Delete.Bind(this)
        this.Events["_BtnUndo"] := this.Undo.Bind(this)
        this.Events["_BtnSaveAs"] := this.SaveAs.Bind(this)
        this.Events["_BtnMisc"] := this.MiscMenu.Bind(this)
        this.Events["_BtnClose"] := this.Close.Bind(this)
        this.Events["_HotkeyEnter"] := this.Save.Bind(this)

        ; properties
        this.SetDefault()
        this.Margin(5, 5)
        this.Options("+LabelmanageGui_")
        
        ; controls
        this.Add("Edit", "w390 section Limit255", "") ; 255 is windows max file name length
        this.Add("Button", "w140 x5 r2 gmanageGui_BtnHandler", "Delete")
        this.Add("Button", "w85 x+5 r2 Disabled gmanageGui_BtnHandler", "Undo")
        this.Add("Button", "w55 x+5 r2 gmanageGui_BtnHandler", "Play")
        this.Add("Button", "w55 x+5 r2 gmanageGui_BtnHandler", "Save As")
        this.Add("Button", "w35 x+5 r2 gmanageGui_BtnHandler", "Misc")

        this.Add("StatusBar")
        SB_SetParts(97, 97, 97)
        SB_SetText("Remaining:`t`t0", 1) ; remaining
        SB_SetText("Session:`t`t0", 2) ; session
        SB_SetText("Hourly:`t`t0", 3) ; per hour
        SB_SetText("Total:`t`t" settings.stats.TotalClips, 4) ; total

        ; hotkeys
		hotkey, IfWinActive, % this.ahkid
        hotkey, enter, manageGui_HotkeyEnter
        hotkey, IfWinActive

        ; show
        this.Pos(settings.manageGuiX, settings.manageGuiY)
        return
    }

    Save() {
        If !(file.Save())
            return
        vlc.Play()

        this.SelectText("Edit1")
    }

    Play() {
        vlc.Play()

        this.SelectText("Edit1")
    }

    Delete() {
        If !(file.Delete())
            return
        vlc.Play()

        this.SelectText("Edit1")
    }

    Undo() {
        If !(file.Undo())
            return
        vlc.Play()

        this.SelectText("Edit1")
    }

    SaveAs() {
        SplitPath, % file.clip, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

        this.Disable() ; disable gui input
        FileSelectFile, SelectedFile, S3, % manageGui.GetText("Edit1"), Save As, %OutExtension% (*.%OutExtension%)
        If !(SelectedFile) {
            this.Enable() ; re-enable gui input
            return
        }
        this.Enable() ; re-enable gui input

        FileCopy, % file.clip, % SelectedFile "." OutExtension
    }

    SetForward() {
        ; InputBox, OutputVar , Title, Prompt, , Width, Height, X, Y, Locale, Timeout, Default
        InputBox, UserInput , Prompt, Please enter amount of seconds at the end of a clip to forward towards`n`n0 to disable forwarding
            , , 340, 180, X, Y, , , % settings.ForwardSeconds
        if ErrorLevel
            return ; CANCEL was pressed.
        
        If UserInput is not Integer
        {
            msgbox, 4160, , % "Input is not integer!"
            this.SetForward()
            return
        }

        If (UserInput < 0)
            UserInput := 0

        settings.ForwardSeconds := UserInput
    }

    SavePos() {
        WinGetPos, manageGuiX, manageGuiY, manageGuiW, manageGuiH, % this.ahkid
        If !(manageGuiX) or !(manageGuiY)
            return
        If (manageGuiX < 0) or (manageGuiY < 0)
            manageGuiX := "", manageGuiY := ""
        settings.manageGuiX := manageGuiX, settings.manageGuiY := manageGuiY
    }

    MiscMenu() {
        menu, miscmenu, add
        menu, miscmenu, DeleteAll

        menu, miscmenu, add, Set forward seconds, MiscMenu_SetForward
        menu, miscmenu, add

        clipSourcePath := % settings.clipSourcePath
        menu, miscmenu, add, Open source folder:`t%clipSourcePath%, MiscMenu_OpenSource
        clipDestinationPath := % settings.clipDestinationPath
        menu, miscmenu, add, Open destination folder:`t%clipDestinationPath%, MiscMenu_OpenDestination

        menu, miscmenu, show
    }

    Close() {
        this.SavePos()
        exitapp
    }
}

MiscMenu_SetForward:
    manageGui.SetForward()
    manageGui.Play()
return

MiscMenu_OpenSource:
    run, % settings.clipSourcePath
return

MiscMenu_OpenDestination:
    run, % settings.clipDestinationPath
return

manageGui_BtnHandler:
    ; get active button text without spaces
    ControlGetFocus, OutputControl, A
    ControlGetText, OutputControlText, % OutputControl, A
    OutputControlText := StrReplace(OutputControlText, A_Space)

    ; call the class's method
    for a, b in class_manageGui.Instances 
		if (a = A_Gui+0)
			b["Events"]["_Btn" OutputControlText].Call()
return

manageGui_HotkeyEnter:
	; call the class's method
    for a, b in class_manageGui.Instances 
		if (a = WinExist("A")+0) ; if instance gui hwnd is identical to currently active window hwnd
			b["Events"]["_HotkeyEnter"].Call()
return

manageGui_Close:
    ; call the class's method
    for a, b in class_manageGui.Instances 
		if (a = A_Gui+0)
			b["Events"]["_BtnClose"].Call()
return