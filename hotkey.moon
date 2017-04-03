_ = require 'lodash'
conf = require 'conf'
layout = require 'layout'
keyboard = require 'keyboard'
app = require 'app'
bind = hs.hotkey.bind
util = require 'util'
inputsrc = require 'inputsrc'
notificationCenter = require 'notification'

listLcag =
  a: inputsrc\selectUS
  b: 'com.apple.iBooksX'
  -- c: 'com.google.Chrome'
  d: inputsrc\selectJP
  e: 'org.gnu.Emacs'
  -- f: 'org.mozilla.firefox'
  g: 'com.torusknot.SourceTreeNotMAS'
  -- h: ''
  i: 'com.apple.iTunes'
  -- j: 'com.jetbrains.intellij'
  -- k: ''
  l: 'org.telegram.desktop'
  m: 'tombeverley.wmail'
  n: 'com.apple.finder'
  o: 'com.agilebits.onepassword-osx'
  p: 'com.readdle.PDFExpert-Mac'
  q: 'com.tencent.qq'
  r: ''
  s: inputsrc\selectCHS
  t: 'com.googlecode.iterm2'
  u: 'com.eusoft.eudic'
  v: ''
  w: 'com.tapbots.TweetbotMac'
  x: 'com.apple.dt.Xcode'
  -- y: 'com.jetbrains.pycharm'
  z: 'com.tencent.xinWeChat'
  -- ['0']: 'com.axosoft.gitkraken'
  -- ['1']: layout\leftOneThird
  -- ['2']: layout\rightHalf
  -- ['3']: layout\max
  -- ['4']: layout\screen
  ["'"]: notificationCenter.switchBetweenTodayAndNotifications
  ['\\']: -> hs.openConsole true
-- ['=']: ''
listHyper =
  a: ''
  b: ''
  c: ''
  d: layout\screen
  e: ''
  f: ''
  g: ''
  h: layout\leftOneThird
  i: ''
  j: layout\leftHalf
  k: layout\leftTwoThird
  l: layout\rightTwoThird
  m: layout\rightDownCorner
  n: ''
  o: ''
  p: layout\rightUpCorner
  q: layout\leftUpCorner
  r: ''
  s: ''
  t: ''
  u: ''
  v: ''
  w: ''
  x: ''
  y: ''
  z: layout\leftDownCorner
  [';']: layout\rightHalf
  ["'"]: layout\rightOneThird
  ['space']: layout\max

bind {}, 'f17', keyboard\toggleInternalKeyboard

for k, v in pairs listLcag
  if type(v) == 'function'
    bind conf.lcag, k, v
  elseif #v > 0
    bind conf.lcag, k, app.activateByBundleID(v)
    -- bind conf.hyper1, k, app.toggleByBundleID(v, true)

for k, v in pairs listHyper
  if type(v) == 'function'
    bind conf.hyper, k, v
