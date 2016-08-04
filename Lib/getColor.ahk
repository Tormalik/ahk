COLORS := {  0xBFA058: "w"
			,0x4C9112: "g"
			,0x912C23: "r"
			,0x453B4D: "b"
			,0x29539C: "u"
			,0x916E46: "p" }



compareColor(col,debug=0){
	global COLORS
	;min   := 442
	min := 195075 ;squared distance 
	found =
	For value, key in COLORS
	{
		change := 0
		;dist := RGBEuclidianDistance(col,value)
		;SetFormat, IntegerFast, hex
		;msgbox % "col:" col "; val " value
		dist := sqRGBEuclidianDistance(col,value)
		if (dist < min){
			found := key
			min   := dist
			change := 1
		}
		if(debug > 0){
			msgbox compare to %value%`ndist:`t%dist%`nfound:`t%found%`nmin:`t%min%`nchange:`t%change%
		}
	}
	return found
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

;for performancereasons
sqRGBEuclidianDistance( c1, c2 ) ; find the distance between 2 colors
{ ; function by [VxE], return value range = [0, 441.67295593006372]
; that just means that any two colors will have a distance less than 442
   r1 := c1 >> 16
   g1 := c1 >> 8 & 255
   b1 := c1 & 255
   r2 := c2 >> 16
   g2 := c2 >> 8 & 255
   b2 := c2 & 255
   return (r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2
}