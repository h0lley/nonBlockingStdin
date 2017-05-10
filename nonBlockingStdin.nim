
when defined(Windows):
    import winConsole
  
    const
        VK_LEFT = 0x25
        VK_UP = 0x26
        VK_RIGHT = 0x27
        VK_DOWN = 0x28
        VK_ESCAPE = 0x1B
        VK_RETURN = 0x0D
        VK_BACK = 0x08
    
    type consoleInputState* = tuple[
        current: string,
        previous: string,
        isReady: bool]
    
    proc listenForConsoleInput (state: var consoleInputState) =
        const EventsToPull = 3
        
        let
            consoleInputHandle = getStdHandle(StdInputHandle)
            consoleOutputHandle = getStdHandle(StdOutputHandle)
        var
            consoleInput: array[EventsToPull, InputRecord]
            eventsPulled: int32
            whitespaceChar = ' '
        
        if peekConsoleInput(consoleInputHandle, addr consoleInput[0], EventsToPull, eventsPulled):
            if 0 < eventsPulled:
                flushConsoleInputBuffer(consoleInputHandle)
                
                for eventIndex in 0..<eventsPulled:
                    if consoleInput[eventIndex].EventType == KeyEvent and
                        consoleInput[eventIndex].Event.KeyEvent.bKeyDown == 1:
                        
                        var
                            written: uint32
                            consoleInfo: ConsoleScreenBufferInfo
                        
                        getConsoleScreenBufferInfo(consoleOutputHandle, consoleInfo)
                        
                        case consoleInput[eventIndex].Event.KeyEvent.wVirtualKeyCode
                            of VkReturn:
                                # Confirm the input
                                state.isReady = true
                                
                                consoleInfo.dwCursorPosition.X = 0
                                consoleInfo.dwCursorPosition.Y += 1
                                setConsoleCursorPosition(consoleOutputHandle, consoleInfo.dwCursorPosition)
                                
                                if state.current.len > 0:
                                    state.previous = state.current
                            
                            of VkBack:
                                # Remove the last character from the input
                                if consoleInfo.dwCursorPosition.X <= 0: break
                                state.current = state.current.substr(0, state.current.len - 2)
                                
                                consoleInfo.dwCursorPosition.X -= 1
                                setConsoleCursorPosition(consoleOutputHandle, consoleInfo.dwCursorPosition)
                                
                                writeConsole(consoleOutputHandle, addr whitespaceChar, 1, written)
                                
                                setConsoleCursorPosition(consoleOutputHandle, consoleInfo.dwCursorPosition)
                                                        
                            of VkDown, VkEscape:
                                # Clear current input
                                state.current = ""
                                
                                consoleInfo.dwCursorPosition.X = 0
                                setConsoleCursorPosition(consoleOutputHandle, consoleInfo.dwCursorPosition)
                                
                                for i in 1..consoleInfo.dwSize.X - 1:
                                    writeConsole(consoleOutputHandle, addr whitespaceChar, 1, written)
                                
                                setConsoleCursorPosition(consoleOutputHandle, consoleInfo.dwCursorPosition)
                            
                            of VkUp:
                                # Insert the previous input - one should suffice
                                if state.previous.len > 0:
                                    state.current = state.previous
                                    
                                    consoleInfo.dwCursorPosition.X = 0
                                    setConsoleCursorPosition(consoleOutputHandle, consoleInfo.dwCursorPosition)
                                
                                    for i in 0..state.previous.high:
                                        writeConsole(consoleOutputHandle, addr state.previous[i], 1, written)
                            
                            of VkLeft, VkRight:
                                # No need for manual caret placement
                                discard
                            
                            else:
                                # Add a character to the input and write it to the console
                                # No need for multiline rules
                                if consoleInfo.dwCursorPosition.X >= consoleInfo.dwSize.X - 1: break
                                
                                # Ignore any input that's not a character
                                if consoleInput[eventIndex].Event.KeyEvent.uChar.UnicodeChar == 0:
                                    break
                                
                                var character = char(consoleInput[eventIndex].Event.KeyEvent.uChar.UnicodeChar)                                                            
                                writeConsole(consoleOutputHandle, addr character, 1, written)
                                
                                state.current &= character
    
    
    proc readStdinNonBlocking* (state: var consoleInputState): string =
        if state.current == nil:
            state.current = ""
            state.previous = ""
            state.isReady = false
        
        if state.isReady:
            result = state.current
            state.current = ""
            state.isReady = false
            
        else:
            listenForConsoleInput(state)
            result = ""

else:
    import threadpool
    
    type consoleInputState* = FlowVar[TaintedString]
    
    proc readStdinNonBlocking* (state: var consoleInputState): string =
        if state == nil:
            result = ""
            state = spawn readLine stdin
        
        elif state.isReady:
            result = ^state
            state = spawn readLine stdin
            
        else:
            result = ""
