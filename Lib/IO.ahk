WINDOW_NAME=Nox App Player
ORIGIN_X=63
ORIGIN_Y=711
SIZE_X=71
SIZE_Y=71
OFFSET_X=20
OFFSET_Y=20
SQUARES_X=7
SQUARES_Y=7
PQ_W=730 
PQ_H=1451

readChars(
global
    chars:={}
    i:=0
    Loop {
        IniRead, char, config.ini, "chars", ("c".i), 0
        if(char=0){
            break
        }
        chars[char] := IniReadChar(char)
    }

)

IniReadChar(char) {
    ret:= {}
    colors:=["w", "g", "r", "b", "u", "p"]
    For col in colors {
        IniRead, val, config.ini, char, col, -10
        if (col > -10){
            ret[col]:=val
        }
    }
}

IniWriteChar(
    colors:=["w", "g", "r", "b", "u", "p"]
)


;Displays a 2 dimensional grid according to data in array arr
showGrid(ByRef arr, t, modal:=0)
{
	global
	Gui, Destroy
	;Prepare Title for list view
	header := "0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |`r`n"
	StringTrimLeft, header, header, 1 ;Remove first char

	;Create List to display
	Gui, +AlwaysOnTop +ToolWindow +LastFound
	Gui, Add, ListView, +Grid h180 w320, %header%
	gui_hwnd := WinExist()
	Loop, 7
	{
		y := A_index
		LV_Add(y,y,arr[1, y],arr[2, y],arr[3, y],arr[4, y],arr[5, y],arr[6, y],arr[7, y])
	}
	Gui, Add, Text,, %t%
	Gui, Add, Button, Default, Close
	LV_ModifyCol()  ; Auto-size each column to fit its contents.
	;clipboard := c
	WinGetPos, wX, wY, w, h, %WINDOW_NAME%
	x := wX+w
	Gui, Show, x%x% y%wY%, showGrid
	;WinMove, showGrid, ,wY
	if (modal>0) {
		WinWait, AHK_ID %gui_hwnd%
		WinWaitClose, AHK_ID %gui_hwnd%
	}
	;sleep 3000
	return
}

timediff(st)
{
   transform,S,MOD,st,60
   stringlen,L1,S
   if L1 =1
   S=0%S%
   if S=0
   S=00

   M1 :=(st/60)
   transform,M2,MOD,M1,60
   transform,M3,Floor,M2
   stringlen,L2,M3
   if L2 =1
   M3=0%M3%
   if M3=0
   M3=00

   H1 :=(M1/60)
   transform,H2,Floor,H1
   stringlen,L2,H2
   if L2=1
   H2=0%H2%
   if H2=0
   H2=00
   result= %H2%:%M3%:%S%
   return result
}

drawRect(col, x, y, w, h){
global
;msgbox drawRect x%x%, y%y%, w%w%, h%h%
	StartDrawGDIP()
	ClearDrawGDIP()

	pBrush := Gdip_BrushCreateSolid(col)
	Gdip_FillRectangle(G, pBrush, x, y, w, h)
	Gdip_DeleteBrush(pBrush)

	EndDrawGDIP()
	return	
}
