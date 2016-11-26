-- 取 Apple 键盘和 60% 键盘相同的部分作为基础
-- ,-----------------------------------------------------------------------------------------.
-- |  `  |  1  |  2  |  3  |  4  |  5  |  6  |  7  |  8  |  9  |  0  |  -  |  =  |   BSPC    |
-- |-----------------------------------------------------------------------------------------|
-- |   TAB  |  Q  |  W  |  E  |  R  |  T  |  Y  |  U  |  I  |  O  |  P  |  [  |  ]  |    \   |
-- |-----------------------------------------------------------------------------------------|
-- |    ESC    |  A  |  S  |  D  |  F  |  G  |  H  |  J  |  K  |  L  |  ;  |  '  |           |
-- |-----------------------------------------------------------------------------------------|
-- |    LSFT     |  Z  |  X  |  C  |  V  |  B  |  N  |  M  |  ,  |  .  |  /  |      UP       |
-- |-----------------------------------------------------------------------------------------|
-- |     | LCTL | LALT | LGUI |              SPACE                     | RGUI |LEFT|DOWN|RGHT|
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
-- |    |F12/LCTL|F11/LALT|F10/LGUI|          SPACE/HYPER0          |F9/HYPER1|    |    |    |
-- `-----------------------------------------------------------------------------------------'
-- Layer 1
-- ,-----------------------------------------------------------------------------------------.
-- |     |     |     |     |     |     |     |     |     |     |     |     |     |    Del    |
-- |-----------------------------------------------------------------------------------------|
-- |      |  V-  |  V+  | MUTE |     |     |     |     |     |     |     |     |     |       |
-- |-----------------------------------------------------------------------------------------|
-- |         |SLCK|PAUS|BL_DEC|BL_INC|BL_TOGG|LEFT| DOWN | UP | RGHT |     |     |    |      |
-- |-----------------------------------------------------------------------------------------|
-- |     |     | MPRV | MPLY | MNXT |     |     |     |     |     |     |     |         |    |
-- |-----------------------------------------------------------------------------------------|
-- |                                                                                         |
-- `-----------------------------------------------------------------------------------------'
-- Layer 2
-- ,-----------------------------------------------------------------------------------------.
-- |     |     |     |     |     |     |     |     |     |     |     |     |     |           |
-- |-----------------------------------------------------------------------------------------|
-- |        |     |     |     |     |     |     |     |     |     |     |     |     |        |
-- |-----------------------------------------------------------------------------------------|
-- |         |     |     |     |     |     | HOME | PGDN | PGUP | END |     |     |          |
-- |-----------------------------------------------------------------------------------------|
-- |              |     |     |     |     |     |     |     |     |     |     |              |
-- |-----------------------------------------------------------------------------------------|
-- |     |       |      |      |                                       |      |    |    |    |
-- `-----------------------------------------------------------------------------------------'
_ = require 'lodash'
app = require 'app'
util = require 'util'
conf = require 'conf'
hasExternalDevice = require 'keyboard'
codes = hs.keycodes.map
codes.leftShift = 56
codes.leftCtrl = 59
codes.leftAlt = 58
codes.leftCmd = 55
codes.rightCmd = 54
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
  key = if _.isNumber key then key else codes[key]
  keyEvent(mods, '', isdown)\setKeyCode key

state = {
  startTime: util.now!
}

