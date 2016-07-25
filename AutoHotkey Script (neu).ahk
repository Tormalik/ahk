; ==UserScript==
; @name           AutoPuzzleQuest
; @namespace      http://userscripts.org/users/49912
; @description    Script to play a board game (Puzzle Quest)
; @forum          http://www.autohotkey.com/forum/viewtopic.php?t=32786
; @source         http://www.autohotkey.net/~vixay/AutoPuzzleQuest.zip
; @identifier     http://www.autohotkey.com/forum/topic5663.html
; @version        1.2
; @date           2008-06-19
; @creator        ViXaY XaVieR
; @include        Nox App Player
; ==/UserScript==
; Original Source: see @source
;
; Proof of concept thang to recognise pieces by colour.
;
; Assumes that all pieces are primary (rgb) or secondary (cmy)
; colors, orange, or grey. Doesn't use PixelSearch, as the
; background may be any colour. Instead, checks the color of a
; single pixel offset within each square to build a map of the
; board layout each turn, then operates on that.
;
; Detection of red/orange/yellow and cyan/blue is really a bit dodgy
; and often wrong.
;
; Copyright is explicitly released upon the public domain.
; This means you may do as you wish with it, without credit.

; ==TO DO==
;DONE trigger to start combat - use hoteky Ctrl+Alt+1..4 or GUI, Alt+F1
;DONE autodetection of end - see gameOver()
;DONE preferences for 4 in ones and skulls, and for scrolls, or anvils  depending on game mode (BATTLE, TRAIN MOUNT, RESEARCH SPELL, FORGE ITEM)
;DONE GUI for options (type of combat, delay, wait for AI turn ...etc)
;DONE check for defeat banner
;DONE check colors for wild cards and black skulls, scrolls & anvils - created a new function as well
;DONE disable wait for my turn in different game modes
;DONE output grid (in memory) in a neat way - see showGrid()
;DONE fix color detection (sometimes it still makes illegal moves)
;DONE scan grid only after our turn indicator has come
;SOMEWHAT DONE overlay possible moves on GRID for better user Decision making & faster searches for moves - see PQ_SHOW
;DONE higlight/help/assist mode (dont make the moves, just show them) tooltips? - see PQ_SHOW
;DONE shortcut keys for spells 1-6
;DONE Add PAUSE value Control to GUI (to allow modification of delay)
;DONE move mouse to position of image found by default to provide subtle feedback that loop has terminated.
; detect game modes by checking on screen
; some illegal moves are due to flashing icons on grid?
; check if spell is available via getPixelColor

;IDEA spell loop for battle
;	check for 4
;		check for skulls
;			check available spells/mana
;	 			if stun & FAVOR & promotion can be cast
;					cast Stun
;					cast Favor
;				if favor is active
;					find promotion candidate (to get four in one)
;						cast promotion
;				if favor is active
;					count magenta if >= 16 
;						cast Knight Lord
;				if enemy health > 150
;					if can cast DeathGaze
;						cast DeathGaze
;	...etc.

