#include-once
#include <Misc.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Global Const $CFG_SETTING_INVALID=0
Global Enum $CFG_TRANS_INVALID=0, $CFG_TRANS_LTR, $CFG_TRANS_RTL, $CFG_TRANS_ALIGN, $CFG_TRANS_COUNT
Global Enum $CFG_DEC_INVALID=0, $CFG_DEC_ASCII, $CFG_DEC_SUB64A, $CFG_DEC_SUB64B, $CFG_DEC_ITA2, $CFG_DEC_HEX, $CFG_DEC_COUNT
Global Enum $CFG_CLROP_BIT1, $CFG_CLROP_BIT0, $CFG_CLROP_BORDER,$CFG_CLROP_LINE
Global $CFG_CLRNM_0='BIT1'; NOTE: this is only so we can implement a pseudo-lookup.
Global $CFG_CLRNM_1='BIT0'
Global $CFG_CLRNM_2='BORDER'
Global $CFG_CLRNM_3='LINE'



Global $CFG_TRANS_MODE=SLoad("TransMode",$CFG_TRANS_LTR)
Global $CFG_DEC_MODE=SLoad("DecMode",$CFG_DEC_SUB64A)

Global $CFG_CLR_BIT1=SLoad("ColorOn",0x00FF00)
Global $CFG_CLR_BIT0=SLoad("ColorOff",0xFF0000)
Global $CFG_CLR_BORDER=SLoad("ColorBorder",0x000001)
Global $CFG_CLR_LINE=SLoad("ColorLine",0xFFFF00)

Global $CFG_WIDTH=SLoad("Width",800)
Global $CFG_HEIGHT=SLoad("Height",600)

Global $ABVCFG_PARENTA=0
Global $ABVCFG_PARENTB=0
Global $ABVCFG_UPDATEEVENT=""



