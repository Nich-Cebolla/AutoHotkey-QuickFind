
#Include <Object.Prototype.Stringify_V1.0.0>
; https://github.com/Nich-Cebolla/Stringify-ahk/blob/main/Object.Prototype.Stringify.ahk
#Include <Align_V1.0.0>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
#Include QuickFind.ahk
#SingleInstance force
Test_QuickFind()

global qf_debug := { pause: false, lines: '' }

/**
 * @description - Initiates the test.
 * @param {Integer} [Which=1] - One of the following options:
 * - 1: Test `QuickFind.Call`
 * - 2: Test `QuickFind.GetFunc.Prototype.Call`
 */
class Test_QuickFind {

    static BtnCtrlNames := ['Start', 'Pause', 'Stop', 'Exit', 'Reload', 'Clear', 'Equality', 'ListLines']
    , GreaterThan := [false, true]
    , EqualTo := [false, true]

    static Options := {
        FontOpt: 'S11 Q5'
      , FontStandard: 'Roboto'
      , FontMono: ['Mono', 'Roboto Mono']
    }

    static Paused := 0
    , Stop := 0
    , Init := 0
    , Finished := 0

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

    static Call(Which := 1) {
        static i, TA, GT, ET, B, FI
        global debug_pause
        if !this.HasOwnProp('G') {
            this.CreateGui()
        }
        if this.Paused {
            this.Paused := 0
            Process_Loop(Which)
        } else {
            this.i := { find: 1, gt: 1, et: 1, bounds: 1, array: 1, fn: 1, count: 0 }
            this.Result := []
            this.Problem := []
            this.Paused := 1
            if !this.Init {
                this.Init := 1
                n := 0
                if !this.Functions.Length {
                    loop {
                        try {
                            this.Functions.Push(Process_%(++n)%)
                        } catch {
                            break
                        }
                    }
                }
                static TAS := this.TestArrays, GTS := this.GreaterThan, ETS := this.EqualTo
                , BS := this.Bounds, FIS := this.FindIndices, FNS := this.Functions
                return
            } else {
                Process_Loop(Which)
            }
        }
        if this.Stop {
            this.Stop := this.Paused := 0
        } else if !this.Paused {
            this.ShowTooltip('Done')
            this.Finished := 1
        }

        Process_Loop(Which) {
            i := this.i
            Result := this.Result
            G := this.G
            while i.array <= TAS.Length {
                TA := TAS[i.array]
                while i.gt <= GTS.Length {
                    GT := GTS[i.gt]
                    while i.et <= ETS.Length {
                        ET := ETS[i.et]
                        while i.bounds <= BS.Length {
                            B := BS[i.bounds]
                            while i.find <= FIS.Length {
                                FI := FIS[i.find]
                                if FI < B.Start
                                || FI > B.End {
                                    i.find++
                                    continue
                                }
                                while i.fn <= FNS.Length {
                                    if this.Paused || this.Stop {
                                        return
                                    }
                                    FNS[i.fn](Which)
                                    i.count++
                                    i.fn++
                                }
                                i.fn := 1
                                i.find++
                            }
                            i.find := 1
                            i.bounds++
                        }
                        i.bounds := 1
                        i.et++
                    }
                    i.et := 1
                    i.gt++
                }
                i.gt := 1
                i.array++
            }
        }
        /**
         * @description - A wrapper for calling the functions and storing the results.
         */
        Process_Main(Which, ExpectedIndex, ExpectedValue, LineNumber) {
            if GT {
                if ET {
                    Condition := '>='
                } else {
                    Condition := '>'
                }
            } else {
                if ET {
                    Condition := '<='
                } else {
                    Condition := '<'
                }
            }
            if this.G['ChkDebug'].Value {
                Result := _GetResult(&FoundValue)
                if Result !== ExpectedIndex || (FoundValue??'') !== ExpectedValue {
                    this.Problem.Push(O := _Obj(FoundValue??'', Result))
                    this.UpdateDisplay(O)
                    this.G['TxtTotal_Problem'].Text := this.Problem.Length
                    if qf_debug.HasOwnProp('lines') && qf_debug.lines is Array && qf_debug.lines.Length {
                        this.WriteDebug()
                    }
                    qf_debug.pause := true
                    Result := _GetResult(&FoundValue)
                    if qf_debug.pause {
                        qf_debug.pause := false
                    }
                } else {
                    this.Result.Push(_Obj(FoundValue??'', Result))
                    this.G['TxtTotal_Result'].Text := this.Result.Length
                }
                qf_debug.lines := []
                qf_debug.lines.Capacity := 1000
            } else {
                Result := _GetResult(&FoundValue)
                if Result !== ExpectedIndex || (FoundValue??'') !== ExpectedValue {
                    this.Problem.Push(O := _Obj(FoundValue??'', Result))
                    this.G['TxtTotal_Problem'].Text := this.Problem.Length
                } else {
                    this.Result.Push(_Obj(FoundValue??'', Result))
                    this.G['TxtTotal_Result'].Text := this.Result.Length
                }
            }

            _GetResult(&FoundValue) {
                if Which == 1 {
                    return QuickFind(TA, GetValue(FI), &FoundValue, Condition, B.Start, B.End)
                } else {
                    Finder := QuickFind.Func(TA, Condition, B.Start, B.End)
                    Result := Finder(GetValue(FI), &FoundValue)
                    Finder.Dispose()
                    return Result
                }
            }
            _Obj(FoundValue, Result) => { i: i.Clone(), FoundIndex: Result, ExpectedIndex: ExpectedIndex, Arr: _CopyArray()
            , FindValue: GetValue(FI), FindIndex: FI, FoundValue: FoundValue, ExpectedValue: ExpectedValue
            , LineNumber: LineNumber }
        }
        GetValue(Index) => i.array == 1 ? Index - 501 : 501 - Index

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
                Process_Main(Which, FI, GetValue(FI), A_LineNumber)
            } else {
                ; If ET is false, the function fails to find the value when FI - 1 < B.Start || FI + 1 > B.End
                ; depending on the direction fo the array and whether GT is true.
                if GT {
                    if i.array == 1 { ; adcending values.
                        if FI + 1 > B.End {
                            Process_Main(Which, '', '', A_LineNumber)
                        } else {
                            Process_Main(Which, FI + 1, GetValue(FI + 1), A_LineNumber)
                        }
                    } else { ; descending values
                        if FI - 1 < B.Start {
                            Process_Main(Which, '', '', A_LineNumber)
                        } else {
                            Process_Main(Which, FI - 1, GetValue(FI - 1), A_LineNumber)
                        }
                    }
                } else {
                    if i.array == 1 { ; adcending values.
                        if FI - 1 < B.Start {
                            Process_Main(Which, '', '', A_LineNumber)
                        } else {
                            Process_Main(Which, FI - 1, GetValue(FI - 1), A_LineNumber)
                        }
                    } else { ; descending values.
                        if FI + 1 > B.End {
                            Process_Main(Which, '', '', A_LineNumber)
                        } else {
                            Process_Main(Which, FI + 1, GetValue(FI + 1), A_LineNumber)
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
            ; index of the value. I defined the function to determine sort order and
            ; search direction internally; this block of tests validates this has been impleented
            ; correctly.

            ; The "first" found value in this block will either be +/-1 or +/-2 from FI, unless
            ; the value is at the edge of the array. In those cases, the correct index may
            ; be FI.

            ; Greater than =========================================================
            if GT {
                ; Equal to ---------------------------------------------------------
                if ET {
                    ; When ET is true, we are looking at indices +/- 1 from FI.
                    if i.array == 1 { ; adcending values.
                    ; When GT and ascending, the search direction is left-to-right.
                    ; So the correct index is FI - 1 when ET.
                        if FI - 1 < B.Start {
                                ; The ExpectedValue stays GetValue(FI)
                                ; because that's what we put in there for this test.
                            Process_Main(Which, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Process_Main(Which, FI - 1, GetValue(FI), A_LineNumber)
                        }
                    } else { ; descending values.
                    ; When GT and descending, the search direction is right-to-left.
                    ; So the correct index is FI + 1 when ET.
                        if FI + 1 > B.End {
                            Process_Main(Which, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Process_Main(Which, FI + 1, GetValue(FI), A_LineNumber)
                        }
                    }
                } else {
                ; ------------------------------------------------------------------
                ; Not equal to -----------------------------------------------------
                ; When !ET, the correct index is +/-2 from FI.
                    if i.array == 1 { ; adcending values.
                        ; Search direction is left-to-right, so next greatest value is at index FI + 2.
                        if FI + 2 > B.End {
                            Process_Main(Which, '', '', A_LineNumber)
                        } else {
                            Process_Main(Which, FI + 2, GetValue(FI + 2), A_LineNumber)
                        }
                    } else { ; descending values.
                        ; Search direction is right-to-left.
                        if FI - 2 < B.Start {
                            Process_Main(Which, '', '', A_LineNumber)
                        } else {
                            Process_Main(Which, FI - 2, GetValue(FI - 2), A_LineNumber)
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
                    if i.array == 1 { ; adcending values.
                        if FI + 1 > B.End {
                            Process_Main(Which, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Process_Main(Which, FI + 1, GetValue(FI), A_LineNumber)
                        }
                    } else { ; descending values.
                    ; Search direction is left-to-right, so correct index is FI - 1 when ET.
                        if FI - 1 < B.Start {
                            Process_Main(Which, FI, GetValue(FI), A_LineNumber)
                        } else {
                            Process_Main(Which, FI - 1, GetValue(FI), A_LineNumber)
                        }
                    }
                } else {
                ; ------------------------------------------------------------------
                ; Not equal to -----------------------------------------------------
                    if i.array == 1 { ; adcending values.
                    ; !GT and ascending, so the search direction is right-to-left.
                    ; The next smallest value is at index FI - 2.
                        if FI - 2 < B.Start {
                            Process_Main(Which, '', '', A_LineNumber)
                        } else {
                            Process_Main(Which, FI - 2, GetValue(FI - 2), A_LineNumber)
                        }
                    } else { ; descending values.
                        ; Search direction is left-to-rigth.
                        if FI + 2 > B.End {
                            Process_Main(Which, '', '', A_LineNumber)
                        } else {
                            Process_Main(Which, FI + 2, GetValue(FI + 2), A_LineNumber)
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
            if FI + 1 > this.Len || FI - 1 < 1 {
                return
            }
            TA.Delete(FI)
            TA[FI - 1] := GetValue(FI - 1)
            TA[FI + 1] := GetValue(FI + 1)
            if GT {
                if i.array == 1 {
                    if FI + 1 > B.End {
                        Process_Main(Which, '', '', A_LineNumber)
                    } else {
                        Process_Main(Which, FI + 1, GetValue(FI + 1), A_LineNumber)
                    }
                } else {
                    if FI - 1 < B.Start {
                        Process_Main(Which, '', '', A_LineNumber)
                    } else {
                        Process_Main(Which, FI - 1, GetValue(FI - 1), A_LineNumber)
                    }
                }
            } else {
                if i.array == 1 {
                    if FI - 1 < B.Start {
                        Process_Main(Which, '', '', A_LineNumber)
                    } else {
                        Process_Main(Which, FI - 1, GetValue(FI - 1), A_LineNumber)
                    }
                } else {
                    if FI + 1 > B.End {
                        Process_Main(Which, '', '', A_LineNumber)
                    } else {
                        Process_Main(Which, FI + 1, GetValue(FI + 1), A_LineNumber)
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
                    Result.End := k
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
    static CreateGui() {
        Opt := this.Options
        G := this.G := Gui('-DPIScale +Resize')
        G.SetFont(Opt.FontOpt, Opt.FontStandard)
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

        G.Show()

        Align.GroupWidth_S([G['BtnNext_Result'], G['BtnNext_Problem']])
        G['BtnNext_Result'].GetPos(&cx, &cy, &cw)
        G.Add('Text', Format('x{} y{} Section vTxtDuration', cx + cw + G.MarginX, cy), 'Duration:')
        G.Add('Text', 'xs w100 vTxtDurationValue', '0')

        for Ctrl in G {
            if Ctrl.Type == 'Edit' {
                this.SetFonts(Ctrl, Opt.FontMono)
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
            Align.CenterV(G['TxtOf_' Name], G['BtnPrevious_' Name])
            Align.CenterV(G['TxtTotal_' Name], G['BtnPrevious_' Name])
            Align.CenterV(G['EditJump_' Name], G['BtnPrevious_' Name])
        }

        _GetName(Ctrl) => StrSplit(Ctrl.Name, '_')[2]

        HChangeEditJump(Ctrl, *) {
            Ctrl.Text := RegExReplace(Ctrl.Text, '[^\d]', '', &ReplaceCount)
            ControlSend('{End}', Ctrl)
            if ReplaceCount {
                this.ShowTooltip('Numbers only!')
            }
        }

        HClickButtonClear(*) {
            this.Stop := this.Paused := this.Init := this.Finished := 0
            G['Result'].Text := G['Array'].Text := ''
            G['TxtTotal_Result'].Text := G['TxtTotal_Problem'].Text := '0'
            G['EditJump_Result'].Text := G['EditJump_Problem'].Text := '1'
            this()
        }

        HClickButtonEquality(*) {
            this.LaunchEqualToTester()
        }

        HClickButtonExit(*) {
            ExitApp()
        }

        HClickButtonJump(Ctrl, *) {
            if this.SetIndex(_GetName(Ctrl), G['EditJump_' _GetName(Ctrl)].Text) {
                this.ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                Name := _GetName(Ctrl)
                this.UpdateDisplay(this.%Name%[this.%Name%Index])
            }
        }

        HClickButtonListLines(*) {
            ListLines()
        }

        HClickButtonNext(Ctrl, *) {
            if this.IncIndex(_GetName(Ctrl), 1) {
                this.ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                Name := _GetName(Ctrl)
                this.UpdateDisplay(this.%Name%[this.%Name%Index])
            }
        }

        HClickButtonPause(*) {
            this.Paused := 1
            this.ShowTooltip('Paused.')
        }

        HClickButtonPrevious(Ctrl, *) {
            if this.IncIndex(_GetName(Ctrl), -1) {
                this.ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                Name := _GetName(Ctrl)
                this.UpdateDisplay(this.%Name%[this.%Name%Index])
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
            if G['ChkStandard'].Value {
                this(1)
            } else if G['ChkClosure'].Value {
                this(2)
            }
            this.EndTime := A_TickCount
            G['TxtDurationValue'].Text := Round((this.EndTime - this.StartTime) / 1000, 4)
        }

        HClickButtonStop(*) {
            this.Stop := 1
            this.ShowTooltip('Stopping.')
        }

        HClickCheckboxDebug(Ctrl, *) {
            global qf_debug, qf_debug_file
            if Ctrl.Value {
                qf_debug.lines := []
                qf_debug.lines.Capacity := 1000
                this.ShowTooltip('Debug on!')
            } else {
                qf_debug.lines := ''
                this.ShowTooltip('Debug off!')
            }
        }

        HClickCheckboxWhich(Ctrl, *) {
            G.LastChecked.Value := 0
            G.LastChecked := Ctrl
            Ctrl.Value := 1
        }
    }
    static SetIndex(Name, Value) {
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
    static IncIndex(Name, n) {
        if !this.%Name%.Length {
            return 1
        }
        this.SetIndex(Name, this.%Name%Index + n)
        this.G['EditJump_' Name].Text := this.%Name%Index
    }
    static __ResultIndex := 0
    static ResultIndex {
        Get => this.__ResultIndex
        Set => this.SetIndex('Result', Value)
    }
    static __ProblemIndex := 0
    static ProblemIndex {
        Get => this.__ProblemIndex
        Set => this.SetIndex('Problem', Value)
    }
    static UpdateDisplay(ResultObj) {
        i := ResultObj.i
        Results := [
            ['Find index', ResultObj.FindIndex]
          , ['Expected index', ResultObj.ExpectedIndex]
          , ['Found index', ResultObj.FoundIndex]
          , ['Find value', ResultObj.FindValue]
          , ['Expected value' , ResultObj.ExpectedValue]
          , ['Found value', ResultObj.FoundValue]
          , ['IndexStart', this.Bounds[i.bounds].Start]
          , ['IndexEnd', this.Bounds[i.bounds].End]
          , ['GreaterThan', (this.GreaterThan[i.gt] ? 'true' : 'false')]
          , ['EqualTo', (this.EqualTo[i.et] ? 'true' : 'false')]
          , ['Direction', (i.array == 1 ? 1 : -1)]
          , ['Iteration', i.count]
          , ['Function index', i.fn]
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
        Str .= '`r`nDescription: ' . this.TestDescriptions[i.fn]
        this.G['Result'].Text := Str
        this.UpdateArrayCtrl(ResultObj.Arr)
    }
    static WriteDebug() {
        global qf_debug
        for line in qf_debug.lines {
            Str .= line '`r`n'
        }
        f := FileOpen(A_ScriptDir '\qf_debug_out.txt', 'w')
        f.Write(Str)
        sleep 500
        f.Close()
    }
    static LaunchEqualToTester() {
        local a, MG, EG
        EG := Gui('-DPIScale +Resize')
        a := EG.a := []
        this.SetFonts(EG, this.Options.FontMono)
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
                    this.ShowTooltip('No array!')
                    return
                }
            }
            Result := QuickFind.Equality(EG.a, EG['Find'].Text, &LastIndex, EG['IndexStart'].Text, EG['IndexEnd'].Text)
            EG['Result'].Text := 'Found index: ' Result '; Last index: ' (LastIndex??'')
            this.ShowTooltip('Done!')
        }

        HClickButtonModifyArray(*) {
            Flag := 1
            if EG.HasOwnProp('MG') {
                try {
                    EG.MG.Show()
                    Flag := 0
                }
            }
            if Flag {
                EG.MG := MG := Gui('-DPIScale +Resize')
                MG.Index := 1
                MG.SetFont('S11 Q5')
                this.SetFonts(MG, this.Options.FontMono)
                MG.Add('Button', 'Section vBtnPrevious', 'Previous').OnEvent('Click', HClickButtonPrevious)
                MG.Add('Edit', 'ys w70 vEditJump')
                MG.Add('Text', 'ys vTxtOf', 'of')
                MG.Add('Text', 'ys w40 vTxtTotal', '0')
                MG.Add('Button', 'ys vBtnJump', 'Jump').OnEvent('Click', HClickButtonJump)
                MG.Add('Button', 'ys vBtnNext', 'Next').OnEvent('Click', HClickButtonNext)
                MG.Add('Button', 'ys vBtnSave', 'Save').OnEvent('Click', HClickButtonSave)
                Align.CenterV(MG['TxtOf'], MG['BtnPrevious'])
                Align.CenterV(MG['TxtTotal'], MG['BtnPrevious'])
                Align.CenterV(MG['EditJump'], MG['BtnPrevious'])
                MG.SetFont('S10 Q5', this.Options.FontStandard)
                MG['BtnPrevious'].GetPos(, &cy, , &ch)
                X := MG.MarginX
                Y := cy + ch + MG.MarginY + 20
                N := 1
                this.SetFonts(MG, this.Options.FontMono)
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
        }
        _Fill(Str) {
            loop 4 - StrLen(Str) {
                s .= ' '
            }
            return s Str
        }
        HClickButtonPrevious(*) {
            _SetIndex(-1)
        }

        HClickButtonJump(*) {
            _SetIndex(, MG['EditJump'].Text)
        }

        HClickButtonNext(*) {
            _SetIndex(1)
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
            this.ShowTooltip('Created!')
        }
        _Save() {
            if !a.Length {
                this.ShowTooltip('First make an array!.')
                return
            }
            i := (MG.Index - 1) * 100
            loop 5 {
                for n in StrSplit(MG['e' A_Index].Text, '`r`n') {
                    a[++i] := n
                }
            }
        }
        _SetIndex(dx?, n?) {
            if !a.Length {
                this.ShowTooltip('First make an array!.')
                return
            }
            _Save()
            pgs := a.Length / 100
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
                this.ShowTooltip('First make an array!.')
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

    ; not done yet

    ; static CreateScroller(G, Name, PreviousCtrl) {
    ;     G['BtnPrevious_' Name].GetPos(&cx, &cy, &cw, &ch)
    ;     G.Add('Edit', Format('x{} y{} w50 Section vEditJump_{}', cx + cw + G.MarginX, cy, Name), 1).OnEvent('Change', HChangeEditJump)
    ;     G.Add('Text', 'ys vTxtOf_' Name, ' of ')
    ;     G.Add('Text', 'ys w40 vTxtTotal_' Name, '0')
    ;     G.Add('Button', 'ys vBtnJump_' Name, 'Jump').OnEvent('Click', HClickButtonJump)
    ;     G.Add('Button', 'ys vBtnNext_' Name, 'Next ' Name).OnEvent('Click', HClickButtonNext)
    ;     Align.CenterV(G['TxtOf_' Name], G['BtnPrevious_' Name])
    ;     Align.CenterV(G['TxtTotal_' Name], G['BtnPrevious_' Name])
    ;     Align.CenterV(G['EditJump_' Name], G['BtnPrevious_' Name])

    ;     HChangeEditJump(Ctrl, *) {
    ;         Ctrl.Text := RegExReplace(Ctrl.Text, '[^\d]', '', &ReplaceCount)
    ;         ControlSend('{End}', Ctrl)
    ;         if ReplaceCount {
    ;             this.ShowTooltip('Numbers only!')
    ;         }
    ;     }
    ;     HClickButtonPrevious(Ctrl, *) {
    ;         if this.IncIndex(_GetName(Ctrl), -1) {
    ;             this.ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
    ;         } else {
    ;             this.UpdateDisplay(_GetName(Ctrl))
    ;         }
    ;     }

    ;     HClickButtonNext(Ctrl, *) {
    ;         if this.IncIndex(_GetName(Ctrl), 1) {
    ;             this.ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
    ;         } else {
    ;             this.UpdateDisplay(_GetName(Ctrl))
    ;         }
    ;     }

    ;     HClickButtonJump(Ctrl, *) {
    ;         if this.SetIndex(_GetName(Ctrl), G['EditJump'].Text) {
    ;             this.ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
    ;         } else {
    ;             this.UpdateDisplay(_GetName(Ctrl))
    ;         }
    ;     }
    ; }
    static UpdateArrayCtrl(ArrCopyObj) {
        k := ArrCopyObj.Start - 1
        while ++k <= ArrCopyObj.End - 1 {
            Str .= Format('{:5}', k) ' : ' ArrCopyObj.Arr[A_Index] '`r`n'
        }
        this.G['Array'].Text := Trim(Str, '`r`n')
    }
    static SetFonts(GuiOrCtrl, FontList) {
        for Font in FontList {
            GuiOrCtrl.SetFont(, Font)
        }
    }
    static ShowTooltip(Str) {
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
    static TestDescriptions := [
        'Searches for the value at the indicated index, and the value is present at the index.'
      , 'Searches for the value at the indicated index, and the value is present both at the indicated index, and on adjacent indices.'
      , 'Searches for the value at the indicated index, and the value absent from the array.'
    ]
}
