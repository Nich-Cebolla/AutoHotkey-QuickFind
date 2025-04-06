
#Include QuickFind.ahk
#Include Words.ahk

GetWordValue := ObjBindMethod(QuickFind, 'GetWordValueUseCache') ; To use cache
; GetWordValue := ObjBindMethod(QuickFind, 'GetWordValue') ; No cache

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

GetWordValue() {
    local n := 0
    for c in StrSplit(StrUpper(SubStr(Word, 1, 10))) {
        if Ord(c) >= 123
            n += (Ord(c) - 58) / 68 ** A_Index
        else
            n += (Ord(c) - 32) / 68 ** A_Index
    }
    return n
}

