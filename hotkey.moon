_ = require 'lodash'
conf = require 'conf'
layout = require 'layout'
app = require 'app'
bind = hs.hotkey.bind
util = require 'util'
inputsrc = require 'inputsrc'
listLcag =
  a: inputsrc\selectUS
  b: 'com.tapbots.TweetbotMac'
  c: 'com.google.Chrome'
  d: inputsrc\selectJP
  e: 'org.gnu.Emacs'
  f: 'com.apple.finder'
  g: 'com.torusknot.SourceTreeNotMAS'
  h: ''
  i: 'com.apple.iTunes'
  j: ''
  k: ''
  l: 'org.telegram.desktop'
  m: 'com.francescodilorenzo.Mailbro'
  n: ''
  o: 'com.agilebits.onepassword-osx'
  p: 'com.readdle.PDFExpert-Mac'
  q: 'com.tencent.qq'
  r: ''
  s: inputsrc\selectCHS
  t: 'com.googlecode.iterm2'
  u: ''
  v: ''
  w: 'com.tencent.xinWeChat'
  x: ''
  y: ''
  z: ''
  -- ['0']: 'com.axosoft.gitkraken'
  -- ['1']: layout\leftOneThird
  -- ['2']: layout\rightHalf
  -- ['3']: layout\max
  -- ['4']: layout\screen
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
for k, v in pairs listLcag
  if type(v) == 'function'
    bind conf.lcag, k, v
  elseif #v > 0
    bind conf.lcag, k, app.activateByBundleID(v)
    -- bind conf.hyper1, k, app.toggleByBundleID(v, true)

for k, v in pairs listHyper
  if type(v) == 'function'
    bind conf.hyper, k, v
