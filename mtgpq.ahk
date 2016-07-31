; ==UserScript==

#SingleInstance force
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

; Window name
;WINDOW_NAME=Nox
WINDOW_NAME=Clipboard03.png - IrfanView
; Coords within the window for the top left of the board.
ORIGIN_X=63
ORIGIN_Y=711
;Size of a single square.
SIZE_X=71
SIZE_Y=71
;Margin between bubbles
OFFSET_X=20
OFFSET_Y=20
; Number of squares on board.
SQUARES_X=7
SQUARES_Y=7
; Game Mode we are in
PQ_MODE=1
;0 = default
;1 = Battle
;2 = Train Mounts
;3 = Research Spells
;4 = Forge Items
PQ_PRIORITY_1=w ;Skulls
PQ_PRIORITY_2=w ;Skulls
PQ_PRIORITY_3=s ;Scrolls
PQ_PRIORITY_4=a ;Anvils
; Show moves only? or actually move?
PQ_SHOW=1

SetBatchLines, -1
Process, Priority,, High

;#Include Lib/GDIP.ahk
#Include Lib/GDIP_All.ahk
#Include Lib/GDIpHelper.ahk
;#Include Lib/Gdip_ImageSearch.ahk
#Include Lib/regionGetColor.ahk ;Import color funktionen
#Include Lib/GetColor.ahk ;eigene color funktionen

SetUpGDIP(2 * A_ScreenWidth)
;you should also do a search and replace for the above name
PQ_W=831
PQ_H=1380
;window width & height
COLORS := {b: 0x453B4D, g: 0x4C9112, p: 0x916E46, r: 0x912C23, u: 0x29539C, w: 0xBFA058}
c2 := {}
arr := []
#IfWinActive Clipboard03.png - IrfanView
	F2::searchArea()
	F3::readState(arr)
	F4::compareColor(0x4C9112)
	
#IfWinActive Nox
	F3::readState(arr)

compareColor(col)

getCoords(x_num, y_num, ByRef x_start, ByRef y_start, ByRef x_end = 0, ByRef y_end = 0, ByRef w = 0, Byref h = 0)
{
	global ORIGIN_X
	global ORIGIN_Y
	global SIZE_X
	global SIZE_Y
	global OFFSET_X
	global OFFSET_Y
	WinGetPos, wX, wY, , , %WINDOW_NAME%
	margin := 30
	w := SIZE_X - 2 * margin
	h := SIZE_Y - 2 * margin

	x_start := wX + ORIGIN_X + (x_num - 1) * (SIZE_X+OFFSET_X) + margin
	x_end   := x_start + w
	
	y_start := wY + ORIGIN_Y + (y_num - 1) * (SIZE_Y+OFFSET_Y) + margin
	y_end   := y_start + h
	
	return  
}


drawRect(col, x, y, w, h){
global
	StartDrawGDIP()
	ClearDrawGDIP()

	pBrush := Gdip_BrushCreateSolid(col)
	Gdip_FillRectangle(G, pBrush, x, y, w, h)
	Gdip_DeleteBrush(pBrush)

	EndDrawGDIP()
	return	
}

searchArea(){
global
	
	Loop, 7
	{
	j := A_Index
	Loop, 7
	{
	i := A_Index
		getCoords(i, j, x, y, x2, y2, w, h)
		drawRect(0x80FF0000, x, y, w, h)
		;msgbox % x y
	}
	}
	;msgbox pling
	StartDrawGDIP()
	ClearDrawGDIP()
	EndDrawGDIP()
}

readState(ByRef arr){
global
	t1:= A_now

	arr	:= []
	Loop, 7
	{
		j := A_Index
		Loop, 7
		{
			i := A_Index
			
			getCoords(i, j, x, y, a, b, w, h)
			col := regionGetColor(x, y, w, h)
			col := compareColor(col)
			;msgbox % col
			arr[i, j] := col
			;drawRect(col, x_start, y_start, w, h)
		}
	}

	t2 := A_now
	t2 -= t1, s
	t:= timediff(t2)
	showGrid(arr,SQUARES_X,t)
	return arr
}


getMoves(arr){

}


;===== SUPPORT =====
;Displays a 2 dimensional grid according to data in array arr
showGrid(ByRef arr, length, t)
{
	global
	Gui, Destroy
	;Prepare Title for list view
	header =
	Loop, %length%
	{
		header = %header% | %A_index%
	}
	StringTrimLeft, header, header, 1 ;Remove first char
	;clipboard = %header% ;DEBUG
	;Create List to display
	Gui, +AlwaysOnTop +ToolWindow
	Gui, Add, ListView, +Grid h180 w320, %header%
	;c =
	;c = %c% 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |`r`n
	;msgbox %arr%, %length% ;DEBUG
	Loop, %length%
	{
		y := A_index
		LV_Add(y,arr[1, y],arr[2, y],arr[3, y],arr[4, y],arr[5, y],arr[6, y],arr[7, y])
		; Loop, %length%
		; {
			; x := A_index
			; val := arr[x, y]
			; ;c = %c%%val% | 
		; }
		;c = %c%`r`n 
	}
	Gui, Add, Text,, Dauer %t%
	;LV_ModifyCol()  ; Auto-size each column to fit its contents.
	;clipboard := c
	Gui, Show, 
	sleep 3000
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





ExitApp
