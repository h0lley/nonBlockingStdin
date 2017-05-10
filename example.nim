
import nonBlockingStdin

var state: consoleInputState

while true:
    
    let command = state.readStdinNonBlocking()
    
    if command == "ping":
        echo "pong"
    
    if command == "quit":
        break
