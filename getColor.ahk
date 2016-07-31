getMedianColors(){
	global
	; StartDrawGDIP()
	; Gdip_SetSmoothingMode(G, 3) ;none
	; WinGetPos, X, Y, , , %WINDOW_NAME%
	; X := X + ORIGIN_X
	; Y := Y + ORIGIN_Y
	; pBitmap := Gdip_CreateBitmapFromFile("IMG/allc.png")
	; Gdip_GetImageDimensions(pBitmap,w,h)
	; Gdip_DrawImage(G, pBitmap, X, Y, w, h)
	; Gdip_DisposeImage(pBitmap)
	; EndDrawGDIP()
	; WinActivate, ahk_id %hwnd1%
	cols:=["r","g","u","p","w","b"]
	Gui, 1:+AlwaysOnTop +ToolWindow
	Gui, 1:Color, col
	Gui, 1:Add, Edit, vGUItext +ReadOnly, Color: 0x000000
	Gui, 1:Show, , regionColor
	Loop, 6
	{
		x := A_Index
		c := cols[x]
		col := getColor(x,1)
		GuiControl, , GUItext, % col
		;msgbox % col
		c2[c] := col
	}
	msgbox % c2["r"] ", " c2["g"] ", " c2["u"] ", " c2["p"] ", " c2["w"] ", " c2["b"] ", "
	; verarbeitung
	StartDrawGDIP()
	ClearDrawGDIP()
	EndDrawGDIP()

	return c2
}

getColor(i,j,hwnd=0){
	getCoords(i,j,x,y,a,b,w,h)
	col := regionGetColor(x, y, w, h, hwnd)
	;msgbox % x "x" y ", "  w "x" h ": '"  col "'"
	return col
}

RGBEuclidianDistance( c1, c2 ) ; find the distance between 2 colors
{ ; function by [VxE], return value range = [0, 441.67295593006372]
; that just means that any two colors will have a distance less than 442
   r1 := c1 >> 16
   g1 := c1 >> 8 & 255
   b1 := c1 & 255
   r2 := c2 >> 16
   g2 := c2 >> 8 & 255
   b2 := c2 & 255
   return Sqrt( (r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2 )
}