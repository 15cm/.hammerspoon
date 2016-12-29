conf = require 'conf'
util = require 'util'
bind = hs.hotkey.bind
_ = require 'lodash'

keyboard = 
  toggleInternalKeyboard: (slient) =>
    () ->
      load = not internalKeyboardEnabled
      res = hs.applescript.applescript("display dialog \"Really #{if load then 'enable' else 'disable'} internal keyboard?\"")
      if res
        hs.execute("echo #{util.getSystemPwd()} | sudo -S #{if load then 'kextload' else 'kextunload'} /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/")
        internalKeyboardEnabled = not internalKeyboardEnabled
        util\notify('内置键盘', if load then '启用' else '禁用') unless slient
        if internalKeyboardEnabled then print 'true' else print 'false'
  isExternalKeyboard: (keyboardType) =>
    return keyboardType == 40
keyboard