export eventtapWatcher = new({ keyDown, keyUp, flagsChanged }, (e) ->
  keyboardType = e\getProperty keyboardEventKeyboardType
  return unless keyboardType and _.includes conf.enabledDevice, keyboardType
  return true if hasExternalDevice! and keyboardType and _.includes conf.disableDevice, keyboardType
  type, code, flags = e\getType!, e\getKeyCode!, e\getFlags!
  mods = _.keys flags
  print math.floor((util.now!-state.startTime+0.5)*100)/100, type, code, _.str(mods)

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
      state.spaceDownTime = nil
      state.spaceCombo = false
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
  elseif state.spaceDown and type == keyDown
    state.spaceCombo = true
    mods = _.union mods, conf.hyper0
    return true, {
      key mods, code, true
      key mods, code, false
    }
  elseif state.spaceDown and type == keyUp
    return true

  -- RGUI -> F9/HYPER1
  elseif code == codes.rightCmd and _.str(mods) == '{"cmd"}' and type == flagsChanged
    state.rightCmdDown = util.now!
    return true
  elseif code == codes.rightCmd and _.str(mods) == '{}' and type == flagsChanged
    if state.rightCmdCombo
      state.rightCmdDown = false
      state.rightCmdCombo = false
      return true
    elseif util.now! < state.rightCmdDown + conf.oneTapTimeout
      state.rightCmdDown = false
      return true, {
        key mods, codes.f9, true
        key mods, codes.f9, false
      }
  elseif state.rightCmdDown and type == keyDown
    state.rightCmdCombo = true
    mods = _.union mods, conf.hyper1
    return true, {
      key mods, code, true
      key mods, code, false
    }
  elseif state.rightCmdDown and type == keyUp
    return true

  -- ESC -> ESC/LCTL
  elseif code == codes.escape and type == keyDown
    state.escapeDown = true
    return true
  elseif code == codes.escape and type == keyUp
    state.escapeDown = false
    if state.escapeCombo
      state.escapeCombo = false
      return true
    else
      return true, {
        key mods, code, true
        key mods, code, false
      }
  elseif state.escapeDown and type == keyDown
    state.escapeCombo = true
    mods = _.union mods, {'ctrl'}
    return true, {
      key mods, code, true
      key mods, code, false
    }
  elseif state.escapeDown and type == keyUp
    return true

  -- LSFT -> F17/LSFT
  elseif code == codes.leftShift and _.str(mods) == '{"shift"}' and type == flagsChanged
    state.leftShiftDown = util.now!
    return true
  elseif code == codes.leftShift and _.str(mods) == '{}' and type == flagsChanged
    if state.leftShiftDown and util.now! < state.leftShiftDown + conf.oneTapTimeout
      state.leftShiftDown = false
      return true, {
        key mods, codes.f17, true
        key mods, codes.f17, false
      }

  -- LCTL -> F12/LCTL
  elseif code == codes.leftCtrl and _.str(mods) == '{"ctrl"}' and type == flagsChanged
    state.leftCtrlDown = util.now!
    return true
  elseif code == codes.leftCtrl and _.str(mods) == '{}' and type == flagsChanged
    if state.leftCtrlDown and util.now! < state.leftCtrlDown + conf.oneTapTimeout
      state.leftCtrlDown = false
      return true, {
        key mods, codes.f12, true
        key mods, codes.f12, false
      }

  -- LALT -> F11/LALT
  elseif code == codes.leftAlt and _.str(mods) == '{"alt"}' and type == flagsChanged
    state.leftAltDown = util.now!
    return true
  elseif code == codes.leftAlt and _.str(mods) == '{}' and type == flagsChanged
    if state.leftAltDown and util.now! < state.leftAltDown + conf.oneTapTimeout
      state.leftAltDown = false
      return true, {
        key mods, codes.f11, true
        key mods, codes.f11, false
      }

  -- LGUI -> F10/LGUI
  elseif code == codes.leftCmd and _.str(mods) == '{"cmd"}' and type == flagsChanged
    state.leftCmdDown = util.now!
    return true
  elseif code == codes.leftCmd and _.str(mods) == '{}' and type == flagsChanged
    if state.leftCmdDown and util.now! < state.leftCmdDown + conf.oneTapTimeout
      state.leftCmdDown = false
      return true, {
        key mods, codes.f10, true
        key mods, codes.f10, false
      }

  -- ` -> `/Layer 2
  elseif code == codes['`'] and type == keyDown
    state.twoDown = true
    return true
  elseif code == codes['`'] and type == keyUp
    state.twoDown = false
    if state.twoCombo
      state.twoCombo = false
      return true
    else
      return true, {
        key mods, code, true
        key mods, code, false
      }
  elseif state.twoDown and type == keyDown
    state.twoCombo = true
    layer2 =
      h: 'home'
      j: 'pagedown'
      k: 'pageup'
      l: 'end'
    code = layer2[codes[code]] or code
    return true, {
      key mods, code, true
      key mods, code, false
    }
  elseif state.twoDown and type == keyUp
    return true

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
        q: 'SOUND_DOWN'
        w: 'SOUND_UP'
        e: 'MUTE'
        a: 'BRIGHTNESS_DOWN'
        s: 'BRIGHTNESS_UP'
        d: 'ILLUMINATION_DOWN'
        f: 'ILLUMINATION_UP'
        g: 'ILLUMINATION_TOGGLE'
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
      app.running 'com.netease.163music',
        -> press({'cmd'}, 'left'),
        -> sys 'PREVIOUS'
      return true
    elseif code == codes.x
      app.running 'com.netease.163music',
        -> press({}, 'space'),
        -> sys 'PLAY'
      return true
    elseif code == codes.c
      app.running 'com.netease.163music',
        -> press({'cmd'}, 'right'),
        -> sys 'NEXT'
      return true
  elseif state.oneDown and type == keyUp
    return true

  state.leftCmdDown = false
  state.leftAltDown = false
  state.leftCtrlDown = false
  state.leftShiftDown = false
)\start!
