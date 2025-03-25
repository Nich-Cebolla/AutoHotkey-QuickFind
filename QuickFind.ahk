/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-QuickFind
    Author: Nich-Cebolla
    Version: 1.1.0
    License: MIT
*/

class QuickFind {
    static __New() {
        if this.Prototype.__Class == 'QuickFind' {
            this.WordValueCache := Map()
            this.WordValueCache.CaseSense := false
        }
    }


    ;@region Call
    /**
     * @description - Searches an array for the index which contains the first value that satisfies
     * the condition relative to the input value. This function has these characteristics:
     * - The array is assumed to be in order of value.
     * - The array may have unset indices as long as every set index is in order.
     * - Items may be objects - set the relevant parameter of `ValueProp`, `ValueKey`, or `ValueCallback`.
     * - `QuickFind` determines the search direction internally. The search direction is the inverse
     * direction from
     * @param {Array} Arr - The array to search.
     * @param {Number|Object} Value - The value to search for. When the values in the array are objects,
     * `Value` can be an object as well as long as the numerical value is accessed using the same
     * accessor as the items. However, this value is not required to be an object when the items are;
     * it may be a number regardless of what type of items are in the array. The inverse is not
     * true; `Value` cannot be an object when the items are not objects.
     * @param {VarRef} [OutValue] - A variable that will receive the value at the found index.
     * @param {Boolean} [GreaterThan=true] - If true, the function searches for the first index with a
     * value that is greater than the input value. If false, the function searches for the first index
     * with a value that is less than the input value.
     * @param {Boolean} [EqualTo=true] - If true, the condition includes equality. If false, the
     * condition is strictly greater than or less than.
     * @param {Number} [IndexStart=1] - The index to start the search at.
     * @param {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the
     * array is used.
     * @param {String} [ValueProp] - The property to use when comparing objects
     * @param {String} [ValueKey] - The key to use when comparing objects.
     * @param {Func} [ValueCallback] - The function to use when comparing objects.
     * The function should accept the object as its only parameter, and return a number.
     * @returns {Integer} - The index of the value that satisfies the condition.
     */
    static Call(Arr, Value, &OutValue?, GreaterThan := true, EqualTo := true, IndexStart := 1, IndexEnd?
    , ValueProp?, ValueKey?, ValueCallback?) {
        local i, GetNearest, Direction, ItemValue
        if !Arr.Length {
            throw Error('The array is empty.', -1)
        }
        if !IsSet(IndexEnd) {
            IndexEnd := Arr.Length
        }
        if IndexEnd <= IndexStart {
            throw Error('The end index is less than or equal to the start index.'
            , -1, 'IndexEnd: ' IndexEnd '`tIndexStart: ' IndexStart)
        }
        if IsSet(ValueProp) {
            GetValue := (Item) => Item.%ValueProp%
        } else if IsSet(ValueKey) {
            GetValue := (Item) => Item[ValueKey]
        } else if IsSet(ValueCallback) {
            GetValue := ValueCallback
        } else {
            GetValue := (Item) => Item
        }
        if IsObject(Value) {
            Value := GetValue(Value)
        }
        StopBinary := 0
        R := IndexEnd - IndexStart + 1
        loop {
            if R * 0.5 ** (StopBinary + 1) * 14 <= 27 {
                break
            }
            StopBinary++
            if A_Index > 100 {
                throw Error('When attempting to calculate ``StopBinary``, the loop iterated for '
                A_Index ' iterations. This is either due to an unrealistically large input range,'
                ' or error in the implementation.', -1, 'Input range: ' IndexEnd - IndexStart + 1)
            }
        }
        i := IndexStart
        ; A return value indicates the array had no set indices.
        if _GetNearest1() {
            return
        }
        LeftV := ItemValue
        Left := i
        i := IndexEnd
        if _GetNearest2() {
            if ItemValue == Value {
                return _HandleEqualValues()
            }
            return
        }
        if ItemValue > LeftV {
            ; Values are ascending. We can short-circuit the search if the input value is out
            ; of range.
            if Value > ItemValue || Value < LeftV {
                return
            }
            BaseDirection := 1
            ProcessLoopValue := _ProcessLoopValue1
        } else if ItemValue < LeftV {
            ; Value are descending.
            if Value < ItemValue || Value > LeftV {
                return
            }
            BaseDirection := -1
            ProcessLoopValue := _ProcessLoopValue2
        } else {
            ; Input range is small.
            k := 0
            while !Arr.Has(++k) {
                continue
            }
            v1 := GetValue(Arr[k])
            k := Arr.Length + 1
            while !Arr.Has(--k) {
                continue
            }
            if GetValue(Arr[k]) > v1 {
                BaseDirection := 1
                ProcessLoopValue := _ProcessLoopValue1
            } else {
                BaseDirection := -1
                ProcessLoopValue := _ProcessLoopValue2
            }
        }
        Right := i
        GetNearest := _GetNearest1
        if GreaterThan {
            if EqualTo {
                Condition := () => ItemValue >= Value
                InverseCondition := () => ItemValue <= Value
            } else {
                Condition := () => ItemValue > Value
                InverseCondition := () => ItemValue < Value
            }
            loop StopBinary {
                i := Right - Round((Abs(Right - Left) * 0.5), 0)
                if GetNearest() {
                    if i > IndexEnd {
                        return _Sequence(-1, InverseCondition, -1)
                    } else {
                        return _Sequence(1, Condition, 0)
                    }
                }
                if Value == ItemValue {
                    return _HandleEqualValues()
                }
                ProcessLoopValue()
            }
            if Value > ItemValue {
                if BaseDirection == 1 {
                    return _Sequence(1, Condition, 0)
                } else {
                    return _Sequence(-1, Condition, 0)
                }
            } else if Value < ItemValue {
                if BaseDirection == 1 {
                    return _Sequence(-1, InverseCondition, -1)
                } else {
                    return _Sequence(1, InverseCondition, -1)
                }
            }
        } else {
            if EqualTo {
                Condition := () => ItemValue <= Value
                InverseCondition := () => ItemValue >= Value
            } else {
                Condition := () => ItemValue < Value
                InverseCondition := () => ItemValue > Value
            }
            loop StopBinary {
                i := Right - Round((Abs(Right - Left) * 0.5), 0)
                if GetNearest() {
                    if i > IndexEnd {
                        return _Sequence(-1, Condition, 0)
                    } else {
                        return _Sequence(1, InverseCondition, -1)
                    }
                }
                if Value == ItemValue {
                    return _HandleEqualValues()
                }
                ProcessLoopValue()
            }
            if Value > ItemValue {
                if BaseDirection == 1 {
                    return _Sequence(1, InverseCondition, -1)
                } else {
                    return _Sequence(-1, InverseCondition, -1)
                }
            } else if Value < ItemValue {
                if BaseDirection == 1 {
                    return _Sequence(-1, Condition, 0)
                } else {
                    return _Sequence(1, Condition, 0)
                }
            }
        }
        return _HandleEqualValues()

        _HandleEqualValues() {
            local GetNearest
            if EqualTo {
                if GreaterThan {
                    Direction := BaseDirection * -1
                } else {
                    Direction := BaseDirection
                }
                GetNearest := _GetNearestFunc(Direction)
                while Value == ItemValue {
                    Previous := i
                    i += Direction
                    if GetNearest() {
                        break
                    }
                }
                ; Direction *= -1
                OutValue := Arr[Previous]
                return Previous
            } else {
                if GreaterThan {
                    Direction := BaseDirection
                } else {
                    Direction := BaseDirection * -1
                }
                GetNearest := _GetNearestFunc(Direction)
                while Value == ItemValue {
                    i += Direction
                    if GetNearest() || i > IndexEnd || i < IndexStart {
                        return
                    }
                }
                OutValue := Arr[i]
                return i
            }
        }
        _GetNearestFunc(Direction) {
            switch Direction {
                case 1: return _GetNearest1
                case -1: return _GetNearest2
                default: throw ValueError('Unexpected direction.', -1, Direction)
            }
        }
        _GetNearest1() {
            loop IndexEnd - i + 1 {
                if Arr.Has(i) {
                    ItemValue := GetValue(Arr[i])
                    return
                }
                i++
            }
            return 1
        }
        _GetNearest2() {
            loop i - IndexStart + 1 {
                if Arr.Has(i) {
                    ItemValue := GetValue(Arr[i])
                    return
                }
                i--
            }
            return 1
        }

        _ProcessLoopValue1() {
            if Value > ItemValue {
                GetNearest := _GetNearest1
                Left := i
            } else if Value < ItemValue {
                GetNearest := _GetNearest2
                Right := i
            }
        }
        _ProcessLoopValue2() {
            if Value > ItemValue {
                GetNearest := _GetNearest2
                Right := i
            } else if Value < ItemValue {
                GetNearest := _GetNearest1
                Left := i
            }
        }
        /**
         * @param {Integer} ReturnWhat - 0 = The found index; -1 = The previous found index.
         */
        _Sequence(Direction, Condition, ReturnWhat) {
            local GetNearest := _GetNearestFunc(Direction)
            loop {
                if GetNearest()
                    return
                if ItemValue == Value {
                    return _HandleEqualValues()
                }
                if Condition() {
                    if ItemValue == Value {
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
                        return
                    }
                    if Arr.Has(i) {
                        OutValue := Arr[i]
                        return i
                    }
                }
            }
        }
    }
    ;@endregion



