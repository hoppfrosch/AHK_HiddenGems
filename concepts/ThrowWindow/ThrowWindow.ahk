/* ---------------------------------------------------------------------------------------
	File: ThrowWindow.ahk

	About: Description
    Throw any window by dragging it with the middle mousebutton and releaseing it.
    The window will float around the monitor bouncing of the screen edges.
    Gravity can be applied to a window in 5 different modes.
    Note that performance starts to suffer when there are 3 or more windows
    moving at the same time or when windows have large pictures displayed in them.

	About: Author
		foom, infogulch et.al
		
	About: Source 
		https://autohotkey.com/board/topic/18184-gui-float-question-expertwise-person-help-needed/page-5#entry270491

	About: Categories 
		gui, window

	About: License
		No license given
*/ 

; changes by infogulch:
;    supports multiple monitors
;    window sticks to same spot on mouse that it started dragging from
;    activates the window once gravity starts
;    speed determined by winow movement instead of mouse movement
;    in gravity modes that don't have a default gravity if it hasn't touched it slows by INTERIA
;    in all modes if you don't "throw" it, it stops where you release it
;    add gravity mode 6 that sets gravity to the side you throw it towards
;    doesn't start gravity mode unless user really drags by more than 1 pixel
;        (this prevents clicks that are meant to activate a window from starting to throw it)
;    added system for starting dragging with multiple hotkeys from either the titlebar only or the entire window
;    added optional enforce boundaries that allows a window to be dragged past the monitor working area and left there
;    attemped a quick fix at the memory issue by forcing variables out of permanent memory and then zeroing their length

; changes by temp01:
;    only starts gravity if you start dragging on the title bar with left mouse button
;    ignores the tray

; changes by spazpunt:
;    gravity works with the left mouse button instead of middle mouse button

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ThrowWindows by Matthäus Drobiec (foom)
; Based on EasyGlide by Paul Pliska (ManaUser) Enhancements by Laszlo
; Based on Easy Window Dragging by Chris?
;
;      AutoHotkey Version: 1.0.46+
;                Platform: XP/2k/NT
;                  Author: Matthäus Drobiec (foom)
;                 Version: 0.1
;
; Script Function:
; Throw any window by dragging it with the middle mousebutton and releaseing it.
; The window will float around the monitor bouncing of the screen edges.
; Gravity can be applied to a window in 5 different modes.
; Note that performance starts to suffer when there are 3 or more windows
; moving at the same time or when windows have large pictures displayed in them.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#SingleInstance Force
#NoEnv

;;CONFIG########################################################################
;#######

INERTIA = .96 ; 1 means Move forever, 0 means not at all.
BOUNCYNESS = .5  ; 1 means no speed is lost, 0 means don't bounce.
SENSITIVITY = .33 ; Higher is more responsive, lower smooths out glitchs more.
                  ;    Must be greater than 0 and no higher than 1.

GRAVITY     = 2 ; 0 means turn gravity off. Negative values are possible too. Best results are in range from -2 to 2.
GRAVITYMODE = 6 ; 1 means the bottom edge has gravity only
                ; 2 means the first edge the window hits will be its source of gravity.
                ; 3 means the last edge the window hits will be its source of gravity.
                ; 4 same as 2 but starts of with bottom gravity rather then moving in a straight line.
                ; 5 same as 3 but starts of with bottom gravity rather then moving in a straight line.
                ; 6 means gravity is based on the direction you throw it

EnfBound    = 1 ; 1 to enforce that windows never leave a monitor
                ; 0 to allow a window to be dragged past the monitor and left there
                ;    note that throwing always makes sure the window is inside the monitor area

SCALEWIN    = 0   ; (performance hog) 0=off, 1=on. Scale windows to get the effect of throwing windows to the background.
SCALEFACTOR = .99 ; 0.90 - 0.99 The factor the window should be scaled down by when thrown.
MINWIDTH    = 200 ; Minimum width a window should be scaled too.
MINHEIGHT   = 100 ; Minimum height a window should be scaled too.
                  ; If one of those two minimums is reached scaling stops.
