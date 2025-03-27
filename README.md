
## Description
An AutoHotkey (AHK) implementation of a binary search.

This function performs a binary search on a sorted array, returning the index of the target value if found, or an empty string if not found. A binary search is when you split a range in half repeatedly to narrow in on an input value.

A binary search is optimal when there is little information known about the value that is being searched for and the distribution of values in the array, as this will, on average, require much less processing time to identify the needed value compared to a sequential search.

Within the file `QuickFind_CharExample.ahk` you will find an example of how to use `QuickFind` to search for a word in an array sorted alphabetically.

### V1.1.0:
The function has been changed to a class. Nothing has changed about the `QuickFind` function itself; it is still called from `QuickFind()`.

Added `QuickFind.Func()` which initializes the needed values that are initialized at the start of `QuickFind`, then returns a closure that can be called repeadly to search the input array. This will perform slightly better compared to calling `QuickFind` multiple times for the same input array.

### V1.2.0
Added `QuickFind.Equality`. `QuickFind.Equality` performs a binary search with only an equality condition.

`Test_QuickFind.ahk` has been completely reworked and now features a helpful Gui that can be used for debugging. It requires two dependencies which are linked in the file.

### AutoHotkey Forum Link
https://www.autohotkey.com/boards/viewtopic.php?f=83&t=135897

## QuickFind - Details
- The array is assumed to be in order of value.
- The array may have unset indices as long as every set index is in order.
- Items may be objects - set `ValueCallback` to return the item value.
```ahk
MyArr := [ { prop: 1 }, { prop: 22 }, { prop: 1776 } ]
AccessorFunc(Item, *) {
    return Item.prop
}
MsgBox(QuickFind(MyArr, 22, , , , , AccessorFunc)) ; 2
```
- `QuickFind` determines the search direction internally to allow you to make a decision based on whether you want to find the next greatest or next lowest value. If search direction is relevant to your script or function, the direction is defined as:
  - When `Condition` is ">" or ">=", the search direction is the the same as the direction of ascent (the search direction is the same as the direction values increase).
  - When `Condition` is "<" or "<=", the search direction is the inverse of the direction of ascent (the search direction is the same as the direction values decrease).
  - If every set index within the array contains the same value, and that value satisfies the condition, and at least one set index falls between `IndexStart` and `IndexEnd`, then the function defaults to returning the first set index between `IndexStart` and `IndexEnd` from left-to-right.

#### Parameters
- {Array} Arr - The array to search.
- {Number|Object} Value - The value to search for. This value may be an object as long as its numerical value can be returned by the `ValueCallback` function. This is not required to be an object when the items in the array are objects; it can be either an object or number. If `ValueCallback` accepts more than just the object as a parameter ({@link QuickFind.Call~ValueCallback}) then it is recommended to pass `Value` as a number, or make the second and third parameters of the callback optional.
- {VarRef} [OutValue] - A variable that will receive the value at the found index.
- {String} [Condition='>='] - The inequality symbol indicating what condition satisfies the search. Valid values are:
  - ">": `QuickFind` returns the index of the first value greater than the input value.
  - ">=": `QuickFind` returns the index of the first value greater than or equal to the input value.
  - "<": `QuickFind` returns the index of the first value less than the input value.
  - "<=": `QuickFind` returns the index of the first value less than or equal to the input value.
