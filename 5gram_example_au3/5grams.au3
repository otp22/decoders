#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Constants.au3>
#include <Array.au3>
#include <WinAPI.au3>
#include <Process.au3>
;;;

Global Enum $DIR_RTL, $DIR_LTR

Local $tagLine='byte[5];byte;byte[5];byte'
Local $tagChunk=''
For $i=1 To 13^3
	If $i>1 Then $tagChunk&=';'
	$tagChunk&=$tagLine
Next

Local $gChunk=DllStructCreate($tagChunk)
Local $pChunk=DllStructGetPtr($gChunk)
;MsgBox(0,0,$pChunk)
Local $gLine=0


;MsgBox(0,0,PUBLIC_otpsearch(2,'YUGAY'))
ConsoleWrite(TransMessage(2, 'XNRJI IOVBC EBPNZ BCDDA GHXLJ PDCQR FPEKE JXEFS TXIEB WDRAZ HTVRZ OTXXT KBJSM', $DIR_RTL)&@CRLF)

;requires pN.txt to exist in the current directory where N is the digit you specify to TransMessage.

Exit

Func TransMessage($P, $string, $dir=$DIR_RTL)
	Local $output=''
	$string=StringReplace(StringStripCR($string),@LF,' ')
	$string=StringStripWS($string,1+2+4)
	Local $words=StringSplit($string,' ')
	Local $trans=''
	For $i=1 To UBound($words)-1
		ConsoleWrite("Trans "&$words[$i])
		$trans=Trans($P,$words[$i],$dir)
		ConsoleWrite(" "&$trans&@CRLF)
		$output&=$trans&' '
	Next
	Return $output
EndFunc


;old method of
Func PUBLIC_otpsearch($num,$in)

	$in=StringRegExpReplace($in,"(?s)[^a-zA-Z]","")

	Local $key="p"&Int($num)&".txt"
	Local $out=@TempDir&"\out5gram.txt"
	FileDelete($out)
	_RunDos(StringFormat('find /N "%s" %s > %s',$in,$key,$out))
	Local $outX=FileRead($out)
	$outX=StringReplace($outX,$key,' ')
	$outX=StringReplace($outX,'----------',' ')
	Return $outX
EndFunc



;slow manual method!
Func Trans($P, $5gram, $dir=$DIR_RTL)
	$5gram=StringToBinary($5gram)


	Local $file='p'&Int($P)&".txt"
	Local $size=FileGetSize($file)
	Local $linelen=12
	Local $lines=Int($size/$linelen)

	Local $chunk_lines=13^3
	Local $chunk_size=$chunk_lines*$linelen

	Local $L,$R

	Local $h =_WinAPI_CreateFile2($file,2,2); FileOpen($file, 0); --- open a file for reading
	Local $iRead=0
	If $h=0 Then MsgBox(0,$h,_WinAPI_GetLastErrorMessage())

	ConsoleWrite( $chunk_lines&' lines. '&$chunk_size&' bytes'&@CRLF)

	For $l=1 To $lines Step $chunk_lines
		ConsoleWrite('.'&@CRLF)
		_WinAPI_ReadFile($h, $pChunk, $chunk_size, $iRead)
		If $iRead=0 Then MsgBox(0,$h,_WinAPI_GetLastErrorMessage())
		ConsoleWrite("Read: "&$iRead&@CRLF)
		$maxoffset=$chunk_lines*4
		For $j=0 To $maxoffset Step 52
			;ConsoleWrite("|"&(($j-1)*3+3)&@CRLF)
			;DllStructSetData($gChunk, ($j-1)*4+1,0)
			If DllStructGetData($gChunk, $j+03)=$5gram Then Return DllStructGetDataX($gChunk, $j+01)
			If DllStructGetData($gChunk, $j+07)=$5gram Then Return DllStructGetDataX($gChunk, $j+05)
			If DllStructGetData($gChunk, $j+11)=$5gram Then Return DllStructGetDataX($gChunk, $j+09)
			If DllStructGetData($gChunk, $j+15)=$5gram Then Return DllStructGetDataX($gChunk, $j+13)
			If DllStructGetData($gChunk, $j+19)=$5gram Then Return DllStructGetDataX($gChunk, $j+17)
			If DllStructGetData($gChunk, $j+23)=$5gram Then Return DllStructGetDataX($gChunk, $j+21)
			If DllStructGetData($gChunk, $j+27)=$5gram Then Return DllStructGetDataX($gChunk, $j+25)
			If DllStructGetData($gChunk, $j+31)=$5gram Then Return DllStructGetDataX($gChunk, $j+29)
			If DllStructGetData($gChunk, $j+35)=$5gram Then Return DllStructGetDataX($gChunk, $j+33)
			If DllStructGetData($gChunk, $j+39)=$5gram Then Return DllStructGetDataX($gChunk, $j+37)
			If DllStructGetData($gChunk, $j+43)=$5gram Then Return DllStructGetDataX($gChunk, $j+41)
			If DllStructGetData($gChunk, $j+47)=$5gram Then Return DllStructGetDataX($gChunk, $j+45)
			If DllStructGetData($gChunk, $j+51)=$5gram Then Return DllStructGetDataX($gChunk, $j+49)
		Next
	Next
	_WinAPI_CloseHandle($h)
	;FileClose($h)

	Return 'ERR:'&$5gram