    ;@region EqualTo
    /**
     * @description - Performs a binary search on an array to find one or more indices that contain
     * the input value.
     */
    static EqualTo(Arr, Value, IndexStart := 1, IndexEnd?, SearchDirection := 1
    , ValueProp?, ValueKey?, ValueCallback?) {
        local i, ItemValue, GetNearest
        if !Arr.Length {
            throw Error('The array is empty.', -1)
        }
        if !IsSet(IndexEnd) {
            IndexEnd := Arr.Length
        }
        if IndexEnd <= IndexStart {
            throw Error('The end index is less than or equal to the start index.'
            , -1, 'IndexEnd: ' IndexEnd '`tIndexStart: ' IndexStart)
        }
        StopBinary := 0
        R := IndexEnd - IndexStart + 1
        loop {
            if R * 0.5 ** (StopBinary + 1) * 14 <= 27 {
                break
            }
            StopBinary++
            if A_Index > 100 {
                throw Error('When attempting to calculate ``StopBinary``, the loop iterated for '
                A_Index ' iterations. This is either due to an unrealistically large input range,'
                ' or error in the implementation.', -1, 'Input range: ' IndexEnd - IndexStart + 1)
            }
        }
        if IsSet(ValueProp) {
            GetValue := (Item) => Item.%ValueProp%
        } else if IsSet(ValueKey) {
            GetValue := (Item) => Item[ValueKey]
        } else if IsSet(ValueCallback) {
            GetValue := ValueCallback
        } else {
            GetValue := (Item) => Item
        }
        if IsObject(Value) {
            Value := GetValue(Value)
        }
        if SearchDirection > 0 {
            ProcessLoopValue := _ProcessLoopValue1
        } else {
            ProcessLoopValue := _ProcessLoopValue2
        }
        GetNearest := _GetNearest1
        loop StopBinary {
            i := IndexEnd - Round((Abs(IndexEnd - IndexStart) * 0.5), 0)
            if GetNearest() {
                return _Sequence()
            }
            if Value == ItemValue {
                return _HandleEqualValues()
            }
            ProcessLoopValue()
        }
        return _Sequence()

        _HandleEqualValues(SearchLeft := true) {
            Result := { Start: i, End: i }
            Start := i
            if SearchLeft {
                loop Start - IndexStart {
                    i--
                    if Arr.Has(i) {
                        if GetValue(Arr[i]) == Value {
                            Result.Start := i
                        } else {
                            break
                        }
                    }
                }
                i := Start
            }
            loop IndexEnd - Start {
                i++
                if Arr.Has(i) {
                    if GetValue(Arr[i]) == Value {
                        Result.End := i
                    } else {
                        break
                    }
                }
            }
            return Result
        }
        _GetNearest1() {
            loop IndexEnd - i + 1 {
                if Arr.Has(i) {
                    ItemValue := GetValue(Arr[i])
                    return
                }
                i++
            }
            return 1
        }
        _GetNearest2() {
            loop i - IndexStart + 1 {
                if Arr.Has(i) {
                    ItemValue := GetValue(Arr[i])
                    return
                }
                i--
            }
            return 1
        }
        _ProcessLoopValue1() {
            if Value > ItemValue {
                GetNearest := _GetNearest1
                IndexStart := i
            } else if Value < ItemValue {
                GetNearest := _GetNearest2
                IndexEnd := i
            }
        }
        _ProcessLoopValue2() {
            if Value > ItemValue {
                GetNearest := _GetNearest2
                IndexEnd := i
            } else if Value < ItemValue {
                GetNearest := _GetNearest1
                IndexStart := i
            }
        }
        _Sequence() {
            i := IndexStart - 1
            loop IndexEnd - IndexStart + 1 {
                i++
                if Arr.Has(i) && GetValue(Arr[i]) == Value {
                    return _HandleEqualValues(false)
                }
            }
            return ''
        }
    }
    ;@endregion



