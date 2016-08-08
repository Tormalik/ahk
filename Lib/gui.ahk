;region ;GUIs;########################################################################### 
;Displays a 2 dimensional grid according to data in array arr

CreateGrid() {
global grid_hwnd
global WINDOW_NAME
global MyGrid
global CharChoice
global LoadedConfig
global MyEdit
global Next
global Col_w
global Col_g
global Col_r
global Col_b
global Col_u 

;Grid
    Gui, grid:Destroy
    Gui, grid:Add, Text,, Grid
    header := "0 | 1 | 2 | 3 | 4 | 5 | 6 | 7`r`n"
	StringTrimLeft, header, header, 1
    ;Remove first char
	Gui, grid: +LastFound
	Gui, grid:Add, ListView, +Grid h160 w210 vMyGrid, %header%
    Gui, grid:Default
    grid_hwnd := WinExist()

;charselect
    Gui, Add, Text,, Char
    Gui, grid:Add, DropDownList, vCharChoice gChangeChar w100 Sort,

;configselect
    GuiControlGet, p, Pos, CharChoice
    txtx := px + pw + 10
    txty := py - 19 
    Gui, Add, Text,x%txtx% y%txty%, Config
    Gui, grid:Add, DropDownList, vLoadedConfig gChangeCfg w100 ,x%txtx% y%py% Sort,

;colorvalues
    Gui, grid:Add, Text,x10, w
    Gui, grid:Add, Edit, w38 ReadOnly
    Gui, Add, UpDown, vCol_w gSaveColors Range-10-20, 1
    GuiControlGet, p, Pos, Col_w
    txtx := px + pw + 5
    txty := py - 19 
    Gui, Add, Text,x%txtx% y%txty%, g
    Gui, grid:Add, Edit, w38 x%txtx% y%py% ReadOnly
    Gui, Add, UpDown, vCol_g gSaveColors Range-10-20, 1

    txtx += 43
    Gui, Add, Text,x%txtx% y%txty%, r
    Gui, grid:Add, Edit, w38 x%txtx% y%py% ReadOnly
    Gui, Add, UpDown, vCol_r gSaveColors Range-10-20, 1

    txtx += 43
    Gui, Add, Text,x%txtx% y%txty%, b
    Gui, grid:Add, Edit, w38 x%txtx% y%py% ReadOnly
    Gui, Add, UpDown, vCol_b gSaveColors Range-10-20, 1

    txtx += 43
    Gui, Add, Text,x%txtx% y%txty%, u
    Gui, grid:Add, Edit, w38 x%txtx% y%py% ReadOnly
    Gui, Add, UpDown, vCol_u gSaveColors Range-10-20, 1

    ;  txtx += 35
    ;  Gui, grid:Add, Button, w40 x%txtx% y%py% gSaveColors, Save

;Statusbar
    Gui, grid:Add, StatusBar, , %t%

;moves
    Gui, grid:Add, Text, x10 , Moves ;x230 y238     
    Gui, grid:Font,s10, Consolas
	Gui, grid:Add, Edit, vMyEdit w210 h200 ;R20 x230 y25 h207
    Gui, grid:Font,s9, Segoe UI

;Next
    Gui, grid:Add, Button, Default w100 vNext gGridUpdate, Update

;Closebtn
    GuiControlGet, p, Pos, Next
    txtx := px + pw + 10
    Gui, grid:Add, Button, w100 x%txtx% y%py% gGridClose, Close

;show
    para:=""
    IfWinExist,  %WINDOW_NAME%
    {
        WinGetPos, wX, wY, w, h, %WINDOW_NAME%
        x := wX+w
        para=x%x% y%wY%
    }
    ;msgbox  'x%x%' 'y%wY%' %WINDOW_NAME%
	Gui, grid:Show, %para%, MtG:PQ Helper

    return
}


