
#include ..\QuickFind.ahk

class test {
    static Call(&descriptions?) {
        problems := Map()
        descriptions := ''
        arr := []
        arr.Capacity := 1000
        loop arr.Capacity {
            arr.Push(A_Index)
        }
        eq := ObjBindMethod(QuickFind, 'Equality')

        a := arr.Clone()
        a[2] := a[3] := a[4] := 1
        _Search('1-4 == 1', 1, 1, 4)

        a := arr.Clone()
        a[1] := a[2] := a[3] := 4
        _Search('1-4 == 4', 4, 1, 4)

        a := arr.Clone()
        a[997] := a[998] := a[999] := 1000
        _Search('997-1000 == 1000', 1000, 997, 1000)

        a := arr.Clone()
        a[998] := a[999] := a[1000] := 997
        _Search('997-1000 == 977', 997, 997, 1000)

        a := arr.Clone()
        _Search('500', 500, 500, 500)

        a := arr.Clone()
        _Search('1', 1, 1, 1)

        a := arr.Clone()
        _Search('1000', 1000, 1000, 1000)

        a := arr.Clone()
        _Search('1001', 1001, 0, '')

        a := arr.Clone()
        _Search('0', 0, 0, '')

        if problems.Count {
            return problems
        }

        _Search(name, value, expectedResult, expectedLastIndex) {
            result := eq(a, value, &lastIndex)
            if expectedResult != result {
                descriptions .= '`n' name ' :: expectedResult != result :: ' (expectedResult || '""') ' != ' (result || '""')
                _Set()
            }
            if expectedLastIndex != (lastIndex ?? '') {
                descriptions .= '`n' name ' :: expectedLastIndex != lastIndex :: ' (expectedLastIndex || '""') ' != ' (IsSet(lastIndex) && lastIndex ? lastIndex : '""')
                _Set()
            }
            _Set() {
                if !problems.Has(name) {
                    problems.Set(name, { arr: a, expectedResult: expectedResult, expectedLastIndex: expectedLastIndex, result: result, lastIndex: lastIndex ?? '' })
                }
            }
        }
    }

    static Callback(&descriptions) {
        problems := Map()
        descriptions := ''
        arr := []
        arr.Capacity := 1000
        loop arr.Capacity {
            arr.Push(A_Index)
        }
        eq := ObjBindMethod(QuickFind, 'EqualityCallback')

        a := arr.Clone()
        a[2] := a[3] := a[4] := 1
        _Search('1-4 == 1', 1, 1, 4)

        a := arr.Clone()
        a[1] := a[2] := a[3] := 4
        _Search('1-4 == 4', 4, 1, 4)

        a := arr.Clone()
        a[997] := a[998] := a[999] := 1000
        _Search('997-1000 == 1000', 1000, 997, 1000)

        a := arr.Clone()
        a[998] := a[999] := a[1000] := 997
        _Search('997-1000 == 977', 997, 997, 1000)

        a := arr.Clone()
        _Search('500', 500, 500, 500)

        a := arr.Clone()
        _Search('1', 1, 1, 1)

        a := arr.Clone()
        _Search('1000', 1000, 1000, 1000)

        a := arr.Clone()
        _Search('1001', 1001, 0, '')

        a := arr.Clone()
        _Search('0', 0, 0, '')

        if problems.Count {
            return problems
        }

        _Search(name, value, expectedResult, expectedLastIndex) {
            result := eq(a, callback.Bind(value), &lastIndex)
            if expectedResult != result {
                descriptions .= '`n' name ' :: expectedResult != result :: ' (expectedResult || '""') ' != ' (result || '""')
                _Set()
            }
            if expectedLastIndex != (lastIndex ?? '') {
                descriptions .= '`n' name ' :: expectedLastIndex != lastIndex :: ' (expectedLastIndex || '""') ' != ' (IsSet(lastIndex) && lastIndex ? lastIndex : '""')
                _Set()
            }
            _Set() {
                if !problems.Has(name) {
                    problems.Set(name, { arr: a, expectedResult: expectedResult, expectedLastIndex: expectedLastIndex, result: result, lastIndex: lastIndex ?? '' })
                }
            }
        }
    }

    static Func(&descriptions) {
        problems := Map()
        descriptions := ''
        arr := []
        arr.Capacity := 1000
        loop arr.Capacity {
            arr.Push(A_Index)
        }

        a := arr.Clone()
        a[2] := a[3] := a[4] := 1
        _Search('1-4 == 1', 1, 1, 4)

        a := arr.Clone()
        a[1] := a[2] := a[3] := 4
        _Search('1-4 == 4', 4, 1, 4)

        a := arr.Clone()
        a[997] := a[998] := a[999] := 1000
        _Search('997-1000 == 1000', 1000, 997, 1000)

        a := arr.Clone()
        a[998] := a[999] := a[1000] := 997
        _Search('997-1000 == 977', 997, 997, 1000)

        a := arr.Clone()
        _Search('500', 500, 500, 500)

        a := arr.Clone()
        _Search('1', 1, 1, 1)

        a := arr.Clone()
        _Search('1000', 1000, 1000, 1000)

        a := arr.Clone()
        _Search('1001', 1001, 0, '')

        a := arr.Clone()
        _Search('0', 0, 0, '')

        if problems.Count {
            return problems
        }

        _Search(name, value, expectedResult, expectedLastIndex) {
            finder := QuickFind.Func.EqualityCallback(a, callback)
            result := finder(value, &lastIndex)
            if expectedResult != result {
                descriptions .= '`n' name ' :: expectedResult != result :: ' (expectedResult || '""') ' != ' (result || '""')
                _Set()
            }
            if expectedLastIndex != (lastIndex ?? '') {
                descriptions .= '`n' name ' :: expectedLastIndex != lastIndex :: ' (expectedLastIndex || '""') ' != ' (IsSet(lastIndex) && lastIndex ? lastIndex : '""')
                _Set()
            }
            result := finder.Find(value)
            if expectedResult != result {
                descriptions .= '`n' name ' (find) :: expectedResult != result :: ' (expectedResult || '""') ' != ' (result || '""')
                _Set()
            }
            _Set() {
                if !problems.Has(name) {
                    problems.Set(name, { arr: a, expectedResult: expectedResult, expectedLastIndex: expectedLastIndex, result: result, lastIndex: lastIndex ?? '' })
                }
            }
        }
    }
}

callback(value, arr, i) => value - arr[i]
