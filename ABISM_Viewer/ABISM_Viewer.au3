#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=otp22.ico
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Description=ABISM Viewer
#AutoIt3Wrapper_Res_Fileversion=2.0.0.6
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Crashdemons
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include "ABVConfig.au3"
#include "ABVDecode.au3"
$ABVCFG_UPDATEEVENT="ConfigUpdated"
Global $Tool = "None"
Global $Lines=0
Global $LinesList=""
Global $Transparency = 256
Global $LastActive = 1
Global $LastTool = ""


Local $w = $CFG_WIDTH;1280
Local $h = $CFG_HEIGHT;768
Local $yx = 35
Local $wx = $w
Local $hx = $h - ($yx + 24 + 24 + 2)


Opt("GUIOnEventMode", 1)
#Region ### START Koda GUI section ### Form=C:\Users\Crash\Desktop\abism.kxf
$Form2 = GUICreate("ABVClickWnd", $wx, $hx, 0, 0, $WS_POPUP, $WS_EX_TOOLWINDOW)
GUICtrlCreateLabel('', 0, 0, $wx, $hx)
GUICtrlSetOnEvent(-1, "ClickEventL")
GUISetOnEvent($GUI_EVENT_SECONDARYDOWN, "ClickEventR")
GUISetState()
WinSetTrans($Form2, '', 15)

$strVer=FileGetVersion(@ScriptFullPath)
If Not @Compiled Then $strVer='[Debug]'

$Form1 = GUICreate("ABISM Viewer "&$strVer, $w, $h, 407, 161, -1, $WS_EX_LAYERED)
GUISetOnEvent($GUI_EVENT_CLOSE, 'Close')
GUISetOnEvent($GUI_EVENT_PRIMARYUP, 'Move')
$Button1 = GUICtrlCreateButton("---------", $w - 35*2, 1, 32, 32, $WS_GROUP)
GUICtrlSetOnEvent(-1, "ClickLineTool")
$ButtonCfg=GUICtrlCreateButton("Cfg",0,0,32,32)
GUICtrlSetOnEvent(-1, "frmConfigShow")
$Button3 = GUICtrlCreateButton("Bit", $w - 35, 1, 32, 32, $WS_GROUP)
GUICtrlSetOnEvent(-1, "ClickBitTool")
$Input1 = GUICtrlCreateInput("", 2, $yx + $hx + 1, $w, 24)
GUICtrlSetOnEvent(-1, "UpdateBits")
$Input2 = GUICtrlCreateInput("", 2, $yx + $hx + 1 + 24, $w, 24)
$Graphic1 = 0;GUICtrlCreateGraphic(5, 35, 771, 487)
$Button2 = GUICtrlCreateButton("Nxt", $w - 35 * 3, 1, 32, 32, $WS_GROUP)
GUICtrlSetOnEvent(-1, "ClickNext")
$Button4 = GUICtrlCreateButton("Cls", $w - 35 * 4, 1, 32, 32, $WS_GROUP)
GUICtrlSetOnEvent(-1, "ClickClear")
;$ButtonE = GUICtrlCreateButton("==",2+(776-32),525,32,32,$WS_GROUP)
;GUICtrlSetOnEvent(-1, "ClickTranslate")
GUISetState(@SW_SHOW)
;Sleep(3000)

#EndRegion ### END Koda GUI section ###
$ABVCFG_PARENTA=$Form1
$ABVCFG_PARENTB=$Form2
_WinAPI_SetLayeredWindowAttributes($Form1, 0xABABAB)
ClickClear()
Move()
ClickBitTool()


While 1
	Local $NewActive = WinActive($Form1) Or WinActive($Form2)
	If $LastActive = 0 And $NewActive Then; re-activated from another window
		WinActivate($Form2)
		WinActivate($Form1)
	EndIf
	$LastActive = $NewActive

	If $Tool <> $LastTool Then
		GUICtrlSetBkColor($Button1, 0xFF0000)
		;GUICtrlSetBkColor($Button2, 0xFF0000)
		GUICtrlSetBkColor($Button3, 0xFF0000)
		;GUICtrlSetBkColor($Button4, 0xFF0000)
		Switch $Tool
			Case 'bit'
				GUICtrlSetBkColor($Button3, 0x00DF00)
			Case 'line'
				GUICtrlSetBkColor($Button1, 0x00DF00)
		EndSwitch
		$LastTool = $Tool
	EndIf


	Sleep(300)
WEnd

Func ConfigUpdated()
	WinActivate($Form2)
	WinActivate($Form1)
	GUISwitch($Form1)
	ClickClear()
	UpdateBits()
EndFunc

Func UpdateBits()
	Local $bin = GUICtrlRead($Input1)
	Local $str=BitsToString($bin)

	GUICtrlSetData($Input2, $str)
EndFunc   ;==>UpdateBits

Func ClickTranslate()
	Local $bin = GUICtrlRead($Input1)
	Local $arr = StringSplit($bin, ' ', 2)
	Local $str = ''
	For $byte In $arr
		If StringLen($byte) Then $str &= Chr(_BinaryToDec($byte))
	Next
	$str &= " -- RAW: " & $bin
	GUICtrlSetData($Input1, $str)

EndFunc   ;==>ClickTranslate
Func Close()
	Exit
