using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.Test;

class Platform extends Rect {
  hidden const FONT_SIZE = Gfx.FONT_MEDIUM;
  hidden const TEXT_COLOR = Gfx.COLOR_BLACK;
  hidden const BACKGROUND_COLOR = Gfx.COLOR_LT_GRAY;
  hidden const TEXT_LEFT_PADDING = 5;
  hidden var mName = "";

  function initialize(name) {
    Rect.initialize(0, 0, 0, 0);
    mName = "Platform " + name;
    Test.assert(mName);
   }

  function layoutAndDraw(dc) {
    var bounds = new Rect(x, y, width, height);
    Utils.drawTextWithBackground(
         dc, mName, FONT_SIZE, bounds, TEXT_COLOR, BACKGROUND_COLOR,
         TEXT_LEFT_PADDING,
         Gfx.TEXT_JUSTIFY_LEFT + Gfx.TEXT_JUSTIFY_VCENTER);
  }
}
