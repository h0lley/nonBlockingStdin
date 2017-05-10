
type
    Handle* = int
    cppbool* = int32
    
    Coord {.final, pure.} = object
        X*: int16
        Y*: int16
    SmallRect {.final, pure.} = object
        Left*: int16
        Top*: int16
        Right*: int16
        Bottom*: int16
    
    CharUnion {.final, pure, union.} = object
        UnicodeChar*: uint16
        AsciiChar*: char
    KeyEventRecord {.final, pure.} = object
        bKeyDown*: cppbool
        wRepeatCount*: uint16
        wVirtualKeyCode*: uint16
        wVirtualScanCode*: uint16
        uChar*: CharUnion
        dwControlKeyState*: uint32
    MouseEventRecord {.final, pure.} = object
        dwMousePosition*: Coord
        dwButtonState*: uint32
        dwControlKeyState*: uint32
        dwEventFlags*: uint32
    WindowBufferSizeRecord {.final, pure.} = object
        dwSize*: Coord
    MenuEventRecord {.final, pure.} = object
        dwCommandId: uint32
    FocusEventRecord {.final, pure.} = object
        bSetFocus: cppbool
    EventUnion {.final, pure, union.} = object
        KeyEvent*: KeyEventRecord
        MouseEvent*: MouseEventRecord
        WindowBufferSizeEvent*: WindowBufferSizeRecord
        MenuEvent: MenuEventRecord
        FocusEvent: FocusEventRecord
    InputRecord* {.final, pure.} = object
        EventType*: uint16
        Event*: EventUnion
    
    ConsoleScreenBufferInfo* {.final, pure.} = object
        dwSize*: Coord
        dwCursorPosition*: Coord
        wAttributes*: uint16
        srWindow*: SmallRect
        dwMaximumWindowSize*: Coord
        

const
    STD_INPUT_HANDLE* = -10'i32
    STD_OUTPUT_HANDLE* = -11'i32
    STD_ERROR_HANDLE* = -12'i32
    FOCUS_EVENT* = 0x0010
    KEY_EVENT* = 0x0001
    MENU_EVENT* = 0x0008
    MOUSE_EVENT* = 0x0002
    WINDOW_BUFFER_SIZE_EVENT* = 0x0004


proc getStdHandle* (nStdHandle: int32): Handle
    {.stdcall, dynlib: "kernel32", importc: "GetStdHandle".}

proc getNumberOfConsoleInputEvents* (hConsoleInput: Handle, lpcNumberOfEvents: var uint32): bool
    {.stdcall, dynlib: "kernel32", importc: "GetNumberOfConsoleInputEvents", discardable.}

proc peekConsoleInput* (hConsoleInput: Handle, lpBuffer: ptr InputRecord,
    nLength: uint32, lpNumberOfEventsRead: var int32): bool
    {.stdcall, dynlib: "kernel32", importc: "PeekConsoleInputA", discardable.}

proc flushConsoleInputBuffer* (hConsoleInput: Handle): bool
    {.stdcall, dynlib: "kernel32", importc: "FlushConsoleInputBuffer", discardable.}

proc getConsoleScreenBufferInfo* (hConsoleOutput: Handle,
    lpConsoleScreenBufferInfo: var ConsoleScreenBufferInfo): bool
    {.stdcall, dynlib: "kernel32", importc: "GetConsoleScreenBufferInfo", discardable.}

proc setConsoleCursorPosition* (hConsoleOutput: Handle, dwCursorPosition: Coord): bool
    {.stdcall, dynlib: "kernel32", importc: "SetConsoleCursorPosition", discardable.}

proc writeConsole* (hConsoleOutput: Handle, lpBuffer: pointer,
    nNumberOfCharsToWrite: uint32, lpNumberOfCharsWritten: var uint32): bool
    {.stdcall, dynlib: "kernel32", importc: "WriteConsoleA", discardable.}
