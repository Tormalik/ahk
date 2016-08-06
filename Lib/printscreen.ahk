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

getCenter(i, j, ByRef x_start, ByRef y_start, ByRef x_end = 0, ByRef y_end = 0, ByRef w = 0, Byref h = 0) {
global

}

drawMoves(moves) {
global
	StartDrawGDIP()
	ClearDrawGDIP()
	for key,val in moves {
		RegExMatch(key, "([1-7]),([1-7])-([rd])", c)
		showMove(c1,c2,c3,val)
	}
	EndDrawGDIP()
	return	
}

drawMove(i,j,r,value) {
global
	Gdip_FillPolygon

	return
}

drawRect(col, x, y, w, h) {
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

clear() {
	StartDrawGDIP()
	ClearDrawGDIP()
	EndDrawGDIP()
	return
}

searchArea() {
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

	return
}