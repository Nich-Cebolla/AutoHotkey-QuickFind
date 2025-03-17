
#Include <Object.Prototype.Stringify_V1.0.0>
; https://github.com/Nich-Cebolla/Stringify-ahk/blob/main/Object.Stringify.ahk
#Include QuickFind.ahk

test(2)

/**
 * @description - Initiates the test.
 * @param {Integer} [Which=1] - One of the following options:
 * - 1: Test `QuickFind.Call`
 * - 2: Test `QuickFind.GetFunc.Prototype.Call`
 */
test(Which := 1) {
    global F
    local ArrClone
    G := Gui()
    G.Add('Edit', 'w600 r20 vedit')
    G.Show()
    Len := 10000
    Arr1 := []
    Arr1.Length := Len
    Values1 := []
    Z := 0
    loop Len {
        if Random() > 0.85
            continue
        Arr1[A_Index] := GetValue(A_Index)
        if A_Index > Z {
            Values1.Push({Index: A_Index, Value: Arr1[A_Index]})
            if Z
                Z += 900
            else
                Z := 20
        }
    }
    if !Arr1.Has(Len)
        Arr1[Len] := GetValue(Len)
    Values1.Push({Index: Len, Value: Arr1[Len]})
    Arr2 := []
    Arr2.Length := Len
    Values2 := []
    Z := i := 10001
    loop Len {
        i--
        if Random() > 0.85
            continue
        Arr2[A_Index] := GetValue(i)
        if i < Z {
            Values2.Push({Index: A_Index, Value: Arr2[A_Index]})
            if Z == 10001
                Z := 9980
            else
                Z -= 900
        }
    }
    if !Arr2.Has(1)
        Arr2[1] := GetValue(Len)
    Values2.Push({Index: 1, Value: Arr2[1]})
    GreaterThan := [false, true]
    EqualTo := [false, true]
    IndexStart := [1, 500, 1000, 2500, 5000, 7500, 9500, 9999]
    IndexEnd := [10000, 9500, 9000, 7500, 5000, 2500, 1000, 500, 2]
    Input := { GT: '', ET: '', INS: '', INE: '' }
    loop 2 {
        if A_Index == 1 {
            Arr := Arr1
            Values := Values1
            Order := 1
        } else {
            Arr := Arr2
            Values := Values2
            Order := -1
        }
        for GT in GreaterThan {
            Input.GT := GT
            for ET in EqualTo {
                Input.ET := ET
                for INS in IndexStart {
                    Input.INS := INS
                    for INE in IndexEnd {
                    Input.INE := INE
                        for V in Values {
                            try
                                Process(Arr, V)
                            catch Error as err {
                                if err.Message == 'The end index is less than or equal to the start index.'
                                || 'The range does not contain a value.'
                                    continue
                                else
                                    throw err
                            }
                            if V.Index > INE || V.Index < INS
                                continue
                            ArrClone := Arr.Clone()
                            G['edit'].Text := (
                                'GreaterThan: ' Input.GT
                                '`r`nEqualTo: ' Input.ET
                                '`r`nIndexStart: ' Input.INS
                                '`r`nIndexEnd: ' Input.INE
                                '`r`nValue: ' V.Value
                                '`r`nIndex: ' V.Index
                                '`r`nOrder: ' Order
                            )
                            Operation1(ArrClone, V)
                            if Order == 1 {
                                F := FileOpen('Debug_QuickFind_output.txt', 'w')
                                Result := Process(ArrClone, V)
                                if ET {
                                    if Result !== V.Index && !(V.Index == INS && !GT) {
                                        _Throw('1', ': Result !== V.Index`tV.Index: ' V.Index '`tResult: ' Result)
                                        return
                                    }
                                } else {
                                    if Result {
                                        if Result == V.Index {
                                            _Throw('2', ': Result == V.Index`tV.Index: ' V.Index '`tResult: ' Result)
                                            return
                                        }
                                        if Result > V.Index && !GT {
                                            _Throw('3', ': !GT`tResult > V.Index`tV.Index: ' V.Index '`tResult: ' Result)
                                            return
                                        }
                                        if Result < V.Index && GT {
                                            _Throw('4', ': GT`tResult < V.Index`tV.Index: ' V.Index '`tResult: ' Result)
                                            return
                                        }
                                    } else {
                                        if GT {
                                            if V.Index !== Values[-1].Index && INE > V.Index && !(INE - INS == 1 && !ArrClone.Has(V.Index + 1)) {
                                                _Throw('5', ': !Result`tV.Index: ' V.Index '`tResult: ' Result)
                                                return
                                            }
                                        } else {
                                            if V.Index !== Values[1].Index && !(INE - INS == 1 && !ArrClone.Has(V.Index - 1)) {
                                                _Throw('6', ': !Result`tV.Index: ' V.Index '`tResult: ' Result)
                                                return
                                            }
                                        }
                                    }
                                }
                                F.Close()
                                if GT {
                                    if V.Index !== Values[1].Index && V.Index !== Values[-1].Index {
                                        F := FileOpen('Debug_QuickFind_output.txt', 'w')
                                        Operation2(ArrClone, V, 1)
                                        Result := Process(ArrClone, V)
                                        if Result !== V.Index + 1 {
                                            _Throw('7', ': Result !== V.Index + 1`tV.Index: ' V.Index '`tResult: ' Result)
                                            return
                                        }
                                        F.Close()
                                    }
                                } else {
                                    if V.Index !== Values[1].Index && V.Index !== Values[-1].Index {
                                        F := FileOpen('Debug_QuickFind_output.txt', 'w')
                                        Operation2(ArrClone, V, -1)
                                        Result := Process(ArrClone, V)
                                        if Result !== V.Index - 1 {
                                            _Throw('8', ': Result !== V.Index - 1`tV.Index: ' V.Index '`tResult: ' Result)
                                            return
                                        }
                                        F.Close()
                                    }
                                }
                                if V.Index !== Values[1].Index && V.Index !== Values[-1].Index {
                                    F := FileOpen('Debug_QuickFind_output.txt', 'w')
                                    Operation3(ArrClone, V)
                                    Result := Process(ArrClone, V)
                                    if ET {
                                        if GT {
                                            if Result !== V.Index - 2 {
                                                _Throw('9', ': Result !== V.Index - 2`tV.Index: ' V.Index '`tResult: ' Result)
                                                return
                                            }
                                        } else {
                                            if Result !== V.Index + 2 {
                                                _Throw('10', ': Result !== V.Index - 2`tV.Index: ' V.Index '`tResult: ' Result)
                                                return
                                            }
                                        }
                                    } else {
                                        if GT {
                                            i := V.Index + 3
                                            while !ArrClone.Has(i) && i > 0
                                                i++
                                            if Result !== i {
                                                _Throw('11', ': Result !== i (V.Index + 3, and if unset finding next index)`tV.Index: ' V.Index '`tResult: ' Result '`ti: ' i)
                                                return
                                            }
                                        } else {
                                            i := V.Index - 3
                                            while !ArrClone.Has(i) && i <= ArrClone.Length
                                                i--
                                            if Result !== i {
                                                _Throw('12', 'Result !== i (V.Index - 3, and if unset finding next index)`r`nV.Index: ' V.Index '`tResult: ' Result '`ti: ' i)
                                                return
                                            }
                                        }
                                    }
                                    F.Close()
                                }
                            } else {
                                F := FileOpen('Debug_QuickFind_output.txt', 'w')
                                Result := Process(ArrClone, V)
                                if ET {
                                    if Result !== V.Index {
                                        _Throw('13', ': Result !== V.Index`tV.Index: ' V.Index '`tResult: ' Result)
                                        return
                                    }
                                } else {
                                    if Result {
                                        if Result == V.Index {
                                            _Throw('14', ': Result == V.Index`tV.Index: ' V.Index '`tResult: ' Result)
                                            return
                                        }
                                        if Result > V.Index && GT {
                                            _Throw('15', ': GT`tResult > V.Index`tV.Index: ' V.Index '`tResult: ' Result)
                                            return
                                        }
                                        if Result < V.Index && !GT {
                                            _Throw('16', ': !GT`tResult < V.Index`tV.Index: ' V.Index '`tResult: ' Result)
                                            return
                                        }
                                    } else {
                                        if GT {
                                            if V.Index !== INS {
                                                _Throw('17', ': !Result`tV.Index: ' V.Index '`tResult: ' Result)
                                                return
                                            }
                                        } else {
                                            if V.Index !== Values[-1].Index && !(INE - INS == 1 && (!ArrClone.Has(V.Index - 1) || V.Index == INE)) {
                                                _Throw('18', ': !Result`tV.Index: ' V.Index '`tResult: ' Result)
                                                return
                                            }
                                        }
                                    }
                                }
                                F.Close()
                                if GT {
                                    if V.Index !== Values[1].Index && V.Index !== Values[-1].Index {
                                        F := FileOpen('Debug_QuickFind_output.txt', 'w')
                                        Operation2(ArrClone, V, -1, V.Value + 1)
                                        Result := Process(ArrClone, V)
                                        if Result !== V.Index - 1 {
                                            _Throw('19', ': Result !== V.Index - 1`tV.Index: ' V.Index '`tResult: ' Result)
                                            return
                                        }
                                        F.Close()
                                    }
                                } else {
                                    if V.Index !== Values[1].Index && V.Index !== Values[-1].Index && V.Index <= INE {
                                        F := FileOpen('Debug_QuickFind_output.txt', 'w')
                                        Operation2(ArrClone, V, 1, V.Value - 1)
                                        Result := Process(ArrClone, V)
                                        if Result !== V.Index + 1 {
                                            _Throw('20', ': Result !== V.Index + 1`tV.Index: ' V.Index '`tResult: ' Result)
                                            return
                                        }
                                        F.Close()
                                    }
                                }
                                if V.Index !== Values[1].Index && V.Index !== Values[-1].Index {
                                    F := FileOpen('Debug_QuickFind_output.txt', 'w')
                                    Operation3(ArrClone, V)
                                    Result := Process(ArrClone, V)
                                    if ET {
                                        if GT {
                                            if Result !== V.Index + 2 {
                                                _Throw('21', ': Result !== V.Index - 2`tV.Index: ' V.Index '`tResult: ' Result)
                                                return
                                            }
                                        } else {
                                            if Result !== V.Index - 2 {
                                                _Throw('22', ': Result !== V.Index - 2`tV.Index: ' V.Index '`tResult: ' Result)
                                                return
                                            }
                                        }
                                    } else {
                                        if GT {
                                            i := V.Index - 3
                                            while !ArrClone.Has(i) && i > 0
                                                i--
                                            if Result !== i {
                                                _Throw('23', 'Result !== i (V.Index - 3, and if unset finding next index)`r`nV.Index: ' V.Index '`tResult: ' Result '`ti: ' i)
                                                return
                                            }
                                        } else {
                                            i := V.Index + 3
                                            while !ArrClone.Has(i) && i <= ArrClone.Length
                                                i++
                                            if Result !== i {
                                                _Throw('24', ': Result !== i (V.Index + 3, and if unset finding next index)`tV.Index: ' V.Index '`tResult: ' Result '`ti: ' i)
                                                return
                                            }
                                        }
                                    }
                                    F.Close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    MsgBox('Success!')
    Process(ArrClone, V) {
        switch Which {
            case 1: return QuickFind(ArrClone, V.Value, &OutValue, Input.GT, Input.ET, Input.INS, Input.INE)
            case 2:
                Fn := QuickFind.Func(ArrClone, Input.GT, Input.ET, Input.INS, Input.INE)
                return Fn(V.Value, &OutValue)
        }
    }
    GetValue(i) {
        ; return i * 2 + Round(Random(), 3) - 5000
        return i
    }
    Operation1(ArrClone, V) {
        if !ArrClone.Has(V.Index)
            ArrClone[V.Index] := GetValue(V.Index)
    }
    Operation2(ArrClone, V, delta, Replacement?) {
        if ArrClone.Has(V.Index)
            ArrClone.Delete(V.Index)
        if !ArrClone.Has(V.Index + Delta) {
            if IsSet(Replacement)
                ArrClone[V.Index + Delta] := Replacement
            else
                ArrClone[V.Index + Delta] := GetValue(V.Index + Delta)
        }
    }
    Operation3(ArrClone, V) {
        loop 2
            ArrClone[V.Index - A_Index] := V.Value
        loop 2
            ArrClone[V.Index + A_Index] := V.Value
    }
    _throw(Code, Message) {
        ; To give it time to finish writing the output to file.
        F.Write('`r`n`r`nArrClone:`r`n' ArrClone.Stringify() '`r`n`r`nValues:`r`n' Values.Stringify())
        SetTimer(__Throw, -500)
        F.Close()
        __throw() {
            throw Error('Code: ' Code '`t' Message, -1)
        }
    }
}
