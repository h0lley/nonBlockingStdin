# nonBlockingStdin
This helps with reading from stdin in a non-blocking manner - especially on Windows.

In most cases,

```
import threadpool
spawn readLine stdin
```

will work just fine for you. But should you want to work with DLLs in Windows while reading from stdin without blocking, you'll have to implement the console input logic yourself, using certain Windows API functions.

`winConsole.nim` wraps said functions while `nonBlockingStdin.nim` provides a simple implementation of the console logic as well as an easy way to read the current console input without blocking: `readStdinNonBlocking`. On systems other than Windows, `readStdinNonBlocking` works with spawn as shown above, so you'd need to compile with `--threads:on`.
