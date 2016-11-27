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
isExternalKeyboard = require 'keyboard'
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
  keyEvent(mods, '', isdown)\setKeyCode key

export state = {
  startTime: util.now!
}

-- Hyper0 + A, S, D to inputSource US, CHS, JP
inputSourceUS = 'com.apple.keylayout.US'
inputSourceCHS = 'com.googlecode.rimeime.inputmethod.Squirrel.Rime'
inputSourceJP = 'com.google.inputmethod.Japanese.base'

switchInputSource = (fromSource, toSource) ->
  sourcePosition = (source) ->
    switch source
      when inputSourceUS
        return 1
      when inputSourceJP
        return 2
      when inputSourceCHS
        return 3
      else return nil
  fsrcPos = sourcePosition fromSource
  tsrcPos = sourcePosition toSource
  nextTimes = (tsrcPos - fsrcPos + 3) % 3
  nextKey = {}
  for i = 1, nextTimes
    table.insert nextKey, key({}, codes.f18, true)
    table.insert nextKey, key({}, codes.f18, false)
  return true, nextKey

isVimBindingApp = ->
  app = hs.application.frontmostApplication!
  _.includes conf.vimBindingApp, app\bundleID!
    
export eventtapWatcher = new({ keyDown, keyUp, flagsChanged }, (e) ->
  keyboardType = e\getProperty keyboardEventKeyboardType
  -- print keyboardType
  return unless keyboardType and _.includes conf.enabledDevice, keyboardType
  -- return true if hasExternalDevice! and keyboardType and _.includes conf.disableDevice, keyboardType
  type, code, flags = e\getType!, e\getKeyCode!, e\getFlags!
  mods = _.keys flags
  -- print math.floor((util.now!-state.startTime+0.5)*100)/100, type, code, _.str(mods)

  isDown = if type == keyUp or type == flagsChanged and _.str(mods) == '{}' then false else true
  -- Minila Air ('Physical Mapping')
  if isExternalKeyboard keyboardType
    -- Backquote to Del
    if code == codes['`']
      return true, {
        key mods, codes.delete, isDown
        }
    -- Esc to Backquote
    elseif code == codes.escape
      return true, {
        key mods, codes['`'], isDown
        }

  if _.includes({codes.space, codes['`'], codes['tab']}, code) and _.str(mods) != '{}'
    return

    -- SPACE -> SPACE/HYPER0
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
    mods = _.union mods, conf.hyper0
    switch code
      when codes['a']
        return switchInputSource hs.keycodes.currentSourceID!, inputSourceUS
      when codes['s']
        return switchInputSource hs.keycodes.currentSourceID!, inputSourceCHS
      when codes['d']
        return switchInputSource hs.keycodes.currentSourceID!, inputSourceJP
      else
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
  -- ESC -> ESC/LCTL
  -- elseif code == codes.escape and type == keyDown
  --   state.escapeDown = true
  --   return true
  -- elseif code == codes.escape and type == keyUp
  --   state.escapeDown = false
  --   if state.escapeCombo
  --     state.escapeCombo = false
  --     return true
  --   else
  --     return true, {
  --       key mods, code, true
  --       key mods, code, false
  --     }
  -- elseif state.escapeDown and type == keyDown
  --   state.escapeCombo = true
  --   mods = _.union mods, {'ctrl'}
  --   return true, {
  --     key mods, code, true
  --     key mods, code, false
  --   }
  -- elseif state.escapeDown and type == keyUp
  --   return true

  -- LSFT -> F17/LSFT
  -- elseif code == codes.leftShift and _.str(mods) == '{"shift"}' and type == flagsChanged
  --   state.leftShiftDown = util.now!
  --   return true
  -- elseif code == codes.leftShift and _.str(mods) == '{}' and type == flagsChanged
  --   if state.leftShiftDown and util.now! < state.leftShiftDown + conf.oneTapTimeout
  --     state.leftShiftDown = false
  --     return true, {
  --       key mods, codes.f17, true
  --       key mods, codes.f17, false
  --     }

  -- LCTL -> F12/LCTL
  -- elseif code == codes.leftCtrl and _.str(mods) == '{"ctrl"}' and type == flagsChanged
  --   state.leftCtrlDown = util.now!
  --   return true
  -- elseif code == codes.leftCtrl and _.str(mods) == '{}' and type == flagsChanged
  --   if state.leftCtrlDown and util.now! < state.leftCtrlDown + conf.oneTapTimeout
  --     state.leftCtrlDown = false
  --     return true, {
  --       key mods, codes.f12, true
  --       key mods, codes.f12, false
  --     }

  -- LALT -> F11/LALT
  -- elseif code == codes.leftAlt and _.str(mods) == '{"alt"}' and type == flagsChanged
  --   state.leftAltDown = util.now!
  --   return true
  -- elseif code == codes.leftAlt and _.str(mods) == '{}' and type == flagsChanged
  --   if state.leftAltDown and util.now! < state.leftAltDown + conf.oneTapTimeout
  --     state.leftAltDown = false
  --     return true, {
  --       key mods, codes.f11, true
  --       key mods, codes.f11, false
  --     }

  -- LGUI -> F10/LGUI
  -- elseif code == codes.leftCmd and _.str(mods) == '{"cmd"}' and type == flagsChanged
  --   state.leftCmdDown = util.now!
  --   return true
  -- elseif code == codes.leftCmd and _.str(mods) == '{}' and type == flagsChanged
  --   if state.leftCmdDown and util.now! < state.leftCmdDown + conf.oneTapTimeout
  --     state.leftCmdDown = false
  --     return true, {
  --       key mods, codes.f10, true
  --       key mods, codes.f10, false
  --     }

  -- ` -> `/Layer 2
  -- elseif code == codes['`'] and type == keyDown
  --   state.twoDown = true
  --   return true
  -- elseif code == codes['`'] and type == keyUp
  --   state.twoDown = false
  --   if state.twoCombo
  --     state.twoCombo = false
  --     return true
  --   else
  --     return true, {
  --       key mods, code, true
  --       key mods, code, false
  --     }
  -- elseif state.twoDown and type == keyDown
  --   state.twoCombo = true
  --   layer2 =
  --     h: 'home'
  --     j: 'pagedown'
  --     k: 'pageup'
  --     l: 'end'
  --   code = layer2[codes[code]] or code
  --   return true, {
  --     key mods, code, true
  --     key mods, code, false
  --   }
  -- elseif state.twoDown and type == keyUp
  --   return true

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
      sys:
        q: 'PREVIOUS'
        w: 'PLAY'
        e: 'NEXT'
        a: 'SOUND_DOWN'
        s: 'MUTE'
        d: 'SOUND_UP'
        f: 'ILLUMINATION_DOWN'
        g: 'ILLUMINATION_UP'
        h: 'ILLUMINATION_TOGGLE'
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
        delete: 'forwarddelete'
        h: 'left'
        j: 'down'
        k: 'up'
        l: 'right'
    layerKey = layer1.key[codes[code]]
    layerSys = layer1.sys[codes[code]]
    if layerKey
      return true, {
        key mods, layerKey, true
        key mods, layerKey, false
      }
    elseif layerSys
      sys layerSys
      return true
    elseif code == codes.z
      itunes.setVolume 1
      return true
    elseif code == codes.x
      itunes.volumeDown!
      return true
    elseif code == codes.c
      itunes.volumeUp!
      return true
  elseif state.oneDown and type == keyUp
    return true

  -- Emacs
  -- C-h to Del
  elseif code == codes['h'] and _.str(mods) == '{"ctrl"}'
      return true, {
        key {}, codes.delete, isDown
        }
  -- C-d to FDEl
  elseif code == codes['d'] and _.str(mods) == '{"ctrl"}'
    if not isVimBindingApp!
      return true, {
        key {}, codes.forwarddelete, isDown
        }
  -- C-n to down
  elseif code == codes['n'] and _.str(mods) == '{"ctrl"}'
    if not isVimBindingApp!
      return true, {
        key {}, codes.down, isDown
        }
  -- C-p to up
  elseif code == codes['p'] and _.str(mods) == '{"ctrl"}'
    if not isVimBindingApp!
      return true, {
      key {}, codes.up, isDown
        }
  -- C-f to right
  elseif code == codes['f'] and _.str(mods) == '{"ctrl"}'
    if not isVimBindingApp!
      return true, {
        key {}, codes.right, isDown
        }
  -- C-b to left
  elseif code == codes['b'] and _.str(mods) == '{"ctrl"}'
    if not isVimBindingApp!
      return true, {
        key {}, codes.left, isDown
        }
    -- RALT -> F9/RGUI
    -- if code == codes.rightAlt and _.str(mods) == '{"alt"}' and type == flagsChanged
    --   state.rightAltDown = util.now!
    --   return true
    -- elseif code == codes.rightAlt and _.str(mods) == '{}' and type == flagsChanged
    --   if state.rightAltCombo
    --     state.rightAltDown = false
    --     state.rightAltCombo = false
    --     return true
    --   elseif util.now! < state.rightAltDown + conf.oneTapTimeout
    --     state.rightAltDown = false
    --     return true, {
    --       key mods, codes.f9, true
    --       key mods, codes.f9, false
    --     }
    -- elseif state.rightAltDown and type == keyDown
    --   state.rightAltCombo = true
    --   -- mods = _.union mods, conf.hyper1
    --   mods = _.union {'cmd'}, _.without(mods, 'alt')
    --   return true, {
    --     key mods, code, true
    --     key mods, code, false
    --   }
    -- elseif state.rightAltDown and type == keyUp
    --   return true
  state.leftCmdDown = false
  state.leftAltDown = false
  state.leftCtrlDown = false
  state.leftShiftDown = false
)\start!

key
