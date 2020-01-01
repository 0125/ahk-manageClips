; msgbox 4160 = ; Icon Asterisk (info) 64 + System Modal (always on top) 4096

class vlcClass {
    __New() {
    }

    Play(input) {
        ; check if file exists
        If !(FileExist(input)) {
            msgbox, 4160, , % A_ThisFunc ": '" input "' does not exist!`n`nReloading.."
            reload
            return
        }

        ; check if vlc is running correctly
        this._CheckVlc()

        ; close current clip to begin playing from the start
        this.Stop(input)

        ; play file
        run % settings.vlcExePath A_Space """" input """"

        ; wait for file to be open in vlc
        loop {
            If (this._isFileOpen(input)) ; wait until specified file is in vlc window title
                break
            sleep 10
        }

        ; scroll clip to set amount of seconds
        this._Forward(input)
    }

    Stop(input) {
        ; check if vlc is running correctly
        this._CheckVlc()
        ; close file
        this._PerformAction("stopPlayback")

        ; wait until file is fully closed
        loop {
            If !(this._isFileOpen(input))
                break
            sleep 10
        }
    }

    _Forward(input) {
        ; check if forwarding is enabled
        If !(settings.forwardSeconds)
            return

        ; check if vlc is running correctly
        this._CheckVlc()

        ; calculate amount of seconds to skip using the video duration
        clipDuration := getVideoDuration(input)
        If (clipDuration < settings.forwardSeconds) {
            TrayTip, % A_ScriptName, % "Clip is shorter then amount of seconds to forward ( " settings.forwardSeconds " ) !"
            return
        }
        remainingSeconds := clipDuration - settings.forwardSeconds ; set total amount of seconds to skip forward

        ; calculate skips to get close as possible to seconds to forward
        loop, {
            If (remainingSeconds - 300 < 0)
                break
            remainingSeconds -= 300
            300skip++
        }

        loop, {
            If (remainingSeconds - 60 < 0)
                break
            remainingSeconds -= 60
            60skip++
        }

        loop, {
            If (remainingSeconds - 10 < 0)
                break
            remainingSeconds -= 10
            10skip++
        }

        loop, {
            If (remainingSeconds - 3 < 0)
                break
            remainingSeconds -= 3
            3skip++
        }

        ; execute skips
        loop, % 300skip
            this._PerformAction("300skip")

        loop, % 60skip
            this._PerformAction("60skip")

        loop, % 10skip
            this._PerformAction("10skip")

        loop, % 3skip
            this._PerformAction("3skip")
    }

    _PerformAction(input) {
        ; set key(s) to send to vlc
        If (input = "stopPlayback")
            output := "s"
        If (input = "300skip")
            output = "^!{right}"
        If (input = "60skip")
            output = "^{right}"
        If (input = "10skip")
            output = "{right}"
        If (input = "3skip")
            output = "+{right}"

        ; send keys
        ControlSend, , % output, % "ahk_id " this.hwnd
    }

    _isFileOpen(input) {
        ; see if input is valid
        If !(FileExist(input)) {
            msgbox, 4160, , % A_ThisFunc ": Specified file does not exist!`n`nClosing.."
            exitapp
        }
        
        ; get vlc window title
        WinGetTitle, vlcTitle, % "ahk_id " this.hwnd
        
        ; check if vlc has any sub guis open
        If !(InStr(vlcTitle, "VLC Media Player")) and !(vlcTitle = "") and !(vlcTitle = "vlc") { ; if vlc title is empty or contains 'vlc' while vlc is running, fullscreen is activated
            msgbox, 4160, , % A_ThisFunc ": WinGetTitle Could not read VLC main window title!`n`nFound title: '" vlcTitle "'`n`nReloading.."
            reload
            return
        }

        ; get file name from input path
        SplitPath, % input, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive

        ; check if file name is open in vlc
        If (InStr(vlcTitle, OutNameNoExt))
            return true
        else
            return false
    }

    _CheckVlc() {
        ; if vlc exe path is not available or not valid
        If !(settings.vlcExePath) or !(FileExist(settings.vlcExePath))
            this._SelectPath()
        
        ; if there is more then one instance
        WinGet, Output, List
        loop % Output {
            WinGet, OutputProcess, ProcessName, % "ahk_id " Output%A_Index%
            If (OutputProcess = "vlc.exe") {
                ; check if found process is vlc fullscreen window
                WinGetTitle, vlcTitle, % "ahk_id " Output%A_Index%
                If (vlcTitle = "vlc")
                    continue
                
                ; count process instance
                vlcInstances++
            }
        }
        If (vlcInstances > 1) {
            msgbox, 4160, , % A_ThisFunc ": More then one (hidden) vlc instance running!`n`nDisable multiple vlc instances in settings and close excess`n`nReloading.."
            reload
            return
        }

        ; if vlc is hidden
        If !(WinVisible("ahk_exe vlc.exe"))
            Process, Close, vlc.exe

        ; get vlc handle
        If !(WinExist("ahk_exe vlc.exe")) {
            run % settings.vlcExePath
            WinWait, ahk_exe vlc.exe, , 10
            If (ErrorLevel) {
                msgbox, 4160, , % A_ThisFunc ": Could not find vlc.exe after 10 seconds, ran with: " settings.vlcExePath "`n`nClosing.."
                exitapp
            }
        }
        this.hwnd := WinExist("ahk_exe vlc.exe")
    }

    _SelectPath() {
        ; prompt path select
        FileSelectFile, SelectedFile, 3, , Open vlc.exe, Executables (*.exe)
        if (SelectedFile = "")
            exitapp
        
        ; check if selected path is correct
        if !(InStr(SelectedFile, "vlc.exe")) {
            msgbox, 4160, , % A_ThisFunc ": Incorrect file specified, select vlc.exe"
            this._SelectPath()
            return
        }

        ; save input
        settings.vlcExePath := SelectedFile
    }
}