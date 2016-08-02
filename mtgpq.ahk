; ==UserScript==

#SingleInstance force
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen

; Window name
;WINDOW_NAME=Nox
WINDOW_NAME=Clipboard03.png - IrfanView
; Coords within the window for the top left of the board.
ORIGIN_X:=63
ORIGIN_Y:=711
;Size of a single square.
SIZE_X:=71
SIZE_Y:=71
;Margin between bubbles
OFFSET_X:=20
OFFSET_Y:=20
; Number of squares on board.
SQUARES_X:=7
SQUARES_Y:=7
;window width
PQ_W:=724+6 ; client + border
PQ_H:=1336+115 ; client + border
;gemcolors and their median colors
COLORS := {b: 0x453B4D, g: 0x4C9112, p: 0x916E46, r: 0x912C23, u: 0x29539C, w: 0xBFA058}
;client width
init := false
colorvalue := {b: 0, g: 2, p: 0, r: 0, u: 2, w: 2}
;; INIT CMDS
;#Include Lib/GDIP.ahk
#Include Lib/GDIP_All.ahk
#Include Lib/GDIpHelper.ahk
;#Include Lib/Gdip_ImageSearch.ahk
#Include Lib/regionGetColor.ahk ;Import color funktionen
#Include Lib/GetColor.ahk ;eigene color funktionen
SetBatchLines, -1
Process, Priority,, High
SetUpGDIP(2 * A_ScreenWidth)


;window width & height
; colors ok for margin <= 25
c2 := {}
#IfWinActive Clipboard03.png - IrfanView
	F1::getMoves()
	F2::searchArea()
	F3::readState()
	F4::compareColor(0x4C9112)
	F5::Reload
	F6::
		readState()
		;r:=iscol(arr,"r",2,4)
		;r:=checkmove(arr,"g",5,3)
		;i:=4
		;r:= arr[i+1,3]
		msgbox r %r%
		return
	F7::initSettings(true)
#IfWinActive Nox
	F3::readState()
#IfWinActive mtgpq.ahk
	F5::Reload

initSettings(debg=false){
global
	if(!init || debg){
		init := true
	if(A_UserName = "jan"){
		border_left := 3
		border_top := 89 + 7
		; total border should be 115 
		border_bottom := 26
		add_left := 0

		WinGetPos, wX, wY, w, h, %WINDOW_NAME%
		;WinGetTitle, title, %WINDOW_NAME%
		client_height := h-border_top-border_bottom ;h is 7 to big, maybe due to dropshadow
		scale:=(client_height)/(PQ_H-border_top-border_bottom)
		
		if (InStr(WINDOW_NAME,"Clipboard03") && scale < 1)
			add_left := 24
		;msgbox work %A_UserName%
		; Coords within the window for the top left of the board.
		; assume window borders are not scaled#
		ORIGIN_X:=(63 - border_left) * scale + border_left + add_left
		ORIGIN_Y:=(711 - border_top) * scale + border_top  + 23
		
		;Size of a single square.
		SIZE_X:=71*scale
		SIZE_Y:=71*scale
		;Margin between bubbles
		OFFSET_X:=20*scale
		OFFSET_Y:=20*scale
		if debg {
			msgbox h %h% s %scale%`nORIGIN_X:`t%ORIGIN_X%`nORIGIN_Y:`t%ORIGIN_Y%`nSIZE_X:`t%SIZE_X%`nSIZE_Y:`t%SIZE_Y%`nOFFSET_X:`t%OFFSET_X%`nOFFSET_Y:`t%OFFSET_Y%`ncl_height:`t%client_height%
			getCoords(1,1,x,y,x2,y2,w,h)
			drawRect(0xC0FF0000, x, y, w, h)
			msgbox start %x%x%y%
			getCoords(7,7,x,y,x2,y2,w,h)
			drawRect(0xC0FF0000, x, y, w, h)
			msgbox end %x%x%y%
			clear()
		}
	} else {
		;msgbox home %A_UserName%
	}
	}
}




getCoords(i, j, ByRef x_start, ByRef y_start, ByRef x_end = 0, ByRef y_end = 0, ByRef w = 0, Byref h = 0)
{
global
	initSettings()
	WinGetPos, wX, wY, , , %WINDOW_NAME%
	margin := 15 ; current colormedians reliable up to margin 25
	w := SIZE_X - (2 * margin)
	h := SIZE_Y - (2 * margin)

	x_start := wX + ORIGIN_X + (i - 1) * (SIZE_X+OFFSET_X) + margin
	x_end   := x_start + w
	
	y_start := wY + ORIGIN_Y + (j - 1) * (SIZE_Y+OFFSET_Y) + margin
	y_end   := y_start + h
	
	return  
}

