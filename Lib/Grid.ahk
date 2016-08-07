readState() {
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
	UpdateGrid(arr,t)

	return arr
}


getMoves() {
	;msgbox start
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
			cnt:=check(grid,i,j,true) ;true=right
			if (cnt["f"]) {
				key := i "," j "-r"
				moves[key] := cnt
			}
		} 
		if (j<7) { ; horizontal swaps
			cnt:=check(grid,i,j,false) ;false=down
			if (cnt["f"]) {
				key := i "," j "-d"
				moves[key] := cnt
			}
		} 
	}
	}
	drawMoves(moves)
	showMoves(moves)
	return moves
}

;all calls must be safe
check(arr,i1,j1,right) {
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
		;UpdateGrid(grid,i1 "," j1 ":" (right? "right": "down") ": " toStr(ret),1)
	}
		
	;msgbox %  (right ? "r" : "d") ": " (right ? "r" : "d")i1 "x" j1  ": " grid[i1,j1] "=h" h1 "v" v1 " <-> " i2 "x" j2 ": " grid[i2,j2] "=h" h2 "v" v2
	return ret
}


checkmove(ByRef grid,i,j,ByRef lr:=0,ByRef ud:=0) {
global Col_w
global Col_g
global Col_r
global Col_b
global Col_u 
global col2key
	col := grid[i,j]
	;msgbox % "c" col
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
	;msgbox % "c:" col "; l:" l "; r" r "; u" u "; d" d ";" 
	ret := {}
	key := col2key[col]
	;msgbox % "col-'" col "' key-'" key "'"
	ret[key]:=0
	if (lr>1) {
		if (lr>2) {
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
		if (ud>2) {
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
		grid[i,j]:="X" ;add i,j if match
		v := 1 + ( Col_%col% ? Col_%col% : 0 ) 
		inc(ret,key,v) 
		;msgbox % toStr(ret) ":" ud "x" lr
		;msgbox % ret[key]
	}
	return ret 
}


simdrop(ByRef grid,i1:=0,j1:=0,right:=0) {
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
	if (i && 0) {
		txt := "simdrop" i1 "," j1 ":" (right? "right": "down")
		UpdateGrid(grid, txt ,1)
	}
	ret := {}
	ret := sumr(ret, checkmatches(grid))
	ret := sumr(ret, simdrop(grid,i1,j1,right))
	return ret
}

drop(ByRef grid,i,j) {
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

checkmatches(ByRef grid) {
	ret:= {}
	Loop, 7 {
	j := A_Index
	Loop, 7	{
	i := A_Index
		sumr(ret,checkmove(grid,i,j))
	}
	}
	return ret
}


;###########################################################################################
; result Object functions
;###########################################################################################

sumr(ByRef ret,b) {
	For key,value in b {
		found := 0
		if (value>0) {
			inc(ret, key, value)
		}
	}
	return ret
}

inc(byRef ret, key ,val:=1) {
	a:= (ret.HasKey(key) ? ret[key] : 0)
	ret[key] := a + val
	return ret
}

toStr(a) {
	b:=a.Clone()
	txt:= ""
	if b.HasKey("mana") {
		txt.= b["mana"] "m"
		b.delete("mana")
	}
	if b.HasKey("loyl") {
		txt.= (StrLen(txt) ? "," : "") b["loyl"] "p"
		b.delete("loyl")
	}
	if b.HasKey("void") {
		txt.= (StrLen(txt) ? "," : "") b["void"] "v"
		b.delete("void")
	}
	For key,value in b {
		if RegExMatch(key, "lf_(\w)", col) {  ;InStr(key,"lf_") {
			txt.= (StrLen(txt) ? ", " : "") (value>1 ?  value : "") col1
			b.delete(key)
		}
	}
	For key,value in b {
		if RegExMatch(key, "extra_(\w)", col) { ;InStr(key,"extra_") {
			txt.= (StrLen(txt) ? ", " : "") "X"(value>1 ?  value : "") col1
			b.delete(key)
		}
	}
	For key,value in b {
		if (key!="f" && value>0) {
			txt .= (StrLen(txt) ? ", " : "") key ":" value
		}
	}
	return txt
}

