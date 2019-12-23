guiReview(input := "") {
    static _guiReview, newFilename

    If (input = "show") { ; setup gui for the first time
        ; properties
        gui guiReview: new
        gui guiReview: +labelguiReview_ +hwnd_guiReview +AlwaysOnTop

        margin := 10

        ; controls
        gui guiReview: add, edit, w350 vnewFilename
        hotkey, IfWinActive, % "ahk_id " _guiReview
        hotkey, enter, guiReview_Keep
        hotkey, IfWinActive
        gui guiReview: add, button, w295 r2 gguiReview_Delete, Delete
        gui guiReview: add, button, x+5 w50 r2 gguiReview_Play, Play
        gui guiReview: add, button, x%margin% w295 r1 gguiReview_Undo, Undo
        gui guiReview: add, button, x+5 w50 r1 gguiReview_Forward, Forward

        ; show
        If (settings.guiReviewX) and (settings.guiReviewY)
            gui guiReview: show, % "x" settings.guiReviewX " y" settings.guiReviewY
        else
            gui guiReview: show
        return
    }

    If (input = "close") {
        gui guiReview: Destroy
        return
    }

    If (input = "savePos") {
        Gosub guiReview_savePos
        return
    }

    GuiControl guiReview:, Edit1, % input ; set edit control to input
    ControlSend, Edit1, ^a, % "ahk_id " _guiReview ; select current file title
    return

    guiReview_Play:
        review.playFile()
    return

    guiReview_Keep:
        gui guiReview: Submit, NoHide
        review.keepFile(newFilename)
        GuiControl guiReview:, Edit1, ; clear edit control
    return

    guiReview_Delete:
        review.deleteFile()
    return

    guiReview_Undo:
        review.undo()
    return

    guiReview_Forward:
        gui guiReview: +OwnDialogs ; prevent gui interaction and set inputbox ontop of gui
        CoordMode, Mouse, Screen
        MouseGetPos, OutputVarX, OutputVarY
        width := 250
        height := 250
        InputBox, OutputVar, % A_ScriptDir, Choose amount of seconds to Forward rounded by 10, , 250, 250, % OutputVarX - (width / 2), % OutputVarY - (height / 2), , , % settings.ForwardSeconds
        If OutputVar is not integer
        {
            msgbox, 64, , % A_ThisFunc ": Must be integer"
            return
        }
        settings.ForwardSeconds := Round(OutputVar / 10) * 10 ; round by 10 if the user didnt already, and save
    return

    guiReview_close:
        Gosub guiReview_savePos

        review.recycleDeletedFiles()
        exitapp
    return

    guiReview_savePos:
        If !WinExist("ahk_id " _guiReview)
            return
        
        WinGetPos, guiReviewX, guiReviewY, , , % "ahk_id " _guiReview
        settings.guiReviewX := guiReviewX
        settings.guiReviewY := guiReviewY
    return
}