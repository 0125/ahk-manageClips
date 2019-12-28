class class_guiStats {
    static Instances := []
    
    __New(input) {
        this.parentInstance := input
        this._Create()
    }

    Update(input) { ; object with info to display from class_stats
        If !(this.hwnd)
            return
        
        Gui % this.hwnd ":Default" ; set default gui for gui commands to operate on
        LV_Delete()
        LV_Add(,"Passed time", input.PassedTime)
        LV_Add(,"Remaining", input.remainingFiles)
        LV_Add(,"Hourly", input.HourlyHandledFiles)
        LV_Add(,"Handled session", input.HandledFiles)

        LV_Add(,"Total handled", input.totalHandledFiles)
        LV_Add(,"Total passed time", input.totalSecondsElapsed)
        LV_Add(,"Total hourly", Round(input.totalHourlyHandledFiles))

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
		class_guiStats.Instances[hwnd] := this
		this.Events := []
		this.Events["Close"] := this.Close.Bind(this)
        this.Events["Contextmenu"] := this.Contextmenu.Bind(this)
        this.Events["_guiStats_BtnResetStats"] := this._guiStats_BtnResetStats.Bind(this)
        Gui % this.hwnd ":+AlwaysOnTop",

        lvWidth := 180

        ; controls
        Gui % this.hwnd ":Add", ListView, % " w" lvWidth " h160", Stat|Value

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
	
    Contextmenu() {
        Menu, MyMenu, Add
        Menu, MyMenu, DeleteAll
        Menu, MyMenu, Add, Reset stats, guiStats_BtnResetStats
        Menu, MyMenu, Show
    }

    _guiStats_BtnResetStats() {
        this.parentInstance.ResetStats()
    }

	Destroy() {
        class_guiReview.Instances := ""
		this.Events := ""
	}
	
	__Delete() {
		Gui % this.hwnd ":Destroy"
	}
}

guiStats_BtnResetStats:
    for a, b in class_guiStats.Instances 
		if (a = WinExist("A")+0) ; if instance gui hwnd is identical to currently active window hwnd
			b["Events"]["_guiStats_BtnResetStats"].Call()
return