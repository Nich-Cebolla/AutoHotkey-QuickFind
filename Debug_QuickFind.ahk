
/**
 * @description - Searches an array for the index which contains the first value that satisfies
 * the condition relative to the input value. This function has these characteristics:
 * - The array is assumed to be in order of value.
 * - The direction in which this function handles its search is dependent on the value of
 * `GreaterThan` and also the direction the values in the array increase. For example, if
 * `GreaterThan` is true and the values increase from the end of the array to the beginning, the
 * search direction is treated as right to left.
 * - The array may have unset indices as long as every set index is in order.
 * - Items may be objects - set the relevant parameter of `ValueProp`, `ValueKey`, or `ValueCallback`.
 * @param {Array} Arr - The array to search.
 * @param {Number|Object} Value - The value to search for. When the values in the array are objects,
 * `Value` can be an object as well as long as the numerical value is accessed using the same
 * accessor as the items. However, this value is not required to be an object when the items are;
 * it may be a number regardless of what type of items are in the array. The inverse is not
 * true; `Value` cannot be an object when the items are not objects.
 * @param {VarRef} [OutValue] - A variable that will receive the value at the found index.
 * @param {Boolean} [GreaterThan=true] - If true, the function searches for the first index with a
 * value that is GreaterThan than the input value. If false, the function searches for the first index
 * with a value that is less than the input value.
 * @param {Boolean} [EqualTo=true] - If true, the condition includes equality. If false, the condition
 * is strictly greater or less than.
 * @param {Number} [IndexStart=1] - The index to start the search at.
 * @param {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the
 * array is used.
 * @param {String} [ValueProp] - The property to use when comparing objects
 * @param {String} [ValueKey] - The key to use when comparing objects.
 * @param {Func|BoundFunc|Closure} [ValueCallback] - The function to use when comparing objects. The
 * function should accept the object as its only parameter, and return a number.
 * @returns {Integer} - The index of the value that satisfies the condition.
 */
