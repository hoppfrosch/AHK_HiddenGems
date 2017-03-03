/* ---------------------------------------------------------------------------------------
	File: InterfaceLiftWallpaperChanger.ahk.ahk

	About: Description
    Download a random wallpaper from InterfaceLIFT.com and set it to desktop
    
	About: Author
		Argande102 
		
	About: Source 
		https://autohotkey.com/board/topic/98786-interfacelift-wallpaper-changer-v2/

	About: Categories 
	  desktop
		

	About: License
		No license given
*/ 

;--------------------------------------------------;
; InterfaceLIFT Wallpaper Changer v2 by Argande102 ;
;--------------------------------------------------;

SetWorkingDir %A_ScriptDir%

; checking internet connection
if ! DllCall("Wininet.dll\InternetGetConnectedState", "Str", 0x40,"Int",0)
{
  Loop, 10
  {
  Sleep 60000
  internetcount +=1
  if ! DllCall("Wininet.dll\InternetGetConnectedState", "Str", 0x40,"Int",0)
    {}
  Else
    Break
  if A_Index = 10
  {
    TrayTip, No internet connection after 10 retries, Connect to the internet and run the application again.
    Sleep, 10000
    ExitApp
  }
  }
}

; monitor amount, sizes and the highest resolutions
SysGet, monitorCount, MonitorCount
if monitorCount > 1
{
	Loop, %monitorCount%
	{
		SysGet, Monitor%A_Index%, Monitor, %A_Index%
		Monitor%A_Index%Bottom := Monitor%A_Index%Bottom - Monitor%A_Index%Top
		Monitor%A_Index%Right  := Monitor%A_Index%Right  - Monitor%A_Index%Left
	}
	BiggestResWidth = 1
	BiggestResHeight = 1
	Loop, % monitorCount - 1
	{
		otherFighter := A_Index + 1 ; Ready... Fight!
		if (Monitor%BiggestResWidth%Right <= Monitor%otherFighter%Right)
			BiggestResWidth := otherFighter
	}
	Loop, % monitorCount - 1
	{
		otherFighter := A_Index + 1
		if (Monitor%BiggestResHeight%Bottom <= Monitor%otherFighter%Bottom)
			BiggestResHeight := otherFighter
	}
	BiggestRes := Monitor%BiggestResWidth%Right "." Monitor%BiggestResHeight%Bottom
}
else
	BiggestRes := A_ScreenWidth "." A_ScreenHeight ; for single monitors

; download IFL source code
UrlDownloadToFile, https://interfacelift.com/wallpaper/downloads/random/any/, %A_Temp%\interfaceliftpage.html
if ErrorLevel = 1
{
	TrayTip, Error while downloading data from the internet, Connect to the internet and run the application again. Also check interfacelift.com that servers are not down and visit the script's forum thread and check the latest updates.
	Sleep, 15000
	ExitApp
}
FileRead, html, %A_Temp%\interfaceliftpage.html
FileDelete, %A_Temp%\interfaceliftpage.html
RegExMatch(html, ("(?<=\/wallpaper\/previews\/).*?(?=_672x420.jpg)"), urlname) ; part of the dynamic URL
if urlname =
{
	TrayTip, Error while finding dynamic URL, Run the application again. If this error occurs again check interfacelift.com that it's not under maintenance and visit the script's forum thread and check the latest updates.
	Sleep, 15000
	ExitApp
}


; stores all compatible resolutions
Loop
{
	RegExMatch(html, ("(?<=_1"" value="").*?(?="")"), LastResolution)
	if LastResolution =
	{
		if A_Index = 1
		{
			TrayTip, Error while finding resolutions, Run the application again. If this error occurs again visit the script's forum thread and check the latest updates.
			Sleep, 15000
			ExitApp
		}
		break
	}
	StringReplace, LastResolution, LastResolution, % "x", % "."
	WPResolutions := WPResolutions " " LastResolution
	StringReplace, html, html, % "_1"" value=""", % ""
}
Sort, WPResolutions, N D%A_Space%

; find the best compatible resolution
IfInString, WPResolutions, BiggestRes
{
	StringReplace, DLRes, BiggestRes, % ".", % "x"
	Goto, SkipFindRes
}
Loop
{
	RegExMatch(WPResolutions, ("\d+.\d+"), DLRes)
	StringReplace, WPResolutions, WPResolutions, %DLRes%, % ""
	if (DLRes >= BiggestRes)
	{
		StringReplace, DLRes, DLRes, % ".", % "x"
		break
	}
}

SkipFindRes:
; downloads wallpaper
UrlDownloadToFile, % "http://interfacelift.com/wallpaper/7yz4ma1/" urlname "_" DLRes ".jpg", %A_Temp%\wallpaper.bmp
if ErrorLevel = 1
{
	TrayTip, Error while downloading wallpaper, Connect to the internet and run the application again. Also check interfacelift.com that servers are not down and visit the script's forum thread and check the latest updates.
	Sleep, 15000
	ExitApp
}

; sets the wallpaper
RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, WallpaperStyle, 10
RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, TileWallpaper, 0
DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, A_Temp . "\wallpaper.bmp", UInt, 1)