EndFunc   ;==>Close
Func Move()
	;MsgBox(0,0,'move')
	Local $wgp = WinGetPos(GUICtrlGetHandle($Graphic1))
	If Not IsArray($wgp) Then Return

	WinMove($Form2, '', $wgp[0], $wgp[1])
EndFunc   ;==>Move



Func ClickBitTool()
	$Tool = "bit"
EndFunc   ;==>ClickBitTool
Func ClickLineTool()
	$Tool = "line"
	$LinesList=""
	$Lines=7
	ClickClear()
	;MsgBox(0,"ABISM Viewer","Please place the horizontal frequency lines for each of the 7 bits by clicking. "&@CRLF& _
	;"If you are using Automatic Detection mode, you must place these in Left-To-Right bit order (MSB to LSB) - which is generally Low to High frequency.")
EndFunc   ;==>ClickLineTool

Func ClickClear()
	;$Tool="none"
	GUISwitch($Form1)
	GUICtrlDelete($Graphic1)
	$Graphic1 = GUICtrlCreateGraphic(0, $yx, $wx, $hx)
	GUICtrlSetBkColor($Graphic1, 0xABABAB)
	GUICtrlSetColor($Graphic1, 0xFF0000)
	;GUICtrlSetOnEvent(-1, "ClickEventL")

	Local $alines=StringSplit($LinesList,',',2)
	For $y In $alines
		If StringLen($y)=0 Then ContinueLoop
		$y=Int($y)
		GUICtrlSetGraphic($Graphic1, $GUI_GR_MOVE, 0, $y)
		GUICtrlSetGraphic($Graphic1, $GUI_GR_COLOR, $CFG_CLR_LINE)
		GUICtrlSetGraphic($Graphic1, $GUI_GR_LINE, 2000,$y)
	Next
	GUICtrlSetGraphic($Graphic1, $GUI_GR_REFRESH)
	GUICtrlSetData($Input1, GUICtrlRead($Input1) & " ")
EndFunc   ;==>ClickClear
Func ClickNext()
	GUICtrlSetData($Input1, GUICtrlRead($Input1) & " ")
EndFunc   ;==>ClickNext

Func ClickEventL()
	ClickEvent(1)
EndFunc   ;==>ClickEventL
Func ClickEventR()
	ClickEvent(0)
EndFunc   ;==>ClickEventR
Func ClickEvent($k = 'N/A')
	;WinActivate($Form1)
	Local $tPoint = _WinAPI_GetMousePos(True, GUICtrlGetHandle($Graphic1))
	Local $x = DllStructGetData($tPoint, 'X')
	Local $y = DllStructGetData($tPoint, 'Y')
	Switch $Tool
		Case 'bit'
			Local $color = $CFG_CLR_BIT0
			If $k Then $color = $CFG_CLR_BIT1
			;MsgBox(0,$x,$y)
			;GUICtrlSetGraphic($Graphic1, $GUI_GR_MOVE,100,100)
			;GUICtrlSetColor($Graphic1,0)
			GUICtrlSetGraphic($Graphic1, $GUI_GR_COLOR, $CFG_CLR_BORDER)
			GUICtrlSetGraphic($Graphic1, $GUI_GR_RECT, $x - 3, $y - 3, 6, 6)
			GUICtrlSetGraphic($Graphic1, $GUI_GR_COLOR, $color)
			GUICtrlSetGraphic($Graphic1, $GUI_GR_RECT, $x - 2, $y - 2, 4, 4)
			GUICtrlSetGraphic($Graphic1, $GUI_GR_COLOR, $CFG_CLR_BORDER)
			GUICtrlSetGraphic($Graphic1, $GUI_GR_RECT, $x - 1, $y - 1, 2, 2)




			;GUICtrlSetGraphic($Graphic1,$GUI_GR_DOT,$x,$y)
			GUICtrlSetGraphic($Graphic1, $GUI_GR_REFRESH)
			GUICtrlSetData($Input1, GUICtrlRead($Input1) & $k)
			Local $arr = StringSplit(GUICtrlRead($Input1), ' ')
			If IsArray($arr) Then
				If StringLen($arr[UBound($arr) - 1]) = 7 Then GUICtrlSetData($Input1, GUICtrlRead($Input1) & ' ')
			EndIf
			UpdateBits()
		Case 'line'
			If $Lines>0 Then
				$LinesList&=$y&','
				$Lines-=1
				GUICtrlSetGraphic($Graphic1, $GUI_GR_MOVE, 0, $y)
				GUICtrlSetGraphic($Graphic1, $GUI_GR_COLOR, $CFG_CLR_LINE)
				GUICtrlSetGraphic($Graphic1, $GUI_GR_LINE, 2000,$y)
				GUICtrlSetGraphic($Graphic1, $GUI_GR_REFRESH)
				If $Lines=0 Then $Tool='bit'
			EndIf
	EndSwitch
EndFunc   ;==>ClickEvent

Func ClickTransparency()
	$Transparency = Mod($Transparency + 64, 256)
	Local $tmpTrans = $Transparency
	If $tmpTrans < 32 Then $tmpTrans = 32
	WinSetTrans($Form1, '', $tmpTrans)
EndFunc   ;==>ClickTransparency

