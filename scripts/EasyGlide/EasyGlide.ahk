/* ---------------------------------------------------------------------------------------
	File: EasyGlide.ahk

	About: Description
    Make the middle mouse button drag any window, in any internal point.
    Additionally, if you let go while dragging, the window will "glide"
    for short distance, and even bounce off the edges of the screen.
    The distance and "bouncyness" can be adjusted by changing constants

	About: Author
		ManaUser, Laszlo 

	About: Source 
		https://autohotkey.com/board/topic/18184-gui-float-question-expertwise-person-help-needed/page-1

	About: Categories 
		gui, window	

	About: License
		No license given
*/ 

; EasyGlide
; Based on Easy Window Dragging
;
; AutoHotkey Version: 1.0.45.04+
;            Platform: XP/2k/NT
;            Author: Paul Pliska (ManaUser)
;
; Script Function:
; Make the middle mouse button drag any window, in any internal point.
; Additionally, if you let go while dragging, the window will "glide"
; for short distance, and even bounce off the edges of the screen.
; The distance and "bouncyness" can be adjusted by changing constants

#SingleInstance Force
#NoEnv
SetBatchLines -1        ; Run faster
SetWinDelay -1          ; Makes the window moves faster/smoother.
CoordMode Mouse, Screen ; Switch to screen/absolute coordinates.
SysGet WorkArea, MonitorWorkArea

SpeedA     = 0.90       ; Averaging factor (for slow button release)
SpeedB    := 1 - SpeedA ; Speed = A * previous_speed_value + B * new_speed_value
INERTIA    = 0.99       ; 1 means Glide forever, 0 means not at all.
BOUNCYNESS = 0.90       ; 1 means no speed is lost, 0 don't bounce.
SpeedX := SpeedY := 0

~*LButton::             ; Clicking a mouse button stops glide.
~*RButton::
   SetTimer Glide, Off
Return

MButton::
   SetTimer Glide, Off
   MouseGetPos LastMouseX, LastMouseY, MouseWin
   WinGet WinState, MinMax, ahk_id %MouseWin%
   IfNotEqual WinState,0, Return ; Only if the window isn't maximized
   WinGetPos WinX, WinY, WinWidth, WinHeight, ahk_id %MouseWin%
   SetTimer WatchMouse, 10       ; Track the mouse as the user drags it
Return

MButton Up::
   SetTimer WatchMouse, Off      ; MButton has been released, so drag is complete.
   SetTimer Glide, 10            ; Start gliding
Return

WatchMouse:                      ; Drag: Button is still pressed
   MouseGetPos MouseX, MouseY
   WinX += MouseX - LastMouseX
   WinX := WinX < WorkAreaLeft ? WorkAreaLeft : WinX+WinWidth > WorkAreaRight ? WorkAreaRight-WinWidth : WinX
   WinY += MouseY - LastMouseY
   WinY := WinY < WorkAreaTop ? WorkAreaTop : WinY+WinHeight > WorkAreaBottom ? WorkAreaBottom-WinHeight : WinY

   WinMove ahk_id %MouseWin%,, WinX, WinY
   SpeedX := SpeedX*SpeedA + (MouseX-LastMouseX)*SpeedB
   SpeedY := SpeedY*SpeedA + (MouseY-LastMouseY)*SpeedB
   LastMouseX := MouseX, LastMouseY := MouseY
Return

Glide:                           ; Let window glide on
   SpeedX *= INERTIA,  SpeedY *= INERTIA
   If (SpeedX*SpeedX + SpeedY*SpeedY < 0.02) {
      SetTimer Glide, Off        ; It's barely moving, bring it to a complete stop
      Return
   }
   WinX += SpeedX,   WinY += SpeedY
   If (WinX < WorkAreaLeft  OR  WinX + WinWidth > WorkAreaRight)
      SpeedX *= -BOUNCYNESS
   If (WinY < WorkAreaTop  OR  WinY + WinHeight > WorkAreaBottom)
      SpeedY *= -BOUNCYNESS
   WinX := WinX < WorkAreaLeft ? WorkAreaLeft : WinX+WinWidth > WorkAreaRight ? WorkAreaRight-WinWidth : WinX
   WinY := WinY < WorkAreaTop ? WorkAreaTop : WinY+WinHeight > WorkAreaBottom ? WorkAreaBottom-WinHeight : WinY
   WinMove ahk_id %MouseWin%,, WinX, WinY
Return