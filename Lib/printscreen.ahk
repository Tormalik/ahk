getCoords(i, j, ByRef x_start, ByRef y_start, ByRef x_end = 0, ByRef y_end = 0, ByRef w = 0, Byref h = 0) {
global WINDOW_NAME
global ORIGIN_X
global ORIGIN_Y
global SIZE_X
global SIZE_Y
global OFFSET_X
global OFFSET_Y
global PADDING
	initSettings()
	WinGetPos, wX, wY, w, h, %WINDOW_NAME%
	;txt := "name:`t" WINDOW_NAME "`nwX*wY:`t " wX "x" wY "`nw*h:`t" w "x" h "`n"
	;msgbox % txt
	 ; current colormedians reliable up to PADDING 25
	w := SIZE_X - (2 * PADDING)
	h := SIZE_Y - (2 * PADDING)

	x_start := wX + ORIGIN_X + (i - 1) * (SIZE_X+OFFSET_X) + PADDING
	x_end   := x_start + w
	
	y_start := wY + ORIGIN_Y + (j - 1) * (SIZE_Y+OFFSET_Y) + PADDING
	y_end   := y_start + h
	
	return  
}

calibrate() {
global grid_hwnd
global calibrate_step
global calibrate_x1
global calibrate_y1
global WINDOW_NAME
global LoadedConfig
global ORIGIN_X
global ORIGIN_Y
global SIZE_X
global SIZE_Y
global OFFSET_X
global OFFSET_Y
global PADDING
CoordMode, Mouse, Screen
	if (!calibrate_step) {
		calibrate_x1:=0
		calibrate_y1:=0
		calibrate_step:=1
		WinGetPos, wX, wY, w, h, %WINDOW_NAME%
		x := wX+w
		WinMove,ahk_id %grid_hwnd%,, x, wY
		GuiControl, grid:,CharChoice,
		SB_SetText("click in the center of a corner gem")
	}
	if (calibrate_step=1) {
		MouseGetPos, calibrate_x1, calibrate_y1
		calibrate_step:=2
		WinGetPos, wX, wY, w, h, %WINDOW_NAME%
		x := wX+w
		WinMove,ahk_id %grid_hwnd%,, x, wY
		GuiControl, grid:,CharChoice,
		SB_SetText("msgbox click in the center of the opposite corner gem")
	} else if (calibrate_step=2) {
		MouseGetPos, xpos, ypos
		calcgridsize(xpos,ypos)
		calibrate_step:=0
		WinGetPos, wX, wY, w, h, %WINDOW_NAME%
		txt := ""
		vars:= ["LoadedConfig","ORIGIN_X","ORIGIN_Y","SIZE_X","SIZE_Y","OFFSET_X","OFFSET_Y","PADDING","WINDOW_NAME","wX","wY","w","h"]
		for i,var in vars {
			pad:= ("             " var)
			StringRight, pad, pad, 12
			txt .= pad " : " %var% "`n"
		}
		dialog(txt,"Consolas")
		getCoords(1,1,x,y,x2,y2,w,h)
		drawRect(0xC0FF0000, x, y, w, h)
		msgbox start %x%x%y%
		getCoords(7,7,x,y,x2,y2,w,h)
		drawRect(0xC0FF0000, x, y, w, h)
		msgbox end %x%x%y%
		clear()
		MsgBox, 4,, Would you like to save these settings?
		IfMsgBox Yes
		{
			SaveConfig()
			MsgBox Config Saved
		}
	}
}

calcgridsize(calibrate_x2,calibrate_y2){
global calibrate_x1
global calibrate_y1
global WINDOW_NAME
global ORIGIN_X
global ORIGIN_Y
global SIZE_X
global SIZE_Y
global OFFSET_X
global OFFSET_Y
global PADDING
	WinGetPos, wX, wY, w, h, %WINDOW_NAME%
	msgbox % wX "x" wY ", " w "x" h
	x1:=(calibrate_x1 > calibrate_x2 ? calibrate_x2 : calibrate_x1)-wX
	x2:=(calibrate_x1 > calibrate_x2 ? calibrate_x1 : calibrate_x2)-wX
	y1:=(calibrate_y1 > calibrate_y2 ? calibrate_y2 : calibrate_y1)-wY
	y2:=(calibrate_y1 > calibrate_y2 ? calibrate_y1 : calibrate_y2)-wY
	msgbox % x1 "x" y1 ", " x2 "x" y2
	cellx:=(x2-x1)/6
	celly:=(y2-y1)/6
	SIZE_X:=Round(0.777*cellx,2) ;(7/9)
	SIZE_Y:=Round(0.777*celly,2)
	OFFSET_X:=Round(0.222*cellx,2)
	OFFSET_Y:=Round(0.222*celly,2)
	PADDING:=Round(0.666*OFFSET_X,2)
	ORIGIN_X:=Round(x1-(0.5*SIZE_X),2)
	ORIGIN_Y:=Round(y1-(0.5*SIZE_X),2)
	calibrate_x1:=0
	calibrate_y1:=0
}


