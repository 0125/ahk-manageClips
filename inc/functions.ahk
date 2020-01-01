ExitFunc(ExitReason, ExitCode) {
    ; trigger review class __Delete method
    review := ""

    ; write settings to file
    saveSettings()
}

loadSettings() {
    ; read settings from file
    If (FileExist(A_ScriptDir "\settings.json")) {
        FileRead, Output, % A_ScriptDir "\settings.json"
        OutputObj := json.load(Output,,2)
        If (IsObject(OutputObj)) ; only load settings if file could be read correctly
            settings := json.load(Output,,2)
    }
}

saveSettings() {
    ; write settings to file
    FileDelete, % A_ScriptDir "\settings.json"
    FileAppend, % json.dump(settings,,2), % A_ScriptDir "\settings.json"
}

m(x*){
	for a,b in x
		list.=b "`n"
	MsgBox,0, % A_ScriptName, % list
}

getVideoDuration(input) {
    ; open mediainfo.dll instance
    hnd := MediaInfo_New()

    ; open file in mediainfo.dll
    MediaInfo_Open( hnd, input )
 
    ; check if file is a video
    If ( MediaInfo_Get( hnd, 1,0, "StreamKind", 1 ) <> "Video" ) {
        msgbox, 64, , % A_ThisFunc ": '" input "' is not a video file!"
        MediaInfo_Close( hnd )
        return
    }

    ; get video duration timestamp
    durationTimestamp := MediaInfo_Get( hnd, 1,0, "Duration/String3", 1 )
    durationTimestamp := SubStr(durationTimestamp, 1, InStr(durationTimestamp, ".") - 1) ; remove miliseconds

    ; convert timestamp to seconds
    digitsArr := StrSplit(durationTimestamp , ":")
    output += digitsArr[1] * 3600 ; hours
    output += digitsArr[2] * 60 ; minutes
    output += digitsArr[3] ; seconds

    ; close file in mediainfo.dll
    MediaInfo_Close( hnd )
    
    return output
}

MediaInfo_New() {
 Return DllCall( "mediainfo\MediaInfo" ( A_IsUnicode ? "" : "A" ) "_New" )
}

MediaInfo_Open( hnd, MediaFile ) {
 Return DllCall( "mediainfo.dll\MediaInfo" ( A_IsUnicode ? "" : "A" ) "_Open", UInt,hnd
               , Str,MediaFile, UInt )
}

MediaInfo_Get( hnd, StrK=0, StrN=0, Comm="", InfK=0, Srch=0 ) {
 Return DllCall( "mediainfo.dll\MediaInfo" ( A_IsUnicode ? "" : "A" ) "_Get", UInt,hnd
               , Int,StrK, Int,StrN, Str,Comm, Int,InfK, Int,Sech, Str )
}

MediaInfo_Close( hnd ) {
 Return DllCall( "mediainfo\MediaInfo" ( A_IsUnicode ? "" : "A" ) "_Close", UInt,hnd )
}