---
name: macos-window-control
description: Move, resize, and interact with macOS windows and system UI elements — including off-screen windows — using AppleScript via System Events. Use when a window is stuck off-screen, a dialog can't be clicked, or any window/button/menu manipulation is needed.
---

## What I do

Given a window manipulation task (move an off-screen window, click a button in a dialog, minimize/restore a window, interact with a menu), I use AppleScript via `System Events` to:

1. Identify which process and window is involved
2. Read its current position and size
3. Move, resize, click, or otherwise interact with it
4. Confirm success with a follow-up screenshot if needed

---

## Core capabilities (all confirmed working)

### List windows for a process

```applescript
tell application "System Events"
  tell process "AppName"
    set wins to every window
    repeat with w in wins
      set wName to name of w
      set wPos to position of w
      set wSize to size of w
      -- wPos is {x, y}, wSize is {width, height}
    end repeat
  end tell
end tell
```

### Move a window (including off-screen recovery)

```applescript
tell application "System Events"
  tell process "AppName"
    set position of window 1 to {200, 200}
  end tell
end tell
```

To move a window by name:

```applescript
tell application "System Events"
  tell process "AppName"
    set position of window "Window Title" to {200, 200}
  end tell
end tell
```

### Resize a window

```applescript
tell application "System Events"
  tell process "AppName"
    set size of window 1 to {800, 600}
  end tell
end tell
```

### Click a button (by description, NOT by name)

Buttons are found by their `description` attribute, not `name`. Always use description or index:

```applescript
-- By description
tell application "System Events"
  tell process "AppName"
    tell window 1
      set btns to every button
      repeat with b in btns
        if description of b is "close button" then click b
      end repeat
    end tell
  end tell
end tell

-- By index (1=close, 2=fullscreen, 3=minimize on standard windows)
tell application "System Events"
  tell process "AppName"
    click button 1 of window 1
  end tell
end tell
```

### Minimize / restore a window

```applescript
-- Minimize
tell application "System Events"
  tell process "AppName"
    set value of attribute "AXMinimized" of window 1 to true
  end tell
end tell

-- Restore
tell application "System Events"
  tell process "AppName"
    set value of attribute "AXMinimized" of window 1 to false
  end tell
end tell
```

### Click a menu bar item

```applescript
tell application "System Events"
  tell process "AppName"
    click menu bar item "View" of menu bar 1
    -- then interact with menu items:
    click menu item "Zoom" of menu "View" of menu bar item "View" of menu bar 1
  end tell
end tell
```

### Press a key in a focused window

```applescript
tell application "AppName"
  activate
end tell
tell application "System Events"
  key code 53  -- Escape
  -- or:
  keystroke "w" using command down  -- Cmd+W
  -- or:
  key code 36  -- Return/Enter
end tell
```

Common key codes: 36=Return, 53=Escape, 49=Space, 51=Delete, 123=Left, 124=Right, 125=Down, 126=Up

### Click a specific UI element (button, checkbox, etc.) in a dialog

```applescript
tell application "System Events"
  tell process "AppName"
    tell window 1
      -- List all buttons first
      set btns to every button
      -- Then click the right one
      click button "OK"  -- if button has a title
      -- or by description if no title
    end tell
  end tell
end tell
```

---

## Off-screen window recovery workflow

This is the primary use case. Steps:

1. **Find the process** — list running processes, identify by name or PID
2. **Check position** — if `x < -1000` or `y < -1000` or `x > screen_width`, it's off-screen
3. **Move it on-screen** — set position to something safe like `{200, 200}`
4. **Interact** — click buttons, fill fields, dismiss

```bash
# Step 1: Find the process owning the off-screen window
osascript -e 'tell application "System Events" to get name of every process whose background only is false'

# Step 2: Check position of all windows in that process
osascript << 'EOF'
tell application "System Events"
  tell process "ProcessName"
    set wins to every window
    repeat with w in wins
      log (name of w) & " at " & ((item 1 of position of w) as text) & "," & ((item 2 of position of w) as text)
    end repeat
  end tell
end tell
EOF

# Step 3: Move it on-screen
osascript -e 'tell application "System Events" to tell process "ProcessName" to set position of window 1 to {200, 200}'
```

---

## Important caveats and gotchas

- **Button names vs descriptions:** `name of button` often returns `missing value`. Always use `description of button` (e.g. `"close button"`, `"minimize button"`, `"full screen button"`) or click by index.
- **Accessibility permissions:** The terminal/shell running `osascript` must have Accessibility access granted in System Settings > Privacy & Security > Accessibility. If you see `-25211`, that process needs access.
- **Background-only processes:** Some system processes (like `KerberosExtension`) set `background only = true` and their windows are invisible to `System Events`. In that case, CGWindowListCopyWindowInfo (Swift/ObjC) can see the window geometry but AXUIElement cannot interact with it — killing and restarting the process is often the only option.
- **Window index:** `window 1` is the frontmost window of a process, not necessarily index 1 in a list. Use `windows` (plural) and iterate if there are multiple.
- **Ghostty / terminal itself:** When the terminal running osascript needs accessibility, it may prompt for permission. Grant it in System Preferences.

---

## Diagnosing a stuck/off-screen dialog fast

```bash
# 1. Take a screenshot to see current state
screencapture -x ~/Desktop/debug.png

# 2. List all visible processes
osascript -e 'tell application "System Events" to get name of every process whose background only is false'

# 3. For each suspicious process, list its windows and positions
osascript << 'EOF'
tell application "System Events"
  tell process "PROCESS_NAME"
    set wins to every window
    repeat with w in wins
      set pos to position of w
      set sz to size of w
      log (name of w) & ": x=" & (item 1 of pos) & " y=" & (item 2 of pos) & " w=" & (item 1 of sz) & " h=" & (item 2 of sz)
    end repeat
  end tell
end tell
EOF

# 4. Move any off-screen window on-screen
osascript -e 'tell application "System Events" to tell process "PROCESS_NAME" to set position of window 1 to {200, 200}'

# 5. Take another screenshot to confirm
screencapture -x ~/Desktop/after_move.png
```
