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
#Include Lib/Grid.ahk 				;provides model functions
#Include Lib/printscreen.ahk 		;output to screen functions
#Include Lib/Extensions.ahk 		;output to screen functions

calibrate_step:=0
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

#If WinActive(WINDOW_NAME) or WinActive("AHK_ID " grid_hwnd)
	~LButton::Clear()
	~RButton::getMoves()
	F1::getMoves()
	F2::searchArea()
	F3::readState()
	F4::test()
	F5::Reload
	F6::
		initSettings()
		temp_color := getColor(6,5)
		clipboard := temp_color
		msgbox % "Col " temp_color
		return
	F7::initSettings(1)
	F8::calibrate()

#If WinActive(WINDOW_NAME) and (calibrate_step>0)
	LButton::calibrate()

#If WinActive("Visual Studio Code")
	F5::Reload

#IfWinActive

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
		IfWinExist,  %WINDOW_NAME%
		{
			WinActivate, %WINDOW_NAME%
		  	WinWaitActive, %WINDOW_NAME%
		}
		;  if (A_UserName = "jan") {
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

ExitApp