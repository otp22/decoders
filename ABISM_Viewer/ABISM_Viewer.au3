#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=otp22.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Description=ABISM Viewer
#AutoIt3Wrapper_Res_Fileversion=1.0.0.4
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Crashdemons
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
 #include <WinAPI.au3>
Global $Tool="None"
Global $LineOn=False
Global $Transparency=256
Global $LastActive=1
Global $LastTool=""


Local $w=1280
Local $h=768
Local $yx=35
Local $wx=$w
Local $hx=$h-($yx+24+24+2)


Opt("GUIOnEventMode", 1)
#Region ### START Koda GUI section ### Form=C:\Users\Crash\Desktop\abism.kxf
$Form2=GUICreate("Form2",$wx,$hx,0,0 ,$WS_POPUP,$WS_EX_TOOLWINDOW)
GUICtrlCreateLabel('',0,0, $wx,$hx)
GUICtrlSetOnEvent(-1, "ClickEventL")
GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, "ClickEventR")
GUISetState()
WinSetTrans($Form2,'',15)


$Form1 = GUICreate("ABISM Viewer", $w, $h, 407, 161,-1,$WS_EX_LAYERED)
GUISetOnEvent($GUI_EVENT_CLOSE,'Close')
GUISetOnEvent($GUI_EVENT_PRIMARYUP,'Move')
$Button1 = 0xDEAD;GUICtrlCreateButton("---------", 746, 1, 32, 32, $WS_GROUP)
;GUICtrlSetOnEvent(-1, "ClickLineTool")
$Button3 = GUICtrlCreateButton("Bit", $w-35, 1, 32, 32, $WS_GROUP)
GUICtrlSetOnEvent(-1, "ClickBitTool")
$Input1 = GUICtrlCreateInput("", 2, $yx+$hx+1, $w, 24)
GUICtrlSetOnEvent(-1, "UpdateBits")
$Input2 = GUICtrlCreateInput("", 2, $yx+$hx+1+24, $w, 24)
$Graphic1 = 0;GUICtrlCreateGraphic(5, 35, 771, 487)
$Button2 = GUICtrlCreateButton("Nxt", $w-35*2, 1, 32, 32, $WS_GROUP)
GUICtrlSetOnEvent(-1, "ClickNext")
$Button4 = GUICtrlCreateButton("Cls", $w-35*3, 1, 32, 32, $WS_GROUP)
GUICtrlSetOnEvent(-1, "ClickClear")
;$ButtonE = GUICtrlCreateButton("==",2+(776-32),525,32,32,$WS_GROUP)
;GUICtrlSetOnEvent(-1, "ClickTranslate")
GUISetState(@SW_SHOW)
;Sleep(3000)

#EndRegion ### END Koda GUI section ###

_WinAPI_SetLayeredWindowAttributes ($Form1,0xABABAB)
ClickClear()
Move()
ClickBitTool()


While 1
	Local $NewActive=WinActive($Form1) Or WinActive($Form2)
	If $LastActive=0 And $NewActive Then; re-activated from another window
		WinActivate($Form2)
		WinActivate($Form1)
	EndIf
	$LastActive=$NewActive

	If $Tool<>$LastTool Then
		GUICtrlSetBkColor($Button1,0xFF0000)
		GUICtrlSetBkColor($Button2,0xFF0000)
		GUICtrlSetBkColor($Button3,0xFF0000)
		GUICtrlSetBkColor($Button4,0xFF0000)
		Switch $Tool
			Case 'bit'
				GUICtrlSetBkColor($Button3,0x00DF00)
			Case 'line'
				GUICtrlSetBkColor($Button1,0x00DF00)
		EndSwitch
		$LastTool=$Tool
	EndIf


	Sleep(300)
WEnd


Func UpdateBits()
	Local $bin=GUICtrlRead($Input1)
	Local $arr=StringSplit($bin,' ',2)
	Local $str=''
	For $byte In $arr
		If StringLen($byte) Then
			Local $asc=_BinaryToDec($byte)
			If BitAnd($asc,32) Then $asc-=64
			;If $asc>64 Then $asc-=64
			$str&=Chr($asc)
		EndIf
		 ;$str &= Chr(_BinaryToDec($byte))
	Next
	;$str&= " -- RAW: "&$bin
	GUICtrlSetData($Input2,$str)
EndFunc

Func ClickTranslate()
	Local $bin=GUICtrlRead($Input1)
	Local $arr=StringSplit($bin,' ',2)
	Local $str=''
	For $byte In $arr
		If StringLen($byte) Then $str &= Chr(_BinaryToDec($byte))
	Next
	$str&= " -- RAW: "&$bin
	GUICtrlSetData($Input1,$str)

