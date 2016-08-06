; ==UserScript==
;region ;AutoExec; #####################################################################
#SingleInstance force
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
;INIT Includes
#Include Lib/GDIP_All.ahk
#Include Lib/GDIpHelper.ahk
#Include Lib/regionGetColor.ahk 	;Import color functions
#Include Lib/GetColor.ahk 			;own color functions
#Include Lib/ini.ahk 			    ;save load ini functions
#Include Lib/gui.ahk 				;own gui functions
#Include Lib/grid.ahk 				;provides model functions
#Include Lib/printscreen.ahk 		;output to screen functions

init := false
Process, Priority,, High
SetBatchLines, -1
SetTitleMatchMode 2

;start GUI
getMoves()

;OnExit, ExitSub
;#######################################################################################
;autoexec end
return
;end_region
;#######################################################################################

;region ;Labels and Hotkeys; ###########################################################
^F1::getMoves() ;global start hook

#If WinActive(WINDOW_NAME)
	F1::getMoves()
	F2::searchArea()
	F3::readState()
	F4::test()
	F5::Reload
	F6::
		initSettings()
		temp_color := getColor(5,7)
		clipboard := temp_color
		msgbox % "Col " temp_color
		return
	F7::initSettings(true)

#If WinActive("Visual Studio Code")
	F5::Reload

ExitSub:
	;savesettings()
	ExitApp

;end_region

;region ;Functions; ####################################################################
initSettings(debg:=0) {
global
	SetUpGDIP(2 * A_ScreenWidth)
	if (!init || debg) {
		init := true
		LoadedConfig := lastCfg()
		CharChoice := lastChar()
		temploaded := LoadedConfig
		LoadConfig(LoadedConfig)
		if (StrLen(temploaded)) {
			LoadedConfig := temploaded
			LoadConfig(LoadedConfig)
		}
		if (!StrLen(CharChoice))
			CharChoice:="gideon"
		changeChar()
		IfWinExist,  %WINDOW_NAME% {
			WinActivate, %WINDOW_NAME%
			WinWaitActive, %WINDOW_NAME%
		}
		;  if (A_UserName = "jan") {
		;  	WinGetPos, wX, wY, w, h, A
		;  	WinGetTitle, Title, A
		;  	if (InStr(Title,"IrfanView")) {
		;  		if (RegExMatch(Title, "Zoom: (\d+) x (\d+)" , match)) {
		;  			if (InStr(Title,"Screenshot")) {
		;  				LoadedConfig:="WorkScreenshot"
		;  			}else {
		;  				LoadedConfig:="WorkIrfan"
		;  			}
		;  			LoadConfig(LoadedConfig)
		;  		}
		;  	} else {
		;  		LoadedConfig:="WorkNox"
		;  		LoadConfig(LoadedConfig)
		;  		WinGetTitle, Title, A
		;  		if (InStr(Title,"Nox")) {
		;  			wid := WinExist("A")
		;  			WINDOW_NAME := "AHK_ID " wid
		;  		}
		;  	}
		;  } else { ;home
		;  	WinGetTitle, Title, A
		;  	if (InStr(Title,"Nox")) {
		;  		LoadedConfig:="HomeNox"
		;  		LoadConfig(LoadedConfig)
		;  		wid := WinExist("A")
		;  		WINDOW_NAME := "AHK_ID " wid
		;  	} else {
		;  		LoadedConfig:="HomeIrfan"
		;  		LoadConfig(LoadedConfig)
		;  	}
		;  }
		chars:=readChars()
		WinGetPos, wX, wY, w, h, %WINDOW_NAME%
		if (debg) {
			getCoords(1,1,x,y,x2,y2,w,h)
			txt := ""
			vars:= ["LoadedConfig","ORIGIN_X","ORIGIN_Y","SIZE_X","SIZE_Y","OFFSET_X","OFFSET_Y","PADDING","WINDOW_NAME","wX","wY","w","h"]
			for i,var in vars {
				pad:= ("             " var)
				StringRight, pad, pad, 12
				txt .= pad " : " %var% "`n"
			}
			dialog(txt,"Consolas")
			drawRect(0xC0FF0000, x, y, w, h)
			msgbox start %x%x%y%
			getCoords(7,7,x,y,x2,y2,w,h)
			drawRect(0xC0FF0000, x, y, w, h)
			msgbox end %x%x%y%
			clear()
		}
	} ;init end
}

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


ExitApp