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
