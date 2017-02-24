using Toybox.Graphics as Gfx;
using Toybox.Test;
using Toybox.System;

class Stop extends Rect {
  hidden var mName;
  hidden var mId;
  hidden var mLines = [];

  function initialize(name, id, lines) {
    Rect.initialize(0, 0, 0, 0);
    mName = name;
    mId = id;
    mLines = lines;
    Test.assert(mName);
    Test.assert(mId);
  }

  function getName() { return mName; }

  function getId() { return mId; }

  function layoutAndDraw(dc) {
    var bounds = new Rect(x, y, width, height);
    Utils.drawTextWithBackground(
        dc, mName, Constants.STOP_NAME_FONT, bounds, Constants.STOP_TEXT_COLOR,
        Constants.STOP_NAME_BACKGROUND_COLOR, Constants.STOP_NAME_LEFT_PADDING,
        Gfx.TEXT_JUSTIFY_LEFT);
    var currentX = bounds.x + Constants.STOP_NAME_LEFT_PADDING;
    var currentY = bounds.y + bounds.height / 2;
    var lineKeys = mLines.keys();
    for (var i = 0; i < lineKeys.size(); i++) {
      var lineName = lineKeys[i];
      var color = mLines[lineName];
      var size = Utils.drawTextWithBackground(
         dc, lineName, Constants.LINE_NAME_FONT,
         new Rect(currentX, currentY, 0, 0),
         Constants.LINE_TEXT_COLOR, color,
         Constants.LINE_NAME_HORIZONTAL_PADDING,
         Gfx.TEXT_JUSTIFY_LEFT + Gfx.TEXT_JUSTIFY_VCENTER);
      currentX += size[:width] + Constants.LINE_NAME_HORIZONTAL_PADDING * 2;
    }
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
    dc.drawLine(bounds.x, bounds.bottom() - 1,
                bounds.width, bounds.bottom() - 1);
  }
}