getCenter(i, j, ByRef x, ByRef y) {
global
	initSettings()
	WinGetPos, wX, wY, w, h, %WINDOW_NAME%
	x := wX + ORIGIN_X + (i - 1) * (SIZE_X+OFFSET_X) + SIZE_X/2
	y := wY + ORIGIN_Y + (j - 1) * (SIZE_Y+OFFSET_Y) + SIZE_Y/2
	return
}

drawMoves(moves) {
global G	
	StartDrawGDIP()
	ClearDrawGDIP()
	pBrush := Gdip_BrushCreateSolid(0xC0A0A0A0)		; polygon fill
	pPen:=Gdip_CreatePen(0xC0FFFFFF, 2) 			; polygon outline
	Gdip_SetInterpolationMode(G, 7)
	for key,val in moves {
		RegExMatch(key, "([1-7]),([1-7])-([rd])", c)
		drawMove(c1,c2,c3,val,pBrush,pPen)
	}
	Gdip_DeletePen(pPen)
	Gdip_DeleteBrush(pBrush)
	EndDrawGDIP()
	return	
}

drawMove(i,j,r,value,pBrush,pPen) {
global G
	i2:=(r="r"? i+1 : i)
	j2:=(r="r"? j : j+1)
	getCenter(i, j, x1,y1)
	getCenter(i2,j2,x4,y4)

	if (r="r") {
		q:= (x4-x1)/4
		x1+=q/6
		x4-=q/6
		q:= (x4-x1)/4
		
		x2:= x1+q
		y2:= y1-q
		x3:= x4-q 
		y3:= y4-q
		x5:= x4-q
		y5:= y4+q
		x6:= x1+q
		y6:= y1+q 
	} else {
		q:= (y4-y1)/4
		y1+=q/6 
		y4-=q/6
		q:= (y4-y1)/4

		x2:= x1+q
		y2:= y1+q
		x3:= x4+q 
		y3:= y4-q
		x5:= x4-q
		y5:= y4-q
		x6:= x1-q
		y6:= y1+q 

	}
	poly:= x1 "," y1 "|" x2 "," y2 "|" x3 "," y3 "|" x4 "," y4 "|" x5 "," y5 "|" x6 "," y6
	Gdip_SetSmoothingMode(G,4)
	Gdip_FillPolygon(G,pBrush, poly)
	;poly outline
	Loop, 6 {
		a := A_Index
		b := Mod(a, 6) + 1 ; 7=>1
		sx := Round(x%a%,1)
		sy := Round(y%a%,1)
		ex := Round(x%b%,1)
		ey := Round(y%b%,1)
		Gdip_DrawLine(G, pPen, sx, sy, ex, ey)
	}
	x1 := (x1+x4)/2
	y1 := (y1+y4)/2
	t:=toStr(value)
	;msgbox % "'" t "'"
	t:=StrReplace(t, "," , "`n",cnt)
	options:="Center vCenter s12 "
	outline:=" cFFFFFFFF"
	color:=" cFF000000"
	w:=0.7 ;outline width
	Gdip_SetSmoothingMode(G,1)
	y1-=4
	y1-=cnt*8
	;posis:=[("x" x1-w " y" y1-w outline),("x" x1-w " y" y1+w outline),("x" x1+w " y" y1-w outline),("x" x1+w " y" y1+w outline),("x" x1 " y" y1 color)]
	posis:=[("x" x1 " y" y1 color)]
	For i,pos in posis {
		Gdip_TextToGraphics(G,t,(options pos))
	}

	return
}

drawRect(col, x, y, w, h) {
global G
;msgbox drawRect x%x%, y%y%, w%w%, h%h%
	StartDrawGDIP()
	ClearDrawGDIP()

	pBrush := Gdip_BrushCreateSolid(col)
	Gdip_FillRectangle(G, pBrush, x, y, w, h)
	Gdip_DeleteBrush(pBrush)

	EndDrawGDIP()

	return	
}

clear() {
global G
	StartDrawGDIP()
	ClearDrawGDIP()
	EndDrawGDIP()
	return
}

searchArea() {
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

	return
}