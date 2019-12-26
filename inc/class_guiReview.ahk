class class_guiReview {
	static Instances := []

	__New(input) { ; input = review class instance
		this.parentInstance := input
		
		; properties
		Gui, New, +hwndhwnd
		this.hwnd := hwnd
		class_guiReview.Instances[hwnd] := this
		this.Events := []
		this.Events["Close"] := this.Close.Bind(this)
		this.Events["_guiReview_HotkeyEnter"] := this._guiReview_HotkeyEnter.Bind(this)
		this.Events["_guiReview_BtnDelete"] := this._guiReview_BtnDelete.Bind(this)
		this.Events["_guiReview_BtnPlay"] := this._guiReview_BtnPlay.Bind(this)
		this.Events["_guiReview_BtnUndo"] := this._guiReview_BtnUndo.Bind(this)
		this.Events["_guiReview_BtnForward"] := this._guiReview_BtnForward.Bind(this)
		this.Events["_guiReview_BtnSaveAs"] := this._guiReview_BtnSaveAs.Bind(this)
		this.Events["_guiReview_BtnStats"] := this._guiReview_BtnStats.Bind(this)
		margin := 5
		leftMargin := 10
		editWidth := 450
		btnWidth := 50

		; controls
        Gui % this.hwnd ":Add", edit, % " w" editWidth
        Gui % this.hwnd ":Add", button, % "w" editWidth - btnWidth - margin " r2 gguiReview_BtnDelete", Delete
        Gui % this.hwnd ":Add", button, x+5 w50 r2 gguiReview_BtnPlay, Play
        Gui % this.hwnd ":Add", button, % "x" leftMargin " w" editWidth - (btnWidth * 3) - (margin * 3) " r1 gguiReview_BtnUndo", Undo
        Gui % this.hwnd ":Add", button, x+5 w50 r1 gguiReview_BtnForward, Forward
        Gui % this.hwnd ":Add", button, x+5 w50 r1 gguiReview_BtnSaveAs, Save as
        Gui % this.hwnd ":Add", button, x+5 w50 r1 gguiReview_BtnStats, Stats

		; hotkeys
		hotkey, IfWinActive, % "ahk_id " this.hwnd
        hotkey, enter, guiReview_HotkeyEnter
        hotkey, IfWinActive

		; show
		If (settings.guiReviewX) and (settings.guiReviewY)
			Gui % this.hwnd ":Show", % "x" settings.guiReviewX " y" settings.guiReviewY
		else
			Gui % this.hwnd ":Show"
	}
	
	Update(input) {
		SplitPath, % input, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		
		; edit control
		; GuiControl % this.hwnd ":", Edit1, % OutNameNoExt
		; ControlSend, Edit1, ^a, % "ahk_id " this.hwnd

        ; gui title
		OutDirName := SubStr(OutDir, InStr(OutDir, "\", , 0) + 1)
		Gui % this.hwnd ":Show", , % OutDirName " : " OutNameNoExt
	}
	SetGuiOwner(input) {
		Gui % this.hwnd ":+Owner" input ; set gui as owner of vlc
		WinActivate, % "ahk_id" this.hwnd ; bring gui on top of vlc
	}

	getNewFileName() {
		ControlGetText, OutputVar, Edit1, % "ahk_id " this.hwnd
		return OutputVar
	}

	_setEditFocus() {
		ControlFocus, Edit1, % "ahk_id " this.hwnd
	}

	_guiReview_HotkeyEnter() {
		this.parentInstance.Save()

		this._setEditFocus()
	}

	_guiReview_BtnPlay() {
		this.parentInstance.Play()

		this._setEditFocus()
	}

	_guiReview_BtnDelete() {
		this.parentInstance.Delete()

		this._setEditFocus()
	}

	_guiReview_BtnUndo() {
		this.parentInstance.Undo()

		this._setEditFocus()
	}

	_guiReview_BtnForward() {
		Gui % this.hwnd ":+OwnDialogs" ; prevent gui interaction and set inputbox ontop of gui
        CoordMode, Mouse, Screen
        MouseGetPos, OutputVarX, OutputVarY
        boxW := 250
        boxH := 150
        InputBox, OutputVar, % A_ScriptDir, Choose amount of seconds to Forward rounded by 10, , % boxW, % boxH, % OutputVarX - (boxW / 2), % OutputVarY - (boxH / 2), , , % settings.ForwardSeconds
        If OutputVar is not integer
        {
            msgbox, 64, , % A_ThisFunc ": Must be integer"
            return
        }
        settings.ForwardSeconds := Round(OutputVar / 10) * 10 ; round by 10 if the user didnt already, and save

		this._setEditFocus()
	}

	_guiReview_BtnSaveAs() {
		this.parentInstance.SaveAs()

		this._setEditFocus()
	}

	_guiReview_BtnStats() {
		this.parentInstance.ShowStatsGui()

		this._setEditFocus()
	}

	SavePos() {
		If !(WinExist("ahk_id " this.hwnd))
            return
		WinGetPos, outX, outY, , , % "ahk_id " this.hwnd
		settings.guiReviewX := outX
        settings.guiReviewY := outY
	}

	Close() {
		msgbox, 68, % A_ScriptName, Are you sure you want to exit the program?
		IfMsgBox, No
			return
		exitapp
	}
	
	Destroy() {
		class_guiReview.Instances := ""
		this.Events := ""
	}
	
	__Delete() {
		Gui % this.hwnd ":Destroy"
	}
}

guiReview_BtnDelete:
	for a, b in class_guiReview.Instances 
		if (a = A_Gui+0)
			b["Events"]["_guiReview_BtnDelete"].Call()
return

guiReview_BtnPlay:
	for a, b in class_guiReview.Instances 
		if (a = A_Gui+0)
			b["Events"]["_guiReview_BtnPlay"].Call()
return

guiReview_BtnUndo:
	for a, b in class_guiReview.Instances 
		if (a = A_Gui+0)
			b["Events"]["_guiReview_BtnUndo"].Call()
return

guiReview_BtnForward:
	for a, b in class_guiReview.Instances 
		if (a = A_Gui+0)
			b["Events"]["_guiReview_BtnForward"].Call()
return

guiReview_BtnSaveAs:
	for a, b in class_guiReview.Instances 
		if (a = A_Gui+0)
			b["Events"]["_guiReview_BtnSaveAs"].Call()
return

guiReview_BtnStats() {
	for a, b in class_guiReview.Instances 
		if (a = A_Gui+0)
			b["Events"]["_guiReview_BtnStats"].Call()
}

guiReview_HotkeyEnter:
	for a, b in class_guiReview.Instances 
		if (a = WinExist("A")+0) ; if instance gui hwnd is identical to currently active window hwnd
			b["Events"]["_guiReview_HotkeyEnter"].Call()
return