QuickFind(Arr, Value, &OutValue?, GreaterThan := true, EqualTo := true, IndexStart := 1, IndexEnd?
, ValueProp?, ValueKey?, ValueCallback?, StopBinary?) {
    local i, ReturnWhat := Left := Right := Direction := BaseDirection := Previous := OutValue := ''
    global F
    ; If you have a need for the binary search to cease early, set the value here.
    StopBinary := unset
    if !Arr.Length
        throw Error('The array is empty.', -1)
    if IsSet(ValueProp) {
        GetValue := (Item) => Item.%ValueProp%
        if IsObject(Value)
            Value := Value.%ValueProp%
    } else if IsSet(ValueKey) {
        GetValue := (Item) => Item[ValueKey]
        if IsObject(Value)
            Value := Value[ValueKey]
    } else if IsSet(ValueCallback) {
        GetValue := ValueCallback
        if IsObject(Value)
            Value := ValueCallback(Value)
    } else
        GetValue := (Item) => Item
    if !IsSet(IndexEnd)
        IndexEnd := Arr.Length
    if IndexEnd <= IndexStart
        throw Error('The end index is less than or equal to the start index.'
        , -1, 'IndexEnd: ' IndexEnd '`tIndexStart: ' IndexStart)
    if !IsSet(StopBinary) {
        StopBinary := 0, R := IndexEnd - IndexStart + 1
        loop {
            if R * 0.5 ** (StopBinary + 1) * 14 <= 27
                break
            StopBinary++
            if A_Index > 100
                throw Error('When attempting to calculate ``StopBinary``, the loop iterated for '
                A_Index ' iterations. This is either due to an unrealistically large input range,'
                ' or error in the implementation.', -1, 'Input range: ' IndexEnd - IndexStart + 1)
        }
    }
    if GreaterThan {
        if EqualTo {
            Condition := () => OutValue >= Value
            C := 'OutValue >= Value'
            InverseCondition := () => OutValue <= Value
            IC := 'OutValue <= Value'
        } else {
            Condition := () => OutValue > Value
            C := 'OutValue > Value'
            InverseCondition := () => OutValue < Value
            IC := 'OutValue < Value'
        }
    } else {
        if EqualTo {
            Condition := () => OutValue <= Value
            C := 'OutValue <= Value'
            InverseCondition := () => OutValue >= Value
            IC := 'OutValue >= Value'
        } else {
            Condition := () => OutValue < Value
            C := 'OutValue < Value'
            InverseCondition := () => OutValue > Value
            IC := 'OutValue > Value'
        }
    }
    i := IndexStart
    if GetNearest(1)
        return OutValue := ''
    v1 := OutValue
    Left := i
    i := IndexEnd
    if GetNearest(-1)
        return OutValue := ''
    if OutValue > v1
        BaseDirection := 1
    else
        BaseDirection := -1
    Output1('0', 'OutputValue: ' OutValue '`tv1: ' v1 '`tBaseDirection: ' BaseDirection)
    Right := i
    Direction := 1
    if GreaterThan {
        Output1('1', 'Entering GreaterThan loop')
        loop StopBinary {
            i := Right - Round((Abs(Right - Left) * 0.5), 0)
            if GetNearest(Direction) {
                if i > IndexEnd {
                    Output1('2', 'GetNearest returned true in core loop. i > IndexEnd. i: ' i)
                    return _Sequence(-1, InverseCondition, -1)
                } else {
                    Output1('3', 'GetNearest returned true in core loop. i < IndexStart. i: ' i)
                    return _Sequence(1, Condition, 0)
                }
            }
            if Value == OutValue {
                Output1('4', 'Values were equal in core loop.')
                return _HandleEqualValues()
            }
            Output1('5', 'Loop iteration performed. A_Index: ' A_Index)
            _ProcessLoopValue()
        }
        Output1('6', 'Exited core loop.')
        if Value > OutValue {
            if BaseDirection == 1 {
                AC := C
                Output3(1, C, 0)
                return _Sequence(1, Condition, 0)
            } else {
                AC := C
                Output3(2, C, 0)
                return _Sequence(-1, Condition, 0)
            }
        } else if Value < OutValue {
            if BaseDirection == 1 {
                AC := IC
                Output3(3, IC, -1)
                return _Sequence(-1, InverseCondition, -1)
            } else {
                AC := IC
                Output3(4, IC, -1)
                return _Sequence(1, InverseCondition, -1)
            }
        }
    } else {
        Output1('1', 'Entering Less than (!GreaterThan) loop')
        loop StopBinary {
            i := Right - Round((Abs(Right - Left) * 0.5), 0)
            if GetNearest(Direction) {
                if i > IndexEnd {
                    Output1('8', 'GetNearest returned true in core loop. i > IndexEnd. i: ' i)
                    return _Sequence(-1, Condition, 0)
                } else {
                    Output1('9', 'GetNearest returned true in core loop. i < IndexStart. i: ' i)
                    return _Sequence(1, InverseCondition, -1)
                }
            }
            if Value == OutValue {
                Output1('10', 'Values were equal in core loop.')
                return _HandleEqualValues()
            }
            Output1('11', 'Loop iteration performed. A_Index: ' A_Index)
            _ProcessLoopValue()
        }
        Output1('12', 'Exited core loop.')
        if Value > OutValue {
            if BaseDirection == 1 {
                AC := IC
                Output3(5, IC, -1)
                return _Sequence(1, InverseCondition, -1)
            } else {
                AC := IC
                Output3(6, IC, -1)
                return _Sequence(-1, InverseCondition, -1)
            }
        } else if Value < OutValue {
            if BaseDirection == 1 {
                AC := C
                Output3(7, C, 0)
                return _Sequence(-1, Condition, 0)
            } else {
                AC := C
                Output3(8, C, 0)
                return _Sequence(1, Condition, 0)
            }
        }
    }
    Output1('13', 'Values were equal when exiting core loop.')
    return _HandleEqualValues()

    _HandleEqualValues() {
        if EqualTo {
            if GreaterThan {
                Direction := BaseDirection * -1
            } else {
                Direction := BaseDirection
            }
            Output1('14', 'Entering HandleEqualValues, EqualTo block.')
            while Value == OutValue {
                Previous := i
                Output1('15', 'HandleEqualValues loop iteration performed. Before GetNearest. A_Index: ' A_Index)
                i += Direction
                if GetNearest(Direction)
                    break
                Output1('16', 'HandleEqualValues loop iteration performed. After GetNearest. A_Index: ' A_Index)
            }
            Output1('', 'Exiting HandleEqualValues.')
            OutValue := Arr[Previous]
            return Previous
        } else {
            if GreaterThan
                Direction := BaseDirection
            else
                Direction := BaseDirection * -1
            Output1('17', 'Entering HandleEqualValues, !EqualTo block.')
            while Value == OutValue {
                Output1('18', 'HandleEqualValues loop iteration performed. Before GetNearest. A_Index: ' A_Index)
                i += Direction
                if GetNearest(Direction) || i > IndexEnd || i < IndexStart
                    return OutValue := ''
                Output1('19', 'HandleEqualValues loop iteration performed. After GetNearest. A_Index: ' A_Index)
            }
            Output1('20', 'Exiting HandleEqualValues.')
            return i
        }
    }
    GetNearest(Direction) {
        while !Arr.Has(i) {
            i += Direction
            if i > IndexEnd || i < IndexStart {
                Output1('21', 'Exiting GetNearest due to index not found. i: ' i)
                return 1
            }
        }
        OutValue := GetValue(Arr[i])
    }
    _ProcessLoopValue() {
        if Value > OutValue {
            if BaseDirection == 1
                Direction := 1, Left := i
            else
                Direction := -1, Right := i
        } else if Value < OutValue {
            if BaseDirection == 1
                Direction := -1, Right := i
            else
                Direction := 1, Left := i
        }
    }
    /**
     * @param {Integer} ReturnWhat - 0 = The found index; -1 = The previous found index.
     */
    _Sequence(Direction, Condition, ReturnWhat) {
        Output2('22', 'Beginning sequence loop.', ReturnWhat)
        loop {
            Output2('23', 'Sequence loop iteration before GetNearest. A_Index: ' A_Index, ReturnWhat)
            if GetNearest(Direction)
                return OutValue := ''
            Output2('24', 'Sequence loop iteration after GetNearest. A_Index: ' A_Index, ReturnWhat)
            if OutValue == Value {
                Output2('25', 'Entering HandleEqualValues from Sequence.', ReturnWhat)
                return _HandleEqualValues()
            }
            if Condition() {
                Output2('26', 'Condition met.', ReturnWhat)
                if OutValue == Value
                    return i
                if ReturnWhat == -1 {
                    if IsSet(Previous) {
                        Output2('27', 'Exiting FindNext and returning Previous index: ' Previous, ReturnWhat)
                        OutValue := GetValue(Arr[Previous])
                        return Previous
                    } else {
                    Output2('28', 'Entering FindNext with Direction (' Direction ') := Direction * -1 (' (Direction * -1) ')', ReturnWhat)
                        return _FindNext(Direction * -1)
                    }
                } else {
                    Output2('29', 'Exiting Sequence loop and returning i: ' i '`tA_Index: ' A_Index, ReturnWhat)
                    return i
                }
            }
            Previous := i
            i += Direction
        }

        _FindNext(Direction) {
            loop {
                i += Direction
                if i > IndexEnd || i < IndexStart {
                    Output1('30', 'Exiting FindNext due to index not found. i: ' i)
                    return OutValue := ''
                }
                if Arr.Has(i) {
                    Output1('31', 'Returning i from FindNext: ' i)
                    OutValue := GetValue(Arr[i])
                    return i
                }
            }
        }
    }
    Output1(N, Message) {
        if IsSet(F) {
            F.Write(
                'Message Index: ' N
                '`r`nMessage: ' Message
                '`r`nCurrent Value: ' OutValue '`tInput Value: ' Value '`tCurrent index: ' i
                '`r`nLeft: ' Left '`tRight: ' Right '`tIndexEnd: ' IndexEnd '`tIndexStart: ' IndexStart
                '`r`nGT: ' GreaterThan '`tET: ' EqualTo '`tBaseDirection: ' BaseDirection '`tDirection: ' Direction
                '`r`nValid condition: ' C
                '`r`nOutValue > Value: ' (OutValue > Value)
                '`r`nOutValue < Value: ' (OutValue < Value)
                '`r`nOutValue == Value: ' (OutValue == Value)
                '`r`n`r`n'
            )
        }
    }
    Output2(N, Message, RW?) {
        if IsSet(F) {
            F.Write(
                'Message Index: ' N
                '`r`nMessage: ' Message
                '`r`nCurrent Value: ' OutValue '`tInput Value: ' Value '`tCurrent index: ' i
                '`r`nLeft: ' Left '`tRight: ' Right '`tIndexEnd: ' IndexEnd '`tIndexStart: ' IndexStart
                '`r`nGT: ' GreaterThan '`tET: ' EqualTo '`tBaseDirection: ' BaseDirection '`tDirection: ' Direction
                '`r`nOriginal condition: ' C
                '`r`nActive condition: ' AC
                '`r`nOutValue > Value: ' (OutValue > Value)
                '`r`nOutValue < Value: ' (OutValue < Value)
                '`r`nOutValue == Value: ' (OutValue == Value)
                (IsSet(RW) ? '`r`nReturnWhat: '  RW : '')
                '`r`n`r`n'
            )
        }
    }
    Output3(N, AC, RW) {
        if IsSet(F) {
            F.Write(
                'Entering Sequence ' N
                '`r`nActive condition: ' AC
                '`r`nOriginal condition: ' C
                '`r`nReturnWhat: ' RW
                '`r`n`r`n'
            )
        }
    }
}
