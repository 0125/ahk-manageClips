g_scriptReqs=
(
Script requirements:
- Have vlc installed

VLC settings:
- Loop single file
- Allow only one instance
- Do not resize interface to video size
)
global g_scriptReqs

global sourcePath

#Persistent
#SingleInstance, force
SetBatchLines -1
hotkey, ~^s, reloadScript

Gosub loadSettings
OnExit, exitRoutine

hotkey, ~^s, off

loop, 
	guiReview(promptSourcePath())
exitapp
return

promptSourcePath() {
	InputBox, output, Choose clip source folder, % g_scriptReqs, , , , , , , , % sourcePath
	If (output = "") or (ErrorLevel) ; ErrorLevel = InputBox canceled
		exitapp
	return output
}

guiRename(input) {
	static
	global guiRename_MyTreeView, guiRename_treeRoot, guiRename_save, guiRename_name, guiRenameX, guiRenameY, guiRenameW, guiRenameH
	
	SplitPath, input, , dir, ext, name
	
	If !(_guiRename = "")
	{
		gui rename: show
		guicontrol rename: , guiRename_name, % name
		
		ControlFocus, Edit1, % "ahk_id " _guiRename
		ControlSend, Edit1, ^a, % "ahk_id " _guiRename
		
		WinWaitClose, % "ahk_id " _guiRename
		return guiRenameErrorLevel
	}
	
	ControlWidth := 280
	ImageListID := IL_Create(5)
	Loop 5 
		IL_Add(ImageListID, "shell32.dll", A_Index)
	If (guiRename_treeRoot = "")
		guiRename_treeRoot := dir
	
	; properties
	gui rename: margin, 5, 5
	gui rename: Default
	gui rename: +Hwnd_guiRename +LabelguiRename_ -MinimizeBox +AlwaysOnTop +Resize
	
	; controls
	gui rename: add, text, , Title
	gui rename: add, edit, w%ControlWidth% vguiRename_name, % name
	gui rename: add, text, , Folder
	gui rename: add, edit, w%ControlWidth% vguiRename_treeRoot gguiRename_MyTreeViewRefreshTimer, % guiRename_treeRoot
	gui rename: add, TreeView, vguiRename_MyTreeView r10 w%ControlWidth% gguiRename_MyTreeView ImageList%ImageListID% AltSubmit
	gui rename: add, button, x5 w%ControlWidth% gguiRename_save vguiRename_save, Save (enter)
	
	gui rename: add, statusbar
	
	Gosub guiRename_MyTreeViewRefresh
	
	; hotkeys
	hotkey, IfWinActive, % "ahk_id " _guiRename
	hotkey, enter, guiRename_save
	hotkey, IfWinActive
	
	; show
	If !(guiRenameX = "") and !(guiRenameY = "") and !(guiRenameW = "") and !(guiRenameH = "")
		gui Rename: show, % "x" guiRenameX " y" guiRenameY " w" guiRenameW " h" guiRenameH
	else
		gui Rename: show, AutoSize
	
	; close
	WinWaitClose, % "ahk_id " _guiRename
	return guiRenameErrorLevel
	
	guiRename_MyTreeViewRefreshTimer:
		SetTimer, guiRename_MyTreeViewRefresh, -100
	return
	
	guiRename_MyTreeViewRefresh:
		gui rename: default
		gui rename: submit, nohide

		GuiControl, -Redraw, guiRename_MyTreeView
		
		TV_Delete()

		SplashTextOn, 200, 25, TreeView and StatusBar Example, Loading the tree...
		AddSubFoldersToTree(guiRename_treeRoot)
		SplashTextOff
		
		GuiControl, +Redraw, guiRename_MyTreeView
		
		guiRename_selectedFullPath := "" ; empty selected folder var incase it is deleted
		SB_SetText("")
	return
	
	guiRename_MyTreeView:
		if (A_GuiEvent = "RightClick")
		{
			; xTvMenu
			Menu, guiRename_MyTreeViewMenu, Add
			Menu, guiRename_MyTreeViewMenu, DeleteAll

			Menu, guiRename_MyTreeViewMenu, Add, Refresh, guiRename_MyTreeViewRefresh
			Menu, guiRename_MyTreeViewMenu, Show
			return
		}
	
		if A_GuiEvent <> S  ; i.e. an event other than "select new tree item".
			return  ; Do nothing.
		
		TV_GetText(SelectedItemText, A_EventInfo) ; determine the full path of the selected folder:
		ParentID := A_EventInfo
		Loop  ; Build the full path to the selected folder.
		{
			ParentID := TV_GetParent(ParentID)
			if not ParentID  ; No more ancestors.
				break
			TV_GetText(ParentText, ParentID)
			SelectedItemText = %ParentText%\%SelectedItemText%
		}
		guiRename_selectedFullPath = %guiRename_treeRoot%\%SelectedItemText%

		SB_SetText(SelectedItemText)
	return
	
	guiRename_save:
		gui rename: submit, nohide
		
		If (guiRename_selectedFullPath = "")
		{
			Msgbox, 262208, , Select a folder to save into!
			return
		}
		
		Gosub vlcStopPlayback
		
		FileMove, % input, % guiRename_selectedFullPath "\" guiRename_name "." ext
		If (ErrorLevel)
		{
			msgbox, 262208, , Clip with this name already exists in this folder or contains strange characters
			return
		}
		
		WinGetPos(_guiRename, guiRenameX, guiRenameY, guiRenameW, guiRenameH, 1)
		guiRenameErrorLevel := 0
		gui rename: hide
	return
	
	guiRename_size:
		if A_EventInfo = 1  ; The window has been minimized.  No action needed.
		return
		; Otherwise, the window has been resized or maximized. Resize the controls to match.
		
		GuiControl rename: Move, guiRename_name, % "W" . (A_GuiWidth - 10)  ; -30 for StatusBar and margins.
		GuiControl rename: Move, guiRename_treeRoot, % "W" . (A_GuiWidth - 10)  ; -30 for StatusBar and margins.
		
		GuiControl rename: Move, guiRename_MyTreeView, % "W" . (A_GuiWidth - 10)  ; -30 for StatusBar and margins.
		GuiControl rename: Move, guiRename_MyTreeView, % "H" . (A_GuiHeight - 150)  ; -30 for StatusBar and margins.
		
		GuiControl rename: Move, guiRename_save, % "W" . (A_GuiWidth - 10)  ; -30 for StatusBar and margins.
		GuiControl rename: Move, guiRename_save, % "Y" . (A_GuiHeight - 52)  ; -30 for StatusBar and margins.
	return
	
	guiRename_close:
		WinGetPos(_guiRename, guiRenameX, guiRenameY)
		guiRenameErrorLevel := 1
		gui rename: hide
	return
}