EndFunc
Func Close()
	Exit
EndFunc
Func Move()
	;MsgBox(0,0,'move')
	Local $wgp=WinGetPos(GUICtrlGetHandle($Graphic1))
	If Not IsArray($wgp) Then Return

	WinMove($Form2,'',$wgp[0],$wgp[1])
EndFunc



Func ClickBitTool()
	$Tool="bit"
EndFunc
Func ClickLineTool()
	$Tool="line"
	$LineOn=False
EndFunc

Func ClickClear()
	;$Tool="none"
	GUICtrlDelete($Graphic1)
	$Graphic1 = GUICtrlCreateGraphic(0, $yx, $wx, $hx)
	GUICtrlSetBkColor($Graphic1,0xABABAB)
	GUICtrlSetColor($Graphic1,0xFF0000)
	GUICtrlSetGraphic($Graphic1,$GUI_GR_REFRESH)
	;GUICtrlSetOnEvent(-1, "ClickEventL")
	GUICtrlSetData($Input1,GUICtrlRead($Input1)&" ")
EndFunc
Func ClickNext()
	GUICtrlSetData($Input1,GUICtrlRead($Input1)&" ")
EndFunc

Func ClickEventL()
	ClickEvent(1)
EndFunc
Func ClickEventR()
	ClickEvent(0)
EndFunc
Func ClickEvent($k='N/A')
	Local $tPoint=_WinAPI_GetMousePos(True, GUICtrlGetHandle($Graphic1))
	Local $x=DllStructGetData($tPoint,'X')
	Local $y=DllStructGetData($tPoint,'Y')
	Switch $Tool
		Case 'bit'
			Local $color=0xFF0000
			If $k Then $color=0x00FF00
			;MsgBox(0,$x,$y)
			;GUICtrlSetGraphic($Graphic1, $GUI_GR_MOVE,100,100)
			;GUICtrlSetColor($Graphic1,0)
			GUICtrlSetGraphic($Graphic1,$GUI_GR_COLOR,0x000000)
			GUICtrlSetGraphic($Graphic1,$GUI_GR_RECT,$x-3,$y-3,6,6)
			GUICtrlSetGraphic($Graphic1,$GUI_GR_COLOR,$color)
			GUICtrlSetGraphic($Graphic1,$GUI_GR_RECT,$x-2,$y-2,4,4)
			GUICtrlSetGraphic($Graphic1,$GUI_GR_COLOR,0x000000)
			GUICtrlSetGraphic($Graphic1,$GUI_GR_RECT,$x-1,$y-1,2,2)




			;GUICtrlSetGraphic($Graphic1,$GUI_GR_DOT,$x,$y)
			GUICtrlSetGraphic($Graphic1,$GUI_GR_REFRESH)
			GUICtrlSetData($Input1,GUICtrlRead($Input1)&$k)
			Local $arr=StringSplit(GUICtrlRead($Input1),' ')
			If IsArray($arr) Then
				If StringLen($arr[UBound($arr)-1])=7 Then GUICtrlSetData($Input1,GUICtrlRead($Input1)&' ')
			EndIf
			UpdateBits()
		Case 'line'
			If $LineOn Then
			Else
			EndIf
			$LineOn=(Not $LineOn)
	EndSwitch
EndFunc

Func ClickTransparency()
	$Transparency=Mod($Transparency+64,256)
	Local $tmpTrans=$Transparency
	If $tmpTrans<32 Then $tmpTrans=32
	WinSetTrans($Form1,'',$tmpTrans)
EndFunc


; --------------------- Functions -----------------------------
; Binary to Decimal
Func _BinaryToDec($strBin)
Local $Return
Local $lngResult
Local $intIndex

If StringRegExp($strBin,'[0-1]') then
$lngResult = 0
For $intIndex = StringLen($strBin) to 1 step -1
$strDigit = StringMid($strBin, $intIndex, 1)
Select
case $strDigit="0"
; do nothing
case $strDigit="1"
$lngResult = $lngResult + (2 ^ (StringLen($strBin)-$intIndex))
case else
; invalid binary digit, so the whole thing is invalid
$lngResult = 0
$intIndex = 0 ; stop the loop
EndSelect
Next

$Return = $lngResult
    Return $Return
Else
    ;MsgBox(0,"Error","Wrong input, try again ...")
    Return 0
EndIf
EndFunc
