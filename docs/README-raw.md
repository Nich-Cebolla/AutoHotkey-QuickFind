
## Description
An AutoHotkey (AHK) implementation of a binary search.

This function performs a binary search on a sorted array, returning the index of the target value if found, or an empty string if not found. A binary search is when you split a range in half repeatedly to narrow in on an input value.

A binary search is optimal when there is little information known about the value that is being searched for and the distribution of values in the array, as this will, on average, require much less processing time to identify the needed value compared to a sequential search. It's also ideal for situations when the benefit for writing code that analyzes and responds to an array's current distribution of values outweighs the cost of writing and maintaining that code, because this will consistently require a small bit of processing time to perform its function, even on very large arrays.

@@@Link@@@

## Parameters
- {Array} Arr - The array to search.
- {Number|Object} Value - The value to search for. When the values in the array are objects, `Value` can be an object as well as long as the numerical value is accessed using the same accessor as the items. However, this value is not required to be an object when the items are; it may be a number regardless of what type of items are in the array. The inverse is not true; `Value` cannot be an object when the items are not objects.
- {VarRef} [OutValue] - A variable that will receive the value at the found index.
- {Boolean} [GreaterThan=true] - If true, the function searches for the first index with a value that is GreaterThan than the input value. If false, the function searches for the first index with a value that is less than the input value.
- {Boolean} [EqualTo=true] - If true, the condition includes equality. If false, the condition is strictly greater or less than.
- {Number} [IndexStart=1] - The index to start the search at.
- {Number} [IndexEnd] - The index to end the search at. If not provided, the length of the array is used.
- {String} [ValueProp] - The property to use when comparing objects
- {String} [ValueKey] - The key to use when comparing objects.
- {Func|BoundFunc|Closure} [ValueCallback] - The function to use when comparing objects. The function should accept the object as its only parameter, and return a number.

## Returns
- {Integer} - The index of the found value, or an empty string if not found.

## Limitations
- The array is assumed to be in order of value.
- The function cannot search for only an equal value. The condition must include greater than or less than.

## Implementation Details
This function has these characteristics:
- The direction in which this function handles its search is dependent on the value of `GreaterThan` and also the direction the values in the array increase. For example, if `GreaterThan` is true and the values increase from the end of the array to the beginning, the search direction is treated as right to left.
- The array may have unset indices as long as every set index is in order.
- Items may be objects - set the relevant parameter of `ValueProp`, `ValueKey`, or `ValueCallback`.
- The point at which the binary search stops is calculated using this relationship:
 - R 0.5 ** (Z + 1) S <= H
  - R Is the range `IndexEnd - IndexStart + 1`.
  - Z is the unknown variable found to satisfy the relationship, which becomes the `StopBinary` value.
  - S is an approximation of the number of operations required to search 1 index sequentially (14).
  - H is an approximation of the number of operations required to halve the range (27).
 - This relationship assumes each operation is atomic. Passing a value to a function is counted as an operation.

## Contents

### QuickFind.ahk
Contains the code for the `QuickFind` function.

### Test_QuickFind.ahk
A comprehensive validation test for `QuickFind`.

### Debug_QuickFind.ahk
A debug version of `QuickFind`, intended to be used with `Test_QuickFind.ahk` (don't forget to change the #Include statement).
