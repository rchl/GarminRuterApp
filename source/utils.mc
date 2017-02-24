using Toybox.Graphics as Gfx;
using Toybox.Lang;
using Toybox.Math;
using Toybox.Test;
using Toybox.Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.Timer;
using Toybox.System;

class Utils {
  static function hitTest(eventX, eventY, rects) {
    for (var i = 0; i < rects.size(); i++) {
      var rect = rects[i];
      if (eventX >= rect.x && eventX < rect.right() && eventY >= rect.y
          && eventY < rect.bottom()) {
        return rect;
      }
    }
    return null;
  }

  static function drawClock(dc, foreground, background) {
    var font = Constants.CLOCK_SIZE;
    var timeInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var clockString = Lang.format(
            "  $1$:$2$", [timeInfo[:hour], timeInfo[:min].format("%02d")]);
    var fontDimensions = dc.getTextDimensions(clockString, font);
    var RIGHT_PADDING = 6;
    var x = dc.getWidth() - fontDimensions[0] - RIGHT_PADDING;
    var y = 0;
    var width = fontDimensions[0] + RIGHT_PADDING;
    dc.setColor(background, background);
    dc.fillRectangle(x, y, width, fontDimensions[1]);
    dc.setColor(foreground, Gfx.COLOR_TRANSPARENT);
    dc.drawText(dc.getWidth() - RIGHT_PADDING, 0, font, clockString,
                Gfx.TEXT_JUSTIFY_RIGHT);
  }

  static function fillRoundedRectangleWithInset(dc, x, y, width, height,
                                                radius, inset) {
    x += inset;
    y += inset;
    width -= inset * 2;
    height -= inset * 2;
    dc.fillRoundedRectangle(x, y, width, height, radius);
  }

  static function drawTextWithBackground(dc, text, font, bounds, foreground,
                                         background, inset, justify) {
    var fontDimensions = dc.getTextDimensions(text, font);
    if (bounds.width == 0 || bounds.height == 0) {
      if (bounds.width == 0) {
        bounds.width = fontDimensions[0] + inset * 2;
      }
      if (bounds.height == 0) {
        bounds.height = fontDimensions[1];
      }
    }
    if (fontDimensions[0] > bounds.width || fontDimensions[1] > bounds.height) {
      font -= 1;
    }
    dc.setColor(background, background);
    dc.fillRectangle(bounds.x, bounds.y, bounds.width, bounds.height);
    dc.setColor(foreground, Gfx.COLOR_TRANSPARENT);
    var centerHorizontally = (justify & Gfx.TEXT_JUSTIFY_CENTER) != 0;
    var textX = bounds.x + (centerHorizontally ? bounds.width / 2 : inset);
    var centerVertically = (justify & Gfx.TEXT_JUSTIFY_VCENTER) != 0;
    var textY = bounds.y + (centerVertically ? bounds.height / 2 : 0);
    dc.drawText(textX, textY, font, text, justify);
    return {
      :width => bounds.width,
      :height => bounds.height
    };
  }

  static function TimeToMoment(time) {
    // This assumes that time is in UTC format (no timezone).
    // Example: 2017-02-21T23:45:42+01:00
    var result = Calendar.moment({
      :year => time.substring(0, 4).toNumber(),
      :month => time.substring(5, 7).toNumber(),
      :day => time.substring(8, 10).toNumber(),
      :hour => time.substring(11, 13).toNumber(),
      :minute => time.substring(14, 16).toNumber(),
      :second => time.substring(17, 19).toNumber()
    });
    // // Convert to UTC without the timezone shift.
    // var sign = time.substring(19, 20).equals("+") ? -1 : 1;
    // var timezoneDifference = ((time.substring(20, 22).toNumber() * 60 * 60) +
    //     (time.substring(23, 25).toNumber() * 60)) * sign;
    // return new Time.Moment(result.value() + timezoneDifference);
    return result;
  }

  static function drawStar(dc, x, y, radius) {
    var PI = 3.1416;
    var alpha = (2 * PI) / 10;
    var starXY = [x, y];
    var points = [];
    for (var i = 11; i != 0; i--) {
      var r = radius * (i % 2 + 1) / 2;
      var omega = alpha * i;
      points.add([r * Math.sin(omega) + starXY[0],
                  r * Math.cos(omega) + starXY[1]]);
    }
    dc.fillPolygon(points);
  }
}
