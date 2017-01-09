hs.window.animationDuration = 0
hs.window.setFrameCorrectness = false

-- pack 2 windows aligned together
 --  ratio1 |    ratio2
 --         x0
 --  --------------------
 -- |                   |
 -- |  w1   |    w2     |
 -- |                   |
 --  -------------------
-- w2 is wider than w1
class packAligned
  new: (w1, w2, ratio1, ratio2) =>
    @w1 = w1
    @w2 = w2
    @r1 = ratio1
    @r2 = ratio2
  moveTo: (x1, y1, x2, y2, isRight = false) =>
    if not isRight
      x0 = (@r1 * x2 + @r2 * x1) / (@r1 + @r2)
      @w1\move("[#{x1}, #{y1}, #{x0}, #{y2}]")
      @w2\move("[#{x0}, #{y1}, #{x2}, #{y2}]")
    else
      x0 = (@r2 * x2 + @r1 * x1) / (@r1 + @r2)
      @w2\move("[#{x1}, #{y1}, #{x0}, #{y2}]")
      @w1\move("[#{x0}, #{y1}, #{x2}, #{y2}]")
  nextScreen: =>
    @w1\moveToScreen @w2\screen!\next!, true, true
    @w2\moveToScreen @w2\screen!\next!, true, true

layout =
  frontmost: ->
    hs.window.frontmostWindow!
  moveTo: (x1, y1, x2, y2, isRight = false) =>
    w = @frontmost!
    -- print "Window title: #{w\title!}"
    app = w\application!
    if app\name! == "Google Chrome" and w\title! ~= "Tabs Outliner" and app\findWindow('Tabs Outliner')
      wTabOutliner = app\getWindow 'Tabs Outliner'
      packAligned(wTabOutliner, w, 1, 3)\moveTo(x1, y1, x2, y2, isRight)
    else
      w\move("[#{x1}, #{y1}, #{x2}, #{y2}]")
  nextScreen: =>
    w = @frontmost!
    app = w\application!
    if app\name! == "Google Chrome" and w\title! ~= "Tabs Outliner" and app\findWindow('Tabs Outliner')
      wTabOutliner = app\getWindow 'Tabs Outliner'
      packAligned(wTabOutliner, w, 1, 3)\nextScreen!
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
