; use base gui class

class guiReviewClass extends gui {
    Setup() {
        ; events
        this.Events["Close"] := this.Close.Bind(this)
        this.Events["_afterButtonPress"] := this._afterButtonPress.Bind(this)
        this.Events["_BtnDelete"] := this.Delete.Bind(this)
		this.Events["_BtnPlay"] := this.Play.Bind(this)
		this.Events["_BtnUndo"] := this.Undo.Bind(this)
		this.Events["_BtnForward"] := this.Forward.Bind(this)
		this.Events["_BtnSaveAs"] := this.SaveAs.Bind(this)
		this.Events["_BtnStats"] := this.Stats.Bind(this)
		this.Events["_HotkeyEnter"] := this.Save.Bind(this)

        ; controls
        margin := 5
		leftMargin := 10
		editWidth := 450
		btnWidth := 50
        
        this.Add("Edit", "w" editWidth)
        this.Add("Button", "w" editWidth - btnWidth - margin " r2 gguiReview_BtnHandler", "Delete")
        this.Add("Button", "x+5 w50 r2 gguiReview_BtnHandler", "Play")
        this.Add("Button", "x" leftMargin " w" editWidth - (btnWidth * 3) - (margin * 3) " r1 gguiReview_BtnHandler", "Undo")
        this.Add("Button", "x+5 w50 r1 gguiReview_BtnHandler", "Forward")
        this.Add("Button", "x+5 w50 r1 gguiReview_BtnHandler", "Save as")
        this.Add("Button", "x+5 w50 r1 gguiReview_BtnHandler", "Stats")

        ; hotkeys
		hotkey, IfWinActive, % "ahk_id " this.hwnd
        hotkey, enter, guiReview_HotkeyEnter
        hotkey, IfWinActive

        ; show
        this.Pos(settings.guiReviewX, settings.guiReviewY)
        
        ; reset edit control & focus input + set guiReview as owner of vlc
        this._afterButtonPress()
    }

    Delete() {
        review.delete()
    }

    Play() {
        review.Play()
    }

    Forward() {
        ; prevent gui interaction and set inputbox ontop of gui
        Gui % this.hwnd ":+OwnDialogs"

        ; show inputbox ontop of cursor
        CoordMode, Mouse, Screen
        MouseGetPos, OutputVarX, OutputVarY
        boxW := 250
        boxH := 150
        InputBox, OutputVar, % A_ScriptDir, Amount of seconds to forward to at the end of the clip, , % boxW, % boxH, % OutputVarX - (boxW / 2), % OutputVarY - (boxH / 2), , , % settings.ForwardSeconds
        If OutputVar is not integer
        {
            msgbox, 64, , % A_ThisFunc ": Must be integer"
            return
        }
        settings.ForwardSeconds := OutputVar
    }

    SaveAs() {
        review.SaveAs()
    }

    Save() {
        review.Save()
    }

    Undo() {
        review.Undo()
    }

    Stats() {
        msgbox % A_ThisFunc
    }

    _afterButtonPress() {
        ; reset edit control & focus input
        this._FocusEdit()

        ; make guiReview owner of vlc
        this._SetVlcOwner()
    }

    _FocusEdit() {
        this.SetText()
        this.ControlFocus("Edit1")
    }

    _SetVlcOwner() {
        ; store vlc hwnd
        static vlcHwnd

        ; check if vlc hwnd has changed
        hwnd := WinExist("ahk_exe vlc.exe")
        If !(vlcHwnd = hwnd) or !(vlcHwnd) { ; vlc hwnd has changed or not yet been set
            vlcHwnd := hwnd
            this.Owner(vlchwnd)
        }
    }

    Close() {
        this.SavePos()
        exitapp
    }

    SavePos() {
        WinGetPos, guiReviewX, guiReviewY, guiReviewW, guiReviewH, % this.ahkid
        If (guiReviewX < 0) or (guiReviewY < 0)
            return
        settings.guiReviewX := guiReviewX
        settings.guiReviewY := guiReviewY
    }
}

guiReview_BtnHandler:
    ; get active button text without spaces
    ControlGetFocus, OutputControl, A
    ControlGetText, OutputControlText, % OutputControl, A
    OutputControlText := StrReplace(OutputControlText, A_Space)

    ; call the class's method
    for a, b in guiReviewClass.Instances 
		if (a = A_Gui+0) {
			b["Events"]["_Btn" OutputControlText].Call()
			b["Events"]["_afterButtonPress"].Call()
        }
return

guiReview_HotkeyEnter:
	; call the class's method
    for a, b in guiReviewClass.Instances 
		if (a = WinExist("A")+0) { ; if instance gui hwnd is identical to currently active window hwnd
			b["Events"]["_HotkeyEnter"].Call()
            b["Events"]["_afterButtonPress"].Call()
        }
return