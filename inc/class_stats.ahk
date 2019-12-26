class class_Stats {
    __New(input) {
        this.startTime := A_Now ; keep track of elapsed time
        this.remainingFiles := input ; keep track of processed files
        this.handledFiles := 0 ; keep track of processed files

        this.AddAction()
    }

    AddAction() {
        this.handledFiles++
        this.remainingFiles--
        this.UpdateStats()
    }

    RemoveAction() {
        this.handledFiles--
        this.remainingFiles++
        this.UpdateStats()
    }

    UpdateStats() {
        this._setTimePassed()
        this._setHourlyHandledFiles()

        info := []
        info.remainingFiles := this.remainingFiles
        info.HourlyHandledFiles := this.HourlyHandledFiles
        info.PassedTime := FormatTimeSeconds(this.elapsedSeconds)
        this.guiStats.Update(info)
    }

    ShowGui() {
        If !(IsObject(this.guiStats)) { ; if gui not already created
            this.guiStats := new class_guiStats ; create gui
            g__guiStats := this.guiStats  ; holds class instance for saving position
        }
        else
            this.guiStats.Show()
        this.UpdateStats()
    }

    _setTimePassed() {
        ; calculate amount of seconds passed since start time
        endTime := A_Now
        elapsedSeconds := endTime
        EnvSub, elapsedSeconds, this.startTime, Seconds
        this.elapsedSeconds := elapsedSeconds
    }

    _setHourlyHandledFiles() {
        Output := this.handledFiles / this.elapsedSeconds ; files per second
        Output *= 3600 ; files per hour
        this.HourlyHandledFiles := Round(Output)
    }
}