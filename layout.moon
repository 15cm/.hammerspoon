hs.window.animationDuration = 0
hs.window.setFrameCorrectness = false

layout =
  frontmost: ->
    hs.window.frontmostWindow!
  sideWindowTitle: 'Sidewise'
  sideWindowWidth: 14
  moveTo: (x1, y1, x2, y2, isRight = false) =>
    w = @frontmost!
    app = w\application!
    if app\name! == "Google Chrome" and w\title! ~= @sideWindowTitle and app\findWindow(@sideWindowTitle)
      w\move("[#{x1}, #{y1}, #{x2 - @sideWindowWidth}, #{y2}]")
    else
      w\move("[#{x1}, #{y1}, #{x2}, #{y2}]")
  nextScreen: =>
    w = @frontmost!
    app = w\application!
    if app\name! == "Google Chrome" and w\title! ~= @sideWindowTitle and app\findWindow(@sideWindowTitle)
      sideWindow = app\getWindow @sideWindowTitle
      sideWindow\moveToScreen w\screen!\next!, true, true
      w\moveToScreen w\screen!\next!, true, true
    else
      w\moveToScreen w\screen!\next!, true, true
  leftOneThird: =>
    @moveTo 0, 0, 33, 100
  leftHalf: =>
    @moveTo 0, 0, 50, 100
  leftTwoThird: =>
    @moveTo 0, 0, 67, 100
  rightOneThird: =>
    @moveTo 67, 0, 100, 100, true
  rightHalf: =>
    @moveTo 50, 0, 100, 100, true
  rightTwoThird: =>
    @moveTo 33, 0, 100, 100, true
  max: =>
    @moveTo 0, 0, 100, 100
  leftUpCorner: =>
    @moveTo 0, 0, 25, 25
  leftDownCorner: =>
    @moveTo 0, 75, 25, 100
  rightUpCorner: =>
    @moveTo 75, 0, 100, 25
  rightDownCorner: =>
    @moveTo 75, 75, 100, 100
  screen: =>
    @nextScreen!
layout