AddSubFoldersToTree(Folder, ParentItemID = 0)
{
    ; This function adds to the TreeView all subfolders in the specified folder.
    ; It also calls itself recursively to gather nested folders to any depth.
    Loop %Folder%\*.*, 2  ; Retrieve all of Folder's sub-folders.
        AddSubFoldersToTree(A_LoopFileFullPath, TV_Add(A_LoopFileName, ParentItemID, "Expand Icon4"))
}

guiReview(input) {
	global _guiReview, guiReviewX, guiReviewY
	
	input := RTrim(input, "\")
	
	If !InStr(FileExist(input), "D")
	{
		msgbox, 262208, , reviewClips(): input is not a folder
		exitapp
	}
	
	reviewFiles := []
	loop, % input "\*.*", 0, 0
		reviewFiles.push(A_LoopFileFullPath)

	; properties
	gui review: +Hwnd_guiReview +LabelguiReview_ -MinimizeBox +AlwaysOnTop
	
	; controls
	gui review: add, button, x10 w100 r2 gguiReview_scheduleFileDelete, Delete
	gui review: add, button, x+10 w100 r2 gguiReview_keep, Keep
	gui review: add, button, x+10 w100 r2 gguiReview_open, Open
	
	; show
	If !(guiReviewX = "") and !(guiReviewY = "")
		gui Review: show, % "x" guiReviewX " y" guiReviewY " AutoSize"
	else
		gui Review: show, AutoSize
	
	reviewFilesNr++ ; set var to 1
	Gosub guiReview_open
	
	; close
	WinWaitClose, % "ahk_id " _guiReview
	return
	
	guiReview_nextFile:
		reviewFilesNr++
		
		If (reviewFilesNr = reviewFiles.Length() + 1)
		{
			Gosub vlcStopPlayback ; stop playback since this is the last file and can't be stopped by playing the next file
			Gosub guiReview_fileDelete
			WinKill, ahk_exe vlc.exe
			gui review: destroy
			return
		}
		
		Gosub guiReview_open
	return
	
	guiReview_open:
		SplitPath, % reviewfiles[reviewFilesNr], , , ext, name
		gui review: show, , % name "." ext
		
		reviewfile := reviewfiles[reviewFilesNr]
		run "%vlcPath%" "%reviewfile%"
		
		If !(ext = "jpg") and !(ext = "jpeg") and !(ext = "png") and !(ext = "gif") and !(ext = "bmp") 
		{ ; assume video file
			WinWait, ahk_exe vlc.exe
			loop, 4
				Gosub vlcForward10
			Gosub vlcForward5
		}

		Gosub guiReview_fileDelete
	return
	
	guiReview_scheduleFileDelete:
		guiReview_deleteFile := reviewfiles[reviewFilesNr]
		
		GoSub guiReview_nextFile
	return
	
	guiReview_fileDelete:
		If !(guiReview_deleteFile = "")
		{
			FileRecycle, % guiReview_deleteFile
			guiReview_deleteFile := ""
		}
	return
	
	guiReview_keep:
		gui review: +Disabled
		
		Gosub vlcStopPlayback
		If (guiRename(reviewfiles[reviewFilesNr]) = 1) ; guiRename was closed without applying changes
		{
			gui review: -Disabled
			return
		}
		
		GoSub guiReview_nextFile
		
		gui review: -Disabled
	return
	
	
	guiReview_close:
		exitapp
	return
}


vlcStopPlayback:
	; ControlSend, , s, ahk_exe vlc.exe
	
	Gosub activateVlc
	Send, s
return

vlcForward10:
	; ControlSend, , !{right}, ahk_exe vlc.exe
	Gosub activateVlc
	Send, !{right}
return

vlcBackward10:
	; ControlSend, , !{left}, ahk_exe vlc.exe
	Gosub activateVlc
	Send, !{right}
return

vlcForward5:
	; ControlSend, , +{right}, ahk_exe vlc.exe
	Gosub activateVlc
	Send, !{right}
return

backward5:
	; ControlSend, , +{left}, ahk_exe vlc.exe
	Gosub activateVlc
	Send, !{right}
return

activateVlc:
	IfWinNotActive, ahk_exe vlc.exe
		WinActivate, ahk_exe vlc.exe
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
	
	; get vlc path
	If (vlcPath = "")
		RegRead, vlcPath, HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\VideoLAN\VLC
	If (vlcPath = "")
	{
		FileSelectFile, vlcPath , 3, , Select vlc executable, Executables (*.exe) ; File Must Exist / Path Must Exist
		If vlcPath not contains vlc.exe
		{
			msgbox Selected executable is not vlc`n`nClosing script
			exitapp
		}
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
		ini_insertKey(ini, "General", "vlcPath=" . "")
		
	ini_insertSection(ini, "Settings")
		ini_insertKey(ini, "Settings", "guiReviewX=" . "")
		ini_insertKey(ini, "Settings", "guiReviewY=" . "")
		ini_insertKey(ini, "Settings", "guiRenameW=" . "")
		ini_insertKey(ini, "Settings", "guiRenameH=" . "")
		ini_insertKey(ini, "Settings", "guiRenameX=" . "")
		ini_insertKey(ini, "Settings", "guiRenameY=" . "")
		ini_insertKey(ini, "Settings", "guiRename_treeRoot=" . "")
	
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
