inputsource =
  inputSourceUS: 'com.apple.keylayout.US'
  -- inputSourceZH: 'com.googlecode.rimeime.inputmethod.Squirrel.Rime'
  inputSourceZH: 'com.logcg.inputmethod.LogInputMac.LogInputMacSP'
  inputSourceJP: 'com.google.inputmethod.Japanese.base'
  sourcePosition: (source) =>
    switch source
      when self.inputSourceUS
        return 2
      when self.inputSourceZH
        return 1
      when self.inputSourceJP
        return 3
      else return 0
  switchFromTo: (fromSource, toSource) =>
    fsrcPos = self\sourcePosition fromSource
    tsrcPos = self\sourcePosition toSource
    nextTimes = (tsrcPos - fsrcPos + 3) % 3
    for i = 1, nextTimes
      -- System Preferences -> Keyboard -> Shortcuts -> InputSources -> Select Next Input source in input menu: F18
      (hs.eventtap.event.newKeyEvent({}, 'a', true)\setKeyCode 79)\post!
  selectUS: =>
    self\switchFromTo hs.keycodes.currentSourceID!, self.inputSourceUS
  selectZH: =>
    self\switchFromTo hs.keycodes.currentSourceID!, self.inputSourceZH
  selectJP: =>
    self\switchFromTo hs.keycodes.currentSourceID!, self.inputSourceJP
inputsource
