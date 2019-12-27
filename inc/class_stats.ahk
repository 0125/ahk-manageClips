class class_Stats {
    __New(input) {
        this.startTime := A_Now ; keep track of elapsed time
        this.remainingFiles := input ; keep track of processed files
        this.handledFiles := 0 ; keep track of processed files
    }

    AddAction() {
        this.handledFiles++
        settings.totalHandledFiles++
        this.remainingFiles--
        this.UpdateStats()
    }

    RemoveAction() {
        this.handledFiles--
        settings.totalHandledFiles--
        this.remainingFiles++
        this.UpdateStats()
    }

    UpdateStats() {
        this._setTimePassed()
        this._setHourlyHandledFiles()

        this.info := []
        this.info.remainingFiles := this.remainingFiles
        this.info.HandledFiles := this.HandledFiles
        this.info.HourlyHandledFiles := this.HourlyHandledFiles
        this.info.PassedTime := FormatTimeSeconds(this.elapsedSeconds)

        this.info.totalHandledFiles := settings.totalHandledFiles
        this.info.totalSecondsElapsed := FormatTimeSeconds(settings.totalSecondsElapsed + this.elapsedSeconds)
        this.info.totalHourlyHandledFiles := settings.totalHandledFiles / (settings.totalSecondsElapsed + this.elapsedSeconds)

        this.guiStats.Update(this.info)
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

    SaveStats() {
        If !(IsObject(this.info)) ; check if there stats to save
            return

        this.UpdateStats()
        settings.totalSecondsElapsed += this.elapsedSeconds
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