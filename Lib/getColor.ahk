COLORS := {  0xBFA058: "w"
			,0x4C9112: "g"
			,0x912C23: "r"
			,0xBC663F: "r"  ;red support
			,0x453B4D: "b"
			,0x7B50BC: "b"  ;black support
			,0x8558BB: "b"  ;black support
			,0x29539C: "u"
			,0x38312C: "v"  ;void
			,0x31271D: "v"
			,0x26211B: "v"
			,0x504B32: "v" ;forest background
			,0x424A38: "v" ;forest background
			,0x181816: "v" ;forest background
			,0x916E46: "p" }

col2key := {w: "mana", g: "mana", r: "mana", b: "mana", u: "mana", p: "loyl", v: "void"}


iscol(ByRef grid,col,i,j) { ;secure get shortcircuit
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

compareColor(col,debug=0){
	global COLORS
	;min   := 442
	min := 195075 ;squared distance 
	found =
	For value, key in COLORS {
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