clear(){
	StartDrawGDIP()
	ClearDrawGDIP()
	EndDrawGDIP()
	return	
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

searchArea(){
global
	initSettings()
	Loop, 7
	{
	j := A_Index
	Loop, 7
	{
	i := A_Index
		getCoords(i, j, x, y, x2, y2, w, h)
		drawRect(0xC0FF0000, x, y, w, h)
		;msgbox % x y
	}
	}
	;msgbox pling
	clear()
}

readState(){
global
	initSettings()
	t1:= A_now

	arr	:= []
	Loop, 7 {
	j := A_Index
	Loop, 7	{
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


getMoves(){
global
	msgbox start
	mesh := readState()
	moves := {}
	;main
	Loop, 7
	{
	j := A_Index
	Loop, 7
	{
	i := A_Index
		if (i<7) { ; horizontal swaps
			cnt:=check(arr,i,j,true) ;true=right
			if (cnt>0) {
				key := i "," j "-r"
				;msgbox % key ": " cnt
				moves[key] := cnt
			}
		} 
		if (j<7) { ; horizontal swaps
			cnt:=check(arr,i,j,false) ;false=down
			if (cnt>0) {
				key := i "," j "-d"
				;msgbox % key ": " cnt
				moves[key] := cnt
			}
		} 
	}
	}
	result =
	For key, value in moves
		result .= key ": " value "`n"
	msgbox % result
	return moves
}

;all calls must be safe
check(arr,i1,j1,right){
	
	ret := 0
	mesh := Array_DeepClone(arr) ;.Clone()
	i2:= (right ? i1+1 : i1) ; check right
	j2:= (right ? j1 : j1+1) ; check down
	;switch
	tmp := mesh[i2, j2]
	;msgbox % 1 ": "  tmp " " mesh[i2, j2]
	mesh[i2, j2] := mesh[i1, j1]
	mesh[i1, j1] := tmp
	;msgbox % 2 ": " tmp " " mesh[i2, j2]
	;check
	ret += checkmove(mesh, i1, j1, h1, v1)
	ret += checkmove(mesh, i2, j2, h2, v2)
	;msgbox %  (right ? "r" : "d") ": " (right ? "r" : "d")i1 "x" j1  ": " mesh[i1,j1] "=h" h1 "v" v1 " <-> " i2 "x" j2 ": " mesh[i2,j2] "=h" h2 "v" v2
	return ret
}


checkmove(mesh,i,j,ByRef lr=0,ByRef ud=0){
	global colorvalue
	col := mesh[i,j]
	lr := ( iscol(mesh,col,i-1,j) ? (iscol(mesh,col,i-2,j) ? 2 : 1) : 0)
	lr += ( iscol(mesh,col,i+1,j) ? (iscol(mesh,col,i+2,j) ? 2 : 1) : 0)
	ud := ( iscol(mesh,col,i,j-1) ? (iscol(mesh,col,i,j-2) ? 2 : 1) : 0)
	ud += ( iscol(mesh,col,i,j+1) ? (iscol(mesh,col,i,j+2) ? 2 : 1) : 0)
	ret := (lr>1 ? lr : 0)
	ret += (ud>1 ? ud : 0)
	if ret {
		ret++ 
		ret+=colorvalue[col]
	}
	;msgbox %i%,%j%: lr %lr%, ud %ud%, ret %ret%, col %col%
	return ret ;add i,j if match
}

iscol(ByRef mesh,col,i,j){ ;secure get shortcircuit
	return ( (i<0 || i>7 || j<0 || j>7) ? 0 : (col=mesh[i,j]))
}

Array_DeepClone(Array, Objs=0)
{
    if !Objs
        Objs := {}
    Obj := Array.Clone()
    Objs[&Array] := Obj ; Save this new array
    For Key, Val in Obj
        if (IsObject(Val)) ; If it is a subarray
            Obj[Key] := Objs[&Val] ; If we already know of a refrence to this array
            ? Objs[&Val] ; Then point it to the new array
            : Array_DeepClone(Val,Objs) ; Otherwise, clone this sub-array
    return Obj
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
	Gui, Add, Button, Default, Close
	;LV_ModifyCol()  ; Auto-size each column to fit its contents.
	;clipboard := c
	Gui, Show, 
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

ButtonClose:
Gui, Destroy
return


ExitApp
