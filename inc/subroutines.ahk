GuiClose:
	for a, b in class_guiReview.Instances 
		if (a = A_Gui+0)
			b["Events"][SubStr(A_ThisLabel, 4)].Call()

	for a, b in class_guiStats.Instances 
		if (a = A_Gui+0)
			b["Events"][SubStr(A_ThisLabel, 4)].Call()
return

GuiContextMenu:
	for a, b in class_guiStats.Instances 
		if (a = A_Gui+0)
			b["Events"]["Contextmenu"].Call()
return