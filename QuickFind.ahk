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
     * - Items may be objects - set `ValueCallback` to return the item value.
     * @example
        MyArr := [ { prop: 1 }, { prop: 22 }, { prop: 1776 } ]
        AccessorFunc(Item, *) {
            return Item.prop
        }
        MsgBox(QuickFind(MyArr, 22, , , , , AccessorFunc)) ; 2
     * @
     * - `QuickFind` determines the search direction internally to allow you to make a decision based
     * on whether you want to find the next greatest or next lowest value. If search direction is
     * relevant to your script or function, the direction is defined as:
     *   - When `Condition` is ">" or ">=", the search direction is the the same as the direction of ascent.
     *   - When `Condition` is "<" or "<=", the search direction is the inverse of the direction of ascent.
     *   - If all of the set indices within the array contain the same value, and that value
     * satisfies the condition, and at least one set index falls between `IndexStart` and `IndexEnd`,
     * then the function defaults to returning the first set index between `IndexStart` and `IndexEnd`
     * from left-to-right.
     * @param {Array} Arr - The array to search.
     * @param {Number|Object} Value - The value to search for. This value may be an object as long
     * as its numerical value can be returned by the `ValueCallback` function. This is not required
     * to be an object when the items in the array are objects; it can be either an object or number.
     * @param {VarRef} [OutValue] - A variable that will receive the value at the found index.
     * @param {String} [Condition='>='] - The inequality symbol indicating what condition satisfies
     * the search. Valid values are:
     * - ">": `QuickFind` returns the index of the first value greater than the input value.
     * - ">=": `QuickFind` returns the index of the first value greater than or equal to the input value.
     * - "<": `QuickFind` returns the index of the first value less than the input value.
     * - "<=": `QuickFind` returns the index of the first value less than or equal to the input value.
     * @param {Number} [IndexStart=1] - The index to start the search at.
     * @param {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the
     * array is used.
     * @param {Func} [ValueCallback] - The function that returns the item's numeric value.
     * The function can accept up to three parameters, in this order:
     * - The current item being evaluated.
     * - The item's index.
     * - The input array.
     * @returns {Integer} - The index of the first value that satisfies the condition.
     */
    static Call(Arr, Value, &OutValue?, Condition := '>=', IndexStart := 1, IndexEnd?, ValueCallback?) {
        local i, Direction, ItemValue
        global qf_debug
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


        ;@region Set compares

        if IsSet(ValueCallback) {
            Compare_GT := _Compare_GT_2
            Compare_GTE := _Compare_GTE_2
            Compare_LT := _Compare_LT_2
            Compare_LTE := _Compare_LTE_2
            Compare_EQ := _Compare_EQ_2
            if IsObject(Value) {
                Value := ValueCallback(Value)
            }
            GetValue := () => ValueCallback(Arr[i])
        } else {
            Compare_GT := _Compare_GT_1
            Compare_GTE := _Compare_GTE_1
            Compare_LT := _Compare_LT_1
            Compare_LTE := _Compare_LTE_1
            Compare_EQ := _Compare_EQ_1
            GetValue := () => Arr[i]
        }
        ;@endregion

        ;@region Get Left-Right
        ; This block starts to identify the sort direction, and also sets `Left` and `Right` in the
        ; process.
        i := IndexStart
        ; No return value indicates the array had no set indices between IndexStart and IndexEnd.
        if !_GetNearest_L2R() {
            throw Error('The indices within the input range are all unset.', -1)
        }
        LeftV := GetValue()
        Left := i
        i := IndexEnd
        ; This will always return 1 because we know that there is at least one value in the input range.
        _GetNearest_R2L()
        RightV := GetValue()
        Right := i
        ;@endregion

        ;@region 1 Unique val
        ; This block handles conditions where there is only one unique value between `IndexStart`
        ; and `IndexEnd`.
        if RightV == LeftV {
            ; First, we validate `Value`. We might be able to skip the whole process if `Value` is
            ; out of range. We can also prepare the return value so we don't need to re-check
            ; `Condition`. The return value will be a function of the sort direction.
            qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '1 Unique val; Entered 1 Unique val. Val: ' RightV)
            switch Condition {
                case '>':
                    if LeftV <= Value {
                        return
                    }
                    Result := (BaseDirection) => BaseDirection ? Right : Left
                case '>=':
                    if LeftV < Value {
                        return
                    }
                    Result := (BaseDirection) => BaseDirection ? Right : Left
                case '<':
                    if LeftV >= Value {
                        return
                    }
                    Result := (BaseDirection) => BaseDirection ? Left : Right
                case '<=':
                    if LeftV > Value {
                        return
                    }
                    Result := (BaseDirection) => BaseDirection ? Left : Right
            }
            ; `Value` satisfies the condition at this point. If `Right == Left`, then there is only
            ; one set index and we can return that.
            qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '1 Unique val; Value satisfies condition.')
            if Right == Left {
                OutValue := Arr[Right]
                return Right
            }
            ; At this point, we know `Value` is valid and there are multiple indices with `Value`.
            ; Therefore, we must know the sort direction so we know whether to return `Left` or
            ; `Right`.
            qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '1 Unique val; Multiple indices with value.')
            i := 0
            while !Arr.Has(++i) {
                continue
            }
            LeftV := GetValue()
            i := Arr.Length + 1
            while !Arr.Has(--i) {
                continue
            }
            RightV := GetValue()
            qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '1 Unique val;; LeftV: ' LeftV ' RightV: ' RightV)
            if LeftV == RightV {
                ; Default to `Left` because there is no sort direction.
                OutValue := Arr[Left]
                return Left
            } else if RightV > LeftV {
                OutValue := Arr[Result(1)]
                return Result(1)
            } else {
                OutValue := Arr[Result(-1)]
                return Result(-1)
            }
        }
        ;@endregion

        switch Condition {

            ;@region case >=
            case '>=':
                Condition := Compare_GTE
                AltCondition := Compare_LTE
                HandleEqualValues := _HandleEqualValues_EQ
                EQ := true
                if RightV > LeftV {
                    if Value > RightV {
                        ; `Value` is out of range.
                        return
                    }
                    HEV_Direction := -1
                    ProcessLoopValue := _ProcessLoopValue_1
                    Sequence_GT := _Sequence_GT_A_2
                    Sequence_LT := _Sequence_GT_A_1
                    Compare_Loop := Compare_LT
                } else {
                    if Value > LeftV {
                        ; `Value` is out of range.
                        return
                    }
                    HEV_Direction := 1
                    ProcessLoopValue := _ProcessLoopValue_2
                    Sequence_GT := _Sequence_GT_D_2
                    Sequence_LT := _Sequence_GT_D_1
                    Compare_Loop := Compare_GT
                }
            ;@endregion

            ;@region case >
            case '>':
                Condition := Compare_GT
                AltCondition := Compare_LT
                HandleEqualValues := _HandleEqualValues_NEQ
                EQ := false
                if RightV > LeftV {
                    if Value >= RightV {
                        ; `Value` is out of range.
                        return
                    }
                    HEV_Direction := 1
                    ProcessLoopValue := _ProcessLoopValue_1
                    Sequence_GT := _Sequence_GT_A_2
                    Sequence_LT := _Sequence_GT_A_1
                    Compare_Loop := Compare_LT
                } else {
                    if Value >= LeftV {
                        ; `Value` is out of range.
                        return
                    }
                    HEV_Direction := -1
                    ProcessLoopValue := _ProcessLoopValue_2
                    Sequence_GT := _Sequence_GT_D_2
                    Sequence_LT := _Sequence_GT_D_1
                    Compare_Loop := Compare_GT
                }
            ;@endregion

            ;@region case <=
            case '<=':
                Condition := Compare_LTE
                AltCondition := Compare_GTE
                HandleEqualValues := _HandleEqualValues_EQ
                EQ := true
                if RightV > LeftV {
                    if Value < LeftV {
                        ; `Value` is out of range.
                        return
                    }
                    HEV_Direction := 1
                    ProcessLoopValue := _ProcessLoopValue_1
                    Sequence_GT := _Sequence_LT_A_2
                    Sequence_LT := _Sequence_LT_A_1
                    Compare_Loop := Compare_LT
                } else {
                    if Value < RightV {
                        ; `Value` is out of range.
                        return
                    }
                    HEV_Direction := -1
                    ProcessLoopValue := _ProcessLoopValue_2
                    Sequence_GT := _Sequence_LT_D_2
                    Sequence_LT := _Sequence_LT_D_1
                    Compare_Loop := Compare_GT
                }
            ;@endregion

            ;@region case <
            case '<':
                Condition := Compare_LT
                AltCondition := Compare_GT
                HandleEqualValues := _HandleEqualValues_NEQ
                EQ := false
                if RightV > LeftV {
                    if Value <= LeftV {
                        ; `Value` is out of range.
                        return
                    }
                    HEV_Direction := -1
                    ProcessLoopValue := _ProcessLoopValue_1
                    Sequence_GT := _Sequence_LT_A_2
                    Sequence_LT := _Sequence_LT_A_1
                    Compare_Loop := Compare_LT
                } else {
                    if Value >= LeftV {
                        ; `Value` is out of range.
                        return
                    }
                    HEV_Direction := 1
                    ProcessLoopValue := _ProcessLoopValue_2
                    Sequence_GT := _Sequence_LT_D_2
                    Sequence_LT := _Sequence_LT_D_1
                    Compare_Loop := Compare_GT
                }
            ;@endregion

            default: throw ValueError('Invalid condition.', -1, Condition)
        }

        StopBinary := 0
        R := IndexEnd - IndexStart + 1
        loop 100 {
            if R * 0.5 ** (StopBinary + 1) * 14 <= 27 {
                break
            }
            StopBinary++
        }

        qf_debug.lines.push(Format('{:4}: ', A_LineNumber) 'StopBinary: ' StopBinary)
        if qf_debug.pause {
            ; set breakpoint
            qf_debug.pause := false
        }

        loop StopBinary {
            qf_debug.lines.push(Format('{:4}: ', A_LineNumber) 'Enter loop; Start i: ' i)
            qf_debug.lines.push(Format('{:4}: ', A_LineNumber) 'Enter loop; GetValue(): ' GetValue())
            qf_debug.lines.push(Format('{:4}: ', A_LineNumber) 'Enter loop; Right: ' Right '    Left: ' Left)
            i := Right - Ceil((Right - Left) * 0.5)
            qf_debug.lines.push(Format('{:4}: ', A_LineNumber) 'Process loop; Split i: ' i)
            qf_debug.lines.push(Format('{:4}: ', A_LineNumber) 'Process loop; GetValue() (' GetValue() ') ' (GetValue() > Value ? '>' : GetValue() == Value ? '==' : '<') ' Value (' Value ')')
            while !Arr.Has(i) {
                qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '!Arr.Has(i==' i '); IndexEnd: ' IndexEnd)
                if i + 1 > IndexEnd {
                    qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '!Arr.Has(i==' i '); Reversed search direction.')
                    while !Arr.Has(--i) {
                        qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '!Arr.Has(i==' i '); --i; i ' i)
                        continue
                    }
                    qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '!Arr.Has(i==' i '); Found i: ' i)
                    qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '!Arr.Has(i==' i '); GetValue() (' GetValue() ') ' (GetValue() > Value ? '>' : GetValue() == Value ? '==' : '<') ' Value (' Value ')')
                    if Compare_GT() {
                        qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '!Arr.Has(i==' i '); Entering Sequence_GT.')
                        return Sequence_GT()
                    } else {
                        qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '!Arr.Has(i==' i '); Entering Sequence_LT.')
                        return Sequence_LT()
                    }
                } else {
                    qf_debug.lines.push(Format('{:4}: ', A_LineNumber) '!Arr.Has(i==' i '); i++; i ' i)
                    i++
                }
            }
            if Compare_EQ() {
                qf_debug.lines.push(Format('{:4}: ', A_LineNumber) 'Process loop; Entering HandleEqualValues.')
                return HandleEqualValues()
            }
            if Compare_Loop() {
                qf_debug.lines.push(Format('{:4}: ', A_LineNumber) 'Process loop; Compare_Loop() == true. Previous left: ' Left)
                Left := i
            } else {
                Right := i
            }
        }
        ; If we go the entire loop without landing on an equal value, then we search sequentially
        ; from `i`.
        if Compare_EQ() {
            return HandleEqualValues()
        } else if Compare_GT() {
            return Sequence_GT()
        } else {
            return Sequence_LT()
        }

        _Compare_GTE_1() => Arr[i] >= Value
        _Compare_GTE_2() => ValueCallback(Arr[i]) >= Value
        _Compare_GT_1() => Arr[i] > Value
        _Compare_GT_2() => ValueCallback(Arr[i]) > Value
        _Compare_LTE_1() => Arr[i] <= Value
        _Compare_LTE_2() => ValueCallback(Arr[i]) <= Value
        _Compare_LT_1() => Arr[i] < Value
        _Compare_LT_2() => ValueCallback(Arr[i]) < Value
        _Compare_EQ_1() => Arr[i] == Value
        _Compare_EQ_2() => ValueCallback(Arr[i]) == Value
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == 1
         * - > or >=
         */
        _Sequence_GT_A_1() {
            ; If `Value` > <current value>, and if GT, then we must search toward `Value`
            ; until we hit an equal or greater value. If we hit an equal value and if ET, we return
            ; that. If not ET, then we keep going until we find a greater value. Since we have
            ; already set `Condition` to check for the correct condition, we just need to check
            ; `Condition`.
            loop IndexEnd - i + 1 {
                if Arr.Has(++i) {
                    if Condition() {
                        OutValue := Arr[i]
                        return i
                    }
                }
            }
        }
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == -1
         * - > or >=
         */
        _Sequence_GT_D_1() {
            ; Same as above but in the opposite direction.
            loop i - IndexStart + 1 {
                if Arr.Has(--i) {
                    if Condition() {
                        OutValue := Arr[i]
                        return i
                    }
                }
            }
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == 1
         * - > or >=
         */
        _Sequence_GT_A_2() {
            ; If `Value` < <current value> and if GT, then we are already at an index that
            ; satisfies the condition, but we do not know for sure that it is the first index.
            ; So we must search toward `Value` until finding an index that does not
            ; satisfy the condition. In this case we search agains the direction of ascent.
            Previous := i
            loop i - IndexStart + 1 {
                if Arr.Has(--i) {
                    if AltCondition() {
                        if EQ && Compare_EQ() {
                            return HandleEqualValues()
                        } else {
                            OutValue := Arr[Previous]
                            return Previous
                        }
                    } else {
                        Previous := i
                    }
                }
            }
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == -1
         * - > or >=
         */
        _Sequence_GT_D_2() {
            ; Same as above but opposite direction.
            Previous := i
            loop IndexEnd - i + 1 {
                if Arr.Has(++i) {
                    if AltCondition() {
                        if EQ && Compare_EQ() {
                            return HandleEqualValues()
                        } else {
                            OutValue := Arr[Previous]
                            return Previous
                        }
                    } else {
                        Previous := i
                    }
                }
            }
        }
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == 1
         * - < or <=
         */
        _Sequence_LT_A_1() {
            ; If `Value` > <current value> and if not GT, then we are already at an index that
            ; satisfies the condition, but we do not know for sure that it is the first index.
            ; So we must search toward `Value` until finding an index that does not
            ; satisfy the condition. If we run into an equal value, and if EQ, then we can
            ; pass control over to `HandleEqualValues` because it will do the rest. If not EQ,
            ; then we can ignore equality because we just need `AltCondition` to return true.
            Previous := i
            loop IndexEnd - i + 1 {
                if Arr.Has(++i) {
                    if AltCondition() {
                        if EQ && Compare_EQ() {
                            return HandleEqualValues()
                        } else {
                            OutValue := Arr[Previous]
                            return Previous
                        }
                    } else {
                        Previous := i
                    }
                }
            }
        }
        /**
         * @description - Used when:
         * - `!Compare_GT()`
         * - Ascent == -1
         * - < or <=
         */
        _Sequence_LT_D_1() {
            ; Same as above but opposite direction.
            Previous := i
            loop i - IndexStart + 1 {
                if Arr.Has(--i) {
                    if AltCondition() {
                        if EQ && Compare_EQ() {
                            return HandleEqualValues()
                        } else {
                            OutValue := Arr[Previous]
                            return Previous
                        }
                    } else {
                        Previous := i
                    }
                }
            }
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == 1
         * - < or <=
         */
        _Sequence_LT_A_2() {
            ; If `Value` < <current value>, and if not GT, then we must go opposite of the
            ; direction of ascent until `Condition` returns true.
            loop i - IndexStart + 1 {
                if Arr.Has(--i) {
                    if Condition() {
                        OutValue := Arr[i]
                        return i
                    }
                }
            }
        }
        /**
         * @description - Used when:
         * - `Compare_GT()`
         * - Ascent == -1
         * - < or <=
         */
        _Sequence_LT_D_2() {
            ; Same as above but opposite direction.
            loop IndexEnd - i + 1 {
                if Arr.Has(++i) {
                    if Condition() {
                        OutValue := Arr[i]
                        return i
                    }
                }
            }
        }
        ; This function is used when equality is included in the condition.
        _HandleEqualValues_EQ() {
            ; We are able to prepare for this function beforehand by understanding what direction
            ; we must search in order to find the correct index to return. Since equality is included,
            ; we must search in the opposite direction we otherwise would have, then return the
            ; index that is previous to the first index which contains a value that is NOT equivalent
            ; to `Value`.
            ; Consider an array:
            ; -500 -499 -498 -497 -497 -497 -496 -495 -494
            ; `Value := -497`
            ; If GT, then the correct index is 4 because it is the first index to contain a value
            ; that meets the condition in the search direction, so to find it we must search
            ; <DirectionofAscent> * -1 (-1 in the example) then return 4 when we get to 3.
            ; If LT, then the correct index is 6, so we must do the opposite. Specifically,
            ; we must search <DirectionofAscent> (1 in the example) then return 6 when we get to 7.
            /**
             * @example
                if GT {
                    HEV_Direction := BaseDirection == 1 ? -1 : 1
                } else {
                    HEV_Direction := BaseDirection == 1 ? 1 : -1
                }
             * @
             */
            if HEV_Direction > 0 {
                i--
                LoopCount := Arr.Length - i
            } else {
                i++
                LoopCount := i
            }
            loop LoopCount {
                i += HEV_Direction
                if Arr.Has(i) {
                    if !Compare_EQ() {
                        break
                    }
                    Previous := i
                }
            }
            OutValue := Arr[Previous]
            return Previous
        }
        ; This function is used when equality is not included in the condition.
        _HandleEqualValues_NEQ() {
            ; When equality is not included, the process is different. When GT, we no longer invert
            ; the direction of ascent. We are interested in the first index that contains a value
            ; which meets the condition in the same direction as the direction of ascent. When LT,
            ; we are interested in the first index that contains a value which meets the condition
            ; in the opposite direction of the direction of ascent.
            ; Consider an array:
            ; -500 -499 -498 -497 -497 -497 -496 -495 -494
            ; `Value := -497`
            ; If GT, then the correct index is 7 because it is the first index to contain a value
            ; that meets the condition in the search direction, so to find it we must search
            ; <DirectionofAscent> (1 in the example) then return 7 when we get to 7.
            ; If LT, then the correct index is 3, so we must do the opposite. Specifically,
            ; we must search <DirectionofAscent> * -1 (-1 in the example) then return 3 when we get to 3.
            /**
             * @example
                if GT {
                    HEV_Direction := BaseDirection == 1 ? 1 : -1
                } else {
                    HEV_Direction := BaseDirection == 1 ? -1 : 1
                }
             * @
             */
            loop HEV_Direction > 0 ? IndexEnd - i + 1 : i {
                i += HEV_Direction
                if Arr.Has(i) {
                    if !Compare_EQ() {
                        break
                    }
                }
            }
            if Arr.Has(i) {
                OutValue := Arr[i]
                return i
            }
        }
        _GetNearest_L2R() {
            loop IndexEnd - i + 1 {
                if Arr.Has(i) {
                    return 1
                }
                i++
            }
        }
        _GetNearest_R2L() {
            loop i - IndexStart + 1 {
                if Arr.Has(i) {
                    return 1
                }
                i--
            }
        }
        ; This function is used when the direction of ascent is 1 (left to right).
        _ProcessLoopValue_1() {
            if Value > ItemValue {
                Left := i
            } else if Value < ItemValue {
                Right := i
            }
        }
        ; This function is used when the direction of ascent is -1 (right to left).
        _ProcessLoopValue_2() {
            if Value > ItemValue {
                GetNearest := _GetNearest_R2L
                Right := i
            } else if Value < ItemValue {
                GetNearest := _GetNearest_L2R
                Left := i
            }
        }
    }
    ;@endregion



    ;@region Equality
    /**
     * @description - Performs a binary search on an array to find one or more indices that contain
     * the input value. This function has these characteristics:
     * - The array is assumed to be in order of value.
     * - The array may have unset indices as long as every set index is in order.
     * - Items may be objects - set `ValueCallback` to return the item value.
     * @example
        MyArr := [ { prop: 1 }, { prop: 22 }, { prop: 1776 } ]
        AccessorFunc(Item, *) {
            return Item.prop
        }
        MsgBox(QuickFind(MyArr, 22, , , , , AccessorFunc)) ; 2
     * @
     * - The search direction is always left-to-right. If there are multiple indices with the
     * input value, the index returned by the function will be the lowest index, and the index
     * assigned to `OutLastIndex` will be the highest index.
     * @param {Array} Arr - The array to search.
     * @param {Number|Object} Value - The value to search for. This value may be an object as long
     * as its numerical value can be returned by the `ValueCallback` function. This is not required
     * to be an object when the items in the array are objects; it can be either an object or number.
     * @param {VarRef} [OutLastIndex] - If there are multiple indices containing the input value,
     * `QuickFind.Equality` assigns to this variable the last index which contains the input value.
     * If there is one index containing the input value, `OutLastIndex` will be the same as the return
     * value.
     * @param {Number} [IndexStart=1] - The index to start the search at.
     * @param {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the
     * array is used.
     * @param {Func} [ValueCallback] - The function that returns the item's numeric value.
     * The function can accept up to three parameters, in this order:
     * - The current item being evaluated.
     * - The item's index.
     * - The input array.
     * @returns {Integer} - The index of the first value that satisfies the condition.
     */
    static Equality(Arr, Value, &OutLastIndex?, IndexStart := 1, IndexEnd?, ValueCallback?) {
        local i, ItemValue, GetNearest, Result
        if !Arr.Length {
            throw Error('The array is empty.', -1)
        }
        if !IsSet(IndexEnd) {
            IndexEnd := Arr.Length
        }
        if IndexEnd <= IndexStart {
            throw Error('The end index is less than or equal to the start index.'
            , -1, 'IndexEnd: ' IndexEnd '; IndexStart: ' IndexStart)
        }
        StopBinary := 0
        R := IndexEnd - IndexStart + 1
        loop 100 {
            if R * 0.5 ** (StopBinary + 1) * 14 <= 27 {
                break
            }
            StopBinary++
        }
        if IsSet(ValueCallback) {
            Compare := _Compare2
            CompareGT := _CompareGT2
            if IsObject(Value) {
                Value := ValueCallback(Value)
            }
        } else {
            Compare := _Compare1
            CompareGT := _CompareGT1
        }
        loop StopBinary {
            if !Arr.Has(i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)) {
                if !_GetNearest() {
                    return
                }
            }
            if Compare() {
                Start := Result := OutLastIndex := i
                loop i - IndexStart + 1 {
                    if Arr.Has(--i) {
                        if Compare() {
                            Result := i
                        } else {
                            break
                        }
                    }
                }
                i := Start
                loop IndexEnd - i + 1 {
                    if Arr.Has(++i) {
                        if Compare() {
                            OutLastIndex := i
                        } else {
                            break
                        }
                    }
                }
                return Result
            } else if CompareGT() {
                IndexStart := i
            } else {
                IndexEnd := i
            }
        }
        i := IndexStart - 1
        loop IndexEnd - i {
            if Arr.Has(++i) && Compare() {
                Result := OutLastIndex := i
                loop IndexEnd - i {
                    if Arr.Has(++i) {
                        if Compare() {
                            OutLastIndex := i
                        } else {
                            break
                        }
                    }
                }
                break
            }
        }
        return Result ?? ''

        _Compare1() => Value == Arr[i]
        _Compare2() => Value == ValueCallback(Arr[i])
        _CompareGT1() => Value > Arr[i]
        _CompareGT2() => Value > ValueCallback(Arr[i])
        _GetNearest() {
            Start := i
            loop IndexEnd - i + 1 {
                if Arr.Has(++i) {
                    return 1
                }
            }
            i := Start
            loop i - IndexStart + 1 {
                if Arr.Has(--i) {
                    return 1
                }
            }
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
         * @param {String} [Condition='>='] - The inequality symbol indicating what condition satisfies
         * the search. Valid values are:
         * - ">": `QuickFind` returns the index of the first value greater than the input value.
         * - ">=": `QuickFind` returns the index of the first value greater than or equal to the input value.
         * - "<": `QuickFind` returns the index of the first value less than the input value.
         * - "<=": `QuickFind` returns the index of the first value less than or equal to the input value.
         * @param {Number} [IndexStart=1] - The index to start the search at.
         * @param {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the
         * array is used.
         * @param {Func} [ValueCallback] - The function that returns the item's numeric value.
         * The function can accept up to three parameters, in this order:
         * - The current item being evaluated.
         * - The item's index.
         * - The input array.
         * @returns {QuickFind.Func} - A function object that can be called repeatedly to perform
         * a search on an input array.
         */
        ; static Call(Arr, Condition := '>=', IndexStart := 1, IndexEnd?, ValueCallback?) {
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
        ;     ObjSetBase(Fn := { ObjPtr: ObjPtr(Arr) }, QuickFind.Func.Prototype)
        ;     ObjAddRef(ObjPtr(Arr))
        ;     Fn.DefineProp('Call', { Call: _GetClosure() })
        ;     return Fn

        ;     _GetClosure() {
        ;         local LeftV, RightV, R, i
        ;         , AltCondition, Left, Right, StopBinary, Value, ItemValue, InputValue
        ;         , ProcessLoopValue, GetNearest, GetValue, HandleEqualValues
        ;         , Params_Seq_SR, Params_Seq_Loop_GT, Params_Seq_Loop_LT, Params_Seq_GT, Params_Seq_LT
        ;         , HEV_Direction, Param_HEV_GV

        ;         GetValue := ValueCallback ?? (Item) => Item
        ;         switch Condition {
        ;             case '>': GreaterThan := true, Equality := false
        ;             case '>=': GreaterThan := true, Equality := true
        ;             case '<': GreaterThan := false, Equality := false
        ;             case '<=': GreaterThan := false, Equality := true
        ;             default: throw Error('Invalid condition.', -1, Condition)
        ;         }
        ;         i := 1
        ;         if _GetNearest_L2R() {
        ;             throw Error('The range does not contain a value.', -1)
        ;         }
        ;         LeftV := ItemValue
        ;         i := Arr.Length
        ;         if _GetNearest_R2L() {
        ;             throw Error('The range contains only one value.', -1)
        ;         }
        ;         RightV := ItemValue
        ;         if RightV == LeftV {
        ;             for Item in Arr {
        ;                 if IsSet(Item) {
        ;                     if GetValue(Item) !== RightV {
        ;                         throw Error('The range is not sorted in order of value.', -1)
        ;                     }
        ;                 }
        ;             }
        ;             throw Error('All of the values in the range are equivalent.', -1)
        ;         }
        ;         if GreaterThan {
        ;             if Equality {
        ;                 Condition := () => ItemValue >= InputValue
        ;                 AltCondition := () => ItemValue <= InputValue
        ;                 HEV_Direction_Multiplier := -1
        ;             } else {
        ;                 Condition := () => ItemValue > InputValue
        ;                 AltCondition := () => ItemValue < InputValue
        ;                 HEV_Direction_Multiplier := 1
        ;             }
        ;             ; "Seq" - params for `_Sequence`
        ;             ; "Loop" - in the loop section of the function
        ;             ; "GT" - `i > IndexEnd = true` at the time the function evaluates it.
        ;             Params_Seq_Loop_GT_1 := -1
        ;             Params_Seq_Loop_GT_2 := AltCondition
        ;             Params_Seq_Loop_GT_3 := -1
        ;             ; "LT" - `i < IndexStart = true` at the time the function evaluates `i > IndexEnd`.
        ;             Params_Seq_Loop_LT_1 := 1
        ;             Params_Seq_Loop_LT_2 := Condition
        ;             Params_Seq_Loop_LT_3 := 0
        ;         } else {
        ;             if Equality {
        ;                 Condition := () => ItemValue <= InputValue
        ;                 AltCondition := () => ItemValue >= InputValue
        ;                 HEV_Direction_Multiplier := -1
        ;             } else {
        ;                 Condition := () => ItemValue < InputValue
        ;                 AltCondition := () => ItemValue > InputValue
        ;                 HEV_Direction_Multiplier := -1
        ;             }
        ;             Params_Seq_Loop_GT_1 := -1
        ;             Params_Seq_Loop_GT_2 := Condition
        ;             Params_Seq_Loop_GT_3 := 0
        ;             Params_Seq_Loop_LT_1 := 1
        ;             Params_Seq_Loop_LT_2 := AltCondition
        ;             Params_Seq_Loop_LT_3 := -1
        ;         }
        ;         if RightV > LeftV {
        ;             ; The array is sorted in ascending order.
        ;             ProcessLoopValue := _ProcessLoopValue_1
        ;             HEV_Direction := 1 * HEV_Direction_Multiplier
        ;             if GreaterThan {
        ;                 ; The direction used in `_HandleEqualValues`.
        ;                 ; The parameters passed to `_Sequence` outside of the loop.
        ;                 Params_Seq_GT := [1, Condition, 0]
        ;                 Params_Seq_LT := [-1, AltCondition, -1]
        ;             } else {
        ;                 Params_Seq_GT := [1, AltCondition, -1]
        ;                 Params_Seq_LT := [-1, Condition, 0]
        ;             }
        ;         } else {
        ;             ; The array is sorted in descending order.
        ;             HEV_Direction := -1 * HEV_Direction_Multiplier
        ;             ProcessLoopValue := _ProcessLoopValue_2
        ;             if GreaterThan {
        ;                 Params_Seq_GT := [-1, Condition, 0]
        ;                 Params_Seq_LT := [1, AltCondition, -1]
        ;             } else {
        ;                 Params_Seq_GT := [-1, AltCondition, -1]
        ;                 Params_Seq_LT := [1, Condition, 0]
        ;             }
        ;         }
        ;         if Equality {
        ;             HandleEqualValues := _HandleEqualValues_EQ
        ;         } else {
        ;             HandleEqualValues := _HandleEqualValues_NEQ
        ;         }
        ;         HEV_GetNearest := HEV_Direction > 0 ? _GetNearest_L2R : _GetNearest_R2L
        ;         StopBinary := 0
        ;         R := IndexEnd - IndexStart + 1
        ;         loop 100 {
        ;             if R * 0.5 ** (StopBinary + 1) * 14 <= 27 {
        ;                 break
        ;             }
        ;             StopBinary++
        ;         }
        ;         ; These are no longer needed
        ;         GreaterThan := Equality := R := i := Arr := LeftV := RightV := ItemValue := Value := unset

        ;         return Call

        ;         Call(Self, Value, &OutValue?) {
        ;             Arr := ObjFromPtrAddRef(Self.ObjPtr)
        ;             InputValue := IsObject(Value) ? GetValue(InputValue) : Value
        ;             loop StopBinary {
        ;                 i := Right - Ceil((Right - Left) * 0.5)
        ;                 if GetNearest() {
        ;                     if i > IndexEnd {
        ;                         return _Sequence(Params_Seq_Loop_GT)
        ;                     } else {
        ;                         return _Sequence(Params_Seq_Loop_LT)
        ;                     }
        ;                 }
        ;                 if InputValue == ItemValue {
        ;                     return HandleEqualValues()
        ;                 }
        ;                 ProcessLoopValue()
        ;             }
        ;             if InputValue > ItemValue {
        ;                 return _Sequence(Params_Seq_GT)
        ;             } else if InputValue < ItemValue {
        ;                 return _Sequence(Params_Seq_LT)
        ;             }

        ;             _Sequence(Params) {
        ;                 local GetNearest := _GetNearestFunc(Params[1])
        ;                 loop {
        ;                     if GetNearest() {
        ;                         return OutValue := ''
        ;                     }
        ;                     if ItemValue == InputValue {
        ;                         return HandleEqualValues()
        ;                     }
        ;                     ; `Condition()`
        ;                     if Params[2]() {
        ;                         if ItemValue == InputValue {
        ;                             OutValue := Arr[i]
        ;                             return i
        ;                         }
        ;                         ; An indicator to return the current index (0) or the previous index (-1)
        ;                         if Params[3] == -1 {
        ;                             if IsSet(Previous) {
        ;                                 OutValue := Arr[Previous]
        ;                                 return Previous
        ;                             } else {
        ;                                 loop {
        ;                                     ; Increment direction
        ;                                     i += Params[1]
        ;                                     if i > Right || i < Left {
        ;                                         return OutValue := ''
        ;                                     }
        ;                                     if Arr.Has(i) {
        ;                                         OutValue := Arr[i]
        ;                                         return i
        ;                                     }
        ;                                 }
        ;                             }
        ;                         } else {
        ;                             OutValue := Arr[i]
        ;                             return i
        ;                         }
        ;                     }
        ;                     Previous := i
        ;                     i += Params[1]
        ;                 }
        ;             }
        ;         }


        ;         _HandleEqualValues_EQ() {
        ;             while Value == ItemValue {
        ;                 Previous := i
        ;                 i += Direction
        ;                 if GetNearest() {
        ;                     break
        ;                 }
        ;             }
        ;             ; Direction *= -1
        ;             OutValue := Arr[Previous]
        ;             return Previous
        ;         }
        ;         _HandleEqualValues_NEQ() {
        ;             while InputValue == ItemValue {
        ;                 i += HEV_Direction
        ;                 if GetNearest() || i > IndexEnd || i < IndexStart {
        ;                     return
        ;                 }
        ;             }
        ;             OutValue := Arr[i]
        ;             return i
        ;         }
        ;         _GetNearestFunc(Direction) {
        ;             switch Direction {
        ;                 case 1: return _GetNearest_L2R
        ;                 case -1: return _GetNearest_R2L
        ;                 default: throw ValueError('Unexpected direction.', -1, Direction)
        ;             }
        ;         }
        ;         _GetNearest_L2R() {
        ;             loop IndexEnd - i + 1 {
        ;                 if Arr.Has(i) {
        ;                     ItemValue := GetValue(Arr[i])
        ;                     return
        ;                 }
        ;                 i++
        ;             }
        ;             return 1
        ;         }
        ;         _GetNearest_R2L() {
        ;             loop i - IndexStart + 1 {
        ;                 if Arr.Has(i) {
        ;                     ItemValue := GetValue(Arr[i])
        ;                     return
        ;                 }
        ;                 i--
        ;             }
        ;             return 1
        ;         }
        ;         _ProcessLoopValue_1() {
        ;             if InputValue > ItemValue {
        ;                 GetNearest := _GetNearest_L2R
        ;                 Left := i
        ;             } else if InputValue < ItemValue {
        ;                 GetNearest := _GetNearest_R2L
        ;                 Right := i
        ;             }
        ;         }
        ;         _ProcessLoopValue_2() {
        ;             if InputValue > ItemValue {
        ;                 GetNearest := _GetNearest_R2L
        ;                 Right := i
        ;             } else if InputValue < ItemValue {
        ;                 GetNearest := _GetNearest_L2R
        ;                 Left := i
        ;             }
        ;         }
        ;     }
        ; }
        ;@endregion


        ;@region Func.Equality
        ; /**
        ;  * @description - Returns a closure that can be used to repeatedly search the input array
        ;  * for input values.
        ;  * - The reference count for the input array is incremented by 1. If you need to dispose
        ;  * the array, you will have to call `Dispose` on this object to get rid of that reference.
        ;  * Calling the function after `Dispose` results in an error.
        ;  * - The function parameters are:
        ;  *   - **Value** - The value to search for.
        ;  *   - **OutValue** - A variable that will receive the value at the found index.
        ;  * @example
        ;     Arr := [1, 5, 12, 19, 19, 19, , 19, 230, 1991]
        ;     Finder := QuickFind.Equality.Func(Arr)
        ;     Index := Finder(12, &LastIndex)
        ;     OutputDebug(Index) ; 4
        ;     OutputDebug(LastIndex) ; 8
        ;     ; When finished
        ;     Finder.Dispose()
        ;     Index := Finder(230) ; Error: This object has been disposed.
        ;  * @
        ;  * @param {Array} Arr - The array to search.
        ;  * @param {Number} [IndexStart=1] - The index to start the search at.
        ;  * @param {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the
        ;  * array is used.
        ;  * @param {Func} [ValueCallback] - The function that returns the item's numeric value.
        ;  * The function can accept up to three parameters, in this order:
        ;  * - The current item being evaluated.
        ;  * - The item's index.
        ;  * - The input array.
        ;  * @returns {Integer} - The index of the first value that satisfies the condition.
        ;  */
        ; static Equality(Arr, IndexStart := 1, IndexEnd?, ValueCallback?) {
        ;     local i, ItemValue, GetNearest, Result
        ;     if !Arr.Length {
        ;         throw Error('The array is empty.', -1)
        ;     }
        ;     if !IsSet(IndexEnd) {
        ;         IndexEnd := Arr.Length
        ;     }
        ;     if IndexEnd <= IndexStart {
        ;         throw Error('The end index is less than or equal to the start index.'
        ;         , -1, 'IndexEnd: ' IndexEnd '; IndexStart: ' IndexStart)
        ;     }
        ;     StopBinary := 0
        ;     R := IndexEnd - IndexStart + 1
        ;     loop 100 {
        ;         if R * 0.5 ** (StopBinary + 1) * 14 <= 27 {
        ;             break
        ;         }
        ;         StopBinary++
        ;     }
        ;     if IsSet(ValueCallback) {
        ;         Compare := _Compare2
        ;         CompareGT := _CompareGT2
        ;         if IsObject(Value) {
        ;             Value := ValueCallback(Value)
        ;         }
        ;     } else {
        ;         Compare := _Compare1
        ;         CompareGT := _CompareGT1
        ;     }
        ;     loop StopBinary {
        ;         if !Arr.Has(i := IndexEnd - Ceil((IndexEnd - IndexStart) * 0.5)) {
        ;             if !_GetNearest() {
        ;                 return
        ;             }
        ;         }
        ;         if Compare() {
        ;             Start := Result := OutLastIndex := i
        ;             loop i - IndexStart + 1 {
        ;                 if Arr.Has(--i) {
        ;                     if Compare() {
        ;                         Result := i
        ;                     } else {
        ;                         break
        ;                     }
        ;                 }
        ;             }
        ;             i := Start
        ;             loop IndexEnd - i + 1 {
        ;                 if Arr.Has(++i) {
        ;                     if Compare() {
        ;                         OutLastIndex := i
        ;                     } else {
        ;                         break
        ;                     }
        ;                 }
        ;             }
        ;             return Result
        ;         } else if CompareGT() {
        ;             IndexStart := i
        ;         } else {
        ;             IndexEnd := i
        ;         }
        ;     }
        ;     i := IndexStart - 1
        ;     loop IndexEnd - i {
        ;         if Arr.Has(++i) && Compare() {
        ;             Result := OutLastIndex := i
        ;             loop IndexEnd - i {
        ;                 if Arr.Has(++i) {
        ;                     if Compare() {
        ;                         OutLastIndex := i
        ;                     } else {
        ;                         break
        ;                     }
        ;                 }
        ;             }
        ;             break
        ;         }
        ;     }
        ;     return Result ?? ''

        ;     _Compare1() => Value == Arr[i]
        ;     _Compare2() => Value == ValueCallback(Arr[i])
        ;     _CompareGT1() => Value > Arr[i]
        ;     _CompareGT2() => Value > ValueCallback(Arr[i])
        ;     _GetNearest() {
        ;         Start := i
        ;         loop IndexEnd - i + 1 {
        ;             if Arr.Has(++i) {
        ;                 return 1
        ;             }
        ;         }
        ;         i := Start
        ;         loop i - IndexStart + 1 {
        ;             if Arr.Has(--i) {
        ;                 return 1
        ;             }
        ;         }
        ;     }
        ; }
        ;@endregion


        ;@region Func.Equality
        ; static Equality(Arr, IndexStart := 1, IndexEnd?, ValueProp?, ValueKey?, ValueCallback?) {
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
        ;         , ProcessLoopValue := Condition == 1 ? _ProcessLoopValue_1 : _ProcessLoopValue_2

        ;         if IsObject(Value) {
        ;             Value := GetValue(Value)
        ;         }
        ;         GetNearest := _GetNearest_L2R
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
        ;         _GetNearest_L2R() {
        ;             loop IndexEnd - i + 1 {
        ;                 if Arr.Has(i) {
        ;                     ItemValue := GetValue(Arr[i])
        ;                     return
        ;                 }
        ;                 i++
        ;             }
        ;             return 1
        ;         }
        ;         _GetNearest_R2L() {
        ;             loop i - IndexStart + 1 {
        ;                 if Arr.Has(i) {
        ;                     ItemValue := GetValue(Arr[i])
        ;                     return
        ;                 }
        ;                 i--
        ;             }
        ;             return 1
        ;         }
        ;         _ProcessLoopValue_1() {
        ;             if Value > ItemValue {
        ;                 GetNearest := _GetNearest_L2R
        ;                 Left := i
        ;             } else if Value < ItemValue {
        ;                 GetNearest := _GetNearest_R2L
        ;                 Right := i
        ;             }
        ;         }
        ;         _ProcessLoopValue_2() {
        ;             if Value > ItemValue {
        ;                 GetNearest := _GetNearest_R2L
        ;                 Right := i
        ;             } else if Value < ItemValue {
        ;                 GetNearest := _GetNearest_L2R
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
        ;@endregion


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
