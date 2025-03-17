/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-QuickFind
    Author: Nich-Cebolla
    Version: 1.1.0
    License: MIT
*/

class QuickFind {
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
    static Call(Arr, Value, &OutValue?, GreaterThan := true, EqualTo := true, IndexStart := 1, IndexEnd?
    , ValueProp?, ValueKey?, ValueCallback?) {
        local i
        ; If you have a need for the binary search to cease early, set the value here.
        ; StopBinary := unset
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
                InverseCondition := () => OutValue <= Value
            } else {
                Condition := () => OutValue > Value
                InverseCondition := () => OutValue < Value
            }
        } else {
            if EqualTo {
                Condition := () => OutValue <= Value
                InverseCondition := () => OutValue >= Value
            } else {
                Condition := () => OutValue < Value
                InverseCondition := () => OutValue > Value
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
        Right := i
        Direction := 1
        if GreaterThan {
            loop StopBinary {
                i := Right - Round((Abs(Right - Left) * 0.5), 0)
                if GetNearest(Direction) {
                    if i > IndexEnd {
                        return _Sequence(-1, InverseCondition, -1)
                    } else {
                        return _Sequence(1, Condition, 0)
                    }
                }
                if Value == OutValue {
                    return _HandleEqualValues()
                }
                _ProcessLoopValue()
            }
            if Value > OutValue {
                if BaseDirection == 1 {
                    return _Sequence(1, Condition, 0)
                } else {
                    return _Sequence(-1, Condition, 0)
                }
            } else if Value < OutValue {
                if BaseDirection == 1 {
                    return _Sequence(-1, InverseCondition, -1)
                } else {
                    return _Sequence(1, InverseCondition, -1)
                }
            }
        } else {
            loop StopBinary {
                i := Right - Round((Abs(Right - Left) * 0.5), 0)
                if GetNearest(Direction) {
                    if i > IndexEnd {
                        return _Sequence(-1, Condition, 0)
                    } else {
                        return _Sequence(1, InverseCondition, -1)
                    }
                }
                if Value == OutValue {
                    return _HandleEqualValues()
                }
                _ProcessLoopValue()
            }
            if Value > OutValue {
                if BaseDirection == 1 {
                    return _Sequence(1, InverseCondition, -1)
                } else {
                    return _Sequence(-1, InverseCondition, -1)
                }
            } else if Value < OutValue {
                if BaseDirection == 1 {
                    return _Sequence(-1, Condition, 0)
                } else {
                    return _Sequence(1, Condition, 0)
                }
            }
        }
        return _HandleEqualValues()

        _HandleEqualValues() {
            if EqualTo {
                if GreaterThan {
                    Direction := BaseDirection * -1
                } else {
                    Direction := BaseDirection
                }
                while Value == OutValue {
                    Previous := i
                    i += Direction
                    if GetNearest(Direction)
                        break
                }
                OutValue := Arr[Previous]
                return Previous
            } else {
                if GreaterThan
                    Direction := BaseDirection
                else
                    Direction := BaseDirection * -1
                while Value == OutValue {
                    i += Direction
                    if GetNearest(Direction) || i > IndexEnd || i < IndexStart
                        return OutValue := ''
                }
                OutValue := Arr[i]
                return i
            }
        }
        GetNearest(Direction) {
            while !Arr.Has(i) {
                i += Direction
                if i > IndexEnd || i < IndexStart {
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
            loop {
                if GetNearest(Direction)
                    return OutValue := ''
                if OutValue == Value {
                    return _HandleEqualValues()
                }
                if Condition() {
                    if OutValue == Value {
                        OutValue := Arr[i]
                        return i
                    }
                    if ReturnWhat == -1 {
                        if IsSet(Previous) {
                            OutValue := Arr[Previous]
                            return Previous
                        } else {
                            return _FindNext(Direction * -1)
                        }
                    } else {
                        OutValue := Arr[i]
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
                        return OutValue := ''
                    }
                    if Arr.Has(i) {
                        OutValue := Arr[i]
                        return i
                    }
                }
            }
        }
    }

    /**
     * @description - A function that's compatible with `QuickFind` that can be used to search
     * an array that is sorted alphabetically for an input word. This has accuracy up to 10
     * characters. Any characters past 10 are ignored.
     * @param {String} Word - The input word.
     * @param {Boolean} [UseCache=true] - When true, word values are cached and recalled from the
     * cache. When false, word values are always calculated.
     * @returns {Float} - A number that can be used for various sorting operations.
     */
    static GetWordValue(Word, UseCache := true) {
        local n := 0
        if UseCache {
            if QuickFind.WordValueCache.Has(Word) {
                return QuickFind.WordValueCache.Get(Word)
            }
            _Process()
            QuickFind.WordValueCache.Set(Word, n)
        } else {
            _Process()
        }
        return n

        _Process() {
            for c in StrSplit(StrUpper(Word)) {
                if Ord(c) >= 123
                    n += (Ord(c) - 58) / 68 ** A_Index
                else
                    n += (Ord(c) - 32) / 68 ** A_Index
                if A_Index >= 10 ; Accuracy is lost around 10 characters.
                    break
            }
        }
    }

    /**
     * @property {BoundFunc} QuickFind.GetWordValue - Returns a function object that is compatible
     * with `QuickFind`. Used to search for a word in an array sorted alphabetically.
     */
    static GetWordValueFunc => ObjBindMethod(this, 'GetWordValue')

    /**
     * @property {Map} QuickFind.WordValueCache - A cache used by `GetWordValue`.
     */
    static WordValueCache := Map()

    class Func {

        /**
         * @description - Creates a function object that can be called repeatedly to perform
         * a search on an input array. This saves a little bit of processing overhead by initializing
         * the needed values that are normally set at the beginning of `QuickFind`, then binds them
         * to a callable object. Note:
         * - The reference count for the input array is incremented by 1. If you need to dispose
         * the array, you will have to call `Dispose` on this object to get rid of that reference.
         * Calling the function after `Dispose` results in an error.
         * - The function parameters are:
         *   - **Value** - The value to search for.
         *   - **OutValue** - A variable that will receive the value at the found index.
         * - All of the parameters are the same, except you will not pass `Value` or `OutValue` here;
         * pass them when calling the function.
         */
        static Call(Arr, GreaterThan := true, EqualTo := true, IndexStart := 1, IndexEnd?
        , ValueProp?, ValueKey?, ValueCallback?) {
            local BaseDirection, GetValue, i, Fn, Left, Right, StopBinary, v1, Value
            ; If you have a need for the binary search to cease early, set the value here.
            ; StopBinary := unset
            if !Arr.Length {
                throw Error('The array is empty.', -1)
            }
            if IsSet(ValueProp) {
                GetValue := (Item) => Item.%ValueProp%
            } else if IsSet(ValueKey) {
                GetValue := (Item) => Item[ValueKey]
            } else if IsSet(ValueCallback) {
                GetValue := ValueCallback
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
            i := IndexStart
            if _GetNearest(1)
                throw Error('The range does not contain a value.', -1)
            Left := i
            v1 := Value
            i := IndexEnd
            if _GetNearest(-1)
                throw Error('The range contains only one value.', -1)
            if Value > v1
                BaseDirection := 1
            else
                BaseDirection := -1
            Right := i
            ObjAddRef(ObjPtr(Arr))
            ObjSetBase(Fn := { ObjPtr: ObjPtr(Arr) }, QuickFind.Func.Prototype)
            Fn.DefineProp('Call', { Call: Call.Bind(BaseDirection, EqualTo, GetValue, GreaterThan
            , IndexEnd, IndexStart, Left, Right, StopBinary) })
            return Fn

            _GetNearest(Direction) {
                while !Arr.Has(i) {
                    i += Direction
                    if i > IndexEnd || i < IndexStart {
                        return 1
                    }
                }
                Value := GetValue(Arr[i])
            }

            Call(BaseDirection, EqualTo, GetValue, GreaterThan, IndexEnd, IndexStart, Left, Right
            , StopBinary, Self, Value, &OutValue?) {
                local Arr := ObjFromPtrAddRef(Self.ObjPtr)
                , Condition
                , Direction := 1
                , i := IndexStart
                , InverseCondition
                if IsObject(Value) {
                    Value := GetValue(Value)
                }
                if GreaterThan {
                    if EqualTo {
                        Condition := () => OutValue >= Value
                        InverseCondition := () => OutValue <= Value
                    } else {
                        Condition := () => OutValue > Value
                        InverseCondition := () => OutValue < Value
                    }
                    loop StopBinary {
                        i := Right - Round((Abs(Right - Left) * 0.5), 0)
                        if GetNearest(Direction) {
                            if i > IndexEnd {
                                return _Sequence(-1, InverseCondition, -1)
                            } else {
                                return _Sequence(1, Condition, 0)
                            }
                        }
                        if Value == OutValue {
                            return _HandleEqualValues()
                        }
                        _ProcessLoopValue()
                    }
                    if Value > OutValue {
                        if BaseDirection == 1 {
                            return _Sequence(1, Condition, 0)
                        } else {
                            return _Sequence(-1, Condition, 0)
                        }
                    } else if Value < OutValue {
                        if BaseDirection == 1 {
                            return _Sequence(-1, InverseCondition, -1)
                        } else {
                            return _Sequence(1, InverseCondition, -1)
                        }
                    }
                } else {
                    if EqualTo {
                        Condition := () => OutValue <= Value
                        InverseCondition := () => OutValue >= Value
                    } else {
                        Condition := () => OutValue < Value
                        InverseCondition := () => OutValue > Value
                    }
                    loop StopBinary {
                        i := Right - Round((Abs(Right - Left) * 0.5), 0)
                        if GetNearest(Direction) {
                            if i > IndexEnd {
                                return _Sequence(-1, Condition, 0)
                            } else {
                                return _Sequence(1, InverseCondition, -1)
                            }
                        }
                        if Value == OutValue {
                            return _HandleEqualValues()
                        }
                        _ProcessLoopValue()
                    }
                    if Value > OutValue {
                        if BaseDirection == 1 {
                            return _Sequence(1, InverseCondition, -1)
                        } else {
                            return _Sequence(-1, InverseCondition, -1)
                        }
                    } else if Value < OutValue {
                        if BaseDirection == 1 {
                            return _Sequence(-1, Condition, 0)
                        } else {
                            return _Sequence(1, Condition, 0)
                        }
                    }
                }
                return _HandleEqualValues()

                _HandleEqualValues() {
                    if EqualTo {
                        if GreaterThan {
                            Direction := BaseDirection * -1
                        } else {
                            Direction := BaseDirection
                        }
                        while Value == OutValue {
                            Previous := i
                            i += Direction
                            if GetNearest(Direction)
                                break
                        }
                        OutValue := Arr[Previous]
                        return Previous
                    } else {
                        if GreaterThan
                            Direction := BaseDirection
                        else
                            Direction := BaseDirection * -1
                        while Value == OutValue {
                            i += Direction
                            if GetNearest(Direction) || i > IndexEnd || i < IndexStart
                                return OutValue := ''
                        }
                        OutValue := Arr[i]
                        return i
                    }
                }
                GetNearest(Direction) {
                    while !Arr.Has(i) {
                        i += Direction
                        if i > IndexEnd || i < IndexStart {
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
                    loop {
                        if GetNearest(Direction)
                            return OutValue := ''
                        if OutValue == Value {
                            return _HandleEqualValues()
                        }
                        if Condition() {
                            if OutValue == Value {
                                OutValue := Arr[i]
                                return i
                            }
                            if ReturnWhat == -1 {
                                if IsSet(Previous) {
                                    OutValue := Arr[Previous]
                                    return Previous
                                } else {
                                    return _FindNext(Direction * -1)
                                }
                            } else {
                                OutValue := Arr[i]
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
                                return OutValue := ''
                            }
                            if Arr.Has(i) {
                                OutValue := Arr[i]
                                return i
                            }
                        }
                    }
                }
            }
        }

        /**
         * @description - Calls `QuickFind` using the preset values. See the parameter descriptions
         * above `QuickFind.Call` for full details of the parameters.
         * @param {Number|Object} Value - The value to search for.
         * @param {VarRef} [OutValue] - A variable that will receive the value at the found index.
         * @returns {Integer} - The index of the value that satisfies the condition.
         */
        Call(Value, &OutValue?) {
            ; This is overridden by the constructor.
        }

        /**
         * @description - Releases the reference to the array. Calling the function after `Dispose`
         * results in an error.
         */
        Dispose() {
            Ptr := this.ObjPtr
            this.DeleteProp('ObjPtr')
            ObjRelease(Ptr)
            this.DefineProp('Call', { Call: ThrowError })
            ThrowError(*) {
                err := Error('This object has been disposed.', -2)
                err.What := Type(this) '.Prototype.Call'
                throw err
            }
        }
    }
}