    ;@region WordValue
    /**
     * @description - A function that's compatible with `QuickFind` that can be used to search
     * an array that is sorted alphabetically for an input word. This has (a degree of) accuracy up
     * to 10 characters. Any characters past 10 are ignored.
     * @param {String} Word - The input word.
     * @param {Boolean} [UseCache=true] - When true, word values are cached and recalled from the
     * cache. When false, word values are always calculated.
     * @returns {Float} - A number that can be used for various sorting operations.
     */
    static GetWordValue(Word, UseCache := true) {
        static Cache := QuickFind.WordValueCache
        local n := 0
        if UseCache {
            if Cache.Has(Word) {
                return Cache.Get(Word)
            }
            _Process()
            Cache.Set(Word, n)
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
                if A_Index >= 10 ; Accuracy is completely lost around 10 characters.
                    break
            }
        }
    }
    ;@endregion



    /**
     * @property {Map} QuickFind.WordValueCache - A cache used by `GetWordValue`. This gets
     * overridden at runtime.
     */
    static WordValueCache := ''


    ;@region Func
    class Func {



        ;@region Func.Call
        /**
         * @description - Creates a function object that can be called repeatedly to perform
         * a search on an input array. This saves a little bit of processing overhead by initializing
         * the needed values that are normally set at the beginning of `QuickFind`, then returns
         * a closure that maintains the calculated values.
         * - The reference count for the input array is incremented by 1. If you need to dispose
         * the array, you will have to call `Dispose` on this object to get rid of that reference.
         * Calling the function after `Dispose` results in an error.
         * - The function parameters are:
         *   - **Value** - The value to search for.
         *   - **OutValue** - A variable that will receive the value at the found index.
         * @example
            Arr := [1, 5, 12, 19, 44, 101, 209, 209, 230, 1991]
            Finder := QuickFind.Func(Arr)
            Index := Finder(12, &Value)
            OutputDebug(Index) ; 3
            OutputDebug(Value) ; 12
            ; When finished
            Finder.Dispose()
            Index := Finder(44, &Value) ; Error: This object has been disposed.
         * @
         * @param {Array} Arr - The array to search.
         * @param {Boolean} [GreaterThan=true] - If true, the function searches for the first index with a
         * value that is greater than the input value. If false, the function searches for the first index
         * with a value that is less than the input value.
         * @param {Boolean} [EqualTo=true] - If true, the condition includes equality. If false, the
         * condition is strictly greater than or less than.
         * @param {Number} [IndexStart=1] - The index to start the search at.
         * @param {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the
         * array is used.
         * @param {String} [ValueProp] - The property to use when comparing objects
         * @param {String} [ValueKey] - The key to use when comparing objects.
         * @param {Func} [ValueCallback] - The function to use when comparing objects.
         * The function should accept the object as its only parameter, and return a number.
         * @returns {QuickFind.Func} - A function object that can be called repeatedly to perform
         * a search on an input array.
         */
        static Call(Arr, GreaterThan := true, EqualTo := true, IndexStart := 1, IndexEnd?
        , ValueProp?, ValueKey?, ValueCallback?) {
            if !Arr.Length {
                throw Error('The array is empty.', -1)
            }
            if !IsSet(IndexEnd) {
                IndexEnd := Arr.Length
            }
            if IndexEnd <= IndexStart {
                throw Error('The end index is less than or equal to the start index.'
                , -1, 'IndexEnd: ' IndexEnd '`tIndexStart: ' IndexStart)
            }
            ObjSetBase(Fn := { ObjPtr: ObjPtr(Arr) }, QuickFind.Func.Prototype)
            ObjAddRef(ObjPtr(Arr))
            Fn.DefineProp('Call', { Call: _GetClosure() })
            return Fn

            _GetClosure() {
                local Arr, Condition, InverseCondition, GetValue, Left, LeftValue, Right, RightValue
                , HandleEqualValues, InputValue, ItemValue, ProcessLoopValue, StopBinary
                , HEV_Direction, R, i
                , Params_Seq_SR, Params_Seq_Loop_GT, Params_Seq_Loop_LT, Params_SEQ_GT, Params_Seq_LT
                , Param_HEV_GV, Param_Loop_GV := true
                if IsSet(ValueProp) {
                    GetValue := (Item) => Item.%ValueProp%
                } else if IsSet(ValueKey) {
                    GetValue := (Item) => Item[ValueKey]
                } else if IsSet(ValueCallback) {
                    GetValue := ValueCallback
                    ValueCallback := ''
                } else {
                    GetValue := (Item) => Item
                }
                i := IndexStart
                if _GetNearest(true) {
                    throw Error('The range does not contain a value.', -1)
                }
                LeftValue := ItemValue
                Left := i
                i := IndexEnd
                if _GetNearest(false) {
                    throw Error('The range contains only one value.', -1)
                }
                RightValue := ItemValue
                Right := i
                StopBinary := 0
                R := Right - Left + 1
                loop {
                    if R * 0.5 ** (StopBinary + 1) * 14 <= 27
                        break
                    StopBinary++
                    if A_Index > 100
                        throw Error('When attempting to calculate ``StopBinary``, the loop iterated for '
                        A_Index ' iterations. This is either due to an unrealistically large input range,'
                        ' or error in the implementation.', -1, 'Input range: ' IndexEnd - IndexStart + 1)
                }
                if GreaterThan {
                    ; SR - "SmallRange"
                    ; SR is used when binary search is skipped due to the input range being small.
                    Params_Seq_SR := ['', Condition, 0]
                    ; "Loop" - in the looop portion of the function
                    ; "GT" - `i > IndexEnd = true` at the time the function evalutes it.
                    Params_Seq_Loop_GT := [-1, InverseCondition, -1]
                    Params_Seq_Loop_LT := [1, Condition, 0]
                    if EqualTo {
                        Condition := () => ItemValue >= InputValue
                        InverseCondition := () => ItemValue <= InputValue
                    } else {
                        Condition := () => ItemValue > InputValue
                        InverseCondition := () => ItemValue < InputValue
                    }
                } else {
                    Params_Seq_SR := ['', InverseCondition, -1]
                    Params_Seq_Loop_GT := [-1, Condition, 0]
                    Params_Seq_Loop_LT := [1, InverseCondition, -1]
                    if EqualTo {
                        Condition := () => ItemValue <= InputValue
                        InverseCondition := () => ItemValue >= InputValue
                    } else {
                        Condition := () => ItemValue < InputValue
                        InverseCondition := () => ItemValue > InputValue
                    }
                }
                if RightValue > LeftValue {
                    ; The array is sorted in ascending order.
                    ProcessLoopValue := _ProcessLoopValue1
                    Params_Seq_SR[1] := 1
                    if GreaterThan {
                        ; The direction used in `_HandleEqualValues()`
                        HEV_Direction := 1
                        Params_Seq_GT := [1, Condition, 0]
                        Params_Seq_LT := [-1, InverseCondition, -1]
                    } else {
                        HEV_Direction := -1
                        Params_Seq_GT := [1, InverseCondition, -1]
                        Params_Seq_LT := [-1, Condition, 0]
                    }
                } else {
                    ; The array is sorted in descending order.
                    ProcessLoopValue := _ProcessLoopValue2
                    Params_Seq_SR[1] := -1
                    if GreaterThan {
                        HEV_Direction := -1
                        Params_Seq_GT := [-1, Condition, 0]
                        Params_Seq_LT := [1, InverseCondition, -1]
                    } else {
                        HEV_Direction := 1
                        Params_Seq_GT := [-1, InverseCondition, -1]
                        Params_Seq_LT := [1, Condition, 0]
                    }
                }
                if EqualTo {
                    HEV_Direction *= -1
                    HandleEqualValues := _HandleEqualValues1
                } else {
                    HandleEqualValues := _HandleEqualValues2
                }
                ; The value passed to `_GetNearest` within `HandleEqualValues`
                Param_HEV_GN := HEV_Direction > 0
                ; These are no longer needed
                GreaterThan := EqualTo := IndexStart := IndexEnd := R := i := unset

                return Call

                Call(Self, Value, &OutValue?) {
                    Arr := ObjFromPtrAddRef(Self.ObjPtr)
                    InputValue := IsObject(Value) ? GetValue(Value) : Value
                    if !StopBinary {
                        return _Sequence(Params_Seq_SR)
                    }
                    loop StopBinary {
                        i := Right - Round((Abs(Right - Left) * 0.5), 0)
                        if _GetNearest(Param_Loop_GV) {
                            if i > IndexEnd {
                                return _Sequence(Params_Seq_Loop_GT)
                            } else {
                                return _Sequence(Params_Seq_Loop_LT)
                            }
                        }
                        if InputValue == ItemValue {
                            return HandleEqualValues()
                        }
                        ProcessLoopValue()
                    }
                    if InputValue > ItemValue {
                        return _Sequence(Params_SEQ_GT)
                    } else if InputValue < ItemValue {
                        return _Sequence(Params_Seq_LT)
                    }

                    _Sequence(Params) {
                        loop {
                            if _GetNearest(Param_HEV_GN) {
                                return OutValue := ''
                            }
                            if ItemValue == InputValue {
                                return HandleEqualValues()
                            }
                            ; `Condition()`
                            if Params[2]() {
                                if ItemValue == InputValue {
                                    OutValue := Arr[i]
                                    return i
                                }
                                ; An indicator to return the current index (0) or the previous index (-1)
                                if Params[3] == -1 {
                                    if IsSet(Previous) {
                                        OutValue := Arr[Previous]
                                        return Previous
                                    } else {
                                        loop {
                                            ; Increment direction
                                            i += Params[1]
                                            if i > Right || i < Left {
                                                return OutValue := ''
                                            }
                                            if Arr.Has(i) {
                                                OutValue := Arr[i]
                                                return i
                                            }
                                        }
                                    }
                                } else {
                                    OutValue := Arr[i]
                                    return i
                                }
                            }
                            Previous := i
                            i += Params[1]
                        }
                    }
                }

                _HandleEqualValues1() {
                    loop Right - i {
                        Previous := i
                        i += HEV_Direction
                        if _GetNearest(Param_HEV_GV) {
                            break
                        }
                    }
                    OutValue := Arr[Previous]
                    return Previous
                }
                _HandleEqualValues2() {
                    loop i - Left + 1 {
                        if _GetNearest(Param_HEV_GV) || i > Right || i < Left {
                            return ItemValue := ''
                        }
                        i += HEV_Direction
                    }
                    OutValue := Arr[i]
                    return i
                }
                _GetNearest(LeftToRight) {
                    if LeftToRight {
                        loop Right - i + 1 {
                            if Arr.Has(i) {
                                ItemValue := GetValue(Arr[i])
                                return
                            }
                            i++
                        }
                    } else {
                        loop i - Left + 1 {
                            if Arr.Has(i) {
                                ItemValue := GetValue(Arr[i])
                                return
                            }
                            i--
                        }
                    }
                    return 1
                }
                _ProcessLoopValue1() {
                    if InputValue > ItemValue {
                        Left := i
                        LeftValue := ItemValue
                        Param_Loop_GV := true
                    } else if InputValue < ItemValue {
                        Right := i
                        RightValue := ItemValue
                        Param_Loop_GV := false
                    }
                }
                _ProcessLoopValue2() {
                    if InputValue > ItemValue {
                        Right := i
                        RightValue := ItemValue
                        Param_Loop_GV := false
                    } else if InputValue < ItemValue {
                        Left := i
                        LeftValue := ItemValue
                        Param_Loop_GV := true
                    }
                }
            }
        }
        ;@endregion



        ; Currently untested

        ; ;@region Func.EqualTo
        ; static EqualTo(Arr, IndexStart := 1, IndexEnd?, ValueProp?, ValueKey?, ValueCallback?) {
        ;     local i, ItemValue, v1, StopBinary, GetValue, Condition
        ;     ; If you have a need for the binary search to cease early, set the value here.
        ;     ; StopBinary := unset
        ;     if !Arr.Length {
        ;         throw Error('The array is empty.', -1)
        ;     }
        ;     if !IsSet(IndexEnd) {
        ;         IndexEnd := Arr.Length
        ;     }
        ;     if IndexEnd <= IndexStart {
        ;         throw Error('The end index is less than or equal to the start index.'
        ;         , -1, 'IndexEnd: ' IndexEnd '`tIndexStart: ' IndexStart)
        ;     }
        ;     if !IsSet(StopBinary) {
        ;         StopBinary := 0, R := IndexEnd - IndexStart + 1
        ;         loop {
        ;             if R * 0.5 ** (StopBinary + 1) * 14 <= 27 {
        ;                 break
        ;             }
        ;             StopBinary++
        ;             if A_Index > 100 {
        ;                 throw Error('When attempting to calculate ``StopBinary``, the loop iterated for '
        ;                 A_Index ' iterations. This is either due to an unrealistically large input range,'
        ;                 ' or error in the implementation.', -1, 'Input range: ' IndexEnd - IndexStart + 1)
        ;             }
        ;         }
        ;     }
        ;     if IsSet(ValueProp) {
        ;         GetValue := (Item) => Item.%ValueProp%
        ;     } else if IsSet(ValueKey) {
        ;         GetValue := (Item) => Item[ValueKey]
        ;     } else if IsSet(ValueCallback) {
        ;         GetValue := ValueCallback
        ;     } else {
        ;         GetValue := (Item) => Item
        ;     }
        ;     i := IndexStart
        ;     if _GetNearest(1) {
        ;         return ''
        ;     }
        ;     v1 := ItemValue
        ;     Left := i
        ;     i := IndexEnd
        ;     if _GetNearest(-1) {
        ;         return ItemValue == v1 ? Left : ''
        ;     }
        ;     Condition := ItemValue > v1 ? 1 : -1
        ;     Right := i
        ;     ObjAddRef(ObjPtr(Arr))
        ;     ObjSetBase(Fn := { ObjPtr: ObjPtr(Arr) }, QuickFind.Func.Prototype)
        ;     Fn.DefineProp('Call', { Call: Call.Bind(Condition, GetValue, Left, Right, StopBinary) })
        ;     return Fn

        ;     _GetNearest(Direction) {
        ;         if Direction == 1 {
        ;             loop IndexEnd - i + 1 {
        ;                 if Arr.Has(i) {
        ;                     ItemValue := GetValue(Arr[i])
        ;                     return
        ;                 }
        ;                 i++
        ;             }
        ;         } else if Direction == -1 {
        ;             loop i - IndexStart + 1 {
        ;                 if Arr.Has(i) {
        ;                     ItemValue := GetValue(Arr[i])
        ;                     return
        ;                 }
        ;                 i--
        ;             }
        ;         } else {
        ;             throw ValueError('Unexpected ``Direction``.', -1, Direction)
        ;         }
        ;         return 1
        ;     }

        ;     Call(Condition, GetValue, Left, Right, StopBinary, Self, Value) {
        ;         local Arr := ObjFromPtrAddRef(Self.ObjPtr)
        ;         , i := Left
        ;         , ItemValue
        ;         , ProcessLoopValue := Condition == 1 ? _ProcessLoopValue1 : _ProcessLoopValue2

        ;         if IsObject(Value) {
        ;             Value := GetValue(Value)
        ;         }
        ;         GetNearest := _GetNearest1
        ;         loop StopBinary {
        ;             i := Right - Round((Abs(Right - Left) * 0.5), 0)
        ;             if GetNearest() {
        ;                 if i > IndexEnd {
        ;                     Right := IndexEnd
        ;                 } else {
        ;                     Left := IndexStart
        ;                 }
        ;                 return _Sequence()
        ;             }
        ;             if Value == ItemValue {
        ;                 return _HandleEqualValues()
        ;             }
        ;             ProcessLoopValue()
        ;         }
        ;         return _Sequence()

        ;         _HandleEqualValues(SearchLeft := true) {
        ;             Result := { Start: i, End: i }
        ;             Start := i
        ;             if SearchLeft {
        ;                 loop Start - IndexStart {
        ;                     i--
        ;                     if Arr.Has(i) {
        ;                         if GetValue(Arr[i]) == Value {
        ;                             Result.Start := i
        ;                         } else {
        ;                             break
        ;                         }
        ;                     }
        ;                 }
        ;                 i := Start
        ;             }
        ;             loop IndexEnd - Start {
        ;                 i++
        ;                 if Arr.Has(i) {
        ;                     if GetValue(Arr[i]) == Value {
        ;                         Result.End := i
        ;                     } else {
        ;                         break
        ;                     }
        ;                 }
        ;             }
        ;             return Result.Start == Result.End ? Result.Start : Result
        ;         }
        ;         _GetNearest1() {
        ;             loop IndexEnd - i + 1 {
        ;                 if Arr.Has(i) {
        ;                     ItemValue := GetValue(Arr[i])
        ;                     return
        ;                 }
        ;                 i++
        ;             }
        ;             return 1
        ;         }
        ;         _GetNearest2() {
        ;             loop i - IndexStart + 1 {
        ;                 if Arr.Has(i) {
        ;                     ItemValue := GetValue(Arr[i])
        ;                     return
        ;                 }
        ;                 i--
        ;             }
        ;             return 1
        ;         }
        ;         _ProcessLoopValue1() {
        ;             if Value > ItemValue {
        ;                 GetNearest := _GetNearest1
        ;                 Left := i
        ;             } else if Value < ItemValue {
        ;                 GetNearest := _GetNearest2
        ;                 Right := i
        ;             }
        ;         }
        ;         _ProcessLoopValue2() {
        ;             if Value > ItemValue {
        ;                 GetNearest := _GetNearest2
        ;                 Right := i
        ;             } else if Value < ItemValue {
        ;                 GetNearest := _GetNearest1
        ;                 Left := i
        ;             }
        ;         }
        ;         _Sequence() {
        ;             i := Left - 1
        ;             loop Right - Left + 1 {
        ;                 i++
        ;                 if Arr.Has(i) && GetValue(Arr[i]) == Value {
        ;                     return _HandleEqualValues(false)
        ;                 }
        ;             }
        ;             return ''
        ;         }
        ;     }
        ; }
        ; ;@endregion



        ;@region Prototype
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
        ;@endregion
    }
    ;@endregion
}