;DONE Request for Context Sensitive Help in ISense thread (so i don't have to run two scripts) - modified script myself

; Globals.

; Offset to measure within the square.
SG_OFFSET_X=23
SG_OFFSET_Y=11
; Coords within the window for the top left of the board.
SG_ORIGIN_X=56
SG_ORIGIN_Y=657
; Size of a single square.
SG_SIZE_X=90
SG_SIZE_Y=90
; Number of squares on board.
SG_SQUARES_X=7
SG_SQUARES_Y=7
; Remember last move so we're less likely to get stuck trying the same wrong move forever.
; But if there are TWO wrong moves, then...
SG_LAST_X=0
SG_LAST_Y=0
; Whether this version allows piece dragging rather than click/click.
SG_DRAG_OK=1
; Debugg  ing level
PQ_DBG=0
; Whether to Pause (for AI turn) or not
PQ_PAUSE=1000
; Start at top of board or bottom
PQ_TOP=0
; Is AI Turn available
PQ_AI=0
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
PQ_WINDOW_NAME=Nox
;you should also do a search and replace for the above name
PQ_W=724
PQ_H=1336
;window width & height

SpellX = 100 ;Initialy X Position of the first spell
SpellY = 500 ;Initialy Y Position of the first spell
SpellDistance = 41 ;# of pixels for each spell button

F10::ExitApp
F11::Reload ; pause/reload the script. stop scripts execution
F12::Run "C:\Users\m4ch\AppData\Roaming\Nox\bin\Nox.exe"

; Debugging & GUI shortcut keys
#IfWinActive Nox
{
F1::LaunchGUI()
F2::
anaylyzeResolution()
return
F3::trainMount()

F5::toggleVar("PQ_DBG")
F6::toggleVar("PQ_SHOW")
F7::toggleVar("PQ_PAUSE")
F8::toggleVar("PQ_AI")

F9::
	;for debugging purposes
	scanGrid()
	showGrid("SG_COLOR",8)
	tempvar = %sg_line% %clipboard%
	showGrid("SG_ARR",8)
	clipboard = %tempvar% %clipboard%
	Gui, Destroy
return
}
#IfWinActive
;Spells shortcuts
#IfWinActive Nox App Player
{
1::
2::
3::
4::
5::
6::
7::
;clickSpell() routine
t_hot := A_ThisHotKey
	;save current coordinates
	MouseGetPos, xpos, ypos 
	;click on spell
	MouseClick, L, SpellX, SpellY + (t_hot-1)*SpellDistance
	Sleep	100
	;go back to original coordinates
	MouseMove, xpos, ypos 
return
}
#IfWinActive

; Main loop for playing the game
^!z::
startPlaying:
Loop
{
	getWindow() ;Ensure PQ window is active
	scanGrid()	; Done Scanning Grid
	;prioritize Skulls first, then other types
	;gotMove = 
	;if (PQ_MODE = 1 || PQ_MODE = 2)
		;gotMove = getMoveFor("w")
	;else if (PQ_MODE = 3)
		;gotMove = getMoveFor("s")
	;else if (PQ_MODE = 4)
		;gotMove = getMoveFor("a")
	;if (!gotMove) getMove()
	;!getMoveFor("k") ;check for wildcard moves as well - will require more complicated logic!
	if !checkGridFor4()
		if (!getMoveFor(PQ_PRIORITY_%PQ_MODE%))
			getMove()

	if PQ_DBG
	{
		tp := PQ_PRIORITY_%PQ_MODE%
		MsgBox, DEBUG %PQ_DBG%, Mode %PQ_MODE%, PQ_PRIORITY %tp%
		;clipboard = %sg_line%
		showGrid("SG_COLOR",8)
		LV_ModifyCol() ;AutoFit Columns
		;Gui, Show, Hide x55 y66 w300 h200,
		;Resize Window
		;Gui, Show, w600 
		;Resize Control in window
		;GuiControl, Move, SysListView321, w600
		; save data to append to clipboard
		tempvar = %sg_line% %clipboard%
		showGrid("SG_ARR",8)
		clipboard = %tempvar% %clipboard%
		;return
		break
		}
;	if (gameOver() == 1) ;victory
;	{
;		return ;Exit loop if finished puzzle
;	}
;	else if (gameOver() == 2) ;DoneSmall
;	{
;	}
;	if (gameOver() == 3) ;defeat
;	{
;		;various retry options depending on mode
;	}
	if (gameOver() > 0)
	{
		if PQ_MODE = 2
		{
			MouseMove, 10, 10
			;after victory condition
			;Click Done on message saying you've upgraded your mount
			
			if findImage("DoneSmall.bmp")
				clickMoveWait(500)
			; find and click on continue

			;defeat or victory click on continue
			if findImage("Continue.bmp")
			{
				clickMoveWait(1000)
			}
			else if findImage("LevelUp.bmp")
			{
				clickMoveWait(1000)
				if findImage("DoneOnly.bmp")
					clickMoveWait(500)
			}
			;Go through the whole Train Mounts thing again
			if (!trainMount())
				return
		}
		else if PQ_MODE >= 3
		{
			if (!retryAgain())
				return
		}
		else
			return ;Exit loop if finished puzzle
	}
	if PQ_AI
		waitForMyTurn()
	;wait here after AI has played to let pieces fall and text clear
	;if PQ_PAUSE
	sleep, %PQ_PAUSE%
}
return

;===== LOGIC =====

; Scans Grid into array for evaluation later
scanGrid()
{
	global
	; Loop Y then X: move across every square, down only once per line.
	sg_line := ("")
	Loop, %SG_SQUARES_Y%
	{
		sg_y := A_Index 
		sg_py := yCoordToPixel(A_Index)
		sg_line = %sg_line% `n# %A_Index% :
		Loop, %SG_SQUARES_X%
		{
			sg_x := A_Index
			sg_px := xCoordToPixel(A_Index)
			PixelGetColor, sg_color, %sg_px%, %sg_py%, RGB
			SG_COLOR_%sg_x%_%sg_y% := sg_color
			;sg_c := hex2Color(sg_color)
			sg_c := colorLookup(sg_color)
			SG_ARR_%sg_x%_%sg_y% := sg_c
			;col := SG_ARR_%sg_x%_%sg_y%
			;MsgBox, SG_ARR_%sg_x%_%sg_y%  = %col%
			sg_line = %sg_line% %sg_c% ( %sg_x% , %sg_y% = %sg_px% , %sg_py% )
		}
		;MsgBox, %sg_line%
	}
}

anaylyzeResolution()
{
	global PQ_W
	global PQ_H
	;getWindow()
	WinGetPos, X, Y, W, H, A
	MsgBox, The active window is at %X%`,%Y% with size %W%x%H%  %PQ_W%x%PQ_H% ;DEBUG
	;if ((W <> 1024) || (H <> 768))
	;{
		scaleFactorX := W/PQ_W
		scaleFactorY := H/PQ_H
	;}
	;else
	;{
;		scaleFactorX := 1
		;scaleFactorY := 1
	;}
	MsgBox scaleFactor(X,Y) = %scaleFactorX%,%scaleFactorY%
	return 1
}

;Ensures that the game window is the active window
getWindow()
{
global PQ_W
global PQ_H
; Window management. This shouldn't care about the window name.
WinWait, Nox App Player,
IfWinNotActive, Nox App Player, , WinActivate, Nox App Player,
WinWaitActive, Nox App Player,
WinGetPos, X, Y, PQ_W, PQ_H, A
;save window dimensions
}

; Convert a board y square coord to a screen y coord.
; Returns Top Down or Bottom up depending on SG_TOP
yCoordToPixel(y)
{
global SG_SIZE_Y
global SG_ORIGIN_Y
global SG_OFFSET_Y
global SG_SQUARES_Y
global PQ_TOP
; SG_SQUARES_Y - y as we're working from the bottom for highest scores.
;return ( ( SG_SQUARES_Y - y + 1 ) * SG_SIZE_Y ) + SG_ORIGIN_Y - SG_OFFSET_Y
; normal screen pixels - to conserve moves (lower risk of no moves)
if PQ_TOP
	return ( y * SG_SIZE_Y ) + SG_ORIGIN_Y - SG_OFFSET_Y
else 
	return ( ( SG_SQUARES_Y - y + 1 ) * SG_SIZE_Y ) + SG_ORIGIN_Y - SG_OFFSET_Y
}

; Convert a board square x coord to a screen x coord.
xCoordToPixel(x)
{
global SG_SIZE_X
global SG_ORIGIN_X
global SG_OFFSET_X
return ( x * SG_SIZE_X ) + SG_ORIGIN_X - SG_OFFSET_X
}

; Make the mouse move a piece.
movePiece(x1, y1, x2, y2)
{
global SG_DRAG_OK
global SG_ORIGIN_X
global SG_ORIGIN_Y
global SG_LAST_X
global SG_LAST_Y
global PQ_DBG
global PQ_SHOW

SG_LAST_X := x1
SG_LAST_Y := y1

if PQ_DBG
	MsgBox, Moving from %x1% , %y1% to %x2% , %y2%, set last = %SG_LAST_X% , %SG_LAST_Y%

if PQ_SHOW
{
	MouseClick, L, xCoordToPixel(x1), yCoordToPixel(y1)
	Sleep, 300
	MouseMove, xCoordToPixel(x2), yCoordToPixel(y2)
	Sleep, 100
	return
}
getWindow()
if (SG_DRAG_OK == 1)
{
	MouseClickDrag, L, xCoordToPixel(x1), yCoordToPixel(y1), xCoordToPixel(x2), yCoordToPixel(y2), 2
}
else
{
	MouseClick, L, xCoordToPixel(x1), yCoordToPixel(y1)
	Sleep, 100
	MouseClick, L, xCoordToPixel(x2), yCoordToPixel(y2)
	Sleep, 100
}
; Move to home point to avoid hilighting pieces.
MouseMove, SG_ORIGIN_X, SG_ORIGIN_Y
; Wait for pieces to fall.
Sleep, 1000
}

; Check that the piece in an array coord is not out of bounds,
; and is the same color.
isSameAt(col, x, y)
{
	; Generic global to include array.
	global
	if (x < 1 || x > SG_SQUARES_X || y < 1 || y > SG_SQUARES_Y )
	{
		;MsgBox, returning false as OOB ( %x% < 1 || %x% > %SG_SQUARES_X% || %y% < 1 || %y% > %SG_SQUARES_Y% )
		return false
	}
	ax := SG_ARR_%x%_%y%
	if ( SG_ARR_%x%_%y% == col )
	{
		;MsgBox, returning true as %ax% == %col% and none of ( %x% < 1 || %x% > %SG_SQUARES_X% || %y% < 1 || %y% > %SG_SQUARES_Y% )
		return true
	}
	; special case for wild cards matching any mana
	if ((col = r || col = b || col = g || col = y) && (SG_ARR_%x%_%y% = k))
		return true
	;MsgBox, returning false as %ax% != %col% though none of ( %x% < 1 || %x% > %SG_SQUARES_X% || %y% < 1 || %y% > %SG_SQUARES_Y% )
	return false
}

; Searches for and gets moves for a specific color (allows prioritization)
getMoveFor(pcolor)
{
	global
	; return false if no parameter was provided
	; probably need better error checking
	
	if (pcolor=="") return 0
	MsgBox %SG_SQUARES_Y% %SG_SQUARES_X%
Loop, %SG_SQUARES_Y%
{
	y = %A_Index%
	py := xCoordToPixel(y)
	y1 := ( y + 1 )
	y2 := ( y + 2 )
	y3 := ( y + 3 )
	y_1 := ( y - 1 )
	y_2 := ( y - 2 )
	y_3 := ( y - 3 )
	Loop, %SG_SQUARES_X%
	{
		x = %A_Index%
		col := SG_ARR_%x%_%y%
		; skip checks if not same color as desired
		if (pcolor <> col) 
			continue
		if PQ_DBG
		{
			MsgBox Searching for possible moves for %pcolor% "=" %col% at %x%_%y% ;DEBUG
		}
		; Anti-stick: don't play the same piece twice in a row
		; If it's the only playable square, we'll get it next time round.
		if ( SG_LAST_X == x && SG_LAST_Y == y )
		{
			; Zero them so we can get this square next time if it's the only one.
			SG_LAST_X = 0
			SG_LAST_Y = 0
			Continue
		}
		px := xCoordToPixel(x) ;was px
		x1 := ( x + 1 )
		x2 := ( x + 2 )
		x3 := ( x + 3 )
		x_1 := ( x - 1 )
		x_2 := ( x - 2 )
		x_3 := ( x - 3 )

		if PQ_DBG
		{
			;MsgBox, At %x%, %y% comparing %col% , %x2% , %y% And %col%, %x3%, %y%
			;ListVars
			;Pause
		}

		; X_xx
		if ( isSameAt(col, x2, y) && isSameAt(col, x3, y) )
		{
			movePiece( x, y, x1, y)
			return 1
		}
		; xx_X
		else if ( isSameAt(col, x_2, y) && isSameAt(col, x_3, y) )
		{
			movePiece( x, y, x_1, y)
			return 1 
		}
		; X
		; _
		; x
		; x
		else if ( isSameAt(col, x, y2) && isSameAt(col, x, y3) )
		{
			movePiece( x, y, x, y1)
			return 1
		}
		; x
		; x
		; _
		; X
		else if ( isSameAt(col, x, y_2) && isSameAt(col, x, y_3) )
		{
			movePiece( x, y, x, y_1)
			return 1
		}
		; x_
		; x_
		; _X
		else if ( isSameAt(col, x_1, y_1) && isSameAt(col, x_1, y_2) )
		{
			movePiece( x, y, x_1, y)
			return 1
		}
		; _x
		; _x
		; X_
		else if ( isSameAt(col, x1, y_1) && isSameAt(col, x1, y_2) )
		{
			movePiece( x, y, x1, y)
			return 1
		}
		; _X
		; x_
		; x_
		else if ( isSameAt(col, x_1, y1) && isSameAt(col, x_1, y2) )
		{
			movePiece( x, y, x_1, y)
			return 1
		}
		; X_
		; _x
		; _x
		else if ( isSameAt(col, x1, y1) && isSameAt(col, x1, y2) )
		{
			movePiece( x, y, x1, y)
			return 1
		}
		; X__
		; _xx
		else if ( isSameAt(col, x1, y1) && isSameAt(col, x2, y1) )
		{
			movePiece( x, y, x, y1)
			return 1
		}
		; _xx
		; X__
		else if ( isSameAt(col, x1, y_1) && isSameAt(col, x2, y_1) )
		{
			movePiece( x, y, x, y_1)
			return 1
		}
		; __X
		; xx_
		else if ( isSameAt(col, x_1, y1) && isSameAt(col, x_2, y1) )
		{
			movePiece( x, y, x, y1)
			return 1
		}
		; xx_
		; __X
		else if ( isSameAt(col, x_1, y_1) && isSameAt(col, x_2, y_1) )
		{
			movePiece( x, y, x, y_1)
			return 1
		}
		; x_
		; _X
		; x_
		else if ( isSameAt(col, x_1, y_1) && isSameAt(col, x_1, y1) )
		{
			movePiece( x, y, x_1, y)
			return 1
		}
		; _x
		; X_
		; _x
		else if ( isSameAt(col, x1, y_1) && isSameAt(col, x1, y1) )
		{
			movePiece( x, y, x1, y)
			return 1
		}
		; _X_
		; x_x
		else if ( isSameAt(col, x_1, y1) && isSameAt(col, x1, y1) )
		{
			movePiece( x, y, x, y1)
			return 1
		}
		; x_x
		; _X_
		else if ( isSameAt(col, x_1, y_1) && isSameAt(col, x1, y_1) )
		{
			movePiece( x, y, x, y_1)
			return 1
		}
	}
}
if PQ_DBG
	MsgBox, Unable to find a move
return 0
}
; An extremely nasty bruteforcism: tries each possible move in turn.
; If it finds one, it does it.
; Unfortunately, for the SG_ARR stuff, need all globals defined.
getMove()
{
global
Loop, %SG_SQUARES_Y%
{
	y = %A_Index%
	py := xCoordToPixel(y)
	y1 := ( y + 1 )
	y2 := ( y + 2 )
	y3 := ( y + 3 )
	y_1 := ( y - 1 )
	y_2 := ( y - 2 )
	y_3 := ( y - 3 )
	Loop, %SG_SQUARES_X%
	{
	x = %A_Index%
	; Anti-stick: don't play the same piece twice in a row
	; If it's the only playable square, we'll get it next time round.
	if ( SG_LAST_X == x && SG_LAST_Y == y )
	{
		; Zero them so we can get this square next time if it's the only one.
		SG_LAST_X = 0
		SG_LAST_Y = 0
		Continue
	}
	px := xCoordToPixel(x) ;was px
	x1 := ( x + 1 )
	x2 := ( x + 2 )
	x3 := ( x + 3 )
	x_1 := ( x - 1 )
	x_2 := ( x - 2 )
	x_3 := ( x - 3 )
	col := SG_ARR_%x%_%y%

	;MsgBox, At %x%, %y% comparing %col% , %x2% , %y% And %col%, %x3%, %y%

	; X_xx
	if ( isSameAt(col, x2, y) && isSameAt(col, x3, y) )
	{
		movePiece( x, y, x1, y)
		return
	}
	; xx_X
	else if ( isSameAt(col, x_2, y) && isSameAt(col, x_3, y) )
	{
		movePiece( x, y, x_1, y)
		return
	}
	; X
	; _
	; x
	; x
	else if ( isSameAt(col, x, y2) && isSameAt(col, x, y3) )
	{
		movePiece( x, y, x, y1)
		return
	}
	; x
	; x
	; _
	; X
	else if ( isSameAt(col, x, y_2) && isSameAt(col, x, y_3) )
	{
		movePiece( x, y, x, y_1)
		return
	}
	; x_
	; x_
	; _X
	else if ( isSameAt(col, x_1, y_1) && isSameAt(col, x_1, y_2) )
	{
		movePiece( x, y, x_1, y)
		return
	}
	; _x
	; _x
	; X_
	else if ( isSameAt(col, x1, y_1) && isSameAt(col, x1, y_2) )
	{
		movePiece( x, y, x1, y)
		return
	}
	; _X
	; x_
	; x_
	else if ( isSameAt(col, x_1, y1) && isSameAt(col, x_1, y2) )
	{
		movePiece( x, y, x_1, y)
		return
	}
	; X_
	; _x
	; _x
	else if ( isSameAt(col, x1, y1) && isSameAt(col, x1, y2) )
	{
		movePiece( x, y, x1, y)
		return
	}
	; X__
	; _xx
	else if ( isSameAt(col, x1, y1) && isSameAt(col, x2, y1) )
	{
		movePiece( x, y, x, y1)
		return
	}
	; _xx
	; X__
	else if ( isSameAt(col, x1, y_1) && isSameAt(col, x2, y_1) )
	{
		movePiece( x, y, x, y_1)
		return
	}
	; __X
	; xx_
	else if ( isSameAt(col, x_1, y1) && isSameAt(col, x_2, y1) )
	{
		movePiece( x, y, x, y1)
		return
	}
	; xx_
	; __X
	else if ( isSameAt(col, x_1, y_1) && isSameAt(col, x_2, y_1) )
	{
		movePiece( x, y, x, y_1)
		return
	}
	; x_
	; _X
	; x_
	else if ( isSameAt(col, x_1, y_1) && isSameAt(col, x_1, y1) )
	{
		movePiece( x, y, x_1, y)
		return
	}
	; _x
	; X_
	; _x
	else if ( isSameAt(col, x1, y_1) && isSameAt(col, x1, y1) )
	{
		movePiece( x, y, x1, y)
		return
	}
	; _X_
	; x_x
	else if ( isSameAt(col, x_1, y1) && isSameAt(col, x1, y1) )
	{
		movePiece( x, y, x, y1)
		return
	}
	; x_x
	; _X_
	else if ( isSameAt(col, x_1, y_1) && isSameAt(col, x1, y_1) )
	{
		movePiece( x, y, x, y_1)
		return
	}
	}
}
; MsgBox, Unable to find a move
}

;===== LOGIC =====
;Given a specific cell, it checks if there's a 4 of a kind move possible there
checkFor4(col,x,y, horizontal)
{
	if horizontal
	{
		Cx1 := x + 1
		Cx2 := x + 2
		Cx3 := x + 3
		Cx_1 := x - 1 
		Cy1 := y
		Cy2 := y
		Cy3 := y
		Cy_1 := y
		CMode := "UD"
	}
	else
	{ ;vertical checking
		Cx1 := x
		Cx2 := x
		Cx3 := x
		Cx_1 := x
		Cy1 := y + 1
		Cy2 := y + 2
		Cy3 := y + 3
		Cy_1 := y - 1 
		CMode := "LR"
	}
	;Alternating Match X_x
	;Check for 4 in 1s X_xx or xX_x
	if (isSameAt(col, Cx2, Cy2) && (isSameAt(col, Cx3, Cy3) || isSameAt(col, Cx_1, Cy_1)))
	{
		if PQ_DBG
		{
			MsgBox, Possible 4 of a kind - checking now %x%,%y% = %Cx2%,%Cy2%, checking around %col% %Cx1%,%Cy1%, %CMode%
		}
		;if PQ_SHOW
		;	MouseMove, xCoordToPixel(Cx1), yCoordToPixel(Cy1)
		if huntMoves(col,Cx1,Cy1,CMode) ;Up and down OR Left & Right depending on horizontal
		{
			;MsgBox, Found 4 of a kind! ;DEBUG
			return, 1
		}
	}
	return, 0
}

;finds a matching piece in different directions, and moves it if found
; _X__X_
; X?gg?X
; _X__X_
; g = given
; X = values to check
; ? = x,y coordinate around which to check
; Mode = "LRUD" - which directions to check
; L = Left
; R = Right
; U = Up
; D = Down
huntMoves(col,x,y,mode)
{
	if mode =
		return 0
	Cx1 := x + 1
	Cx_1 := x - 1 
	Cy1 := y + 1
	Cy_1 := y - 1 
	
	;MsgBox, %mode% ;DEBUG
	IfInString, mode, L
	{
		if isSameAt(col, Cx_1, y)
		{
			movePiece( x, y, Cx_1, y)
			return, 1
		}
	}
	IfInString, mode, R
	{
		if isSameAt(col, Cx1, y)
		{
			movePiece( x, y, Cx1, y)
			return, 1
		}
	}
	IfInString, mode, D
	{
		;MsgBox UP %x%, %Cy1% ;Currently inverted, does it matter?
		if isSameAt(col, x, Cy1)
		{
			movePiece( x, y, x, Cy1)
			return, 1
		}
	}
	IfInString, mode, U
	{
		;MsgBox DOWN %x%, %Cy_1%
		if isSameAt(col, x, Cy_1)
		{
			movePiece( x, y, x, Cy_1)
			return, 1
		}
	}
	if PQ_DBG
		MsgBox, No moves found
	return 0
}

;Pretty obvious, scans the grid for 4 of a kind moves
checkGridFor4()
{
	global
	Loop, %SG_SQUARES_Y%
	{
		y = %A_Index%
		Loop, %SG_SQUARES_X%
		{
			x = %A_Index%
			col := SG_ARR_%x%_%y%
			if checkFor4(col, x, y, true) ;check horizontally
				return, 1
			if checkFor4(col, x, y, false) ;check vertically
				return, 1
		}
	}
	return 0
}

;===== HELPERS =====
; converts a specific Hexadecimal color value to a letter
; useful when you always get the same value
; as a failsafe if value doesn't exist in this function it calls hex2Color for a more generic logic based calculation (for times when color value varies slightly)
colorLookup(color)
{
	if color = 0x460000
		col = r ;RED(r)
	else if color = 0x0DBD2E
		col = g ;GREEN(g)
	else if color = 0x33979E
		col = b ;BLUE(b)
	else if color = 0x3C3900
		col = y ;YELLOW(y)
	else if color = 0xDB8331
		col = o ;GOLD(o)
	else if color = 0xE800E8
		col = m ;PURPLE (m)(Stars)
	else if color = 0xCCB7A0
		col = w ;WHITE (w)(Skulls)
	else if color = 0x958675
		col = w ;BLACK (w)(Skulls)
	else if color <= 0x010101
		col = k ;MUTLIPLE (Wildcards) 0x010000(x3) 0x000000 (x2)
	else if color = 0xE4B754
		col = s ;SCROLL
	else if color = 0xC5C48E 
		col = a ;ANVIL - Not exhaustive and correct
	else
		col := hex2Color(color)  ;DEFAULT - call other function
	return col
}
; Convert a hex value to a colour letter, from:
; r(ed)c(yan)g(reen)y(ellow)o(range)b(lue)m(agenta)w(hite). a(nvil), s(croll), k(wildcard)
; Per: r rg=o gr=y g gb=c bg=c b rb=m br=m
hex2Color(color)
{
	global PQ_DBG
	r := ( ( color >> 16 ) & 0xFF )
	g := ( ( color >> 8 ) & 0xFF )
	b := ( color & 0xFF )

	if (r > g && r > b )
	{
		col = r ;assume red
		min := ( r * 0.5 )
		if (min <= g && min <= b )
		col=w ;white
		if (min <= g && min > b ) ; dodgy yellow test.
		if (r - g > 10)
			col=o
		else ; numbers too similar, still yellow.
			col=y
		if (min > g && min <= b )
		col=m
	}
	if (g >= r && g >= b )
	{
		col = g
		min := ( g * 0.6 )
		if (min <= r && min <= b )
		col=w
		if (min <= r && min > b )
		col=y
		if (min > r && min <= b )
	;      col=c ; commented since there ARE no cyan pieces in the test game
		col=b
	}
	if (b >= r && b >= g )
	{
		col = b
		min := ( b * 0.6 )
		if (min <= r && min <= g )
		col=w
		if (min <= r && min > g )
		col=m
		if (min > r && min <= g )
	;      col=c ; commented since there ARE no cyan pieces in the test game
		col=b
	}
	;to get extreme colors (i.e. black)
	if (r < 5 && g < 5 && b < 5)
		col=k ;black (wild cards)
	if (r >= 190 && g >= 190 && b >= 130)
		col=a ;Anvil

	if PQ_DBG
		MsgBox, Colour %color%=%col% r:%r% g:%g% b:%b%
	return col
}

; finds the given image and moves cursor there and returns true
findImage(imgName)
{
	getWindow()
	;A_ScreenWidth/Height could be replaced by actual dimensions of the game window
	; useing WinGetPos (as used in AnalyzeResolution)
	ImageSearch, FoundX, FoundY, 260, 190, A_ScreenWidth, A_ScreenHeight, %imgName%
	if !ErrorLevel
	{
		MouseMove, FoundX, FoundY
		sleep 100
		return, true
	}
	return false
}

; click at current position, move cursor away, and wait for the alloted time
clickMoveWait(mdelay)
{
	MouseClick, L
	MouseMove, -100, -100, 2, R
	Sleep %mdelay%
}

;===== STATUS/Mode Checks =====
; click on Train Mounts (must be on Citadel screen)
trainMount()
{
	; find and click on Train Mounts
	; find and click on OK
	; find and click on Yes
	; Game will start now
	
	if findImage("TrainMounts.bmp")
	{
		MouseClick, L
		;clickMoveWait(500)
		if findImage("Okay.bmp")
		{
			clickMoveWait(500)
			if findImage("Yes.bmp")
			{
				clickMoveWait(500)
				return, true
			}
		}
	}
	return false
}

; check & click on Try Again if possible
retryAgain()
{
	if findImage("TryAgain.bmp")
	{
		;MsgBox The image was found at %FoundX%x%FoundY%
		clickMoveWait(500)
		if findImage("DoneSmall.bmp")
			clickMoveWait(0)
		Sleep 500
		return, true
	}
	return false
}

; Search if combat is over
gameOver()
{
	;replace with a helper function? (as it is all very redundant!) - see findImage()
	
	if findImage("Victory.bmp")
		return, 1
	if findImage("DoneOnly.bmp")
		return, 2
	if findImage("Defeat.bmp")
		return, 3
	return 0
}

;Return true if indicator is over our head
myTurn()
{
	global PQ_DBG
	PixelGetColor, turn_color, 101, 107, RGB
	turn_c := hex2Color(turn_color)
	if PQ_DBG
		MsgBox %turn_color% %turn_c%
	if (turn_c == "o") ;orange = my turn, white = not my turn
		return true
	;sleep 100
	return false
}

; To reduce illegal moves
waitForMyTurn()
{
	Loop
	{
		sleep 100
		if ((a_index > 200) || (myTurn()))
			break  ; Terminate the loop
		;Won't wait longer than 20 seconds (AI doesn't take longer than a few seconds at most)
	}
	sleep 100 ;extra pause to avoid illegal moves in Train Mount Mode
}

;===== SUPPORT =====
;Displays a 2 dimensional grid according to data in array arr
showGrid(arr, length)
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
	clipboard = %header% ;DEBUG
	;Create List to display
	Gui, Add, ListView, +Grid h180 w220, %header%
	;1 | 2 | 3 | 4 | 5 | 6 | 7 | 8
	;msgbox %arr%, %length% ;DEBUG
	sLines = 
	sLine =
	Loop, %length%
	{
		y := A_index
		;sLines = %sLines% %sLine% `n# %A_Index% : ;DEBUG
		sLines = %sLines% %sLine% `n ;DEBUG
		sLine = 
		Loop, %length%
		{
			x := A_index
			tval := %arr%_%x%_%y% ","
			sLine = %sLine% %tval%
		}
		StringTrimRight, sLine, sLine, 1 ;Remove last char
		;sLine = "", %sLine% ; format string for 
		;msgbox %sLine%; DEBUG
		
		;LV_Add("",%sLine%)
		LV_Add("",%arr%_1_%y%,%arr%_2_%y%,%arr%_3_%y%,%arr%_4_%y%,%arr%_5_%y%,%arr%_6_%y%,%arr%_7_%y%,%arr%_8_%y%)
	}
		sLines = %sLines% %sLine% ;add final line from loop
		;LV_ModifyCol()  ; Auto-size each column to fit its contents.
		;MsgBox, %sLines% ;DEBUG
		clipboard = %sLines% ;DEBUG
		Gui, Show, 
		sleep 3000
		return
}

