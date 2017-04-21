CoordMode, Caret, Screen                        ; Use screen coordinates.
CoordMode, Mouse, Screen
Gui, Show, x50 y50 w400 h400, region test window ; Spawn a GUI
WinGetPos,,, Width, Height, region test window ahk_class AutoHotkeyGUI
WinGet, ID, ID, region test window ahk_class AutoHotkeyGUI
                                                ; Get its size and ID
X1 := 50                                        ; These four coordinates define the position  
Y1 := 50                                        ; and size of your circle. If you would draw a box 
X2 := 300                                       ; snugly around your circle, these would be the
Y2 := 300                                       ; coordinates of the top-left and bottom-right corners.
h_region_e1 := DllCall( "CreateEllipticRgn", "int", X1, "int", Y1, "int", X2, "int", Y2 )
h_region_e := DllCall( "CreateRectRgn", "int", 0, "int", 0, "int", Width, "int", Height )
DllCall( "CombineRgn", "uint", h_region_e, "uint", h_region_e, "uint", h_region_e1, "int", 3 )
DllCall( "SetWindowRgn", "uint", ID, "uint", h_region_e, "uint", true )
                                                ; This bit is cannibalised from shimanov. The DllCall
                                                ; to "CreateEllipticRgn" defines the ellipse area. 
                                                ; The "CreateRectRgn" call defines a rectangle. Here 
                                                ; it has the size of our test window.
                                                ; "CombineRgn" and "SetWindowRgn" respectively combine
                                                ; and draw the new region. 
Return