EndFunc
Func DllStructGetDataX(ByRef $stc, $offset)
	Local $tmp=DllStructGetData($gChunk, $offset)
	ConsoleWrite("Element "&$offset&": "&$tmp&@CRLF)
	Return $tmp
EndFunc


Func _WinAPI_CreateFile2($sFileName, $iCreation, $iAccess = 4, $iShare = 0, $iAttributes = 0, $pSecurity = 0)
	Local $iDA = 0, $iSM = 0, $iCD = 0, $iFA = 0

	If BitAND($iAccess, 1) <> 0 Then $iDA = BitOR($iDA, $GENERIC_EXECUTE)
	If BitAND($iAccess, 2) <> 0 Then $iDA = BitOR($iDA, $GENERIC_READ)
	If BitAND($iAccess, 4) <> 0 Then $iDA = BitOR($iDA, $GENERIC_WRITE)

	If BitAND($iShare, 1) <> 0 Then $iSM = BitOR($iSM, $FILE_SHARE_DELETE)
	If BitAND($iShare, 2) <> 0 Then $iSM = BitOR($iSM, $FILE_SHARE_READ)
	If BitAND($iShare, 4) <> 0 Then $iSM = BitOR($iSM, $FILE_SHARE_WRITE)

	Switch $iCreation
		Case 0
			$iCD = $CREATE_NEW
		Case 1
			$iCD = $CREATE_ALWAYS
		Case 2
			$iCD = $OPEN_EXISTING
		Case 3
			$iCD = $OPEN_ALWAYS
		Case 4
			$iCD = $TRUNCATE_EXISTING
	EndSwitch

	If BitAND($iAttributes, 1) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_ARCHIVE)
	If BitAND($iAttributes, 2) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_HIDDEN)
	If BitAND($iAttributes, 4) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_READONLY)
	If BitAND($iAttributes, 8) <> 0 Then $iFA = BitOR($iFA, $FILE_ATTRIBUTE_SYSTEM)
	$iFA = BitOR($iFA, 0x08000000);FILE_FLAG_SEQUENTIAL_SCAN

	Local $aResult = DllCall("kernel32.dll", "handle", "CreateFileW", "wstr", $sFileName, "dword", $iDA, "dword", $iSM, "ptr", $pSecurity, "dword", $iCD, "dword", $iFA, "ptr", 0)
	If @error Or $aResult[0] = Ptr(-1) Then Return SetError(@error, @extended, 0) ; INVALID_HANDLE_VALUE
	Return $aResult[0]
EndFunc   ;==>_WinAPI_CreateFile