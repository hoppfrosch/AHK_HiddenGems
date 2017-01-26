/* ---------------------------------------------------------------------------------------
	File: HiddenGem/glob.ahk
	
	File Globbing

	About: Author: 
		Lexikos

	About: Source: 
		https://autohotkey.com/board/topic/26846-wildcard-folders/#entry173593

	About: Categories: 
		file, path	

	About: License: 
		No license given
*/ 

Glob(list, "C:\Program Files\?u*y\*\*.exe")
MsgBox %list%


/* ---------------------------------------------------------------------------------------
	Method: Glob
		glob iterates the given path pattern, returning a list of matched directory entries
	
	Parameters:
		list - list with found patterns to be retruned
		pattern - path pattern to matched
		IncludeDirs - flag to include directories in matched pathes (else only files will be matched)

	Returns:
		list of matched path patterns

	Example:		
	> Glob(list, "C:\Program Files\?u*y\*\*.exe")
	> MsgBox %list%
*/
Glob(ByRef list, Pattern, IncludeDirs:=0)
{
    if (i:=RegExMatch(Pattern,"[*?]")) && (i:=InStr(Pattern,"\",1,i+1))
        Loop, % SubStr(Pattern, 1, i-1), 2
            Glob(list, A_LoopFileLongPath . SubStr(Pattern,i), IncludeDirs)
    else
        Loop, %Pattern%, %IncludeDirs%
            list .= (list="" ? "" : "`n") . A_LoopFileLongPath
}