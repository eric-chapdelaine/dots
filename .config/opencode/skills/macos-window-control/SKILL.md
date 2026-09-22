---
name: macos-window-control
description: Move, resize, and interact with macOS windows and system UI elements — including off-screen windows — using AppleScript via System Events. Use when a window is stuck off-screen, a dialog can't be clicked, or any window/button/menu manipulation is needed.
---

## Off-screen window recovery (primary use case)

```bash
# 1. Find the process
osascript -e 'tell application "System Events" to get name of every process whose background only is false'

# 2. Check window position
osascript << 'EOF'
tell application "System Events"
  tell process "PROCESS_NAME"
    set wins to every window
    repeat with w in wins
      log (name of w) & ": x=" & (item 1 of position of w) & " y=" & (item 2 of position of w)
    end repeat
  end tell
end tell
EOF

# 3. Move on-screen
osascript -e 'tell application "System Events" to tell process "PROCESS_NAME" to set position of window 1 to {200, 200}'

# 4. Confirm
screencapture -x ~/Desktop/after_move.png
```

---

## Common operations

**Move / resize:**
```applescript
tell application "System Events"
  tell process "AppName"
    set position of window 1 to {200, 200}
    set size of window 1 to {800, 600}
  end tell
end tell
```

**Click a button** — use `description`, not `name` (name is often `missing value`):
```applescript
tell application "System Events"
  tell process "AppName"
    tell window 1
      -- By description:
      repeat with b in every button
        if description of b is "close button" then click b
      end repeat
      -- By index (1=close, 2=fullscreen, 3=minimize):
      click button 1 of window 1
    end tell
  end tell
end tell
```

**Minimize / restore:**
```applescript
tell application "System Events"
  tell process "AppName"
    set value of attribute "AXMinimized" of window 1 to true   -- minimize
    set value of attribute "AXMinimized" of window 1 to false  -- restore
  end tell
end tell
```

**Keystroke:**
```applescript
tell application "AppName" to activate
tell application "System Events"
  keystroke "w" using command down   -- Cmd+W
  key code 53                        -- Escape
  key code 36                        -- Return
end tell
```

---

## Gotchas

- **Button names:** `name of button` often returns `missing value` — always use `description` or index.
- **Accessibility permissions:** shell running `osascript` must have Accessibility access (System Settings → Privacy → Accessibility). Error `-25211` = missing permission.
- **Background-only processes:** `background only = true` processes (e.g. `KerberosExtension`) are invisible to System Events — killing and restarting is often the only option.
- **`window 1`** is the frontmost window of a process, not index 1 in a list.
