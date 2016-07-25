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

;you should also do a search and replace for the above name
PQ_W=831
PQ_H=1380
;window width & height
COLORS := {b: 0, g: 2, p: 1, r: 0, u: 2, w: 2}
arr := Object()
#IfWinActive Clipboard03.png - IrfanView
	F1::searchimage("w",ORIGIN_X,ORIGIN_Y,ORIGIN_X + SQUARES_X * (SIZE_X+OFFSET_X),ORIGIN_Y + SQUARES_Y * (SIZE_Y+OFFSET_Y))
	F2::readstate(arr)

#IfWinActive Nox
	F1::searchimage("w",ORIGIN_X,ORIGIN_Y,ORIGIN_X + SQUARES_X * (SIZE_X+OFFSET_X),ORIGIN_Y + SQUARES_Y * (SIZE_Y+OFFSET_Y))
	F2::readstate(arr)

getCoords(x_num, y_num, ByRef x_start, ByRef y_start, ByRef x_end, ByRef y_end)
{
	global ORIGIN_X
	global ORIGIN_Y
	global SIZE_X
	global SIZE_Y
	global OFFSET_X
	global OFFSET_Y

	x_start := ORIGIN_X + (x_num - 1) * (SIZE_X+OFFSET_X)
	x_end   := x_start + SIZE_X + OFFSET_X
	y_start := ORIGIN_Y + (y_num - 1) * (SIZE_Y+OFFSET_Y)
	y_end   := y_start + SIZE_Y + OFFSET_Y

	return  
}

readState(ByRef arr){
	global SQUARES_X
	global SQUARES_Y
	global COLORS
	
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
			getCoords(x, y, x_start, y_start, x_end, y_end)
			;MsgBox % x_start y_start x_end y_end
			For key, value in COLORS
			{
				FoundX := 0
				FoundY := 0
				CoordMode, Pixel, Relative
				ImageSearch, FoundX, FoundY, x_start,y_start, x_end, y_end, *80 %A_ScriptDir%\%key%.png
				if (FoundX == "")
				{
				}
				else
				{
					arr[x, y] := key
					break
				}
			}
		}
	}
	
	showGrid(arr,SQUARES_X)
	return
}


searchimage(colr, x_start, y_start, x_end, y_end){
	FoundX := 0
	FoundY := 0
	CoordMode, Pixel, Relative
	ImageSearch, FoundX, FoundY, x_start,y_start, x_end, y_end, *80 %A_ScriptDir%\%colr%.png
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
showGrid(ByRef arr, length)
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


;CoordMode Pixel  ; Interprets the coordinates below as relative to the screen rather than the active window.
; ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, *Icon3 %A_ProgramFiles%\SomeApp\SomeApp.exe
; if ErrorLevel = 2
    ; MsgBox Could not conduct the search.
; else if ErrorLevel = 1
    ; MsgBox Icon could not be found on the screen.
; else
    ; MsgBox The icon was found at %FoundX%x%FoundY%