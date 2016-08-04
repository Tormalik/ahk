; ==UserScript==

#SingleInstance force
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
;; INIT CMDS
;#Include Lib/GDIP.ahk
#Include Lib/GDIP_All.ahk
#Include Lib/GDIpHelper.ahk
;#Include Lib/Gdip_ImageSearch.ahk
#Include Lib/regionGetColor.ahk ;Import color funktionen
#Include Lib/GetColor.ahk ;eigene color funktionen

; Window name
WINDOW_NAME=Nox App Player
;WINDOW_NAME=black_support.png
SetTitleMatchMode, RegEx
;WINDOW_NAME=i)^.*- IrfanView
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
;client width
init := false
;gideon
;colorvalue := {w: 2, g: 2, r: 0, b: 0, u: 2, p: 0}
;kiora
colorvalue := { w: -1, g: 1, r: -1, b: -1, u: 2, p: 0}
;kiora 60
;colorvalue := { w: 0, g: 3, r: 0, b: 0, u: 3, p: 0}
;liliana
;colorvalue := {w: -1, g: -1, r: 0, b: 2, u: 1, p: 0}
;koth
;colorvalue := {w: -1, g: 0, r: 9, b: 0, u: -1, p: 0}
;nissa
colorvalue := {w: 1, g: 3, r: 1, b: 0, u: 0, p: -2}

col2key := {w: "mana", g: "mana", r: "mana", b: "mana", u: "mana", p: "loyl", v: "void"}


#If WinActive(WINDOW_NAME)
	F1::getMoves()
	F2::searchArea()
	F3::readState()
	F4::compareColor(0x4C9112)
	F5::Reload
	F6::
		initSettings()
		temp_color := getColor(5,7)
		clipboard := temp_color
		msgbox % "Col " temp_color
		return
	F7::initSettings(true)

#If WinActive("Visual Studio Code")
	F5::Reload

initSettings(debg=0){
global
	SetBatchLines, -1
	Process, Priority,, High
	SetUpGDIP(2 * A_ScreenWidth)
	if(!init || debg){
		init := true
	if(A_UserName = "jan"){
		WinGetPos, wX, wY, w, h, %WINDOW_NAME%
		WinGetTitle, Title, %WINDOW_NAME%
 		if (InStr(Title,"IrfanView")) {
			;WINDOW_NAME := Title
			border_left := 3
			border_top := 48
			; total border should be 115 
			border_bottom := 26
			add_left := 0
			scale:=1
			if (RegExMatch(Title, "Zoom: (\d+) x (\d+)" , match)) {
				;client 1336
				scale:=match2/1336
				add_left := 26
				if(InStr(Title,"Screenshot")){
					scale:=match2/1290
					add_left := 18
				}
				;msgbox % "zoom " match1 " x " match2 " : " scale
			}
			if(InStr(Title,"Screenshot")){
				border_top := 5
			}
				;msgbox work %A_UserName%
			; Coords within the window for the top left of the board.
			; assume window borders are not scaled#
			ORIGIN_X:=63  * scale + add_left 
			ORIGIN_Y:=711 * scale + border_top

			SIZE_X:=71*scale
			SIZE_Y:=71*scale
			;Margin between bubbles
			OFFSET_X:=19.5*scale 
			OFFSET_Y:=19.5*scale

		} else { ;Nox
			;msgbox NOX
			WinGetTitle, Title, A
			if(InStr(Title,"Nox")){
				wid := WinExist("A")
				WINDOW_NAME := "AHK_ID " wid
			}
			; clipboard 3 screenshot includes borders
			border_left := 0 ;3
			border_top := 50 ;37
			; total border should be 115 
			border_bottom := 0 ;3
			add_left := 0
			client_height := h 

			ORIGIN_X:=49
			ORIGIN_Y:=561

			
			;Size of a single square.
			SIZE_X:=63
			SIZE_Y:=63
			;Margin between bubbles
			OFFSET_X:=15
			OFFSET_Y:=16
		}
	} else {
		; home
		WinGetTitle, Title, A
		if(InStr(Title,"Nox")){
			wid := WinExist("A")
			WINDOW_NAME := "AHK_ID " wid
			ORIGIN_X:=54
			ORIGIN_Y:=660
			;Margin between bubbles
			OFFSET_X:=19.5
			OFFSET_Y:=19

		}
		WinGetPos, wX, wY, w, h, %WINDOW_NAME%

		;msgbox home %A_UserName%
	}
	if debg {
		txt := "name:`t" WINDOW_NAME "`nwX*wY:`t " wX "x" wY "`nw*h:`t" w "x" h "`n"
		msgbox %txt%h %h% s %scale%`nORIGIN_X:`t%ORIGIN_X%`nORIGIN_Y:`t%ORIGIN_Y%`nSIZE_X:`t%SIZE_X%`nSIZE_Y:`t%SIZE_Y%`nOFFSET_X:`t%OFFSET_X%`nOFFSET_Y:`t%OFFSET_Y%`ncl_height:`t%client_height%
		getCoords(1,1,x,y,x2,y2,w,h)
		;txt := "name:`t" WINDOW_NAME "`nwX*wY:`t " wX "x" wY "`nw*h:`t" w "x" h "`n"
		;msgbox % txt

		drawRect(0xC0FF0000, x, y, w, h)
		msgbox start %x%x%y%
		getCoords(7,7,x,y,x2,y2,w,h)
		drawRect(0xC0FF0000, x, y, w, h)
		msgbox end %x%x%y%
		clear()
	}

	}
}