SpeedA := 1 - SENSITIVITY


Hotkey, LButton, ThrowTitle
Hotkey, LButton Up, Release

Hotkey, RButton, ThrowAll
Hotkey, RButton Up, Release

;#######
;;CONFIG END. DON'T EDIT BELOW.#################################################

	SetBatchLines -1        ; Run faster
	SetWinDelay -1          ; Makes the window moves faster/smoother.
	CoordMode Mouse, Screen ; Switch to screen/absolute coordinates.
	SendMode, Input

	SpeedX := SpeedY := 0 ; init or else it might not work.
	OnMessage(0x1A , "WM_SETTINGCHANGE") ; In case the workarea changes.
	WM_SETTINGCHANGE(47)
return

ThrowTitle:
ThrowAll:
	if (Started || WatchButton) ; only start one at a time
		return
	Started := True
	MouseGetPos StartMouseX, StartMouseY, MWin
	if (A_ThisLabel = "ThrowTitle") {
		SendMessage, 0x84,, ( StartMouseY << 16 ) | StartMouseX,, ahk_id %MWin% ;WM_NCHITTEST
		if (ErrorLevel != 2) { ; check if this is the title bar
			Send, {%A_ThisHotkey% Down}
			Started := False
			return
		}
		isTitle := True
	}
	else
		isTitle := False
	WinGet WinState, MinMax, ahk_id %MWin%
	if (WinState != 0) { ; If the window is maximized, pass through.
		Send, {%A_ThisHotkey% Down}
		Started := False
		return
	}
	WinGetClass, WinClass, ahk_id %MWin%
	if (WinClass = "Shell_TrayWnd") { ;ignore the notification area
		Send, {%A_ThisHotkey% Down}
		Started := False
		return
	}
	If !InStr(WindowQueue, MWin) && !isTitle ; it's already being moved by gravity; no need to wait
		Loop { ; don't initiate gravity unless it actually starts being dragged at least 2 pixels
			If !GetKeyState(A_ThisHotkey, "P") {
				Send, {%A_ThisHotkey% Down}
				Started := False
				return
			}
			MouseGetPos, _mx, _my
			If Abs(StartMouseX-_mx) >= 1 || Abs(StartMouseY-_my) >= 1
				Break ; the user has attempted to drag the window more than one pixel
			Sleep 10
		}
	SetTimer, WatchMouse, Off
	WatchButton := A_ThisHotkey
	WinActivate, ahk_id %MWin% ;activate this window
	RemoveWin(MWin) ; Necessary else GRAVITYMODE = 4 will fail sometimes.
	WinGetPos WinX, WinY, WinWidth, WinHeight, ahk_id %MWin%
	LastWinX := WinX, LastWinY := WinY, SpeedX := SpeedY := 0
	StartMouseRelX := StartMouseX - WinX, StartMouseRelY := StartMouseY - WinY
	SetTimer WatchMouse, 10        ; Track the mouse as the user drags it
	Started := False
Return

Release:
	If (WatchButton = "")
		Send, {%A_ThisHotkey%}
return

WatchMouse:
	If !GetKeyState( WatchButton, "P" ) {
		SetTimer WatchMouse, Off   ; Button has been released, so drag is complete.
		AddWin(MWin)
		SetTimer Move, 10          ; Start moving
		WatchButton := ""
		Return
	}
	; Drag: Button is still pressed
	MouseGetPos MouseX, MouseY
	WinX := MouseX - StartMouseRelX
	WinY := MouseY - StartMouseRelY
	
	;Enforce Boundaries
	If EnfBound
	{
		Mon := MonAtPos(MouseX, MouseY)
		WinX := WinX < WorkArea%Mon%Left ? WorkArea%Mon%Left : WinX+WinWidth > WorkArea%Mon%Right ? WorkArea%Mon%Right-WinWidth : WinX
		WinY := WinY < WorkArea%Mon%Top ? WorkArea%Mon%Top : WinY+WinHeight > WorkArea%Mon%Bottom ? WorkArea%Mon%Bottom-WinHeight : WinY
	}
	
	SpeedX := SpeedX*SpeedA + (WinX-LastWinX)*SENSITIVITY
	SpeedY := SpeedY*SpeedA + (WinY-LastWinY)*SENSITIVITY
	WinMove ahk_id %MWin%,, WinX, WinY
	LastWinX := WinX, LastWinY := WinY