Opt("GUIOnEventMode", 1)
#Region ### START Koda GUI section ### Form=C:\Users\Crash\Desktop\otp22\code\decoders\ABISM_Viewer\abism_config.kxf
$frmConfig = GUICreate("ABISM Viewer Configuration", 610, 306, 192, 132)
GUISetOnEvent($GUI_EVENT_CLOSE, "frmConfigClose")
$Group1 = GUICtrlCreateGroup("Bit transcription order", 4, 2, 366, 112)
$radTrans0 = GUICtrlCreateRadio("MSB First (in order clicked)", 20, 25, 255, 23)
GUICtrlSetState(-1, $GUI_CHECKED)
$radTrans1 = GUICtrlCreateRadio("LSB First (in order clicked)", 20, 50, 255, 23)
$radTrans2 = GUICtrlCreateRadio("Automatic Detection from Gridlines", 20, 76, 255, 23)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group2 = GUICtrlCreateGroup("Decoding behavior", 4, 120, 366, 180)
$radDec0 = GUICtrlCreateRadio("Raw ASCII", 19, 147, 322, 20)
$radDec1 = GUICtrlCreateRadio("ASCII with 0x40 subtraction (logic A)", 19, 176, 322, 20)
GUICtrlSetState(-1, $GUI_CHECKED)
$radDec2 = GUICtrlCreateRadio("ASCII with 0x40 subtraction (logic B)", 19, 206, 322, 20)
$radDec3 = GUICtrlCreateRadio("ITA2/Baudot (Not ABISM)", 19, 235, 322, 23)
$radDec4 = GUICtrlCreateRadio("Raw Hexadecimal", 19, 264, 322, 20)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Group3 = GUICtrlCreateGroup("Colors", 376, 2, 229, 182)
$Label1 = GUICtrlCreateLabel("Bit On (1)", 457, 32, 57, 20, $SS_RIGHT)
$Label2 = GUICtrlCreateLabel("Bit Off (0)", 458, 72, 56, 20, $SS_RIGHT)
$Label3 = GUICtrlCreateLabel("Bit Border/Contrast", 398, 112, 116, 20, $SS_RIGHT)
$Label4 = GUICtrlCreateLabel("Frequency Gridline ", 394, 152, 120, 20, $SS_RIGHT)
$butColor0 = GUICtrlCreateButton("", 544, 26, 32, 32)
GUICtrlSetTip(-1, "x")
GUICtrlSetOnEvent(-1, "butColorClick")
$butColor1 = GUICtrlCreateButton("", 544, 65, 32, 32)
GUICtrlSetTip(-1, "x")
GUICtrlSetOnEvent(-1, "butColorClick")
$butColor2 = GUICtrlCreateButton("", 544, 103, 32, 32)
GUICtrlSetTip(-1, "x")
GUICtrlSetOnEvent(-1, "butColorClick")
$butColor3 = GUICtrlCreateButton("", 544, 142, 32, 32)
GUICtrlSetTip(-1, "x")
GUICtrlSetOnEvent(-1, "butColorClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$butConfigOK = GUICtrlCreateButton("OK", 376, 189, 229, 111, $WS_GROUP)
GUICtrlSetOnEvent(-1, "butConfigOKClick")
GUISetState(@SW_SHOW,$frmConfig)
#EndRegion ### END Koda GUI section ###
GUISetState(@SW_HIDE,$frmConfig); Koda updates the SW_SHOW line, so I can't keep changing this
GUICtrlSetState($radDec3, $GUI_HIDE)
GUICtrlSetState($radTrans1, $GUI_HIDE)
GUICtrlSetState($radTrans2, $GUI_HIDE)
frmConfigDebugWait()




Func frmConfig__IsDebugging()
	Return (@ScriptName='ABVConfig.au3')
EndFunc
Func frmConfigDebugWait()
	; this routine checks whether the the Config script is being ran directly
	; which would imply it is being debugged.
	; to aide in debugging, we will automatically SHOW the UI and Idle-Wait.
	If frmConfig__IsDebugging() Then
		frmConfigShow()
		While 1
			Sleep(300)
		WEnd
	EndIf
EndFunc


Func butColorClick()
	$ctl=@GUI_CtrlId
	$ictl=$ctl-$butColor0
	If $ictl<0 Then Return MsgBox(0,0,'ABISM Viewer Config',"Error: Invalid Color Control "&$ctl&' '&$radDec0)
	$suffix=Eval("CFG_CLRNM_"&$ictl)
	$clr=Eval("CFG_CLR_"&$suffix)


	$clr=_ChooseColor(2,$clr,2,$frmConfig)
	ConsoleWrite($clr&@CRLF)
	If $clr=-1 Then Return
	If $clr=0 Then $clr=1
	ColorCtlApply($suffix,$clr)
EndFunc



Func butConfigOKClick()
	$CFG_TRANS_MODE=GetRadioValue('Trans')
	$CFG_DEC_MODE=GetRadioValue('Dec')
	SSave("TransMode",$CFG_TRANS_MODE)
	SSave("DecMode",$CFG_DEC_MODE)
	SSave("ColorOn",$CFG_CLR_BIT1)
	SSave("ColorOff",$CFG_CLR_BIT0)
	SSave("ColorBorder",$CFG_CLR_BORDER)
	SSave("ColorLine",$CFG_CLR_LINE)


	GUISetState(@SW_HIDE,$frmConfig)
	If $ABVCFG_PARENTA Then GUISetState(@SW_ENABLE,$ABVCFG_PARENTA)
	If $ABVCFG_PARENTB Then GUISetState(@SW_ENABLE,$ABVCFG_PARENTB)
	Call($ABVCFG_UPDATEEVENT)

	;MsgBox(0,"ABISM Viewer Config","Settings have been updated. "&@CRLF&"NOTE: Color settings will not take effect immediately.")
	If frmConfig__IsDebugging() Then Exit; rather than keep the program running on Idle-Wait with no window.

EndFunc
Func frmConfigClose()
	butConfigOKClick()
EndFunc
Func frmConfigShow()
	If $ABVCFG_PARENTA Then GUISetState(@SW_DISABLE,$ABVCFG_PARENTA)
	If $ABVCFG_PARENTB Then GUISetState(@SW_DISABLE,$ABVCFG_PARENTB)
	frmConfigReset()
	GUISetState(@SW_SHOW,$frmConfig)
	WinActivate($frmConfig)
EndFunc
Func frmConfigReset()
	SettingSelectCtl('radTrans',$CFG_TRANS_MODE)
	SettingSelectCtl('radDec',$CFG_DEC_MODE)
	SettingColorizeCtl('BIT1')
	SettingColorizeCtl('BIT0')
	SettingColorizeCtl('BORDER')
	SettingColorizeCtl('LINE')
EndFunc
;-------------------------------------------------
Func GetRadioValue($type)
	Local $cname="rad"&$type
	Local $ename="CFG_"&$type&"_"
	Local $start=Eval($ename&"INVALID")+1
	Local $end=Eval($ename&"COUNT")-1
	For $i=$start To $end
		Local $ictl=$i-1
		Local $ctrlid=Eval($cname&$ictl)
		If BitAND(GUICtrlRead($ctrlid),$GUI_CHECKED)=$GUI_CHECKED Then
			ConsoleWrite($cname&$ictl&' '&$i&@CRLF)
			Return $i
		EndIf
	Next
EndFunc
Func ColorCtlApply($suffix,$value)
	Assign('CFG_CLR_'&$suffix,$value,2);$value=Eval('CFG_CLR_'&$suffix)
	;SSave('CFG_CLR_'&$suffix,$value)
	$ictrl=Eval('CFG_CLROP_'&$suffix)
	$ctrlid=Eval('butColor'&$ictrl)
	GUICtrlSetBkColor($ctrlid,$value)
EndFunc
Func SettingColorizeCtl($suffix)
	$value=Eval('CFG_CLR_'&$suffix)
	$ictrl=Eval('CFG_CLROP_'&$suffix)
	$ctrlid=Eval('butColor'&$ictrl)
	GUICtrlSetBkColor($ctrlid,$value)
EndFunc
Func SettingSelectCtl($prefix,$value)
	ConsoleWrite($prefix&' '&$value&@CRLF)
	Local $cid=SettingToCID($prefix,$value)
	GUICtrlSetState($cid, $GUI_CHECKED)
EndFunc
Func SettingToCID($prefix,$value)
	Local $tmp=$value-1
	If $tmp<0 Then
		MsgBox(0,"ABISM Viewer Config","An Error occured."&@CRLF&"Could not display form preset "&$prefix&'=['&$value&']')
		$tmp=0
	EndIf
	Return Eval($prefix&$tmp)
EndFunc
;--------------------------------------------------
Func SLoad($setting,$default)
	Local $tmp=Int(IniRead(@ScriptDir&"\ABVConfig.ini","config",$setting,$default))
	If $tmp=$CFG_SETTING_INVALID Then Return $default
	Return $tmp
EndFunc
Func SSave($setting,$value)
	If Int($value)=$CFG_SETTING_INVALID Then Return MsgBox(0,"ABISM Viewer Config","An Error occured."&@CRLF&"Could not write setting "&$setting&'=['&$value&']')
	Return IniWrite(@ScriptDir&"\ABVConfig.ini","config",$setting,Int($value))
EndFunc
