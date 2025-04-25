

#Include QuickFind.ahk
#SingleInstance force
; This is optional and only serves a cosmetic purpose. You can use this script without it.
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
#Include *i <Align_V1.0.0>

Test_QuickFind.Gui()                ; to use the gui
; Result := Test_QuickFind()        ; to run the test without the gui.

class Test_QuickFind {

    ; These are used by the gui. You can modify them without issue. The last font name in the array
    ; would be the one that gets used first.
    static Options := {
        FontOpt: 'S11 Q5'
      , FontStandard: ['Aptos', 'Roboto']
      , FontMono: ['Mono', 'Roboto Mono']
    }

    static Debug := false
    , DebugCallback := ''


    /**
     * @description - Initiates the test. The test is designed to validate `QuickFind`. Specifically,
     * it verifies whether `QuickFind` returns the correct index given the input parameters. This
     * test processes about 4000 iterations, most of them are fringe cases with very small input
     * ranges and/or the `Value` to find is at the edge or just beyond the extreme values in the
     * range. For each call to `QuickFind`, an object is appended to either `Test_QuickFind.Result`
     * or `Test_QuickFind.Problem`, each an array, depending on if the values returned by `QuickFind`
     * match the expected values. The objects have these properties:
     * @example
        _GetResultObj(FoundValue, Result, ExpectedIndex, ExpectedValue, LineNumber, CopyArray := false) => {
            ; `input` is an object containing the various values that control Test_QuickFind's process.
            ; The properties are { find, gt, et, bounds, array, fn, count }.
                ; find: the index passed to `QuickFind`.
                ; gt and et - the condition for the test, e.g. if `gt` and `et` are true, the condition was ">="
                ; bounds - an object containing two properties { Start, End } representing the values
                    ; passed to QuickFind's `InputStart` and `InputEnd` parameters.
                ; array - which array was used. This is either 1 or 2. If 1, the array contained
                    ; values between -500 and 500. If 2, the array contained values between 500 and
                    ; -500.
                ; fn - which test function is being processed. This is 1, 2, or 3, representing the
                    ; nested functions `Process_1`, `Process_2`, and `Process_3` which are nested
                    ; within `Test_QuickFind.Call`.
            input: input.Clone()

          ; `Arr` is an array of size 10-20 containing items within +/- 10 indices from `FindIndex`.
          ; When using the Gui in debug mode, the values are dislayed next to the result values.
          ; This is only copied when a problem occurs.
          , Arr: CopyArray ? _CopyArray() : ''

          ; The value passed to `QuickFind`.
          , FindValue: GetValue(FI)
          ; The index in the test array that contains the value.
          , FindIndex: FI

          ; The value assigned to QuickFind's `OutValue` VarRef parameter.
          , FoundValue: FoundValue
          ; The index returned from `QuickFind`.
          , FoundIndex: Result

          ; The expected index / value.
          , ExpectedValue: ExpectedValue
          , ExpectedIndex: ExpectedIndex

          ; `LineNumber` is the line in `Test_QuickFind` that initiated the `QuickFind` call.
          , LineNumber: LineNumber
        }
     * @
     * When `Test_QuickFind` completes, it will return the number of items contained in
     * `Test_QuickFind.Problem`, which we would hope would be `0`.
     * <br>
     * To test using the Gui, call `Test_QuickFind.Gui()`
     * <br>
     * To test with additional debugging features, set `Test_QuickFind.Debug := true`. When true,
     * and if a problem is encountered, Test_QuickFind will:
     * - Create the result object and append it to `Test_QuickFind.Problem` (it does this even
     * when `Debug` is false).
     * - Set `Test_QuickFind.DebugPause := true`
     * - Call the function assigned to `DebugCallback` if there is one.
     * - If the function returns nonzero, or if there is no function, return `-1` to the function
     * that called `Test_QuickFind`, and leaves `DebugPause == true`. The next time `Test_QuickFind`
     * is called, it repeats the `QuickFind` call with the same parameters as the previous call. I
     * did this because it was easier to debug problems when I had all the information ready before
     * I stepped through the function. The second `QuickFind` call does not produce another result
     * object.
     * - If the function returns zero or an empty string, sets `Test_QuickFind.DebugPause := 0` and
     * resumes processing.
     * @param {Integer} [Which=1] - One of the following options:
     * - 1: Test `QuickFind.Call`
     * - 2: Test `QuickFind.GetFunc.Prototype.Call`
     */
    static Call(Which := 1) {
        if (!this.Paused && !this.DebugPause) || this.Finished {
            this.__Initialie()
        }
        local TA, GT, ET, B, FI, input := this.input
        if !this.Functions.Length {
            loop {
                try {
                    this.Functions.Push(Process_%A_Index%)
                } catch {
                    break
                }
            }
        }
        this.Paused := 0
        Proc := this.GuiActive ? Process_Main_Gui : Process_Main
        Result := Process_Loop(Which)
        if this.Stop {
            this.Stop := this.Paused := 0
        } else if !this.Paused && !this.DebugPause {
            this.__ShowTooltip('Done')
            this.Finished := 1
            this.Result.Capacity := this.Result.Length
            Result := this.Problem.Capacity := this.Problem.Length
        }
        return Result

        Process_Loop(Which) {
            while input.array <= this.TestArrays.Length {
                TA := this.TestArrays[input.array]
                while input.gt <= this.GreaterThan.Length {
                    GT := this.GreaterThan[input.gt]
                    while input.et <= this.EqualTo.Length {
                        ET := this.EqualTo[input.et]
                        while input.bounds <= this.Bounds.Length {
                            B := this.Bounds[input.bounds]
                            while input.find <= this.FindIndices.Length {
                                FI := this.FindIndices[input.find]
                                if FI < B.Start || FI > B.End {
                                    input.find++
                                    continue
                                }
                                while input.fn <= this.Functions.Length {
                                    if this.Paused || this.Stop {
                                        return
                                    }
                                    this.Functions[input.fn](Which)
                                    if this.DebugPause {
                                        return -1
                                    }
                                    input.count++
                                    input.fn++
                                }
                                input.fn := 1
                                input.find++
                            }
                            input.find := 1
                            input.bounds++
                        }
                        input.bounds := 1
                        input.et++
                    }
                    input.et := 1
                    input.gt++
                }
                input.gt := 1
                input.array++
            }
            return Test_QuickFind.Problem.Length
        }

        /**
         * @description - A wrapper for calling the functions and storing the results.
         */
        Process_Main(Which, ExpectedIndex, ExpectedValue, LineNumber) {
            Result := _GetResult(Which, &FoundValue)
            if this.DebugPause {
                this.DebugPause := 0
            } else {
                if Result !== ExpectedIndex || (FoundValue??'') !== ExpectedValue {
                    this.Problem.Push(_GetResultObj(FoundValue??'', Result, ExpectedIndex, ExpectedValue, LineNumber, true))
                    _ProcessDebug()
                } else {
                    this.Result.Push(_GetResultObj(FoundValue??'', Result, ExpectedIndex, ExpectedValue, LineNumber, false))
                }
            }
        }

        Process_Main_Gui(Which, ExpectedIndex, ExpectedValue, LineNumber) {
            Result := _GetResult(Which, &FoundValue)
            if this.DebugPause {
                this.DebugPause := 0
            } else {
                if Result !== ExpectedIndex || (FoundValue??'') !== ExpectedValue {
                    this.Problem.Push(_GetResultObj(FoundValue??'', Result, ExpectedIndex, ExpectedValue, LineNumber, true))
                    this.G['TxtTotal_Problem'].Text := this.Problem.Length
                    if this.Debug {
                        this.__UpdateDisplay(this.Problem[-1])
                        this.DebugPause := 1
                    }
                } else {
                    this.Result.Push(_GetResultObj(FoundValue??'', Result, ExpectedIndex, ExpectedValue, LineNumber, false))
                    if this.GuiActive {
                        this.G['TxtTotal_Result'].Text := this.Result.Length
                    }
                }
            }
        }

        _ProcessDebug() {
            if !this.Debug {
                return
            }
            this.DebugPause := 1
            Callback := this.Callback
            if Callback && !Callback() {
                this.DebugPause := 0
            }
        }

        _GetResult(Which, &FoundValue) {
            if Which == 1 {
                return QuickFind(TA, GetValue(FI), &FoundValue, _GetCondition(), B.Start, B.End)
            } else {
                Finder := QuickFind.Func(TA, _GetCondition(), B.Start, B.End)
                Result := Finder(GetValue(FI), &FoundValue)
                Finder.Dispose()
                return Result
            }
        }

        _GetResultObj(FoundValue, Result, ExpectedIndex, ExpectedValue, LineNumber, CopyArray := false) => {
            input: input.Clone()
          , FoundIndex: Result
          , ExpectedIndex: ExpectedIndex
          , Arr: CopyArray ? _CopyArray() : ''
          , FindValue: GetValue(FI)
          , FindIndex: FI
          , FoundValue: FoundValue
          , ExpectedValue: ExpectedValue
          , LineNumber: LineNumber
        }

        _GetCondition() => GT ? ET ? '>=' : '>' : ET ? '<=' : '<'


        GetValue(Index) => input.array == 1 ? Index - 501 : 501 - Index

        /**
         * @description - Searches for the value at the indicated index, and the value is present
         * at the index.
         */
        Process_1(Which) {
            k := FI - 2
            loop 3 {
                if ++k < 1 || k > this.Len {
                    continue
                }
                TA[k] := GetValue(k)
            }
            if ET {
                ; The loop skips cases where FI > B.End  || FI < B.Start. Consequently,
                ; when ET is true, the function will always find the value in this block.
                Proc(Which, FI, GetValue(FI), A_LineNumber)
            } else {
                ; If ET is false, the function fails to find the value when FI - 1 < B.Start || FI + 1 > B.End
                ; depending on the direction fo the array and whether GT is true.
                if GT {
                    if input.array == 1 { ; adcending values.
                        if FI + 1 > B.End {
                            Proc(Which, '', '', A_LineNumber)
                        } else {
                            Proc(Which, FI + 1, GetValue(FI + 1), A_LineNumber)
                        }
                    } else { ; descending values
                        if FI - 1 < B.Start {
                            Proc(Which, '', '', A_LineNumber)
                        } else {
                            Proc(Which, FI - 1, GetValue(FI - 1), A_LineNumber)
                        }
                    }
                } else {
                    if input.array == 1 { ; adcending values.
                        if FI - 1 < B.Start {
                            Proc(Which, '', '', A_LineNumber)
                        } else {
                            Proc(Which, FI - 1, GetValue(FI - 1), A_LineNumber)
                        }
                    } else { ; descending values.
                        if FI + 1 > B.End {
                            Proc(Which, '', '', A_LineNumber)
                        } else {
                            Proc(Which, FI + 1, GetValue(FI + 1), A_LineNumber)
                        }
                    }
                }
            }
        }

        /**
         * @description - Searches for the value at the indicated index, and the value is present
         * both at the indicated index, and on adjacent indices. The next index over also is ensured
         * to have its own value to simplify the test.
         * The two indices adjacent to FI have the same value as FI, like this:
         * - ..., FI-3, FI-2, FI, FI, FI, FI+2, FI+3, ...
         */
        Process_2(Which) {
            if FI + 1 <= this.Len {
                TA[FI + 1] := GetValue(FI)
            }
            if FI - 1 >= 1 {
                TA[FI - 1] := GetValue(FI)
            }
            if FI + 2 <= this.Len {
                TA[FI + 2] := GetValue(FI + 2)
            }
            if FI - 2 >= 1 {
                TA[FI - 2] := GetValue(FI - 2)
            }

            ; For the function to be correctly implemented, it must return the *first* found
            ; index of the value. input defined the function to determine sort order and
            ; search direction internally; this block of tests validates this has been implemented
            ; correctly.

            ; The "first" found value in this block will either be +/-1 or +/-2 from FI, unless
            ; the value is at the edge of the array. In those cases, the correct index may
            ; be FI.

            ; Greater than =========================================================
            if GT {
                ; Equal to ---------------------------------------------------------
                if ET {
                    ; When ET is true, we are looking at indices +/- 1 from FI.
                    if input.array == 1 { ; ascending values.
                    ; When GT and ascending, the search direction is left-to-right.
                    ; So the correct index is FI - 1 when ET.
                        if FI - 1 < B.Start {
                                ; The ExpectedValue stays GetValue(FI)
                                ; because that's what we put in there for this test.
                            Proc(Which, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Proc(Which, FI - 1, GetValue(FI), A_LineNumber)
                        }
                    } else { ; descending values.
                    ; When GT and descending, the search direction is right-to-left.
                    ; So the correct index is FI + 1 when ET.
                        if FI + 1 > B.End {
                            Proc(Which, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Proc(Which, FI + 1, GetValue(FI), A_LineNumber)
                        }
                    }
                } else {
                ; ------------------------------------------------------------------
                ; Not equal to -----------------------------------------------------
                ; When !ET, the correct index is +/-2 from FI.
                    if input.array == 1 { ; adcending values.
                        ; Search direction is left-to-right, so next greatest value is at index FI + 2.
                        if FI + 2 > B.End {
                            Proc(Which, '', '', A_LineNumber)
                        } else {
                            Proc(Which, FI + 2, GetValue(FI + 2), A_LineNumber)
                        }
                    } else { ; descending values.
                        ; Search direction is right-to-left.
                        if FI - 2 < B.Start {
                            Proc(Which, '', '', A_LineNumber)
                        } else {
                            Proc(Which, FI - 2, GetValue(FI - 2), A_LineNumber)
                        }
                    }
                }
                ; ------------------------------------------------------------------
            ; ======================================================================
            ; Less than ============================================================
            } else {
                ; Equal to ---------------------------------------------------------
                if ET {
                    ; When !GT and ascending, the search direction is right-to-left, so the correct
                    ; index will be FI + 1 when ET.
                    if input.array == 1 { ; adcending values.
                        if FI + 1 > B.End {
                            Proc(Which, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Proc(Which, FI + 1, GetValue(FI), A_LineNumber)
                        }
                    } else { ; descending values.
                    ; Search direction is left-to-right, so correct index is FI - 1 when ET.
                        if FI - 1 < B.Start {
                            Proc(Which, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Proc(Which, FI - 1, GetValue(FI), A_LineNumber)
                        }
                    }
                } else {
                ; ------------------------------------------------------------------
                ; Not equal to -----------------------------------------------------
                    if input.array == 1 { ; adcending values.
                    ; !GT and ascending, so the search direction is right-to-left.
                    ; The next smallest value is at index FI - 2.
                        if FI - 2 < B.Start {
                            Proc(Which, '', '', A_LineNumber)
                        } else {
                            Proc(Which, FI - 2, GetValue(FI - 2), A_LineNumber)
                        }
                    } else { ; descending values.
                        ; Search direction is left-to-rigth.
                        if FI + 2 > B.End {
                            Proc(Which, '', '', A_LineNumber)
                        } else {
                            Proc(Which, FI + 2, GetValue(FI + 2), A_LineNumber)
                        }
                    }
                }
            }
        }

        /**
         * @description - Searches for the value at the indicated index, and the value absent
         * from the array.
         * - ..., FI-3, FI-2, FI-1, unset, FI+1, FI+2, FI+3, ...
         * In this block, regardless of ET, the correct index will be +/- 1 from FI. No index
         * should be returned if that index is < B.Start or > B.End depending on the direction
         * of ascent.
         */
        Process_3(Which) {
            TA.Delete(FI)
            if FI - 1 >= 1 {
                TA[FI - 1] := GetValue(FI - 1)
            }
            if FI + 1 <= TA.Length {
                TA[FI + 1] := GetValue(FI + 1)
            }
            if GT {
                if input.array == 1 {
                    if FI + 1 > B.End {
                        Proc(Which, '', '', A_LineNumber)
                    } else {
                        Proc(Which, FI + 1, GetValue(FI + 1), A_LineNumber)
                    }
                } else {
                    if FI - 1 < B.Start {
                        Proc(Which, '', '', A_LineNumber)
                    } else {
                        Proc(Which, FI - 1, GetValue(FI - 1), A_LineNumber)
                    }
                }
            } else {
                if input.array == 1 {
                    if FI - 1 < B.Start {
                        Proc(Which, '', '', A_LineNumber)
                    } else {
                        Proc(Which, FI - 1, GetValue(FI - 1), A_LineNumber)
                    }
                } else {
                    if FI + 1 > B.End {
                        Proc(Which, '', '', A_LineNumber)
                    } else {
                        Proc(Which, FI + 1, GetValue(FI + 1), A_LineNumber)
                    }
                }
            }
        }

        _CopyArray() {
            k := FI - 11
            Result := { Arr: Copy := [], Start: '', End: '' }
            Copy.Capacity := 20
            loop 20 {
                if ++k < 1 {
                    continue
                }
                if k > this.Len {
                    Result.End := k - 1
                    break
                }
                if !Result.Start {
                    Result.Start := k
                }
                if TA.Has(k) {
                    Copy.Push(TA[k])
                } else {
                    Copy.Push('')
                }
            }
            if !Result.End {
                Result.End := k
            }
            return Result
        }
    }

    /**
     * @description - Launches the test window.
     */
    static Gui() {
        if this.HasOwnProp('G') {
            try {
                this.G.Show()
            } catch {
                this.__CreateGui()
            }
        } else {
            this.__CreateGui()
        }
        this.__Initialie()
        this.GuiActive := 1
    }

    /**
     * @description - If using this as part of a larger validation procedure, you may want to free
     * the resources after validation here is complete. Call `Dispose` to do so.
     */
    static Dispose() {
        for G in ['G', 'EG', 'MG'] {
            if this.HasOwnProp(G) {
                try {
                    this.%G%.Destroy()
                }
                this.DeleteProp(G)
            }
        }
        for Prop in this.OwnProps() {
            if !this.HasMethod(Prop) {
                if this.%Prop% is Array {
                    this.%Prop%.Capacity := 0
                } else if IsObject(this.%Prop%) {
                    ObjSetCapacity(this.%Prop%, 0)
                }
            }
            this.DeleteProp(Prop)
        }
        this.DefineProp('Call', { Call: _Throw })
        _Throw(*) {
            throw Error('This object has been disposed.', -1)
        }
    }


    static __CreateGui() {
        Opt := this.Options
        G := this.G := Gui('-DPIScale +Resize')
        this.__SetFonts(G, Opt.FontStandard)
        G.SetFont(Opt.FontOpt)
        Text := this.BtnCtrlNames[1]
        G.Add('Button', 'Section vBtn' Text, Text).OnEvent('Click', HClickButton%Text%)
        k := 1
        loop this.BtnCtrlNames.Length - 1 {
            Text := this.BtnCtrlNames[++k]
            G.Add('Button', 'vBtn' Text ' ys', Text).OnEvent('Click', HClickButton%Text%)
        }
        G.Add('Checkbox', 'xs Section Checked vChkStandard', 'Standard function').OnEvent('Click', HClickCheckboxWhich)
        G.LastChecked := G['ChkStandard']
        G.Add('Checkbox', 'ys vChkClosure', 'Closure from ``QuickFind.Func``').OnEvent('Click', HClickCheckboxWhich)
        G.Add('Checkbox', 'ys vChkDebug', 'Debug mode').OnEvent('Click', HClickCheckboxDebug)
        G.Add('Button', 'xs Section vBtnPrevious_Result', 'Previous Result').OnEvent('Click', HClickButtonPrevious)
        G.Add('Button', 'xs Section vBtnPrevious_Problem', 'Previous Problem').OnEvent('Click', HClickButtonPrevious)
        G['BtnPrevious_Problem'].GetPos(, , &cw)
        G['BtnPrevious_Result'].Move(, , cw)
        _CreateScroller('Result')
        _CreateScroller('Problem')
        G['BtnPrevious_Problem'].GetPos(, &cy, , &ch)
        G['ChkClosure'].GetPos(&cx, , &cw)
        G.Add('Edit', Format('x{} y{} w400 r21 Section +Wrap vResult', G.MarginX, cy + ch + G.MarginY))
        G.Add('Edit', 'ys w300 hp vArray')
        G.OnEvent('Close', (*) => this.GuiActive := 0)

        G.Show()
        if IsSet(Align) {
            Align.GroupWidth_S([G['BtnNext_Result'], G['BtnNext_Problem']])
        }
        G['BtnNext_Result'].GetPos(&cx, &cy, &cw)
        G.Add('Text', Format('x{} y{} Section vTxtDuration', cx + cw + G.MarginX, cy), 'Duration:')
        G.Add('Text', 'xs w100 vTxtDurationValue', '0')

        for Ctrl in G {
            if Ctrl.Type == 'Edit' {
                this.__SetFonts(Ctrl, Opt.FontMono)
            }
        }

        return

        _CreateScroller(Name) {
            G['BtnPrevious_' Name].GetPos(&cx, &cy, &cw, &ch)
            G.Add('Edit', Format('x{} y{} w50 Section vEditJump_{}', cx + cw + G.MarginX, cy, Name), 1).OnEvent('Change', HChangeEditJump)
            G.Add('Text', 'ys vTxtOf_' Name, ' of ')
            G.Add('Text', 'ys w40 vTxtTotal_' Name, '0')
            G.Add('Button', 'ys vBtnJump_' Name, 'Jump').OnEvent('Click', HClickButtonJump)
            G.Add('Button', 'ys vBtnNext_' Name, 'Next ' Name).OnEvent('Click', HClickButtonNext)
            if IsSet(Align) {
                Align.CenterV(G['TxtOf_' Name], G['BtnPrevious_' Name])
                Align.CenterV(G['TxtTotal_' Name], G['BtnPrevious_' Name])
                Align.CenterV(G['EditJump_' Name], G['BtnPrevious_' Name])
            }
        }

        _GetName(Ctrl) => StrSplit(Ctrl.Name, '_')[2]

        HChangeEditJump(Ctrl, *) {
            Ctrl.Text := RegExReplace(Ctrl.Text, '[^\d]', '', &ReplaceCount)
            ControlSend('{End}', Ctrl)
            if ReplaceCount {
                this.__ShowTooltip('Numbers only!')
            }
        }

        HClickButtonClear(*) {
            this.Stop := this.Paused := this.Finished := 0
            G['Result'].Text := G['Array'].Text := ''
            G['TxtTotal_Result'].Text := G['TxtTotal_Problem'].Text := '0'
            G['EditJump_Result'].Text := G['EditJump_Problem'].Text := '1'
            this.__Initialie()
        }

        HClickButtonEquality(*) {
            this.__LaunchEqualToTester()
        }

        HClickButtonExit(*) {
            ExitApp()
        }

        HClickButtonJump(Ctrl, *) {
            if this.__SetIndex(_GetName(Ctrl), G['EditJump_' _GetName(Ctrl)].Text) {
                this.__ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                Name := _GetName(Ctrl)
                this.__UpdateDisplay(this.%Name%[this.%Name%Index])
            }
        }

        HClickButtonListLines(*) {
            ListLines()
        }

        HClickButtonNext(Ctrl, *) {
            if this.__IncIndex(_GetName(Ctrl), 1) {
                this.__ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                Name := _GetName(Ctrl)
                this.__UpdateDisplay(this.%Name%[this.%Name%Index])
            }
        }

        HClickButtonPause(*) {
            this.Paused := 1
            this.__ShowTooltip('Paused.')
        }

        HClickButtonPrevious(Ctrl, *) {
            if this.__IncIndex(_GetName(Ctrl), -1) {
                this.__ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                Name := _GetName(Ctrl)
                this.__UpdateDisplay(this.%Name%[this.%Name%Index])
            }
        }

        HClickButtonReload(*) {
            Reload()
        }

        HClickButtonStart(*) {
            if this.Finished {
                HClickButtonClear()
            }
            this.StartTime := A_TickCount
            this(G['ChkStandard'].Value ? 1 : 2)
            this.EndTime := A_TickCount
            G['TxtDurationValue'].Text := Round((this.EndTime - this.StartTime) / 1000, 4)
        }

        HClickButtonStop(*) {
            this.Stop := 1
            this.__ShowTooltip('Stopping.')
        }

        HClickCheckboxDebug(Ctrl, *) {
            if Ctrl.Value {
                this.__ShowTooltip('Debug on!')
                this.Debug := true
            } else {
                this.Debug := false
                this.__ShowTooltip('Debug off!')
            }
        }

        HClickCheckboxWhich(Ctrl, *) {
            G.LastChecked.Value := 0
            G.LastChecked := Ctrl
            Ctrl.Value := 1
        }
    }

    static __IncIndex(Name, n) {
        if !this.%Name%.Length {
            return 1
        }
        this.__SetIndex(Name, this.%Name%Index + n)
        this.G['EditJump_' Name].Text := this.%Name%Index
    }

    static __Initialie() {
        this.input := { find: 1, gt: 1, et: 1, bounds: 1, array: 1, fn: 1, count: 0 }
        this.Result := []
        this.Problem := []
        this.Result.Capacity := this.Problem.Capacity := 4000
        this.Paused := 1
        this.Finished := 0
        return
    }

    static __LaunchEqualToTester() {
        local a, MG, EG
        EG := this.EG := Gui('-DPIScale +Resize')
        a := EG.a := []
        this.__SetFonts(EG, this.Options.FontMono)
        EG.Add('Text', 'section +Wrap w600 vTxtInfo', 'To make a test array, enter in the start value (the value'
        ' that will be at index 1), the length of the array, and the increment step.')
        EG.Add('Text', 'xs Section vTxtStartValue', 'Start value:')
        EG.Add('Edit', 'ys w70 vMakeStartValue', '1')
        EG.Add('Text', 'ys vTxtLength', 'Length:')
        EG.Add('Edit', 'ys w70 vMakeLength', '1000')
        EG.Add('Text', 'ys vTxtStep', 'Step:')
        EG.Add('Edit', 'ys w70 vMakeStep', '1')
        EG.Add('Button', 'ys vbtnmake', 'Make').OnEvent('Click', HClickButtonMake)
        EG.Add('Text', 'section xs vTxtParameters', 'Parameters:')
        EG.Add('Button', 'ys vtest', 'Test').onevent('Click', HClickButtonTest)
        EG.Add('Text', 'section xs vTxtIndexStart', 'IndexStart:')
        EG.Add('Edit', 'ys w70 vIndexStart', '1')
        EG.Add('Text', 'ys vTxtIndexEnd', 'IndexEnd:')
        EG.Add('Edit', 'ys w70 vIndexEnd', '1000')
        EG.Add('Text', 'xs section vTxtFind', 'Find:')
        EG.Add('Edit', 'ys w70 vFind', '500')
        EG.Add('Text', 'ys vTxtResult', 'Result:')
        EG.Add('Edit', 'ys w400 vResult')
        EG.Add('Button', 'xs section vModifyArray', 'Modify array').OnEvent('Click', HClickButtonModifyArray)
        EG.show()
        EG['Result'].Setfont('s10')

        HClickButtonTest(*) {
            _Save()
            if !EG.HasOwnProp('a') || !EG.a.Length {
                if EG['MakeStartValue'].Text && EG['MakeLength'].Text {
                    HClickButtonMake()
                } else {
                    this.__ShowTooltip('No array!')
                    return
                }
            }
            Result := QuickFind.Equality(EG.a, EG['Find'].Text, &LastIndex, EG['IndexStart'].Text, EG['IndexEnd'].Text)
            EG['Result'].Text := 'Found index: ' Result '; Last index: ' (LastIndex??'')
            this.__ShowTooltip('Done!')
        }

        HClickButtonModifyArray(*) {
            this.MG := MG := Gui('-DPIScale +Resize')
            MG.Index := 1
            MG.SetFont(this.Options.FontOpt)
            MG.Add('Text', 'Section vTxtInfo', 'Modify any values in the array, then click "SAVE".'
                (a.Length ? '' : ' First make an array using the controls on the other window.')
            )
            this.__SetFonts(MG, this.Options.FontMono)
            MG.Add('Button', 'Section xs vBtnPrevious', 'Previous').OnEvent('Click', HClickButtonPrevious)
            MG.Add('Edit', 'ys w70 vEditJump')
            MG.Add('Text', 'ys vTxtOf', 'of')
            MG.Add('Text', 'ys w40 vTxtTotal', '0')
            MG.Add('Button', 'ys vBtnJump', 'Jump').OnEvent('Click', HClickButtonJump)
            MG.Add('Button', 'ys vBtnNext', 'Next').OnEvent('Click', HClickButtonNext)
            MG.Add('Button', 'ys vBtnSave', 'Save').OnEvent('Click', HClickButtonSave)
            if IsSet(Align) {
                Align.CenterV(MG['TxtOf'], MG['BtnPrevious'])
                Align.CenterV(MG['TxtTotal'], MG['BtnPrevious'])
                Align.CenterV(MG['EditJump'], MG['BtnPrevious'])
            }
            this.__SetFonts(MG, this.Options.FontStandard)
            MG['BtnPrevious'].GetPos(, &cy, , &ch)
            X := MG.MarginX
            Y := cy + ch + MG.MarginY + 20
            N := 1
            this.__SetFonts(MG, this.Options.FontMono)
            loop 5 {
                if A_Index == 1 {
                    MG.Add('Text', Format('x{} y{} Section vt{}', X, Y + 4, A_Index * 3 - 2), '0000').GetPos(, , &width, &ch1)
                    MG['t1'].Text := _Fill('1')
                } else {
                    MG.Add('Text', Format('x{} y{} w{} Section vt{}', X, Y + 4, width, A_Index * 3 - 2), _Fill(N)).GetPos(, , , &ch1)
                }
                MG.Add('Edit', Format('x{} y{} w70 r20 -VScroll ve{}', X + width + 10, Y- 4, A_Index)).GetPos(&cx2, &cy2, &cw2, &ch2)
                N += 9
                MG.Add('Text', Format('x{} y{} w{} vt{}', X, cy2 + 0.5 * ch2 - ch1, width, A_Index * 3 - 1), _Fill(N))
                N += 10
                MG.Add('Text', Format('x{} y{} w{} vt{}', X, cy2 + ch2 - ch1 - 5, width, A_Index * 3), _Fill(N))
                N += 1
                X += MG.MarginX * 2 + cw2 + width
            }
            EG.GetPos(&gx, &gy, &gw, )
            Hmon := DllCall('User32.dll\MonitorFromWindow', 'Ptr', EG.Hwnd, 'UInt', 0x00000000, 'UPtr')
            MonitorInfo := Buffer(40, 0)
            NumPut('Uint', 40, MonitorInfo)
            if DllCall('user32\GetMonitorInfo', 'Ptr', Hmon, 'Ptr', MonitorInfo) {
                L := NumGet(MonitorInfo, 0, 'Int')
                R := NumGet(MonitorInfo, 8, 'Int')
                X := gx - L > R - gx - gw ? L + 100 : gx + gw + 100
                MG.Show('x' X ' y' Y)
            } else {
                MG.Show()
            }
            _UpdateMG()
        }
        _Fill(Str) {
            loop 4 - StrLen(Str) {
                s .= ' '
            }
            return (s??'') Str
        }
        HClickButtonPrevious(*) {
            ___SetIndex(-1)
        }

        HClickButtonJump(*) {
            ___SetIndex(, MG['EditJump'].Text)
        }

        HClickButtonNext(*) {
            ___SetIndex(1)
        }

        HClickButtonSave(*) {
            _Save()
            MG.Hide()
        }
        HClickButtonMake(*) {
            a := EG.a := []
            n := Number(EG['MakeStartValue'].Text)
            Step := Number(EG['MakeStep'].Text)
            EG.a.Capacity := EG['MakeLength'].Text
            loop a.Capacity {
                a.push(n)
                n += Step
            }
            EG['IndexEnd'].Text := EG.a.Length
            if EG.HasOwnProp('MG') {
                try {
                    _UpdateMG()
                }
            }
            if this.HasOwnProp('MG') {
                try {
                    _UpdateMG()
                }
            }
            this.__ShowTooltip('Created!')
        }
        _Save() {
            if !a.Length {
                this.__ShowTooltip('First make an array!.')
                return
            }
            i := (MG.Index - 1) * 100
            loop 5 {
                for n in StrSplit(MG['e' A_Index].Text, '`r`n') {
                    a[++i] := n
                }
            }
        }
        ___SetIndex(dx?, n?) {
            if !a.Length {
                this.__ShowTooltip('First make an array!.')
                return
            }
            _Save()
            pgs := Ceil(a.Length / 100)
            if IsSet(dx) {
                n := MG.Index + dx
            } else if !IsSet(n) {
                throw Error('No set value was provided.')
            }
            if n <= 0 {
                MG.Index := pgs - n
            } else if n > pgs {
                MG.Index := n - pgs
            } else {
                MG.Index := n
            }
            _UpdateMG()
        }
        _UpdateMG() {
            if !a.Length {
                this.__ShowTooltip('First make an array!.')
                return
            }
            i := (MG.Index - 1) * 100
            MG['EditJump'].Text := MG.Index
            MG['TxtTotal'].Text := Round(a.Length / 100, 0)
            N := i + 1
            loop 5 {
                Str := ''
                loop 20 {
                    Str .= (A_Index == 1 ? '' : '`r`n') a[++i]
                }
                MG['e' A_Index].Text := Str
                MG['t' (A_Index * 3 - 2)].Text := _Fill(N)
                MG['t' (A_Index * 3 - 1)].Text := _Fill(N += 9)
                MG['t' (A_Index * 3)].Text := _Fill(N += 10)
                N += 1
            }
        }
    }

    static __SetFonts(GuiOrCtrl, FontList) {
        for Font in FontList {
            GuiOrCtrl.SetFont(, Font)
        }
    }

    static __SetIndex(Name, Value) {
        if !this.%Name%.Length {
            return 1
        }
        Value := Number(Value)
        if (Diff := Value - this.%Name%.Length) > 0 {
            this.__%Name%Index := Diff
        } else if Value < 0 {
            this.__%Name%Index := this.%Name%.Length + Value + 1
        } else if Value == 0 {
            this.__%Name%Index := this.%Name%.Length
        } else if Value {
            this.__%Name%Index := Value
        }
    }

    static __ShowTooltip(Str) {
        static N := [1,2,3,4,5,6,7]
        Z := N.Pop()
        OM := CoordMode('Mouse', 'Screen')
        OT := CoordMode('Tooltip', 'Screen')
        MouseGetPos(&x, &y)
        Tooltip(Str, x, y, Z)
        SetTimer(_End.Bind(Z), -2000)
        CoordMode('Mouse', OM)
        CoordMode('Tooltip', OT)

        _End(Z) {
            ToolTip(,,,Z)
            N.Push(Z)
        }
    }

    static __UpdateArrayCtrl(ArrCopyObj) {
        if ArrCopyObj {
            k := ArrCopyObj.Start - 1
            while ++k <= ArrCopyObj.End - 1 {
                Str .= Format('{:5}', k) ' : ' ArrCopyObj.Arr[A_Index] '`r`n'
            }
            this.G['Array'].Text := Trim(Str, '`r`n')
        } else {
            this.G['Array'].Text := ''
        }
    }

    static __UpdateDisplay(ResultObj) {
        input := ResultObj.input
        Results := [
            ['Find index', ResultObj.FindIndex]
          , ['Expected index', ResultObj.ExpectedIndex]
          , ['Found index', ResultObj.FoundIndex]
          , ['Find value', ResultObj.FindValue]
          , ['Expected value' , ResultObj.ExpectedValue]
          , ['Found value', ResultObj.FoundValue]
          , ['IndexStart', this.Bounds[input.bounds].Start]
          , ['IndexEnd', this.Bounds[input.bounds].End]
          , ['GreaterThan', (this.GreaterThan[input.gt] ? 'true' : 'false')]
          , ['EqualTo', (this.EqualTo[input.et] ? 'true' : 'false')]
          , ['Direction', (input.array == 1 ? 1 : -1)]
          , ['Iteration', input.count]
          , ['Function index', input.fn]
          , ['Line number', ResultObj.LineNumber]
        ]
        GreatestKeyLen := 0
        for Pair in Results {
            if StrLen(Pair[1]) > GreatestKeyLen {
                GreatestKeyLen := StrLen(Pair[1])
            }
        }
        for Pair in Results {
            Str .= Format('{:' GreatestKeyLen '}', Pair[1]) ' : ' Pair[2] '`r`n'
        }
        Str .= '`r`nDescription: ' . this.TestDescriptions[input.fn]
        this.G['Result'].Text := Str
        this.__UpdateArrayCtrl(ResultObj.Arr)
    }

    ; This isn't implemented, and `this.Debug` is no longer an object. This needs to be completely rewritten
    ; static __WriteDebug() {
    ;     for line in this.Debug.Lines {
    ;         Str .= line '`r`n'
    ;     }
    ;     if !this.Debug.Overwrite && FileExist(this.Debug.File) {
    ;         switch MsgBox('A file already exists at ' this.Debug.File '.`r`nClick "Yes" to overwrite.'
    ;         '`r`nClick "No" to append file name with timestamp.'
    ;         '`r`nClick "Cancel" to exit the thread.'
    ;         '`r`nTo Disable this message, set ``Test_Quickfind.Debug.FileAction := <1 or 2>``.',, 'YNC') {
    ;             case 'No': this.Debug.FileAction := 2
    ;             case 'Cancel':
    ;         }
    ;     }
    ;     f := FileOpen(this.Debug.File, 'w')
    ;     f.Write(Str)
    ;     sleep 500
    ;     f.Close()
    ; }

    static __New() {
        FindIndices := this.FindIndices := [1, 2, 3, 4, 5, 9, 10, 11, 250, 499, 500, 501, 989, 990
        , 991, 994, 995, 996, 998, 999, 1000]
        StartIndices := [1, 100, 500, 900, 999]
        ; Offsets get added to the start indices to get the end indices.
        Offsets := [1, 2, 4, 5, 99, 100, 499, 500, 997, 998, 999]
        this.Len := 1000
        ; `Bounds` contains the actual start and end indices, each as an object with `{ Start, End }`
        ; properties.
        this.Bounds := []
        this.Bounds.Capacity := FindIndices.Length * Offsets.Length
        i := k := 0
        loop StartIndices.Length {
            i++
            loop Offsets.Length {
                if StartIndices[i] + Offsets[++k] <= 1000 {
                    this.Bounds.Push({ Start: StartIndices[i], End: StartIndices[i] + Offsets[k] })
                }
            }
            k := 0
        }
        this.Bounds.Capacity := this.Bounds.Length
        ; First test array ascends, second test array descends.
        this.TestArrays := [[], []]
        _ProcessTestArray(-500, 1, this.TestArrays[1])
        _ProcessTestArray(500, -1, this.TestArrays[2])
        this.Functions := []

        return

        _ProcessTestArray(StartValue, Direction, TestArr) {
            k := 1
            v := StartValue + Direction * -1
            TestArr.Length := this.Len
            loop this.Len {
                v += Direction
                if Random() <= 0.85 {
                    TestArr[A_Index] := v
                }
            }
        }
    }

    static __ResultIndex := 0
    static ResultIndex {
        Get => this.__ResultIndex
        Set => this.__SetIndex('Result', Value)
    }

    static __ProblemIndex := 0
    static ProblemIndex {
        Get => this.__ProblemIndex
        Set => this.__SetIndex('Problem', Value)
    }

    ; various flags
    static Paused := 0
    , Stop := 0
    , Finished := 0
    , GuiActive := 0
    , DebugPause := false

    static BtnCtrlNames := ['Start', 'Pause', 'Stop', 'Exit', 'Reload', 'Clear', 'Equality', 'ListLines']
    , GreaterThan := [false, true]
    , EqualTo := [false, true]

    static TestDescriptions := [
        'Searches for the value at the indicated index, and the value is present at the index.'
      , 'Searches for the value at the indicated index, and the value is present both at the indicated index, and on adjacent indices.'
      , 'Searches for the value at the indicated index, and the value absent from the array.'
    ]
}
