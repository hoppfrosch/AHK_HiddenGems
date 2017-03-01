/* ---------------------------------------------------------------------------------------
	File: HiddenGem/System/GetBinaryType.ahk

	About: Description
	  Determines whether a file is an executable (.exe) file, and if so, which subsystem runs the executable file.
	  
	About: Author
		jNizM

	About: Source 
		- https://autohotkey.com/boards/viewtopic.php?f=5&t=28681
		- https://msdn.microsoft.com/en-us/library/aa364819(v=vs.85).aspx

	About: Categories 
		system, msdn, file

	About: License
		No license given
*/ 
MsgBox % GetBinaryType("C:\Windows\System32\calc.exe")    ; -> 32BIT

/* ---------------------------------------------------------------------------------------
	Method: GetBinaryType
		Determines whether a file is an executable (.exe) file, and if so, which subsystem runs the executable file.
	
	Parameters:
		Application - full path to the applicatiom

	Returns:
		Binary Type of the Application

	Example:		
> MsgBox % GetBinaryType("C:\Windows\System32\calc.exe")    ; -> 32BIT
*/
GetBinaryType(Application)
{
    static Type := {0 : "32BIT", 1: "DOS", 2: "WOW", 3: "PIF", 4: "POSIX", 5: "OS216", 6: "64BIT"}
    DllCall("GetBinaryType", "str", Application, "uint*", BinaryType)
    return Type[BinaryType]
}