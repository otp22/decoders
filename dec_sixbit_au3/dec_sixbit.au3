
For $l = 1 To 100
	Local $c = Chr(GetBits($l))
	If $c = "_" Then $c = '_' & @CRLF
	ConsoleWrite($c)
Next
ConsoleWrite(@CRLF)



Func GetBits($l)
	Local $line = FileReadLine("freq.txt", $l)
	If @error Then Return
	Local $d = 0
	If Not StringInStr($line, 392) Then Return

	;If StringInStr($line,392) Then $d=BitOR($d,64)
	;inefficient code follows!!!!
	If StringInStr($line, 495) Then $d = BitOR($d, 32)
	If StringInStr($line, 593) Then $d = BitOR($d, 16)
	If StringInStr($line, 665) Then $d = BitOR($d, 8)
	If StringInStr($line, 699) Then $d = BitOR($d, 4)
	If StringInStr($line, 789) Then $d = BitOR($d, 2)
	If StringInStr($line, 883) Then $d = BitOR($d, 1)

	;ConsoleWrite(' '&$d&"=")

	$d += 32
	;$d+=64
	Return $d
EndFunc   ;==>GetBits