Return

Move:
    If !WindowQueue
        SetTimer Move, Off
    Loop, Parse, WindowQueue , `n
		if A_LoopField
			Move(A_LoopField)
Return

WM_SETTINGCHANGE( w ) {
    global
    if w = 47 ;SPI_SETWORKAREA
	{
		SysGet, MonitorCount, MonitorCount
		Loop %MonitorCount%
			SysGet WorkArea%A_Index%, MonitorWorkArea, %A_Index%
	}
}

MonAtPos( x, y ) {
	global
	loop %MonitorCount%
		If (WorkArea%A_Index%Left <= x && x <= WorkArea%A_Index%Right) && (WorkArea%A_Index%Top <= y && y <= WorkArea%A_Index%Bottom)
			return A_Index
}

AddWin( MWin ) {
    global

    WindowQueue:=List(WindowQueue,MWin)

	%MWin%Mon := MonAtPos(MouseX, MouseY)
    %MWin%WinX := WinX, %MWin%WinY := WinY, %MWin%WinWidth := WinWidth, %MWin%WinHeight := WinHeight
    %MWin%SpeedX := SpeedX, %MWin%SpeedY := SpeedY
	If GravityMode in 1,4,5
		%MWin%gravity := "b" 
	Else If GravityMode = 6
		%MWin%gravity := Abs(%MWin%SpeedX) > Abs(%MWin%SpeedY) ? (%MWin%SpeedX > 0 ? "r" : "l") : (%MWin%SpeedY > 0 ? "b" : "t")
}
RemoveWin( MWin ) {
    global
    local s := "WinX,WinY,WinWidth,WinHeight,SpeedX,SpeedY,mon,gravity,touch,touchedonce"
	WindowQueue:=List(WindowQueue,MWin,"d")
	loop, parse, s, `,  ; force variables out of persistent memory and deliberately zero their length
		VarSetCapacity(%MWin%%A_LoopField%, 64), VarSetCapacity(%MWin%%A_LoopField%, 0)
}

