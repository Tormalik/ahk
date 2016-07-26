; ==UserScript==
; Window name
;WINDOW_NAME=Nox
WINDOW_NAME=Clipboard03.png - IrfanView (Zoom: 688 x 1270)
; Coords within the window for the top left of the board.
ORIGIN_X=69
ORIGIN_Y=712
;Size of a single square.
SIZE_X=71
SIZE_Y=71
;Margin between bubbles
OFFSET_X=19
OFFSET_Y=19
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

#Include Lib/GDIP.ahk
#Include Lib/GDIP_all.ahk
#Include Lib/GDIP_all.ahk
#Include Lib/Gdip_ImageSearch.ahk
OnExit, EXIT_LABEL


;you should also do a search and replace for the above name
PQ_W=831
PQ_H=1380
;window width & height
COLORS := {b: 0, g: 2, p: 1, r: 0, u: 2, w: 2}
arr := Object()
#IfWinActive Clipboard03.png - IrfanView
	F1::searchimage("w",ORIGIN_X,ORIGIN_Y,ORIGIN_X + SQUARES_X * (SIZE_X+OFFSET_X),ORIGIN_Y + SQUARES_Y * (SIZE_Y+OFFSET_Y))
	F2::readstate(arr)
	F3::readstate2(arr)

#IfWinActive Nox
	F1::searchimage("w",ORIGIN_X,ORIGIN_Y,ORIGIN_X + SQUARES_X * (SIZE_X+OFFSET_X),ORIGIN_Y + SQUARES_Y * (SIZE_Y+OFFSET_Y))
	F2::readstate(arr)
	F3::readstate2(arr)

getCoords(x_num, y_num, ByRef x_start, ByRef y_start, ByRef x_end, ByRef y_end)
{
	global ORIGIN_X
	global ORIGIN_Y
	global SIZE_X
	global SIZE_Y
	global OFFSET_X
	global OFFSET_Y

	margin := 15
	x_start := ORIGIN_X + (x_num - 1) * (SIZE_X+OFFSET_X) + margin
	x_end   := x_start + SIZE_X - margin
	y_start := ORIGIN_Y + (y_num - 1) * (SIZE_Y+OFFSET_Y) + margin
	y_end   := y_start + SIZE_Y - margin

	return  
}

readState(ByRef arr){
	global SQUARES_X
	global SQUARES_Y
	global COLORS

	CoordMode, Pixel, Relative
	t1:= A_now
	x_start = 0
	x_end = 0
	y_start = 0
	y_end = 0
	arr := Object()
	c =
	c = %c% 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |`r`n
	Loop, 7
	{
		y := A_Index
		Loop, 7
		{
			x := A_Index
			arr[x, y] := 0
		}
	}
	For key, value in COLORS
	{
		Loop, 7
		{
			y := A_Index
			Loop, 7
			{
				x := A_Index
				if (arr[x, y] == 0){
					CoordMode, Pixel, Relative
					getCoords(x, y, x_start, y_start, x_end, y_end)
					;MsgBox % x_start y_start x_end y_end
					FoundX := 0
					FoundY := 0
					ImageSearch, FoundX, FoundY, x_start,y_start, x_end, y_end, *80 %A_ScriptDir%\IMG\%key%.png
					if (FoundX != "")
					{
						arr[x, y] := key
						;break
					}
				}
			}
		}
	}
	t2 := A_now
	t2 -= t1, s
	t:= timediff(t2)
	showGrid(arr,SQUARES_X,t)
	return
}

readState2(ByRef arr){
	global SQUARES_X
	global SQUARES_Y
	global COLORS
	

	t1:= A_now
	CoordMode, Pixel, Screen
	gdipToken := Gdip_Startup()

	x_start := 0
	x_end 	:= 0
	y_start := 0
	y_end 	:= 0
	arr 	:= Object()
	c =
	c = %c% 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |`r`n
	
	Loop, 7
	{
		y := A_Index
		Loop, 7
		{
			x := A_Index
			arr[x, y] := 0
		}
	}
	WinGet, hwnd,ID, Clipboard03.png - IrfanView	
	bmpHaystack := Gdip_BitmapFromHWND(hwnd)
	msgbox %wx%x%wy% - %ww%x%wh% - %bmpHaystack%
	For key, value in COLORS
	{
		path = IMG/%key%.png
		bmpNeedle := Gdip_CreateBitmapFromFile(path)
		Loop, 7
		{
			y := A_Index
			Loop, 7
			{
				x := A_Index
				if (arr[x, y] == 0){
					getCoords(x, y, x_start, y_start, x_end, y_end)
					;MsgBox % x_start y_start x_end y_end
					RET := Gdip_ImageSearch(bmpHaystack,bmpNeedle,, x_start,y_start, x_end, y_end,80,0xFFFFFF,1,0)
					;ImageSearch, FoundX, FoundY, x_start,y_start, x_end, y_end, *80 %A_ScriptDir%\IMG\%key%.png
					if (RET > 0)
					{
						arr[x, y] := key
						;break
					}
				}
			}
		}
		Gdip_DisposeImage(bmpNeedle)
	}
	Gdip_DisposeImage(bmpHaystack)
	Gdip_Shutdown(gdipToken)
	t2 := A_now
	t2 -= t1, s
	t:= timediff(t2)
	showGrid(arr,SQUARES_X,t)
	return

}

searchimage(colr, x_start, y_start, x_end, y_end){
	FoundX := 0
	FoundY := 0
	CoordMode, Pixel, Relative
	ImageSearch, FoundX, FoundY, x_start,y_start, x_end, y_end, *80 %A_ScriptDir%\IMG\%colr%.png
	; MouseMove, x_start,y_start, 5
	; MouseMove, x_end,y_end, 5
	message =
	ret := false
    if (foundX == "")
	{
		message = The icon was not found
		return false
    }
	else
	{
		MouseMove, FoundX, FoundY, 5
 		message = The icon was found at %FoundX%x%FoundY%
		return true
    }
	; GUI, Name: New  ;
	; Gui, Add, Text,, %message%
	; GUI, Add, Picture, xm ym+30 gCancel, %A_ScriptDir%\b2.png
	; GUI, Add, Button, xm ym+80 Default gCancel, Cancel
	; GUI, Show, , Background Test
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
	Gui, Add, ListView, +Grid h180 w220, %header%
	c =
	c = %c% 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |`r`n
	;msgbox %arr%, %length% ;DEBUG
	Loop, %length%
	{
		y := A_index
		LV_Add(y,arr[1, y],arr[2, y],arr[3, y],arr[4, y],arr[5, y],arr[6, y],arr[7, y])
		Loop, %length%
		{
			x := A_index
			val := arr[x, y]
			c = %c%%val% | 
		}
		c = %c%`r`n 
	}
	Gui, Add, Text,, Dauer %t%
	;LV_ModifyCol()  ; Auto-size each column to fit its contents.
	clipboard := c
	Gui, Show, 
	sleep 3000
	return
}

Cancel(){
	Gui, Destroy
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

EXIT_LABEL: ; be really sure the script will shutdown GDIP
Gdip_Shutdown(gdipToken)
EXITAPP

;CoordMode Pixel  ; Interprets the coordinates below as relative to the screen rather than the active window.
; ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *Icon3 %A_ProgramFiles%\SomeApp\SomeApp.exe
; if ErrorLevel = 2
    ; MsgBox Could not conduct the search.
; else if ErrorLevel = 1
    ; MsgBox Icon could not be found on the screen.
; else
    ; MsgBox The icon was found at %FoundX%x%FoundY%