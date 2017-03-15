/* ---------------------------------------------------------------------------------------
	File: Window_DonutShaped.ahk

	About: Description
    Create a donut shaped window
    
	About: Author
		shimanov 
		
	About: Source 
		https://autohotkey.com/board/topic/7377-create-a-transparent-circle-in-window-w-winset-region/#entry45417

	About: Categories 
	  gui, window

	About: License
		No license given
*/ 
Gui, -Caption
Gui, Add, Picture, x0 y0 w400 h400, c:\windows\winnt.bmp
Gui, Show, x50 y50 w400 h400, region test window

WinGet, hw_gui, ID, region test window

h_region_e1 := DllCall( "CreateEllipticRgn", "int", 80, "int", 80, "int", 320, "int", 320 )
h_region_e := DllCall( "CreateEllipticRgn", "int", 40, "int", 40, "int", 360, "int", 360 )

; RGN_XOR = 3
DllCall( "CombineRgn", "uint", h_region_e, "uint", h_region_e, "uint", h_region_e1, "int", 3 )

DllCall( "SetWindowRgn", "uint", hw_gui, "uint", h_region_e, "uint", true )