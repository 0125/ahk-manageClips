class class_vlc {
    __New(input) { ; input = review class instance
        this.parentInstance := input
        
        ; this._Setup()
    }

    __Call(input) {
        If !(WinExist("ahk_id" this.hwnd)) and !(InStr(input, "_")) { ; if vlc window doesnt exist and class is not calling an internal method
            this._Setup()
            this.parentInstance.SetGuiReviewOwner()
        }
    }
    
    Play(input) {
        If (this.previousFile) ; close currently running file, if any
            this.CloseFile(this.previousFile)
        
        run % settings.vlcExePath A_Space """" input """"
        this._waitFileOpen(input)

        this.previousFile := input
    }

    CloseFile(input) {
        this._PerformAction("stopPlayback")

        this._waitFileClose(input)
    }

    ForwardPlayback() {
        If !(settings.forwardSeconds)
            return

        remainingSeconds := settings.forwardSeconds

        ; calculate skips
        loop, {
            If (remainingSeconds - 300 < 0) ; check if skipping this amount of seconds goes below 0
                break
            remainingSeconds -= 300
            300skip++
        }

        loop, {
            If (remainingSeconds - 60 < 0) ; check if skipping this amount of seconds goes below 0
                break
            remainingSeconds -= 60
            60skip++
        }

        loop, {
            If (remainingSeconds - 10 < 0) ; check if skipping this amount of seconds goes below 0
                break
            remainingSeconds -= 10
            10skip++
        }

        ; execute skips
        loop, % 300skip
            this._PerformAction("300skip")

        loop, % 60skip
            this._PerformAction("60skip")

        loop, % 10skip
            this._PerformAction("10skip")
    }

    _PerformAction(input) {
        If (input = "stopPlayback")
            output := "s"
        If (input = "300skip")
            output = "^!{right}"
        If (input = "60skip")
            output = "^{right}"
        If (input = "10skip")
            output = "{right}"

        ControlSend, , % output, % "ahk_id " this.hwnd
    }

    _waitFileOpen(input) {
        loop {
            If (this._isFileOpen(input)) ; wait until specified file is in vlc window title
                break
            sleep 10
        }
    }

    _waitFileClose(input) {
        loop {
            If !(this._isFileOpen(input)) ; wait until specified file is no longer in vlc window title
                break
            sleep 10
        }
    }

    _isFileOpen(input) {
        SplitPath, % input, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

        WinGetTitle, Output, % "ahk_id " this.hwnd
        If (Output = "VLC media player") ; main gui of vlc is open and does not have any files opened
            return false
        else If InStr(Output, OutNameNoExt) ; main gui of vlc is open and has file open
            return true
        else {
            msgbox, 64, , % A_ThisFunc ": WinGetTitle Could not read VLC main window title!`n`nClosing.."
            exitapp
        }
    }

    _Setup() {
        DetectHiddenWindows, On
        this._Kill()

        try {
            Run, % settings.vlcExePath, , , OutputVarPID
            WinWait, % "ahk_pid " OutputVarPID, , 2
        } catch ErrorLevel {
            msgbox, 64, , % A_ThisFunc ": Could not run vlc, please select vlc executable"
            setVlcPath()
            this.Setup()
            return
        }
        this.hwnd := WinExist("ahk_pid " OutputVarPID)
    }

    _Kill() {
        ; close all vlc instances
        DetectHiddenWindows On ; List all running instances of this script:
        WinGet instances, List, ahk_exe vlc.exe
        this_pid := DllCall("GetCurrentProcessId"),  closed := 0
        Loop % instances { ; For each instance,
            WinGet, pid, PID, % "ahk_id " instances%A_Index%
            Process, Close, % PID
        }
    }
}