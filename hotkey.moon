_ = require 'lodash'
conf = require 'conf'
layout = require 'layout'
keyboard = require 'keyboard'
app = require 'app'
bind = hs.hotkey.bind
util = require 'util'
inputsrc = require 'inputsrc'
layout = require 'layout'
notificationCenter = require 'notification'
itunes = hs.itunes

listHyper1 =
  a: inputsrc\selectUS
  b: 'iBooks'
  c: 'Google Chrome'
  d: inputsrc\selectJP
  e: 'Emacs'
  f: 'Waterfox'
  g: 'SourceTree'
  -- h: ''
  i: 'iTunes'
  j: 'IntelliJ IDEA'
  k: 'Dash'
  l: 'Telegram Desktop'
  m: 'Boxy'
  n: 'Finder'
  o: 'OmniFocus'
  p: 'PDF Expert'
  q: 'QQ'
  -- r: 'com.github.alacritty'
  s: inputsrc\selectZH
  t: 'iTerm'
  -- u: 'EuDic'
  v: ''
  -- w: 'WeChat'
  x: 'Xcode'
  -- y: 'com.jetbrains.pycharm'
  z: 'Spark'
  -- ['0']: 'com.axosoft.gitkraken'
  ['1']:  '1Password'
  ["="]: notificationCenter.switchBetweenTodayAndNotifications
  -- ['\\']: -> hs.openConsole true
-- ['=']: ''
listHyper2 =
  a: -> itunes.previous! itunes.play!
  s: -> itunes.playpause!
  d: -> itunes.next! itunes.play!
  x: -> itunes.volumeDown!
  c: -> itunes.volumeUp!
  f: -> layout\toggleFullScreen!

bind {}, 'f17', keyboard\toggleInternalKeyboard

for k, v in pairs listHyper1
  if type(v) == 'function'
    bind conf.hyper1, k, v
  -- elseif #v > 0
  --   bind conf.hyper1, k, app.activateByName(v)
    -- bind conf.hyperSpace, k, app.toggleByBundleID(v, true)

for k, v in pairs listHyper2
  if type(v) == 'function'
    bind conf.hyper2, k, v