getCoords(i, j, ByRef x_start, ByRef y_start, ByRef x_end = 0, ByRef y_end = 0, ByRef w = 0, Byref h = 0){
global
	initSettings()
	WinGetPos, wX, wY, w, h, %WINDOW_NAME%
	;txt := "name:`t" WINDOW_NAME "`nwX*wY:`t " wX "x" wY "`nw*h:`t" w "x" h "`n"
	;msgbox % txt
	margin := 10 ; current colormedians reliable up to margin 25
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
	t:= "Dauer " timediff(t2)
	showGrid(arr,t)
	return arr
}


getMoves(){
global
	;msgbox start
	Gui, Moves:Destroy
	grid := readState()
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
			if (cnt["f"]) {
				key := i "," j "-r"
				;msgbox % key ": " cnt
				moves[key] := cnt
			}
		} 
		if (j<7) { ; horizontal swaps
			cnt:=check(arr,i,j,false) ;false=down
			if (cnt["f"]) {
				key := i "," j "-d"
				;msgbox % key ": " cnt
				moves[key] := cnt
			}
		} 
	}
	}
	result := ""
	For key, value in moves {
		;msgbox % toStr(value)
		result .= key ":`t" toStr(value) "`n"
	}
	Gui, Moves:New
	Gui, Moves:+AlwaysOnTop +ToolWindow
	Gui, Moves:Add, Text,, %result%
	Gui, Moves:Add, Button, Default, Cancel
	WinGetPos, wX, wY, w, h, %WINDOW_NAME%
	x:=wX+w
	y:=wY+269
	Gui, Moves:Show, x%x% y%y%, Moves
	WinActivate, %WINDOW_NAME%
	return moves
}

;all calls must be safe
check(arr,i1,j1,right){
	
	grid := Array_DeepClone(arr) ;.Clone()
	i2:= (right ? i1+1 : i1) ; check right
	j2:= (right ? j1 : j1+1) ; check down
	;switch
	tmp := grid[i2, j2]
	;msgbox % 1 ": "  tmp " " grid[i2, j2]
	grid[i2, j2] := grid[i1, j1]
	grid[i1, j1] := tmp
	;msgbox % 2 ": " tmp " " grid[i2, j2]
	;check
	ret := {}
	ret := sumr(ret, checkmove(grid, i1, j1, h1, v1))
	ret := sumr(ret, checkmove(grid, i2, j2, h2, v2))
	if ret.HasKey("f") {

		;msgbox % i1 "," j1 ":" (right ? "right": "down")
		ret := sumr(ret , simdrop(grid,i1,j1,right))
		;showGrid(grid,i1 "," j1 ":" (right? "right": "down") ": " toStr(ret),1)
	}
		
	;msgbox %  (right ? "r" : "d") ": " (right ? "r" : "d")i1 "x" j1  ": " grid[i1,j1] "=h" h1 "v" v1 " <-> " i2 "x" j2 ": " grid[i2,j2] "=h" h2 "v" v2
	return ret
}


