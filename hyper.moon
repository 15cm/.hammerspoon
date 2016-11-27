_ = require 'lodash'
conf = require 'conf'
mouse = require 'mouse'
layout = require 'layout'
app = require 'app'
bind = hs.hotkey.bind
util = require 'util'
list =
  -- a: See in key.moon
  b: 'com.tapbots.TweetbotMac'
  c: 'com.google.Chrome'
  -- d: See in key.moon
  e: 'org.gnu.Emacs'
  f: 'org.mozilla.firefox'
  g: 'com.torusknot.SourceTreeNotMAS'
  h: ''
  i: 'com.apple.iTunes'
  j: ''
  k: ''
  l: 'org.telegram.desktop'
  m: 'com.francescodilorenzo.Mailbro'
  n: 'com.apple.finder'
  o: 'com.agilebits.onepassword-osx'
  p: 'com.readdle.PDFExpert-Mac'
  q: 'com.tencent.qq'
  r: ''
  -- s: See in key.moon
  t: 'com.googlecode.iterm2'
  u: ''
  v: ''
  w: 'com.tencent.xinWeChat'
  x: ''
  y: ''
  z: ''
  ['0']: ''
  -- ['0']: 'com.axosoft.gitkraken'
  ['1']: -> util\reload!
  -- ['1']: 'co.zeit.hyperterm'
  ['2']: ''
  [',']: ''
  ['.']: ''
  ['\\']: -> hs.openConsole true
  ['-']: ''
  ['=']: ''
  -- tab: layout\screen
  escape: ''
  up: layout\upHalf
  down: layout\downHalf
for k, v in pairs list
  if type(v) == 'function'
    bind conf.hyper0, k, v
  elseif #v > 0
    bind conf.hyper0, k, app.toggleByBundleID(v)
    -- bind conf.hyper1, k, app.toggleByBundleID(v, true)