UpdateGrid(arr, t, modal:=0) {
global WINDOW_NAME
global CharChoice
global chars
global LoadedConfig
global grid_hwnd

;global clipboard
	;Gui, grid:Destroy
	if !WinExist("ahk_id " grid_hwnd){
        CreateGrid()
    }

    WinGetPos, wX, wY, w, h, %WINDOW_NAME%
	x := wX+w
	;Gui, grid:Show, x%x% y%wY%, Grid
    WinMove,ahk_id %grid_hwnd%,, x, wY 

;Update Grid
    GuiControl, grid:-Redraw,MyGrid   ;-- Redraw off
    LV_Delete() 
	Loop, 7
	{
		y := A_index
		LV_Add(y,y,arr[1, y],arr[2, y],arr[3, y],arr[4, y],arr[5, y],arr[6, y],arr[7, y])
	}
	;LV_ModifyCol()  ; Auto-size each column to fit its contents.
    GuiControl, grid:+Redraw,MyGrid   ;-- Redraw on
    
;Update charselect
    charchoices := ""
    Charchoice:=(StrLen(CharChoice) ? CharChoice : "gideon") ; Default
    for char in chars {
        StringUpper, txt, char, T
		charchoices .= (charchoices="" ? "": "|"  ) txt  (CharChoice=char ? "|": "" )
	}
    StringRight, pipe, charchoices, 1
    If (pipe="|")
        charchoices .= "|"
    GuiControl, grid:,CharChoice,|%charchoices%
	
;Update configselect
    cfgchoices:=""
    cfgs:=AvailableConfigs()
    for i,cfg in cfgs {
	    cfgchoices .= (cfgchoices="" ? "": "|"  ) cfg  (cfg=LoadedConfig ? "|": "" )
	}
    StringRight, pipe, cfgchoices, 1
    If (pipe="|")
        cfgchoices .= "|"
    GuiControl, grid:,LoadedConfig,|%cfgchoices%

;Update colors
    UpdateColors()

;Update Statusbar    
 	SB_SetText(t)

;Clear Moves
    GuiControl, grid:,MyEdit,

;modal
    WinActivate, AHK_ID %grid_hwnd%
    WinActivate, WINDOW_NAME
    if (modal>0) {
		WinWait, AHK_ID %grid_hwnd%
		WinWaitClose, AHK_ID %grid_hwnd%
	}
	
    return
}

UpdateColors(){
global Col_w
global Col_g
global Col_r
global Col_b
global Col_u 
    GuiControl, grid:,Col_w,%Col_w%
    GuiControl, grid:,Col_g,%Col_g%
    GuiControl, grid:,Col_r,%Col_r%
    GuiControl, grid:,Col_b,%Col_b%
    GuiControl, grid:,Col_u,%Col_u%
}

showMoves(moves) {
global WINDOW_NAME
  	result := ""
	For key, value in moves {
		result .= key ":`t" toStr(value) "`n"
	}
    GuiControl, grid:,MyEdit, %result%
	WinActivate, %WINDOW_NAME%
}


changeChar() {
global CharChoice
global chars
global Col_w
global Col_g
global Col_r
global Col_b
global Col_u
    ;  if (!chars) {
    ;      chars:=readChars()
    ;  }
    cs:=LoadChar(CharChoice)
    for col,val in cs {
        Col_%col%:=val
    }
    UpdateColors()
    ;test()
    return
}

test() {
global Col_w
global Col_g
global Col_r
global Col_b
global Col_u 
    result := ""
    colors:=["w", "g", "r", "b", "u"]
	For i, col in colors {
		result .= col ":`t" Col_%col% "`n"
    ;    msgbox % "hahar " key ":" value 
	}
    dialog(result,"Consolas",1)

    return
}



dialog(message,font:="",modal:=1,config:="w230") {
    Gui, Dialog:New
	Gui, Dialog:+AlwaysOnTop +ToolWindow +LastFound
    if (StrLen(font)){
        Gui,Font,s10, %font%
    }
	Gui, Dialog:Add, Text,, %message%
    Gui,Font,s9, Segoe UI
	Gui, Dialog:Add, Button, Default w100 x120 gCloseModal, OK
    modal_hwnd := WinExist()
    Gui, Dialog:Show, %config%
    if (modal>0) {
        WinWait, AHK_ID %modal_hwnd%
        WinWaitClose, AHK_ID %modal_hwnd%
    }
    return
}

;end_region

;region ;helpers; ################################################################################
timediff(st) {
   transform,S,MOD,st,60
   stringlen,L1,S
   if L1 =1
   S=0%S%
   if S=0
   S=00

   M1 :=(st/60)
   transform,M2,MOD,M1,60
   transform,M3,Floor,M2
   stringlen,L2,M3
   if L2 =1
   M3=0%M3%
   if M3=0
   M3=00

   H1 :=(M1/60)
   transform,H2,Floor,H1
   stringlen,L2,H2
   if L2=1
   H2=0%H2%
   if H2=0
   H2=00
   result= %H2%:%M3%:%S%

   return result
}

;region ;labels; ################################################################################
goto endlabel

GridClose:
	Gui, grid:Destroy
	return

GridUpdate:
    getMoves()
    return

SaveColors:    
    Gui, grid:Submit, NoHide
    SaveColors()
    return

CloseModal:
	Gui, Dialog:Destroy
	return

ChangeChar:
    SaveColors() ;save old values
    Gui, grid:Submit, NoHide
    StringLower, CharChoice, CharChoice
    changeChar()
    return

changeCfg:
    Gui, grid:Submit, NoHide
    ;msgbox % LoadedConfig
    setLastCfg()
    LoadConfig(LoadedConfig)
    return

endlabel:
    a=1


;end_region