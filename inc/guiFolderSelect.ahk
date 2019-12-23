guiFolderSelect(input = "") {
    static
    
    If !(g_guiFolderSelect_Mode = "source") and !(g_guiFolderSelect_Mode = "destination") {
        msgbox, 64, , % A_ThisFunc ": Invalid input: g_guiFolderSelect_Mode is not set to source or destination"
        return
    }

    If (input = "refresh") and (_guiFolderSelect) {
        Gosub guiFolderSelect_Treeview_Refresh
        return
    }

    If (input = "savePos") {
        Gosub guifolderSelect_savePos
        return
    }

    ; properties
    gui guiFolderSelect: New ; set as default gui to be used by gui commands such as TV_Add
    gui guiFolderSelect: Default ; set as default gui to be used by gui commands such as TV_Add
    gui guiFolderSelect: +hwnd_guiFolderSelect +labelguiFolderSelect_On
    
    margin := 10
    controlMaxWidth := 400

    ; controls
    gui guiFolderSelect: add, text, w350, Root
    gui guiFolderSelect: add, edit, % "w" controlMaxWidth-55 " vguiFolderSelect_Root gguiFolderSelect_Root section", % settings[g_guiFolderSelect_Mode "Root"]
    gui guiFolderSelect: add, button, x+5 ys-1 gguiFolderSelect_Browse w50, Browse

    guiFolderSelect_TreeviewImageListID := IL_Create(5)
    Loop 5 
        IL_Add(guiFolderSelect_TreeviewImageListID, "shell32.dll", A_Index)

    gui guiFolderSelect: add, text, w350 x%margin%, Folder
    gui guiFolderSelect: add, treeview, x%margin% w%controlMaxWidth% h350 AltSubmit vguiFolderSelect_Treeview gguiFolderSelect_Treeview ImageList%guiFolderSelect_TreeviewImageListID%
    Gosub guiFolderSelect_Treeview_Refresh

    ; show

    If (settings.guifolderSelectX) and (settings.guifolderSelectY)
        gui guifolderSelect: show, % "x" settings.guifolderSelectX " y" settings.guifolderSelectY, % "Select " g_guiFolderSelect_Mode " folder"
    else
        gui guifolderSelect: show, , % "Select " g_guiFolderSelect_Mode " folder"
    WinWaitClose, % "ahk_id" _guiFolderSelect
    return output

    guiFolderSelect_Root:
        Gosub guiFolderSelect_Treeview_Refresh
    return

    guiFolderSelect_Treeview:
        TV_GetText(SelectedItemText, A_EventInfo)

        If (A_GuiEvent = "Normal") { ; left click
            ; msgbox Normal
        }
        If (A_GuiEvent = "DoubleClick") { ; right click
            output := getTreeViewSelectedFullPath(guiFolderSelect_Root, SelectedItemText, A_EventInfo)
            Gosub guifolderSelect_savePos
            gui guiFolderSelect: Submit
            ; msgbox DoubleClick
        }
        If (A_GuiEvent = "RightClick") { ; right click
            ; msgbox RightClick
        }
    return

    guiFolderSelect_Treeview_Refresh:
        gui guiFolderSelect: Default
        gui guiFolderSelect: Submit, NoHide

        TV_Delete() ; empty treeview
        If !folderExist(guiFolderSelect_Root)
            return

        SplashTextOn, 400, 50, % A_ScriptName, Loading treeview..
        SplitPath, % settings[g_guiFolderSelect_Mode "Folder"], OutFileName, OutDir, OutExtension, FolderNoExt, OutDrive
        AddSubFoldersToTree(guiFolderSelect_Root,, FolderNoExt) ; populate treeview
        SplashTextOff
    return

    guiFolderSelect_Browse:
        FileSelectFolder, Output, , , Select source root 
        If !folderExist(Output)
            return
        GuiControl guiFolderSelect:, Edit1, % Output
    return

    guiFolderSelect_OnContextMenu:
        if (A_GuiControl != "guiFolderSelect_Treeview")  ; This check is optional. It displays the menu only for clicks inside the TreeView.
            return

        ; reset context menu
        Menu, TreeviewMenu, Add
        Menu, TreeviewMenu, DeleteAll

        ; check if rightclick was on a folder or inside the treeview
        TV_GetText(SelectedItemText, A_EventInfo)
        If !(SelectedItemText)
            g_guiFolderSelect_TreeviewSelectedFullPath := settings[g_guiFolderSelect_Mode "Root"] ; right clicked in treeview but not on a folder
        else
            g_guiFolderSelect_TreeviewSelectedFullPath := getTreeViewSelectedFullPath(guiFolderSelect_Root, SelectedItemText, A_EventInfo)
        Menu, TreeviewMenu, Add, &New, TreeviewMenu_newFolder
        Menu, TreeviewMenu, Add, &Open, TreeviewMenu_OpenFolder
        If (SelectedItemText)
            Menu, TreeviewMenu, Add, &Delete, TreeviewMenu_deleteFolder ; dont show delete option when root folder is selected
        Menu, TreeviewMenu, Add
        Menu, TreeviewMenu, Add, &Refresh, TreeviewMenu_refresh
        Menu, TreeviewMenu, Show, %A_GuiX%, %A_GuiY%
    return

    guiFolderSelect_OnClose:
        Gosub guifolderSelect_savePos
        
        exitapp
    return

    guifolderSelect_savePos:
        If !WinExist("ahk_id " _guifolderSelect)
            return
        
        WinGetPos, guifolderSelectX, guifolderSelectY, , , % "ahk_id " _guifolderSelect
        settings.guifolderSelectX := guifolderSelectX
        settings.guifolderSelectY := guifolderSelectY
    return
}

TreeviewMenu_newFolder:
    gui guiFolderSelect: +OwnDialogs ; prevent gui interaction and set inputbox ontop of gui
    CoordMode, Mouse, Screen
    MouseGetPos, OutputVarX, OutputVarY
    width := 250
    height := 250
    InputBox, OutputVar, % A_ScriptDir, , , 300, 120, % OutputVarX - (width / 2), % OutputVarY - (height / 2)
    
    FileCreateDir, % g_guiFolderSelect_TreeviewSelectedFullPath "\" OutputVar
    guiFolderSelect("refresh")
return

TreeviewMenu_OpenFolder:
    run, % g_guiFolderSelect_TreeviewSelectedFullPath
return

TreeviewMenu_deleteFolder:
    FileRecycle, % g_guiFolderSelect_TreeviewSelectedFullPath
    guiFolderSelect("refresh")
return

TreeviewMenu_refresh:
    guiFolderSelect("refresh")
return

TreeviewMenu_dummy:
return