inputsource =
  inputSourceUS: 'com.apple.keylayout.US'
  inputSourceCHS: 'com.sogou.inputmethod.sogou.pinyin'
  inputSourceJP: 'com.google.inputmethod.Japanese.base'
  sourcePosition: (source) =>
    switch source
      when self.inputSourceUS
        return 1
      when self.inputSourceCHS
        return 2
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
  selectCHS: =>
    self\switchFromTo hs.keycodes.currentSourceID!, self.inputSourceCHS
  selectJP: =>
    self\switchFromTo hs.keycodes.currentSourceID!, self.inputSourceJP
inputsource
