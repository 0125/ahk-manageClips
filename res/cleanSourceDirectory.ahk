#SingleInstance, force

inputDir := A_Args[1]
If !(FolderExist(inputDir))
    exitapp

; recycle .deleted files
Loop, Files, % inputDir "\*.deleted", FR ; loop all files and recurse into subdirectories
{
    recycleName := A_LoopFileDir "\" RTrim(A_LoopFileName, ".deleted") ; Remove .deleted suffix before recycling
    FileMove, % A_LoopFileFullPath, % recycleName
    FileRecycle, % recycleName
}

; recycle empty folders
Loop, Files, % inputDir "\*.*", DR ; loop all folders and recurse into subdirectories
{
    currentDir := A_LoopFileFullPath
    fileCount := false
    Loop, Files, % currentDir "\*.*", FR ; loop all files and recurse into subdirectories
        fileCount++

    If !(fileCount)
        FileRecycle, % currentDir
}
exitapp

FolderExist(input) {
    if InStr(FileExist(input), "D")
        return true
    return false
}