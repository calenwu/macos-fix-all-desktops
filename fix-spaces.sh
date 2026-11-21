#!/bin/bash
# fix-spaces: reset Dock "Assign To" for selected apps by clicking the Dock menu,
# exactly like doing it by hand: Options > None, then Options > All Desktops.
#
# Needs Accessibility permission for your terminal app
# (System Settings > Privacy & Security > Accessibility). Apps must be in the Dock.
#
# Usage:
#   fix-spaces          reset all apps
#   fix-spaces status   show stored values

APPS=("Obsidian" "Claude" "Slack" "Terminal")

if [ "$1" = "status" ]; then
  defaults read com.apple.spaces app-bindings
  exit 0
fi

osascript - "${APPS[@]}" <<'EOF'
on setAssign(appName, choice)
  tell application "System Events" to tell process "Dock"
    set dockItem to UI element appName of list 1
    perform action "AXShowMenu" of dockItem
    delay 0.4
    tell menu 1 of dockItem
      click menu item "Options"
      delay 0.4
      click menu item choice of menu 1 of menu item "Options"
    end tell
  end tell
  delay 0.4
end setAssign

on run argv
  set failed to {}
  repeat with appName in argv
    set appName to appName as text
    try
      setAssign(appName, "None")
      setAssign(appName, "All Desktops")
    on error errMsg
      set end of failed to appName & ": " & errMsg
    end try
  end repeat
  if failed is {} then
    return "Reset " & (count of argv) & " apps: None -> All Desktops."
  else
    set AppleScript's text item delimiters to linefeed
    return "Some apps failed:" & linefeed & (failed as text)
  end if
end run
EOF
