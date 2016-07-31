#Persistent
#SingleInstance, force

Gosub loadSettings
OnExit, exitRoutine

InputBox, sourcePath, Source path, , , , 110, , , , , % sourcePath
If (sourcePath = "")
	exitapp
	
reviewClips(sourcePath)
msgbox script end
return

reviewClips(input) {
	
	input := RTrim(input, "\")
	
	If !InStr(FileExist(input), "D")
	{
		msgbox reviewClips(): input is not a folder
		exitapp
	}
	
	loop, % input "\*.*", 1, 2
	{
		run % A_LoopFileFullPath
		WinWait, ahk_class QWidget
		loop, 4
			Gosub vlcForward10
		Gosub vlcForward5
		
		guiReview(A_LoopFileFullPath)
	}
}

guiReview(input) {
	global _guiReview, guiReviewX, guiReviewY
	
	; properties
	gui review: +Hwnd_guiReview +LabelguiReview_ 
	
	; controls
	gui review: add, button, w100 r2 gguiReview_delete, Delete
	gui review: add, button, w100 r2 gguiReview_keep, Keep
	
	; show
	If !(guiReviewX = "") and !(guiReviewY = "")
		gui Review: show, % "x" guiReviewX " y" guiReviewY " AutoSize", Inv Count
	else
		gui Review: show, AutoSize, Inv Count
	
	; close
	WinWaitClose, % "ahk_id " _guiReview
	return
	
	guiReview_delete:
		Gosub vlcStopPlayback
		
		FileRecycle, % input
		
		Gosub guiReview_destroy
	return
	
	guiReview_keep:
		Gosub guiReview_rename
		
		Gosub guiReview_destroy
	return
	
	guiReview_rename:
		Gosub vlcStopPlayback
		
		SplitPath, input, , dir, ext, name
		
		InputBox, output, Title, , , 150, 110, % guiReviewX, % guiReviewY, , , % name
		If (output = "")
			return
			
		FileMove, % input, % dir "\" output "." ext
	return
	
	guiReview_destroy:
		WinGetPos(_guiReview, guiReviewX, guiReviewY)
		gui review: destroy
	return
	
	guiReview_close:
		exitapp
	return
}


vlcStopPlayback:
	ControlSend, , s, ahk_class QWidget
return

vlcForward10:
	ControlSend, , !{right}, ahk_class QWidget
return

vlcBackward10:
	ControlSend, , !{left}, ahk_class QWidget
return

vlcForward5:
	ControlSend, , +{right}, ahk_class QWidget
return

backward5:
	ControlSend, , +{left}, ahk_class QWidget
return


loadSettings:
	SplitPath, A_ScriptName, , , , ScriptName
	iniFile := A_ScriptDir "\" ScriptName ".ini"
	
	ini_load(ini, iniFile)
	If (ErrorLevel = 1)
	{
		Gosub writeIni
		ini_load(ini, iniFile)
	}
	
	iniWrapper_loadAllSections(ini)
return

saveSettings:
	iniWrapper_saveAllSections(ini)
		
	ini_save(ini, iniFile)
return

writeIni:
	ini_insertSection(ini, "General")
		ini_insertKey(ini, "General", "sourcePath=" . "")
		
	ini_insertSection(ini, "Settings")
		ini_insertKey(ini, "Settings", "guiReviewX=" . "")
		ini_insertKey(ini, "Settings", "guiReviewY=" . "")
	
	ini_save(ini)
return
exitRoutine:
	WinGetPos(_guiReview, guiReviewX, guiReviewY)
	
	Gosub saveSettings
	
	exitapp
return

~^s::reload