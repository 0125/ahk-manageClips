class class_stats {
    __New() {
        this.TrackTime := new class_trackTime
        this.TrackTime.Start() ; start tracking time

        this.TotalClips := settings.stats.TotalClips ; set total clips
    }
    
    Add() {
        ; session
        i := this.SessionClips
        i++
        this.SessionClips := i

        ; total
        TotalClips := this.TotalClips
        TotalClips++
        this.TotalClips := TotalClips

        this.Update()
    }

    Del() {
        ; session
        i := this.SessionClips
        i--
        this.SessionClips := i

        ; total
        TotalClips := this.TotalClips
        TotalClips--
        this.TotalClips := TotalClips

        this.Update()
    }

    Save() {
        settings.stats := {}
        settings.stats.TotalClips := this.TotalClips
    }

    Update() {
        ; session hourly clips
        passedSeconds := this.TrackTime.Get()
        reviewedClips := this.SessionClips
        sessionHourlyClips := reviewedClips / passedSeconds * 3600
        sessionHourlyClips := Round(sessionHourlyClips)

        manageGui.SetDefault() ; set default gui for SB_SetText
        SB_SetText("Session:`t`t" this.SessionClips, 2) ; session
        SB_SetText("Hourly:`t`t" sessionHourlyClips, 3) ; per hour
        SB_SetText("Total:`t`t" this.TotalClips, 4) ; total

        this.Save()
    }
}