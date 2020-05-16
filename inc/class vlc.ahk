class class_vlc {
    __New() {
        ; prompt vlc exe path if not available, or valid. save to settings file
        If (!FileExist(settings.vlcExePath)) {
            FileSelectFile, vlcExePath, 3, , Please specifiy VLC media players executable: 'vlc.exe', Executables (*.exe) ; 3 = file & path must exist
            SplitPath, vlcExePath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
            If !(vlcExePath) or !(OutFileName = "vlc.exe") {
                msgbox, 4160, , %A_ThisFunc%: vlc.exe not specified!`n`nClosing..
                exitapp
            }
            settings.vlcExePath := vlcExePath
        }
    }

    Play() {
        If (!FileExist(file.clip)) {
            msgbox, 4160, , %A_ThisFunc%: File does not exist!
            reload
            return
        }
        
        this.Setup()

        Run, % settings.vlcExePath A_Space """" file.clip """"

        loop ; wait until file is opened
            If FileOpened(file.clip)
                break

        this._Forward()
    }

    Stop() {
        this.Setup()
    
        ControlSend, , s, % this.ahkid

        loop { ; wait until file is closed
            WinGetTitle, vlcTitle, % this.ahkid
            If (vlcTitle = "VLC media player")
                break
        }
    }

    Setup() {
        WinGet, vlcTitles, List, ahk_exe vlc.exe ; count open vlc windows
        If WinExist(this.ahkid) and (vlcTitles = 1) ; vlc is running, without sub menus open and window handle is stored
            return
        
        If (vlcTitles > 1) {
            msgbox, 4160, , % A_ThisFunc ": Found multiple VLC windows! `n`nReminder to enable VLC setting: 'Allow only one instance'"
            this._Restart()
        }

        If !(WinExist("ahk_exe vlc.exe"))
            this._Restart()

        WinGet, hwnd, ID, ahk_exe vlc.exe
        this.hwnd := hwnd
        this.ahkid := "ahk_id " hwnd

        WinActivate, % this.ahkid
        manageGui.Options("+Owner" this.hwnd)
        WinActivate, % manageGui.ahkid
    }

    _Forward() {
        If !(settings.ForwardSeconds)
            return

        ; calculate amount of seconds to skip using the video duration
        clipDuration := getVideoDuration(file.clip)
        If (clipDuration < settings.forwardSeconds) {
            TrayTip, % A_ScriptName, % "Clip is shorter then amount of seconds to forward ( " settings.ForwardSeconds " ) !"
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
        sleep 150 ; give vlc some time to completely load the clip

        loop, % 300skip
            ControlSend, , ^!{right}, % this.ahkid

        loop, % 60skip
            ControlSend, , ^{right}, % this.ahkid

        loop, % 10skip
            ControlSend, , {right}, % this.ahkid

        loop, % 3skip
            ControlSend, , +{right}, % this.ahkid

    }

    _Restart() {
        Process, Close, vlc.exe
        Run, % settings.vlcExePath
        WinWait, ahk_exe vlc.exe ; wait till vlc is opened. prevents a glitch where vlc opens video in a separate window
    }
}