; #NoTrayIcon

running := false
popupPid :=

#u::
if (running)
{
	WinActivate ahk_pid %popupPid%
}
else
{
	Run, C:\ezautocompl.exe -path C:\example.yml ,,, popupPid
	running := true

	SetTimer , WatchPopupPid
}
return

WatchPopupPid:
Process, WaitClose, %popupPid%
; ToolTip, % "foobar"
running := false
return