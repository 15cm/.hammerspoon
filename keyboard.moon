conf = require 'conf'
util = require 'util'
bind = hs.hotkey.bind
_ = require 'lodash'

-- isExternalDevice = (e) ->
--   _.includes(conf.externalDevice.productName, e.productName) or _.includes(conf.externalDevice.productID, e.productID)
export internalKeyboardEnabled = true
toggleInternalKeyboard = (slient) ->
  () ->
    load = not internalKeyboardEnabled
    res = hs.applescript.applescript("display dialog \"Really #{if load then 'enable' else 'disable'} internal keyboard?\"")
    if res
      hs.execute("echo #{util.getSystemPwd()} | sudo -S #{if load then 'kextload' else 'kextunload'} /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/")
      internalKeyboardEnabled = not internalKeyboardEnabled
      util\notify('内置键盘', if load then '启用' else '禁用') unless slient
      if internalKeyboardEnabled then print 'true' else print 'false'

bind conf.hyper0, "6", toggleInternalKeyboard(false)

isExternalKeyboard = (type) ->
  _.includes conf.externalDevice, type

isExternalKeyboard


-- checkKeyboard = ->
--   for k, v in pairs(hs.usb.attachedDevices())
--     print v.productName, ": ", v.productID
--     if isExternalDevice v
--       return toggleInternalKeyboard false, true
--   toggleInternalKeyboard true, true


-- export usbWatcher = hs.usb.watcher.new((e)->
--   checkKeyboard!
-- )\start!

-- export caffeinateWatcher = hs.caffeinate.watcher.new((e) ->
--   -- 5, lock; 6, unlock;
--   -- sleep display: 3, 10; 4, 11
--   -- sleep: 3, 10, 0, 4, 11
--   if e == hs.caffeinate.watcher.screensDidUnlock
--     checkKeyboard!
-- )\start!

-- checkKeyboard!

-- hasExternalDevice = ->
--   for k, v in pairs(hs.usb.attachedDevices())
--     if isExternalDevice v
--       return true
--   return

-- hasExternalDevice
