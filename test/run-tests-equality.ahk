
#include test-equality.ahk

t()

t() {
    if result := test(&descriptions) {
        OutputDebug(descriptions '`n')
        sleep 1
    }
    if result2 := test.Callback(&descriptions) {
        OutputDebug(descriptions '`n')
        sleep 1
    }
    if result3 := test.Func(&descriptions) {
        OutputDebug(descriptions '`n')
        sleep 1
    }
}
