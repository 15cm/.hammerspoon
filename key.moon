
-- 取 Apple 键盘和 60% 键盘相同的部分作为基础
-- ,-----------------------------------------------------------------------------------------.
-- |  ESC  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  0  |  -  |  =  | BSPC|BQT|
-- |-----------------------------------------------------------------------------------------|
-- |   TAB  |  Q  |  W  |  E  |  R  |  T  |  Y  |  U  |  I  |  O  |  P  |  [  |  ]  |    \   |
-- |-----------------------------------------------------------------------------------------|
-- |    LCTL    |  A  |  S  |  D  |  F  |  G  |  H  |  J  |  K  |  L  |  ;  |  '  |          |
-- |-----------------------------------------------------------------------------------------|
-- |    LSFT     |  Z  |  X  |  C  |  V  |  B  |  N  |  M  |  ,  |  .  |  /  |      UP       |
-- |-----------------------------------------------------------------------------------------|
  -- | LCTL | LALT | LGUI |  SPC |       SPACE          |  SPC   | RALT | LEFT | DOWN | RGHT |
-- `-----------------------------------------------------------------------------------------'
-- Layer 0(默认层)
-- ,-----------------------------------------------------------------------------------------.
-- |  `/L2   |     |     |     |     |     |     |     |     |     |     |     |     |       |
-- |-----------------------------------------------------------------------------------------|
-- | TAB/L1 |     |     |     |     |     |     |     |     |     |     |     |     |        |
-- |-----------------------------------------------------------------------------------------|
-- |   ESC/LCTL  |     |     |     |     |     |     |     |     |     |     |     |         |
-- |-----------------------------------------------------------------------------------------|
-- |   F17/LSFT   |     |     |     |     |     |     |     |     |     |     |              |
-- |-----------------------------------------------------------------------------------------|
-- |   LCTL|LALT|LGUI|SPC/HYPER0| SPACE/HYPER0 |SPC/HYPER0| RGUI | APP | LEFT  | DOWN  | UP  |
-- `-----------------------------------------------------------------------------------------'
-- Layer 1
-- ,-----------------------------------------------------------------------------------------.
-- |     |     |     |     |     |     |     |     |     |     |     |     |     |    Del    |
-- |-----------------------------------------------------------------------------------------|
-- |      | MPRV | MPLY | MNXT |     |     |     |     |     |     |     |     |     |       |
-- |-----------------------------------------------------------------------------------------|
-- |         | Mute | V- | V+ |     |     |     |    |      |      |     |     |     |       |
-- |-----------------------------------------------------------------------------------------|
-- |     |  iMute |  iV-  | iV+    |    |     |     |     |     |     |     |     |     |    |
-- |-----------------------------------------------------------------------------------------|
-- |                                                                                         |
-- `-----------------------------------------------------------------------------------------'
-- Layer 2 (Hyper0)
-- ,-----------------------------------------------------------------------------------------.
-- |     |     |     |     |     |     |     |     |     |     |     |     |     |           |
-- |-----------------------------------------------------------------------------------------|
-- |        |     |     |     |     |     |     |     |     |     |     |     |     |        |
-- |-----------------------------------------------------------------------------------------|
-- |         |INPUT1|INPUT2|INPUT3|     |     |     |     |     |     |     |     |          |
-- |-----------------------------------------------------------------------------------------|
-- |              |     |     |     |     |     |     |     |     |     |     |              |
-- |-----------------------------------------------------------------------------------------|
-- |     |       |      |      |                                       |      |    |    |    |
-- `-----------------------------------------------------------------------------------------'
_ = require 'lodash'
app = require 'app'
util = require 'util'
conf = require 'conf'
keyboard = require 'keyboard'
mouse = require 'mouse'
codes = hs.keycodes.map
itunes = hs.itunes
codes.leftShift = 56
codes.leftCtrl = 59
codes.leftAlt = 58
codes.leftCmd = 55
codes.rightCMD = 54
codes.rightAlt = 61

{
  :new
  keyStroke: press
  event:
    types:
      :keyDown
      :keyUp
      :flagsChanged
    properties:
      :keyboardEventKeyboardType
    newKeyEvent: keyEvent
    newSystemKeyEvent: sysEvent
} = hs.eventtap

sys = (name, mods={}) ->
  sysEvent(name, true)\setFlags(mods)\post!
  util.delay conf.sysEventTimeout, ->
    sysEvent(name, false)\setFlags(mods)\post!

key = (mods, key, isdown) ->
  -- _.print mods
  -- _.print key
  -- _.print isdown
  key = if _.isNumber key then key else codes[key]
  keyEvent(mods, 'a', isdown)\setKeyCode key

export state = {
  startTime: util.now!
}

appBindingType = ->
  app = hs.application.frontmostApplication!
  if _.includes conf.vimBindingApp, app\bundleID!
    return 'vim'
  elseif _.includes conf.partialVimBindingApp, app\bundleID!
    return 'partial'
  elseif _.includes conf.notEmacsBindingApp, app\bundleID!
    return 'notEmacs'
  else
    return 'other'
isTotalVimBindingApp = ->
  app = hs.application.frontmostApplication!
  return if _.includes conf.totalVimBindingApp, app\bundleID! then true else false
isPartialVimBindingApp = ->
  app = hs.application.frontmostApplication!
  return if _.includes conf.partialVimBindingApp, app\bundleID! then true else false
isVimBindingApp = ->
  return isTotalVimBindingApp or isPartialVimBindingApp
isNotEmacsBindingApp = ->
  app = hs.application.frontmostApplication!
  return if _.includes conf.notEmacsBindingApp, app\bundleID! then true else false

export eventtapWatcher = new({ keyDown, keyUp, flagsChanged }, (e) ->
  keyboardType = e\getProperty keyboardEventKeyboardType
  type, code, flags = e\getType!, e\getKeyCode!, e\getFlags!
  mods = _.keys flags
  -- print math.floor((util.now!-state.startTime+0.5)*100)/100, type, code, _.str(mods)

  isDown = if type == keyUp or type == flagsChanged and _.str(mods) == '{}' then false else true

  if _.includes({codes.space, codes['`'], codes['tab']}, code) and _.str(mods) != '{}'
    return

  -- Mapping according to applications
  -- Emacs binding
  -- C-h: Del
  elseif code == codes['h'] and _.str(mods) == '{"ctrl"}'
      return true, {
        key {}, codes.delete, isDown
        }
  -- C-d: DEl
  elseif code == codes['d'] and _.str(mods) == '{"ctrl"}'
    if not isVimBindingApp!
      return true, {
        key {}, codes.forwarddelete, isDown
        }
  -- C-n: down
  elseif code == codes['n'] and _.str(mods) == '{"ctrl"}'
    if not isTotalVimBindingApp!
      return true, {
        key {}, codes.down, isDown
        }
  -- C-p to up
  elseif code == codes['p'] and _.str(mods) == '{"ctrl"}'
    if not isTotalVimBindingApp!
      return true, {
      key {}, codes.up, isDown
        }
  -- C-f: right
  elseif code == codes['f'] and _.str(mods) == '{"ctrl"}'
    if not isTotalVimBindingApp!
      return true, {
        key {}, codes.right, isDown
        }
  -- C-b: left
  elseif code == codes['b'] and _.str(mods) == '{"ctrl"}'
    if not isTotalVimBindingApp!
      return true, {
        key {}, codes.left, isDown
        }
  -- C-a: home
  elseif code == codes['a'] and _.str(mods) == '{"ctrl"}'
    if isNotEmacsBindingApp!
      return true, {
        key {"fn"}, codes.home, isDown
        }
  -- C-e: end
  elseif code == codes['e'] and _.str(mods) == '{"ctrl"}'
    if isNotEmacsBindingApp!
      return true, {
        key {"fn"}, codes.end, isDown
        }
  -- C-k: kill to end
  elseif code == codes['k'] and _.str(mods) == '{"ctrl"}'
    if isNotEmacsBindingApp!
      return true, {
        key {"cmd", "shift"}, codes.right, isDown
        key {}, codes.delete, isDown
        }
  -- Cmd-C-u: pageup
  elseif code == codes['u'] and _.str(mods) == '{"cmd", "ctrl"}'
      return true, {
        key {}, codes.pageup, isDown
        }
  -- Cmd-C-u: pageup
  elseif code == codes['d'] and _.str(mods) == '{"cmd", "ctrl"}'
      return true, {
        key {}, codes.pagedown, isDown
        }
 -- Alt-f: jump to next word
  elseif code == codes['f'] and _.str(mods) == '{"alt"}'
    if not isTotalVimBindingApp!
      return true, {
        key {"alt"}, codes.right, isDown
        }
  -- Alf-b: jump to previous word
  elseif code == codes['b'] and _.str(mods) == '{"alt"}'
    if not isTotalVimBindingApp!
      return true, {
        key {"alt"}, codes.left, isDown
        }
  -- Alt-d: kill next word
  elseif code == codes['d'] and _.str(mods) == '{"alt"}'
    if not isTotalVimBindingApp!
      return true, {
        key {"alt", "shift"}, codes.right, isDown
        key {}, codes.delete, isDown
        }
  -- Alt-h: kill previous word
  elseif code == codes['h'] and _.str(mods) == '{"alt"}'
    if not isTotalVimBindingApp!
      return true, {
        key {"alt", "shift"}, codes.left, isDown
        key {}, codes.delete, isDown
        }
  -- Mouse Actions
  elseif code == codes['n'] and _.str(mods) == '{"cmd", "ctrl"}'
    mouse.scrollDown!
    return true
  elseif code == codes['p'] and _.str(mods) == '{"cmd", "ctrl"}'
    mouse.scrollUp!
    return true
  elseif keyboard\isExternalKeyboard keyboardType
    return
  -- Mapping for internal keyboard
    -- SPACE -> SPACE/LCAG
  elseif code == codes.space and type == keyDown
    state.spaceDown = true
    state.spaceDownTime = util.now! unless state.spaceDownTime
    return true
  elseif code == codes.space and type == keyUp
    state.spaceDown = false
    if state.spaceCombo
      state.spaceCombo = false
      state.spaceDownTime= nil
      return true
    if not state.spaceCombo and state.spaceDownTime and (util.now! < state.spaceDownTime + conf.oneTapTimeout)
      state.spaceDownTime = nil
      return true, {
        key mods, code, true
        key mods, code, false
      }
    else
      state.spaceDownTime = nil
      state.spaceCombo = false
      return true
  elseif state.spaceDown and _.str(mods) == '{}' and type == keyDown
    state.spaceCombo = true
    mods = _.union mods, conf.lcag
    return true, {
      key mods, code, true
      key mods, code, false
    }
  elseif state.spaceDown and type == keyUp
    return true

  -- LCTL -> ESC/LCTL
  elseif code == codes.leftCtrl and _.str(mods) == '{"ctrl"}' and type == flagsChanged
    state.leftCtrlDown = util.now!
    return true
  elseif code == codes.leftCtrl and _.str(mods) == '{}' and type == flagsChanged
    if state.leftCtrlDown and util.now! < state.leftCtrlDown + conf.oneTapTimeout
      state.leftCtrlDown = false
      return true, {
        key mods, codes.escape, true
        key mods, codes.escape, false
      }
  -- TAB -> TAB/Layer 1
  elseif code == codes['tab'] and type == keyDown
    state.oneDown = true
    return true
  elseif code == codes['tab'] and type == keyUp
    state.oneDown = false
    if state.oneCombo
      state.oneCombo = false
      return true
    else
      return true, {
        key mods, code, true
        key mods, code, false
      }
  elseif state.oneDown and type == keyDown
    state.oneCombo = true
    layer1 =
      -- sys:
      --   q: 'PREVIOUS'
      --   w: 'PLAY'
      --   e: 'NEXT'
      --   a: 'MUTE'
      --   s: 'SOUND_DOWN'
      --   d: 'SOUND_UP'
      --   f: 'ILLUMINATION_DOWN'
      --   g: 'ILLUMINATION_UP'
      --   h: 'ILLUMINATION_TOGGLE'
      key:
        ['1']: 'f1'
        ['2']: 'f2'
        ['3']: 'f3'
        ['4']: 'f4'
        ['5']: 'f5'
        ['6']: 'f6'
        ['7']: 'f7'
        ['8']: 'f8'
        ['9']: 'f9'
        ['0']: 'f10'
        ['-']: 'f11'
        ['=']: 'f12'
      mod:
        a: {conf.hyper, 'a'}
        b: {conf.hyper, 'b'}
        c: {conf.hyper, 'c'}
        d: {conf.hyper, 'd'}
        e: {conf.hyper, 'e'}
        f: {conf.hyper, 'f'}
        g: {conf.hyper, 'g'}
        h: {conf.hyper, 'h'}
        i: {conf.hyper, 'i'}
        j: {conf.hyper, 'j'}
        k: {conf.hyper, 'k'}
        l: {conf.hyper, 'l'}
        m: {conf.hyper, 'm'}
        n: {conf.hyper, 'n'}
        o: {conf.hyper, 'o'}
        p: {conf.hyper, 'p'}
        q: {conf.hyper, 'q'}
        r: {conf.hyper, 'r'}
        s: {conf.hyper, 's'}
        t: {conf.hyper, 't'}
        u: {conf.hyper, 'u'}
        v: {conf.hyper, 'v'}
        w: {conf.hyper, 'w'}
        x: {conf.hyper, 'x'}
        y: {conf.hyper, 'y'}
        z: {conf.hyper, 'z'}
        [';']: {conf.hyper, ';'}
        ["'"]: {conf.hyper, "'"}
        ['space']: {conf.hyper, 'space'}

    layerKey = layer1.key[codes[code]]
    -- layerSys = layer1.sys[codes[code]]
    layerMod = layer1.mod[codes[code]]
    if layerKey
      return true, {
        key mods, layerKey, true
        key mods, layerKey, false
      }
    elseif layerMod
      { modMods, modKey } = layerMod
      return true, {
        key modMods, modKey, true
        key modMods, modKey, false
      }
    -- elseif layerSys
    --   sys layerSys
    --   return true
    -- elseif code == codes.z
    --   itunes.setVolume 1
    --   return true
    -- elseif code == codes.x
    --   itunes.volumeDown!
    --   return true
    -- elseif code == codes.c
    --   itunes.volumeUp!
    --   return true
  elseif state.oneDown and type == keyUp
    return true

  state.leftCmdDown = false
  state.leftAltDown = false
  state.leftCtrlDown = false
  state.leftShiftDown = false
)\start!

key
