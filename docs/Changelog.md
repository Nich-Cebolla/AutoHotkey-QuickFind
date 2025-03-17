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
