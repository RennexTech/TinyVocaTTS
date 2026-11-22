' Tiny Voca Studio Pro - silent launcher
' Hides the CMD window; runs tinyvoca_pro.bat completely in the background.
' (Run tinyvoca_pro.bat once by double-click first: it does the one-time setup.)
Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("WScript.Shell")
here = fso.GetParentFolderName(WScript.ScriptFullName)
sh.CurrentDirectory = here
sh.Run """" & here & "\tinyvoca_pro.bat""", 0, False