- {Number} [IndexStart=1] - The index to start the search at.
- {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the array is used.
- {Func} [ValueCallback] - A function that returns the item's numeric value. The function can accept up to three parameters, in this order. If not using one of the parameters, be sure to include the necessary `*` symbol to avoid a runtime error.
  - The current item being evaluated.
  - The item's index.
  - The input array.
```ahk
; Assume for some reason I have an array that, on the odd indices contains an item with a
; property `Prop`, and on the even indices contains an item with a key `key`.
MyArr := [ { Prop: 1 }, Map('key', 22), { Prop: 55 }, Map('key', 55), { Prop: 1776 } ]
; I don't need the array object for my function to accomplish it's task, so I put `*` to
; ignore that parameter.
AccessorFunc(Item, Index, *) {
    if Mod(Index, 2) {
        return Item.Prop
    } else {
        return Item['key']
    }
}
; I could also accomplish the same thing like this
AccessorFuncBetter(Item, *) {
    if Type(Item) == 'Map' {
        return Item['key']
    } else {
        return Item.Prop
    }
}
```

#### Returns
- {Integer} - The index of the first value that satisfies the condition.

## QuickFind.Func - Details
Added V1.1.0
- The array does not need to have the same values in it each time the function is called, but these conditions must be true for the function to return the expected result:
  - The array must be sorted in the same direction as it was when the function object was created.
  - The array cannot be a shorter length than `IndexEnd`.
  - The array could be longer than `IndexEnd`, but any values past `IndexEnd` are ignored.
- The reference count for the input array is incremented by 1. If you need to dispose the array, you will have to call `Dispose` on this object to get rid of that reference. Calling the function after `Dispose` results in an error.
- The function parameters are:
  - **Value** - The value to search for.
  - **OutValue** - A variable that will receive the value at the found index.
```ahk
Arr := [1, 5, 12, 19, 44, 101, 209, 209, 230, 1991]
Finder := QuickFind.Func(Arr)
Index := Finder(12, &Value)
MsgBox(Index) ; 3
MsgBox(Value) ; 12
; Do more work
; When finished
Finder.Dispose()
Index := Finder(44, &Value) ; Error: This object has been disposed.
```

#### Parameters
- {Array} Arr - The array to search.
- {String} [Condition='>='] - The inequality symbol indicating what condition satisfies the search. Valid values are:
  - ">": `QuickFind` returns the index of the first value greater than the input value.
  - ">=": `QuickFind` returns the index of the first value greater than or equal to the input value.
  - "<": `QuickFind` returns the index of the first value less than the input value.
  - "<=": `QuickFind` returns the index of the first value less than or equal to the input value.
- {Number} [IndexStart=1] - The index to start the search at.
- {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the array is used.
- {Func} [ValueCallback] - A function that returns the item's numeric value. The function can accept up to three parameters, in this order. If not using one of the parameters, be sure to include the necessary `*` symbol to avoid a runtime error.
  - The current item being evaluated.
  - The item's index.
  - The input array.

#### Returns
- {QuickFind.Func} - The function object.

The function parameters are:
- {Number|Object} Value - The value to search for.
- {VarRef} [OutValue] - A variable that will receive the value at the found index.

## QuickFind.Equality - Details
Added V1.2.0
Performs a binary search on an array to find one or more indices that contain the input value. This function has these characteristics:
- The array is assumed to be in order of value.
- The array may have unset indices as long as every set index is in order.
- Items may be objects - set `ValueCallback` to return the item value.
- The search direction is always left-to-right. If there are multiple indices with the input value, the index returned by the function will be the lowest index, and the index assigned to `OutLastIndex` will be the highest index.

#### Parameters
- {Array} Arr - The array to search.
- {Number|Object} Value - The value to search for. This value may be an object as long as its numerical value can be returned by the `ValueCallback` function. This is not required to be an object when the items in the array are objects; it can be either an object or number.
- {VarRef} [OutLastIndex] - If there are multiple indices containing the input value, `QuickFind.Equality` assigns to this variable the last index which contains the input value. If there is one index containing the input value, `OutLastIndex` will be the same as the return value.
- {Number} [IndexStart=1] - The index to start the search at.
- {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the array is used.
- {Func} [ValueCallback] - The function that returns the item's numeric value. The function can accept up to three parameters, in this order:
  - The current item being evaluated.
  - The item's index.
  - The input array.

#### Returns
- {Integer} - The index of the first value that satisfies the condition.

## Limitations
- The array is assumed to be in order of value.
- The test script is currently tied to the Gui, and so cannot (easily) be included as part of an automated validation process.
- `QuickFind.Equality` does not have an associated `QuickFind.Func.Equality`. The initialization overhead for `QuickFind.Equality` is quite a bit less compared to `QuickFind.Call`, so it's not a major loss, but is still not ideal.

## Implementation Details
The point at which the binary search stops is calculated using this relationship:
- `R * 0.5 ** (Z + 1) * S <= H`
- R Is the range `IndexEnd - IndexStart + 1`.
- Z is the unknown variable found to satisfy the relationship, which becomes the `StopBinary` value.
- S is an approximation of the number of operations required to search 1 index sequentially (14).
- H is an approximation of the number of operations required to halve the range (27).
- This relationship assumes each operation is atomic. Passing a value to a function is counted as an operation.

## Contents

### QuickFind.ahk
Contains the code for the `QuickFind` class.

### Test_QuickFind.ahk
A comprehensive validation test for `QuickFind`.

### QuickFind_CharExample.ahk
Demonstrates how to use `QuickFind` to search for a word in an array sorted alphabetically.

### Words.ahk
Contains an array of words sorted alphabetically, for testing QuickFind_CharExample.ahk.

2025-03-27 - V1.2.0
- Breaking changes
  - The parameters for `QuickFind` have been simplified.
  - `ValueCallback` now accepts three parameters, `Item, Index, Arr`.
- Major updates
  - Added `QuickFind.Equality`. `QuickFind.Equality` performs a binary search with only an equality condition.
  - Completely reworked the test script. It now features a helpful gui that can be used to debug the function.
  - Removed `Debug_QuickFind.ahk` as it is now replaced by the more useful test gui.
- Minor updates
  - Removed `QuickFind.GetWordValueFunc`.
  - Adjusted `QuickFind.WordValueCache` to be case insensitive.
  - Restructured and optimized `QuickFind.Func.Call`. It now returns a closure instead of a boundfunc, and is slightly more efficient compared to its predecessor.
  - Reworked the structure and approach used by `QuickFind.Call`. The logic is essentially the same, but how the logic is implemented is more streamlined, easier to understand, and easier to adjust. It also mirrors the approach used by `QuickFind.Func.Call`, so updating both will be much simpler if needed.
  - Added in comments explaining the various sections of the functions.
  - Updated some of the parameter hints.
  - Added fold regions into the code.
  - Adapted `QuickFind.GetWordValue` to the changes and updated `QuickFind_CharExample.ahk`.

2025-03-16 - V1.1.0
- Converted the function into a class. The function can still be called from `QuickFind()`.
- Added static method `GetWordValue` which can be called to get a number that can be used for various word sorting operations.
- Added static property `GetWordValueFunc` which returns a function object for `GetWordValue`.
- Added a nested class `QuickFind.Func`. When called, it returns a function object that can be called repeatedly to search an input array.
- Updated Test_QuickFind.ahk to allow testing `QuickFind.Func`.
- Updated QuickFind_CharExample.ahk to reflect these changes.

2025-02-23 - V1.0.0
- Added `QuickFind_CharExample.ahk`
- Standardized what value is received by `OutValue`. Previously, I had overlooked this and sometimes it received the unmodified value from the array, and sometimes it received the value after it was processed by `GetValue`. Now, it always receives the unmodified value.

2025-02-16 - V1.0.0
- Uploaded library
