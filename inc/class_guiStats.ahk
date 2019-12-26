class class_guiStats {
    static Instances := []
    
    __New() {
        this._Create()
    }

    Update(input) { ; object with info to display from class_stats
        Gui % this.hwnd ":Default" ; set default gui for gui commands to operate on
        LV_Delete()
        LV_Add(,"Passed time", input.PassedTime)
        LV_Add(,"Remaining", input.remainingFiles)
        LV_Add(,"Hourly", input.HourlyHandledFiles)
        LV_ModifyCol() ; columns are adjusted to fit the contents of the rows
    }

    Show() {
        If (settings.guiStatsX) and (settings.guiStatsY)
			Gui % this.hwnd ":Show", % "x" settings.guiStatsX " y" settings.guiStatsY, % A_ScriptName A_Space "Stats"
		else
			Gui % this.hwnd ":Show", , % A_ScriptName A_Space "Stats"
    }

    _Create() {
        ; properties
		Gui, New, +hwndhwnd
		this.hwnd := hwnd
		class_guiReview.Instances[hwnd] := this
		this.Events := []
		this.Events["Close"] := this.Close.Bind(this)

        lvWidth := 350

        ; controls
        Gui % this.hwnd ":Add", ListView, % " w" lvWidth, Stat|Value

        ; show
		this.Show()
    }

    Close() {
        this.SavePos()
        Gui % this.hwnd ":Hide"
	}

    SavePos() {
        If !(WinExist("ahk_id " this.hwnd))
            return
        WinGetPos, outX, outY, , , % "ahk_id " this.hwnd
        settings.guiStatsX := outX
        settings.guiStatsY := outY
	}
	
	Destroy() {
        class_guiReview.Instances := ""
		this.Events := ""
	}
	
	__Delete() {
		Gui % this.hwnd ":Destroy"
	}
}