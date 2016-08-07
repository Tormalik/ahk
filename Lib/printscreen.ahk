getCoords(i, j, ByRef x_start, ByRef y_start, ByRef x_end = 0, ByRef y_end = 0, ByRef w = 0, Byref h = 0) {
global
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