;toggles the value of a global variable
toggleVar(varName)
{
global
	%varName% := !%varName%
;  if ( %varName% == 1)
;    %varName%=0
;  else
;    %varName%=1
	if PQ_DBG 
		MsgBox,% varName . "=" . %varName% ;Debug
}

;force the value of a global variable
forceVar(varName,varValue)
{
	global
	%varName% := varValue
	if PQ_DBG
		MsgBox,% varName . "=" . %varName% ;Debug
}


;===== GUI =====
; Shows buttons to select mode to play
LaunchGUI()
{
	global PQ_PAUSE
	global PQ_SHOW
	Gui, Add, Button, w110 h20 gbutton1, &1. Battle
	Gui, Add, Button, w110 h20 gbutton2, &2. Train Mount
	Gui, Add, Button, w110 h20 gbutton3, &3. Research Spell
	Gui, Add, Button, w110 h20 gbutton4, &4. Forge Item
	Gui, Add, Text, w110, Delay in milliseconds `n before scanning grid
	Gui, Add, Edit, w110 h20 vPQ_PAUSE Limit4 Number, %PQ_PAUSE%
	Gui, Add, Checkbox, vPQ_SHOW Checked%PQ_SHOW%, Only show moves
	Gui, Add, Button, w64 h20, &About
	Gui, Add, Button, w64 h20, E&xit

	;ToggleAI(forced on/off) - Set Pause == 0, No wait for my turn
	;SetPriority(GemType, Priority#) - sets priority order 1 = highest
	;ToggleStartRow(On/Off) - start at top of board / bottom of board

	;Gui, Show, x257 y110 h130 w125, Minesweeper auto-solver
	Gui, +LastFound +AlwaysOnTop +Border -Disabled -SysMenu +Owner +ToolWindow  ; +ToolWindow avoids a taskbar button and an alt-tab menu item.
	CustomColor = EEAA99  ; Can be any RGB color (it will be made transparent below).
	Gui, Color, %CustomColor%
	; Make all pixels of this color transparent
	;WinSet, TransColor, %CustomColor%
	Gui, Show, x40 y90, PQSolver
	return
}

;==== To Handle GUI events and different modes of the game =====
^!1::
button1:
; Battle
;regular, AI, waitforturn
;higher delay to allow user interaction
	PQ_MODE = 1
	PQ_TOP = 0
	PQ_AI = 1
	PQ_PAUSE = 2000
	Gosub, buttonExit
	Gosub, startPlaying
return
^!2::
button2:
; Train Mount
;timed, AI, waitforturn (same as regular i guess, but there is a time factor now, detect time?)
	PQ_MODE = 2
	PQ_TOP = 0
	PQ_AI = 1
	PQ_PAUSE = 800
	Gosub, buttonExit
	Gosub, startPlaying
return
^!3::
button3:
	; Research Spell
	;single, NO AI, Scrolls, No Moves Condition!
	PQ_MODE = 3
	PQ_TOP = 1
	PQ_AI = 0
	PQ_PAUSE = 0
	Gosub, buttonExit
	Gosub, startPlaying
return
^!4::
button4:
; Forge Item
;single, NO AI, Anvil, No Moves Condition!
	PQ_MODE = 4
	PQ_TOP = 1
	PQ_AI = 0
	PQ_PAUSE = 0
	Gosub, buttonExit
	Gosub, startPlaying
return
buttonAbout:
	MsgBox, , About, Puzzle Quest Auto Solver/Bot/Helper by Vixay Xavier (will autoclose in 5 seconds), 5
	Gosub, buttonExit
return
buttonExit:
	;submit to bind control values to their variables 
	Gui, Submit, NoHide
	Gui, Destroy
	;exitapp
return