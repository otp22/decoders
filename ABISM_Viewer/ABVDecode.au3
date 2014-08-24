#include-once
#include "ABVConfig.au3"

Func BitsToString($bits)
	Local $arr = StringSplit($bits, ' ', 2)
	Local $str = ''
	For $byte In $arr
		If StringLen($byte) Then $str &= BitsToChar($byte)
	Next
	Return $str
EndFunc
Func BitsToChar($bits)
	Global $CFG_DEC_MODE
	Local $dec=_BinaryToDec($bits)
	Switch $CFG_DEC_MODE
		Case $CFG_DEC_ASCII
			Return Chr($dec)
		Case $CFG_DEC_SUB64A
			If BitAND($dec, 32) Then $dec -= 64
			Return Chr($dec)
		Case $CFG_DEC_SUB64B
			If ($dec>=Asc('a') And $dec<=Asc('z')) Or $dec=Asc('`') Then $dec -= 64
			Return Chr($dec)
		Case $CFG_DEC_ITA2
			Return SetError(1,0,"")
		Case $CFG_DEC_HEX
			ConsoleWrite($dec&' '&@CRLF)
			Return Hex(Int($dec),2)
	EndSwitch
EndFunc

; --------------------- Functions -----------------------------
; Binary to Decimal
Func _BinaryToDec($strBin)
	Local $Return
	Local $lngResult
	Local $intIndex

	If StringRegExp($strBin, '[0-1]') Then
		$lngResult = 0
		For $intIndex = StringLen($strBin) To 1 Step -1
			$strDigit = StringMid($strBin, $intIndex, 1)
			Select
				Case $strDigit = "0"
					; do nothing
				Case $strDigit = "1"
					$lngResult = $lngResult + (2 ^ (StringLen($strBin) - $intIndex))
				Case Else
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
EndFunc   ;==>_BinaryToDec