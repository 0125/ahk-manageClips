#Persistent
#SingleInstance, force
hotkey, ~^s, reloadScript

Gosub loadSettings
OnExit, exitRoutine

InputBox, sourcePath, Source path, * Have vlc installed `n* Loop file `n* Single instance mode, , , , , , , , % sourcePath
If (sourcePath = "") or (ErrorLevel) ; ErrorLevel = InputBox canceled
	exitapp

hotkey, ~^s, off

reviewClips(sourcePath)
msgbox, 262208, , Finished
exitapp
return

guiRename(input) {
	static
	global guiRename_selectedFolder
	
	SplitPath, input, , dir, ext, name
	
	; properties
	gui rename: margin, 5, 5
	gui rename: +Hwnd_guiRename +LabelguiRename_ -MinimizeBox +AlwaysOnTop
	
	; controls
	gui rename: add, text, , Title
	gui rename: add, edit, w200 vguiRename_name, % name
	gui rename: add, text, , Folder
	gui rename: add, ListBox, w200 r10 vguiRename_selectedFolder gguiRename_selectedFolder
	gui rename: add, button, w97 gguiRename_newFolder, New
	gui rename: add, button, x+5 w97 gguiRename_deleteFolder, Delete
	gui rename: add, button, x5 w200 gguiRename_save, Save (enter)
	
	Gosub guiRename_refresh
	GuiControl rename: Choose, guiRename_selectedFolder, % guiRename_selectedFolder
	
	; hotkeys
	hotkey, IfWinActive, % "ahk_id " _guiRename
	hotkey, enter, guiRename_save
	hotkey, IfWinActive
	
	; show
	If !(guiRenameX = "") and !(guiRenameY = "")
		gui Rename: show, % "x" guiRenameX " y" guiRenameY " AutoSize", % name "." ext
	else
		gui Rename: show, AutoSize, % name "." ext
	
	; close
	WinWaitClose, % "ahk_id " _guiRename
	gui rename: destroy
	return guiRenameErrorLevel
	
	guiRename_refresh:
		GuiControl rename: , guiRename_selectedFolder, | ; empty listbox
		
		loop, % dir "\*.*", 2, 1
		{
			SplitPath, A_LoopFileFullPath, , , , folderName
			GuiControl rename: , guiRename_selectedFolder, % folderName
		}
	return
	
	guiRename_newFolder:
		InputBox, output, Title, , , 200, 120
		If (output = "")
			return
			
		FileCreateDir, % dir "\" output
		
		Gosub guiRename_refresh
	return
	
	guiRename_deleteFolder:
		gui rename: submit, nohide
		
		msgbox, 262212, , Are you sure you want to delete this folder?
		IfMsgBox No
			return
		
		FileRemoveDir, % dir "\" guiRename_selectedFolder, 1
		
		Gosub guiRename_refresh
	return
	
	guiRename_selectedFolder:
		gui rename: submit, nohide
	return
	
	guiRename_save:
		gui rename: submit, nohide
		
		If (guiRename_selectedFolder = "")
		{
			Msgbox, 262208, ,Select a folder to save into!
			return
		}
		
		Gosub vlcStopPlayback
			
		FileMove, % input, % dir "\" guiRename_selectedFolder "\" guiRename_name "." ext
		If (ErrorLevel)
		{
			msgbox, 262208, , Clip with this name already exists in this folder or contains strange characters
			return
		}
		
		WinGetPos(_guiRename, guiRenameX, guiRenameY)
		guiRenameErrorLevel := 0
		gui rename: destroy
	return
	
	guiRename_close:
		WinGetPos(_guiRename, guiRenameX, guiRenameY)
		guiRenameErrorLevel := 1
		gui rename: destroy
	return
}

reviewClips(input) {
	
	input := RTrim(input, "\")
	
	If !InStr(FileExist(input), "D")
	{
		msgbox, 262208, , reviewClips(): input is not a folder
		exitapp
	}
	
	loop, % input "\*.*", 0, 0 ; files only, no recursing
	{
		run % vlcPath " " A_LoopFileFullPath
		WinWait, ahk_class QWidget
		
		If (A_LoopFileExt = "jpg") or (A_LoopFileExt = "jpeg") or (A_LoopFileExt = "png") or (A_LoopFileExt = "bmp") or (A_LoopFileExt = "gif")
		{
		}
		else
		{
			loop, 4
				Gosub vlcForward10
			Gosub vlcForward5
		}
		
		guiReview(A_LoopFileFullPath)
	}
}

guiReview(input) {
	global _guiReview, guiReviewX, guiReviewY
	
	SplitPath, input, , dir, ext, name
	
	; properties
	gui review: +Hwnd_guiReview +LabelguiReview_ -MinimizeBox
	
	; controls
	gui review: add, button, x10 w100 r2 gguiReview_delete, Delete
	gui review: add, button, x+10 w100 r2 gguiReview_keep, Keep
	gui review: add, button, x+10 w100 r2 gguiReview_open, Open
	
	; show
	If !(guiReviewX = "") and !(guiReviewY = "")
		gui Review: show, % "x" guiReviewX " y" guiReviewY " AutoSize", % name "." ext
	else
		gui Review: show, AutoSize, % name "." ext
	
	; close
	WinWaitClose, % "ahk_id " _guiReview
	return
	
	guiReview_open:
		run % input
	return
	
	guiReview_delete:
		Gosub vlcStopPlayback
		
		FileRecycle, % input
		
		Gosub guiReview_destroy
	return
	
	guiReview_keep:
		Gosub vlcStopPlayback
		If (guiRename(input) = 1) ; guiRename was closed without applying changes
			return
		
		Gosub guiReview_destroy
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
	; ControlSend, , s, ahk_class QWidget
	
	Gosub activateVlc
	Send, s
return

vlcForward10:
	; ControlSend, , !{right}, ahk_class QWidget
	Gosub activateVlc
	Send, !{right}
return

vlcBackward10:
	; ControlSend, , !{left}, ahk_class QWidget
	Gosub activateVlc
	Send, !{right}
return

vlcForward5:
	; ControlSend, , +{right}, ahk_class QWidget
	Gosub activateVlc
	Send, !{right}
return

backward5:
	; ControlSend, , +{left}, ahk_class QWidget
	Gosub activateVlc
	Send, !{right}
return

activateVlc:
	IfWinNotActive, ahk_class QWidget
		WinActivate, ahk_class QWidget
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
	
	If (vlcPath = "")
		RegRead, vlcPath, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\VideoLAN\VLC
	If (vlcPath = "")
	{
		msgbox Could not find vlc installation
		exitapp
	}
	else
		global vlcPath
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
		ini_insertKey(ini, "Settings", "guiRenameX=" . "")
		ini_insertKey(ini, "Settings", "guiRenameY=" . "")
		ini_insertKey(ini, "Settings", "guiRename_selectedFolder=" . "")
	
	ini_save(ini)
return
exitRoutine:
	If WinExist("ahk_id " _guiReview)
		WinGetPos(_guiReview, guiReviewX, guiReviewY)
	
	Gosub saveSettings
	
	exitapp
return

reloadScript:
	reload
return
