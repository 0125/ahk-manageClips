FileOpened(input) {
    FileMove, % input, % input, 0
        return ErrorLevel
}

ExitFunc(ExitReason, ExitCode) {
    manageGui.SavePos()
    stats.Save()
    
    FileDelete, % A_ScriptDir "\settings.json"
    FileAppend, % json.dump(settings,,2), % A_ScriptDir "\settings.json"

    run, % A_ScriptDir "\res\cleanSourceDirectory.ahk" A_Space """" settings.clipSourcePath """" ; recycle .deleted files & empty folders in source path
}

; input = date time stamp eg. A_Now or A_YYYY A_MM A_DD 00 00 00
getPassedTimeSince(input) {
    output := A_Now
    ; EnvAdd, output, 5, Seconds ; debugging: add 5 seconds to current time
    EnvSub, output, input, Seconds ; amount of seconds passed since input

    return output
}

; input = seconds
; output = seconds formatted in HH:mm:ss format
FormatTimeSeconds(input) {
    DateTimeString := A_YYYY A_MM A_DD 00 00 00
    EnvAdd, DateTimeString, input, Seconds ; add passed seconds to nulltime
    FormatTime, output, % DateTimeString, HH:mm:ss ; format created timestamp into readable format

    return output
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