Move( MWin ) {
	global
	local T, G, mon

	G := %MWin%gravity  ;dereferencing is slow.
	mon := %MWin%Mon
	
	If !WinExist("ahk_id" MWin) || Abs(%MWin%SpeedX) < 2 AND Abs(%MWin%SpeedY) < 2 && (GRAVITY ? !%MWin%touchedonce || G = %MWin%Touch : True) {
		RemoveWin(MWin)
		return
	}
	
	if GRAVITY
	{
		%MWin%SpeedX += G = "r" ? GRAVITY : G = "l" ? -GRAVITY : 0
		%MWin%SpeedY += G = "b" ? GRAVITY : G = "t" ? -GRAVITY : 0

		;update wincoords before touch check. If touch() reports collision bouncyness kicks in.
		%MWin%WinX += %MWin%SpeedX,   %MWin%WinY += %MWin%SpeedY

		if (T:=Touch(MWin))
		{
			if GRAVITYMODE = 2
				%MWin%gravity := G ? G : T
			else if (GRAVITYMODE = 3 OR GRAVITYMODE = 5)
				%MWin%gravity := T
			else if GRAVITYMODE = 4
				%MWin%gravity :=  %MWin%touchedonce ? G : T
			%MWin%touchedonce := 1
			%MWin%touch  := T  ;Used to check if window should stop moving when in gravity mode.
			%MWin%SpeedY := (T = "b" || T = "t") ? %MWin%SpeedY * -BOUNCYNESS : %MWin%SpeedY * BOUNCYNESS
			%MWin%SpeedX := (T = "l" || T = "r") ? %MWin%SpeedX * -BOUNCYNESS : %MWin%SpeedX * BOUNCYNESS
		}
		else
		{
			%MWin%touch=
			If (G = "") ; if it hasn't touched yet and it doesn't have gravity, use interia to slow down
				%MWin%SpeedX *= INERTIA,  %MWin%SpeedY *= INERTIA
		}
	}
	else
	{
		%MWin%SpeedX *= INERTIA,  %MWin%SpeedY *= INERTIA
		%MWin%WinX += %MWin%SpeedX,   %MWin%WinY += %MWin%SpeedY
		if (T:=Touch(MWin))
		{
			%MWin%SpeedY *= (T = "b" || T = "t") ? -BOUNCYNESS : 1
			%MWin%SpeedX *= (T = "l" || T = "r") ? -BOUNCYNESS : 1
		}
	}

	;Out of bounds checks.
	%MWin%WinX := %MWin%WinX < WorkArea%Mon%Left ? WorkArea%Mon%Left: %MWin%WinX + %MWin%WinWidth > WorkArea%Mon%Right ? WorkArea%Mon%Right - %MWin%WinWidth : %MWin%WinX
	%MWin%WinY := %MWin%WinY < WorkArea%Mon%Top ? WorkArea%Mon%Top : %MWin%WinY + %MWin%WinHeight > WorkArea%Mon%Bottom ? WorkArea%Mon%Bottom - %MWin%WinHeight : %MWin%WinY

	if SCALEWIN
	{
		Scale(MWin)
		WinMove ahk_id %MWin%,, %MWin%WinX, %MWin%WinY , %MWin%WinWidth, %MWin%WinHeight
	}
	else
		WinMove ahk_id %MWin%,, %MWin%WinX, %MWin%WinY
}
Scale( MWin ) {
    global
    local w, h

    w:=%MWin%WinWidth * SCALEFACTOR,  h:=%MWin%WinHeight * SCALEFACTOR

    if (w > MINWIDTH AND h > MINHEIGHT)
         %MWin%WinX+=(%MWin%WinWidth-w)/2, %MWin%WinWidth := w,%MWin%WinY+=(%MWin%WinHeight-h)/2 , %MWin%WinHeight := h
}

Touch( MWin ) {
    global
	local mon
	mon := %MWin%Mon
    if (%MWin%WinY + %MWin%WinHeight >= WorkArea%Mon%Bottom)
        return "b"
    else if (%MWin%WinY <= WorkArea%Mon%Top)
        return "t"
    else if (%MWin%WinX <= WorkArea%Mon%Left)
        return "l"
    else if (%MWin%WinX + %MWin%WinWidth >= WorkArea%Mon%Right)
        return "r"

}

List( list, Item, Action="", Delim="`n" ) {
;Adds Item to a %Delim% Delimited list, removes it, or selects it by putting 2 Delims behind it.
;Action can be s for select, d for delete, a for add. If ommited it defaults to add.
    if !Item
        return list
    if !list
        if Action = d
            return
        else if Action = s
            return Item . Delim . Delim
        else
            return Item

    if Action = d
        list:=RegExReplace(list,"i)\Q" . Item . "\E(\Q" . Delim . "\E)*","")    ;delete Item if allready in list
    list:=RegExReplace(list,"i)(\Q" . Delim . "\E) {2,}",Delim)                  ;replace succesive Delims
    list:=RegExReplace(list,"i)^(\Q" . Delim . "\E)|(\Q" . Delim . "\E)$","")   ;delete Delims from start and end of list

    if Action = s
        list:=RegExReplace(list,"i)(\Q" . Item . "\E)(?:\Q" . Delim . "\E)*","$1" . Delim . Delim)

    if (Action = "s" || Action = "d" || RegExMatch(list, "i)(?:\Q" . Item . "\E)(?:\Q" . Delim . "\E)*"))  ;the rexexmatch assures we dont add an item twice
        return list
    return Item . Delim . list    ;prepend new items rather then apped makes it easier to debug lists
}