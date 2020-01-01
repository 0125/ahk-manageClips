#SingleInstance, force
#NoTrayIcon
input := A_Args[1]

; check if input is valid
If !(FolderExist(input)) {
    msgbox, 64, , % A_ScriptName ": Input folder '" input "' does not exist!"
    exitapp
}

; wait a period of time to prevent restoring deleted file too soon,
; main script runs this script before reloading it so it has a chance to,
; start using a deleted files while is being recycled
sleep 2000

; recycle deleted files
loop, files, % input "\*.deleted", FR
{
    ; restore original file name
    input := RTrim(A_LoopFileFullPath, ".deleted")
    FileMove, % A_LoopFileFullPath, % input

    ; recycle file
    FileRecycle, % input
}

; recycle empty folders
loop, files, % input "\*.*", DR
{
    ; check if any files exist in the current folder
    foundFiles := ""
    loop, files, % A_LoopFileFullPath "\*.*", FR
        foundFiles++

    ; delete empty folders
    If !(foundFiles)
        FileRecycle, % A_LoopFileFullPath
}

exitapp