checkmove(ByRef grid,i,j,ByRef lr:=0,ByRef ud:=0) {
	global colorvalue
	global col2key
	col := grid[i,j]
	if (col="X" || col="Y")
		return
	l:=0
	while iscol(grid,col,i-(l+1),j) {
		l++
	}
	r:=0
	while iscol(grid,col,i+(r+1),j) {
		r++
	}
	u:=0
	while iscol(grid,col,i,j-(u+1)) {
		u++
	}
	d:=0
	while iscol(grid,col,i,j+(d+1)) {
		d++
	}
	lr := l+r
	ud := u+d
	ret := {}
	key := col2key[col]
	;msgbox % "col-'" col "' key-'" key "'"
	ret[key]:=0
	if (lr>1) {
		if (lr>2){
			l := i-1 ; whole row
			r := 7-i
			t := "lf_" col
			inc(ret,t)
		}
		while (l>0) {
			grid[i-l,j] := "X"
			l--
		}
		while (r>0) {
			grid[i+r,j] := "X"
			r--
		}
		inc(ret,key,lr)
	}
	if (ud>1) {
		if (ud>2){
			u:=j-1 ; whole col
			d:=7-j
			t:="lf_" col
			inc(ret,t)
		}
		
		while (u>0) {
			grid[i,j-u]:="X"
			u--
		}
		while (d>0) {
			grid[i,j+d]:="X"
			d--
		}
		inc(ret,key,ud)
	}
	if ((ud>1 && lr>1) || ud>3 || lr>3) {
		t:= "extra_" col
		inc(ret,t)
	}
	
	
	if (ud>1 || lr>1) {
		inc(ret, "f")
		grid[i,j]:="X"
		v := 1 + ( colorvalue.HasKey(col) ? colorvalue[col] : 0 ) 
		inc(ret,key,v) ;add i,j if match

		;msgbox % toStr(ret) ":" ud "x" lr
		;msgbox % ret[key]
	}
	return ret 
}


simdrop(ByRef grid,i1:=0,j1:=0,right:=0){
	found:=0
	Loop, 7 {
	j := 8-A_Index ;reverse
	Loop, 7	{
	i := 8-A_Index ;reverse
		if iscol(grid, "X",i,j) {
			drop(grid,i,j)
			found++
		}
	}
	}
	if (found<1) {
		return 0
	}
	if (i && false) {
		txt := "simdrop" i1 "," j1 ":" (right? "right": "down")
		showGrid(grid, txt ,1)
	}
	ret := {}
	ret := sumr(ret, checkmatches(grid))
	ret := sumr(ret, simdrop(grid,i1,j1,right))
	return ret
}

drop(ByRef grid,i,j){
	while (grid[i,j]="X")  {
		j2 := j
		while j2 > 1 {
			grid[i,j2] := grid[i,j2-1]
			;setcol(grid,grid[i,j2-1],i,j2)
			j2--
		}
		if (j2 <= 1) {
			grid[i,j2]:="Y"
		} 
	}
}

checkmatches(ByRef grid){
	ret:={}
	Loop, 7 {
	j := A_Index
	Loop, 7	{
	i := A_Index
		sumr(ret,checkmove(grid,i,j))
	}
	}
	return ret
}

sumr(ByRef ret,b){
	For key,value in b {
		found := 0
;		if(ret.HasKey(key) && ret[key]>0 && value>0 ) {
;			msgbox % "ret " ret[key] " - b " value
;			found := 1
;		}
		if (value>0) {
			inc(ret, key, value)
		}
;		if(found) {
;			msgbox % "ret " ret[key] 
;		}

	}
	return ret
}

inc(byRef ret, key ,val:=1){
	a:= (ret.HasKey(key) ? ret[key] : 0)
	ret[key] := a + val
	return ret
}

toStr(a){
	b:=a.Clone()
	txt:= ""
;	if b.HasKey("mana") {
;		msgbox % b["mana"]
;		txt.= b["mana"] "m"
;		b.delete("mana")
;	}
;	if b.HasKey("loyl") {
;		txt.= ", " b["loyl"] "p"
;		b.delete("loyl")
;	}
;	if b.HasKey("void") {
;		txt.= ", " b["void"] "v"
;		b.delete("void")
;	}
;	For key,value in b {
;		if InStr(key,"lf_"){
;			txt.= value "*" key ", "
;			b.delete(key)
;		}
;	}
	For key,value in b {
		if (key!="f" && value>0) {
			txt .= (txt="" ? "" : "; " ) key ":" value
		}
		;txt .= "; " key ":" value
;		msgbox % key ": " value
;		if InStr(key,"extra_"){
;			txt.= value "*" key ", "
;			b.delete(key)
;		}
	}
	return txt
}


iscol(ByRef grid,col,i,j){ ;secure get shortcircuit
	return ( (i<0 || i>7 || j<0 || j>7) ? 0 : (col=grid[i,j]))
}

;setcol(ByRef grid,col,i,j){ ;secure set
;  if(i<0 || i>7 || j<0 || j>7){
;  	    grid[i,j]:=col
;  	    return 1
;    } else {
;  	  return 0
;    }
;  }

Array_DeepClone(Array, Objs:=0){
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

ButtonClose:
Gui, Destroy
return

ButtonCancel:
Gui, Moves:Destroy
return

ExitApp
