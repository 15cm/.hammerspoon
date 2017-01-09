mouse = require 'mouse'
util = require 'util'
conf = require 'conf'
layout = require 'layout'

app =
  toggleByBundleID: (id, max) ->
    () ->
      app = hs.application.frontmostApplication!
      if app and app\bundleID! == id
        app\hide!
      else
        hs.application.launchOrFocusByBundleID id
        mouse.frontmost!
        layout\max! if max
  activateByBundleID: (id) ->
    () ->
        hs.application.launchOrFocusByBundleID id
        if id == 'com.google.Chrome'
          w = hs.window.frontmostWindow!
          if w\title! == 'Tabs Outliner'
            (hs.eventtap.event.newKeyEvent({'cmd'}, 'a', true)\setKeyCode 50)\post!
        mouse.frontmost!
  running: (id, success, fail) ->
    app = hs.application.get id
    if app
      app\activate!
      util.delay conf.appActiveTimeout, ->
        success!
      util.delay conf.appHideTimeout, ->
        app\hide!
    else
      fail!
app
