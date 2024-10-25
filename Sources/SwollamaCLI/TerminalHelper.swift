import Foundation

protocol TerminalHelper {
    var terminalWidth: Int { get }
}

struct DefaultTerminalHelper: TerminalHelper {
    var terminalWidth: Int {
        var w = winsize()
        guard ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 else {
            return 50 // Default fallback width
        }
        return Int(w.ws_col)
    }
}
