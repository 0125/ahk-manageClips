inputRecordingsPath() {
    ; FileSelectFolder, output, E:\Videos\Game clips\Unsorted\1 sort these games\Battlefield 3, , Select folder with game recordings
    output := "E:\Videos\Game clips\Unsorted\1 sort these games\Battlefield 3"
    output := RTrim(output, "\")

    if !folderExist(output) {
        msgbox, 64, % A_ThisFunc, Specified folder does not exist`n`nTerminating script
        exitapp
    }

    If !folderContainsFileType(output, "mp4") {
        msgbox, 64, % A_ThisFunc, Specified folder does not contain any recordings (mp4 format)`n`nTerminating script
        exitapp
    }

    return output
}

guiSourcefolder() {
    FileSelectFolder, OutputVar, StartingFolder, , Select folder with game recordings
    ; properties
    gui guiSourceFolder: +hwnd_guiSourceFolder +label__guiSourceFolder

    ; controls
    gui guiSourceFolder: add, edit, w300, test

    ; show
    gui guiSourceFolder: show
    return
}

folderContainsFileType(folder, fileType) {
    Loop, Files, % folder "\*." fileType
    {
        return true
    }
    return false
}

folderExist(input) {
    if InStr(FileExist(input), "D")
        return true
    return false
}