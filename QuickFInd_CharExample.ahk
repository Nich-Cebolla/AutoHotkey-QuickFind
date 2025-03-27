
#Include QuickFind.ahk
#Include Words.ahk

GetWordValue := ObjBindMethod(QuickFind, 'GetWordValue', true) ; true to use cache
; or
; GetWordValue := ObjBindMethod(QuickFind, 'GetWordValue', false) ; false to not use cache

Index := QuickFind(Words, GetWordValue('coincide'), &WordValue, , , , GetWordValue)
MsgBox('Index: ' Index ' Value: ' WordValue) ; Index: 86 Value: coincide
Index := QuickFind(Words, GetWordValue('counter'), &WordValue, '>=', , , GetWordValue)
MsgBox('Index: ' Index ' Value: ' WordValue) ; Index: 110 Value: cow


/*
Explanation:
The printable character range is 33 - 126.
We subtract 32 to drop the range down to 1 - 94.
Lowercase characters are excluded, which puts { } | and ~ outside the range. An extra
26 must be subtracted from their ordinal values to bring them after the backtick ( ` ) (96).
The total number of characters in the set is 68.
