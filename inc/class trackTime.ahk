class class_trackTime {
    Start() {
        If (this.pausedTime) { ; if timer was paused, set new start time
            newStartTime := A_Now
            EnvAdd, newStartTime, -this.pausedTime, Seconds ; subtract passed time from current time
            this.startTime := newStartTime ; set new start time
            this.pausedTime := "" ; reset paused status
        }
        else ; start fresh
            this.startTime := A_Now
    }

    Pause() {
        this.pausedTime := getPassedTimeSince(this.startTime)
    }

    Stop() {
        this.Reset()
    }

    Reset() {
        this.pausedTime := ""
        this.startTime := A_Now
    }

    Get() {
        ; return FormatTimeSeconds(getPassedTimeSince(this.startTime))
        return getPassedTimeSince(this.startTime)
    }
}