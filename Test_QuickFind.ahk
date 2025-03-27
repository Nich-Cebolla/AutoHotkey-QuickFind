
#Include <Object.Prototype.Stringify_V1.0.0>
; https://github.com/Nich-Cebolla/Stringify-ahk/blob/main/Object.Prototype.Stringify.ahk
#Include <Align_V1.0.0>
; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/blob/main/Align.ahk
#Include QuickFind Copy.ahk
#SingleInstance force
Test_QuickFind()

/**
 * @description - Initiates the test.
 * @param {Integer} [Which=1] - One of the following options:
 * - 1: Test `QuickFind.Call`
 * - 2: Test `QuickFind.GetFunc.Prototype.Call`
 */
class Test_QuickFind {

    static BtnCtrlNames := ['Start', 'Pause', 'Stop', 'Exit', 'Reload', 'Clear', 'EqualTo']
    , GreaterThan := [false, true]
    , EqualTo := [false, true]

    static Options := {
        FontOpt: 'S11 Q5'
      , FontStandard: 'Roboto'
      , FontMono: 'Roboto Mono'
    }

    static Paused := 0
    , Stop := 0
    , Init := 0

    static __New() {
        FindIndices := this.FindIndices := [1, 2, 3, 4, 5, 9, 10, 11, 499, 500, 501, 989, 990, 991
        , 994, 995, 996, 998, 999, 1000]
        StartIndices := [1, 100, 500, 900, 999]
        Offsets := [1, 2, 4, 5, 99, 100, 499, 500, 997, 998, 999]
        this.Len := 1000
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
        if !this.HasOwnProp('G') {
            this.CreateGui()
        }
        if this.Paused {
            this.Paused := 0
            Process_Loop()
        } else {
            this.i := { find: 1, gt: 1, et: 1, bounds: 1, array: 1, fn: 1, count: 0 }
            this.Result := []
            this.Problem := []
            this.Paused := 1
            if !this.Init {
                this.Init := 1
                n := 0
                loop {
                    try {
                        this.Functions.Push(Process_%(++n)%)
                    } catch {
                        break
                    }
                }
                static TAS := this.TestArrays, GTS := this.GreaterThan, ETS := this.EqualTo
                , BS := this.Bounds, FIS := this.FindIndices, FNS := this.Functions
                return
            } else {
                Process_Loop()
            }
        }
        if this.Stop {
            this.Stop := this.Paused := 0
        } else if !this.Paused {
            this.ShowTooltip('Done')
        }

        Process_Loop() {
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
                                    FNS[i.fn]()
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
        Process_Main(ExpectedIndex, ExpectedValue, LineNumber) {
            if Which == 1 {
                Result := QuickFind(TA, GetValue(FI), &FoundValue, GT, ET, B.Start, B.End)
            } else {
                Result := QuickFind.Func(TA, GT, ET, B.Start, B.End)(GetValue(FI), &FoundValue)
            }
            if Result !== ExpectedIndex || (FoundValue??'') !== ExpectedValue {
                this.Problem.Push(O := _Obj())
                this.G['TxtTotal_Problem'].Text := this.Problem.Length
            } else {
                this.Result.Push(_Obj())
                this.G['TxtTotal_Result'].Text := this.Result.Length
            }

            _Obj() => { i: i.Clone(), FoundIndex: Result, ExpectedIndex: ExpectedIndex, Arr: _CopyArray()
            , FindValue: GetValue(FI), FindIndex: FI, FoundValue: (FoundValue??''), ExpectedValue: ExpectedValue
            , LineNumber: LineNumber }
        }
        GetValue(Index) => i.array == 1 ? Index - 501 : 501 - Index

        /**
         * @description - Searches for the value at the indicated index, and the value is present
         * at the index.
         */
        Process_1() {
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
                Process_Main(FI, GetValue(FI), A_LineNumber)
            } else {
                ; If ET is false, the function fails to find the value when FI - 1 < B.Start || FI + 1 > B.End
                ; depending on the direction fo the array and whether GT is true.
                if GT {
                    if i.array == 1 { ; adcending values.
                        if FI + 1 > B.End {
                            Process_Main('', '', A_LineNumber)
                        } else {
                            Process_Main(FI + 1, GetValue(FI + 1), A_LineNumber)
                        }
                    } else { ; descending values
                        if FI - 1 < B.Start {
                            Process_Main('', '', A_LineNumber)
                        } else {
                            Process_Main(FI - 1, GetValue(FI - 1), A_LineNumber)
                        }
                    }
                } else {
                    if i.array == 1 { ; adcending values.
                        if FI - 1 < B.Start {
                            Process_Main('', '', A_LineNumber)
                        } else {
                            Process_Main(FI - 1, GetValue(FI - 1), A_LineNumber)
                        }
                    } else { ; descending values.
                        if FI + 1 > B.End {
                            Process_Main('', '', A_LineNumber)
                        } else {
                            Process_Main(FI + 1, GetValue(FI + 1), A_LineNumber)
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
        Process_2() {
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
                            Process_Main(FI, GetValue(FI), A_LineNumber)
                        } else {
                            Process_Main(FI - 1, GetValue(FI), A_LineNumber)
                        }
                    } else { ; descending values.
                    ; When GT and descending, the search direction is right-to-left.
                    ; So the correct index is FI + 1 when ET.
                        if FI + 1 > B.End {
                            Process_Main(FI, GetValue(FI), A_LineNumber)
                        } else {
                            Process_Main(FI + 1, GetValue(FI), A_LineNumber)
                        }
                    }
                } else {
                ; ------------------------------------------------------------------
                ; Not equal to -----------------------------------------------------
                ; When !ET, the correct index is +/-2 from FI.
                    if i.array == 1 { ; adcending values.
                        ; Search direction is left-to-right, so next greatest value is at index FI + 2.
                        if FI + 2 > B.End {
                            Process_Main('', '', A_LineNumber)
                        } else {
                            Process_Main(FI + 2, GetValue(FI + 2), A_LineNumber)
                        }
                    } else { ; descending values.
                        ; Search direction is right-to-left.
                        if FI - 2 < B.Start {
                            Process_Main('', '', A_LineNumber)
                        } else {
                            Process_Main(FI - 2, GetValue(FI - 2), A_LineNumber)
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
                            Process_Main(FI, GetValue(FI), A_LineNumber)
                        } else {
                            Process_Main(FI + 1, GetValue(FI), A_LineNumber)
                        }
                    } else { ; descending values.
                    ; Search direction is left-to-right, so correct index is FI - 1 when ET.
                        if FI - 1 < B.Start {
                            Process_Main(FI, GetValue(FI), A_LineNumber)
                        } else {
                            Process_Main(FI - 1, GetValue(FI), A_LineNumber)
                        }
                    }
                } else {
                ; ------------------------------------------------------------------
                ; Not equal to -----------------------------------------------------
                    if i.array == 1 { ; adcending values.
                    ; !GT and ascending, so the search direction is right-to-left.
                    ; The next smallest value is at index FI - 2.
                        if FI - 2 < B.Start {
                            Process_Main('', '', A_LineNumber)
                        } else {
                            Process_Main(FI - 2, GetValue(FI - 2), A_LineNumber)
                        }
                    } else { ; descending values.
                        ; Search direction is left-to-rigth.
                        if FI + 2 > B.End {
                            Process_Main('', '', A_LineNumber)
                        } else {
                            Process_Main(FI + 2, GetValue(FI + 2), A_LineNumber)
                        }
                    }
                }
            }
        }

        /**
         * @description - Searches for the value at the indicated index, and the value absent
         * from the array.
         * - ..., FI-3, FI-2, FI-1, unset, FI+1, FI+2, FI+3, ...
         */
        Process_3() {
            if FI + 1 > this.Len || FI - 1 < 1 {
                return
            }
            TA.Delete(FI)
            TA[FI - 1] := GetValue(FI - 1)
            TA[FI + 1] := GetValue(FI + 1)
            if GT {
                if FI + 1 > B.End || FI - 1 < B.Start {
                    Process_Main('', '', A_LineNumber)
                } else {
                    if i.array == 1 {
                        ; GT=1; ET=any; array=1
                        Process_Main(FI + 1, GetValue(FI + 1), A_LineNumber)
                    } else {
                        ; GT=1; ET=any; array=0
                        Process_Main(FI - 1, GetValue(FI - 1), A_LineNumber)
                    }
                }
            } else {
                if FI + 1 > B.End || FI - 1 < B.Start {
                    Process_Main('', '', A_LineNumber)
                } else {
                    if i.array == 1 {
                        ; GT=0; ET=any; array=1
                        Process_Main(FI - 1, GetValue(FI - 1), A_LineNumber)
                    } else {
                        ; GT=0; ET=any; array=0
                        Process_Main(FI + 1, GetValue(FI + 1), A_LineNumber)
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
        G.Add('Checkbox', 'xs Section Checked vChkStandard', 'Standard function')
        G.Add('Checkbox', 'ys vChkClosure', 'Closure from ``QuickFind.Func``')
        G.Add('Button', 'xs Section vBtnPrevious_Result', 'Previous Result').OnEvent('Click', HClickButtonPrevious)
        G.Add('Button', 'xs Section vBtnPrevious_Problem', 'Previous Problem').OnEvent('Click', HClickButtonPrevious)
        G['BtnPrevious_Problem'].GetPos(, , &cw)
        G['BtnPrevious_Result'].Move(, , cw)
        _CreateScroller('Result')
        _CreateScroller('Problem')
        G['BtnPrevious_Problem'].GetPos(, &cy, , &ch)
        G['ChkClosure'].GetPos(&cx, , &cw)
        G.Add('Edit', Format('x{} y{} w400 r16 Section +Wrap vResult', G.MarginX, cy + ch + G.MarginY))
        G.Add('Edit', 'ys w300 hp vArray')
        G.Show()
        Align.GroupWidth_S([G['BtnNext_Result'], G['BtnNext_Problem']])

        for Ctrl in G {
            if Ctrl.Type == 'Edit' {
                Ctrl.SetFont(, Opt.FontMono)
            }
        }

        return


        HClickButtonClear(*) {
            this.Stop := this.Paused := this.Init := 0
            G['Result'].Text := G['Array'].Text := ''
            G['TxtTotal_Result'].Text := G['TxtTotal_Problem'].Text := '0'
            G['EditJump_Result'].Text := G['EditJump_Problem'].Text := '1'
            this()
        }
        HChangeEditJump(Ctrl, *) {
            Ctrl.Text := RegExReplace(Ctrl.Text, '[^\d]', '', &ReplaceCount)
            ControlSend('{End}', Ctrl)
            if ReplaceCount {
                this.ShowTooltip('Numbers only!')
            }
        }
        HClickButtonStart(*) {
            if G['ChkStandard'].Value {
                if G['ChkClosure'].Value {
                    this.ShowTooltip('I apologize, but this is only compatible with one test at a time. Please check only one box.')
                } else {
                    this(1)
                }
            } else if G['ChkClosure'].Value {
                this(2)
            }
        }
        HClickButtonPause(*) {
            this.Paused := 1
            this.ShowTooltip('Paused.')
        }
        HClickButtonStop(*) {
            this.Stop := 1
            this.ShowTooltip('Stopping.')
        }
        HClickButtonEqualTo(*) {
            this.LaunchEqualToTester()
        }
        HClickButtonExit(*) {
            ExitApp()
        }
        HClickButtonPrevious(Ctrl, *) {
            if this.IncIndex(_GetName(Ctrl), -1) {
                this.ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                this.UpdateDisplay(_GetName(Ctrl))
            }
        }
        HClickButtonNext(Ctrl, *) {
            if this.IncIndex(_GetName(Ctrl), 1) {
                this.ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                this.UpdateDisplay(_GetName(Ctrl))
            }
        }
        HClickButtonReload(*) {
            Reload()
        }
        HClickButtonJump(Ctrl, *) {
            if this.SetIndex(_GetName(Ctrl), G['EditJump'].Text) {
                this.ShowTooltip('No ' StrLower(_GetName(Ctrl)) 's!')
            } else {
                this.UpdateDisplay(_GetName(Ctrl))
            }
        }
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
    }
    static IncIndex(Name, n) {
        if !this.%Name%.Length {
            return 1
        }
        this.SetIndex(Name, this.%Name%Index + n)
        this.G['EditJump_' Name].Text := this.%Name%Index
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
    static UpdateDisplay(Name) {
        ResultObj := this.%Name%[this.%Name%Index]
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
    static LaunchEqualToTester() {
        EG := Gui('-DPIScale +Resize')
        EG.a := []
        EG.SetFont('s11', 'roboto mono')
        EG.add('text', 'section vtxtStart', 'Start value:')
        EG.add('edit', 'ys w70 vinputstartvalue')
        EG.add('text', 'ys vtxtlength', 'Length:')
        EG.add('edit', 'ys w70 vinputlength')
        EG.add('button', 'ys vbtnmake', 'Make').OnEvent('Click', hclickbuttonmake)
        EG.add('text', 'xs section vtxtfind', 'Find:')
        EG.add('edit', 'ys w70 vinput')
        EG.add('text', 'ys vtxtresult', 'Result:')
        EG.Add('edit', 'ys w140 voutput')
        EG.Add('button', 'ys vtest', 'Test').onevent('click', hclickbuttontest)
        EG.Add('checkbox', 'xs Section checked vdirection', 'Search direction')
        EG.add('edit', 'xs section w200 vsetindices')
        EG.add('button', 'ys vbtnsetindices', 'Set indices').Onevent('click', hclickbuttonsetindices)
        ; EG.add('button', 'xs section vmodifyarray', 'Modify array').OnEvent('click', hclickbuttonmodifyarray)
        EG.show()
        EG['output'].Setfont('s10')

        hclickbuttontest(*) {
            Result := QuickFind.EqualTo(EG.a, EG['input'].text, , , EG['direction'].value)
            if IsObject(Result) {
                EG['output'].text := 'Start: ' Result.Start '  End: ' Result.End
            } else {
                EG['output'].text := Result
            }
        }
        ; hclickbuttonmodifyarray(*) {
        ;     MG := Gui('-DPIScale +Resize')
        ;     MG.SetFont('s10', 'roboto mono')
        ;     mg.Add('button', 'Section vbtnprevious', 'Previous').OnEvent('click', hclickbuttonprevious)
        ;     mg.Add('button', 'ys vbtnnext', 'Next').OnEvent('click', hclickbuttonnext)
        ;     mg.Add('button', 'ys vbtnpage1', 'Save').OnEvent('click', hclickbuttonsave)
        ;     mg.Add('edit', 'section w400 ve1')
        ;     loop 19 {
        ;         mg.Add('edit', 'xs w400 ve' A_Index + 1)
        ;     }


        ;     _Page(n) {
        ;         loop 20 {
        ;             MG['e' A_Index].Text := ''
        ;         }
        ;         if EG.a.length {
        ;             k := 0
        ;             i := 500 * (n - 1)
        ;             loop 20 {
        ;                 e := MG['e' A_Index]
        ;                 k++
        ;                 loop 50 {
        ;                     if EG.a.Length < i {
        ;                         break
        ;                     }
        ;                     e.text .= EG.a[++i] ','
        ;                 }
        ;             }
        ;         }
        ;     }
        ; }
        hclickbuttonsetindices(*) {
            split := StrSplit(EG['setindices'].text, ',', '`s`t')
            loop split.length / 2 {
                if split[A_Index * 2] = 'unset' {
                    EG.a.Delete(split[A_Index * 2 - 1])
                } else {
                    EG.a[split[A_Index * 2 - 1]] :=  split[A_Index * 2]
                }
            }
        }
        hclickbuttonmake(*) {
            EG.a := []
            n := number(EG['inputstartvalue'].text)
            EG.a.capacity := EG['inputlength'].text
            loop EG.a.capacity {
                EG.a.push(n++)
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
        while ++k <= ArrCopyObj.End {
            Str .= Format('{:5}', k) ' : ' ArrCopyObj.Arr[A_Index] '`r`n'
        }
        this.G['Array'].Text := Trim(Str, '`r`n')
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

