layout = require 'layout'
conf = require 'conf'

mouse =
  clickNotification: ->
    mouse = hs.eventtap.event.newMouseEvent
    types = hs.eventtap.event.types
    clickState = hs.eventtap.event.properties.mouseEventClickState
    point =
      x: hs.screen.primaryScreen!\fullFrame!.w-conf.notification.x
      y: conf.notification.y
    mouse(types.leftMouseDown, point)\setProperty(clickState, 1)\post!
    mouse(types.leftMouseUp, point)\setProperty(clickState, 1)\post!
  frontmost: ->
    winFrame = layout.frontmost!\frame!
    mousePosition = hs.mouse.getRelativePosition!
    fullFrame = hs.mouse.getCurrentScreen!\fullFrame!
    point =
      x: winFrame.x+winFrame.w*mousePosition.x/fullFrame.w
      y: winFrame.y+winFrame.h*mousePosition.y/fullFrame.h
    hs.mouse.setAbsolutePosition point
  scrollUp: ->
    hs.eventtap.scrollWheel {0,1}, {}
  scrollDown: ->
    hs.eventtap.scrollWheel {0,-1}, {}

mouse
