;************************************************
; Test script for Gdip_ImageSearch()
; by MasterFocus
; 02/April/2013 00:30h BRT
;************************************************

#NoEnv
;ListLines, Off
SetBatchLines, -1
Process, Priority,, High

#Include Lib/GDIP.ahk
#Include Lib/Gdip_ImageSearch.ahk

OnExit, EXIT_LABEL

gdipToken := Gdip_Startup()

;;SLEEP, 2000
;;bmpHaystack := Gdip_BitmapFromScreen()

bmpHaystack := Gdip_CreateBitmapFromFile("IMG/Clipboard03.png")
bmpNeedle := Gdip_CreateBitmapFromFile("IMG/g.png")
;  Gdip_ImageSearch(pBitmapHaystack,pBitmapNeedle,ByRef OutputList=""
;  ,OuterX1=0,OuterY1=0,OuterX2=0,OuterY2=0,Variation=0,Trans=""
;  ,SearchDirection=1,Instances=1,LineDelim="`n",CoordDelim=",") {

RET := Gdip_ImageSearch(bmpHaystack,bmpNeedle,LIST,0,0,0,0,65,0xFFFFFF,1,0)
Gdip_DisposeImage(bmpHaystack)
Gdip_DisposeImage(bmpNeedle)
Gdip_Shutdown(gdipToken)
MsgBox, % "Returned: " RET "`n`n" LIST

;; following loop used for pointing to each instance of
;; the needle when the haystack is the screen
/*
CoordMode, Mouse, Screen
Loop, Parse, LIST, `n
{
    StringSplit, Coord, A_LoopField, `,
    MouseMove, %Coord1%, %Coord2%, 0
    Sleep, 200
}
*/

EXIT_LABEL: ; be really sure the script will shutdown GDIP
Gdip_Shutdown(gdipToken)
EXITAPP