notificationCenter =
  switchBetweenTodayAndNotifications: () ->
    hs.osascript.applescript('
    try
      tell application "System Events"
          -- tell process "SystemUIServer"
          --     click menu bar item "Notification Center" of menu bar 1
          -- end tell
          tell application "System Events"
              tell process "Notification Center"
                  if value of radio button "Today" of radio group 1 of window "NotificationTableWindow" is equal to 1 then
                      click radio button "Notifications" of radio group 1 of window "NotificationTableWindow"
                  else
                      click radio button "Today" of radio group 1 of window "NotificationTableWindow"
                  end if
              end tell
          end tell
      end tell
    end try
    ')
  -- send tab after switching
    (hs.eventtap.event.newKeyEvent({}, 'a', true)\setKeyCode 48)\post!
    (hs.eventtap.event.newKeyEvent({}, 'a', false)\setKeyCode 48)\post!
notificationCenter
