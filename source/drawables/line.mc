using Toybox.Graphics as Gfx;
using Toybox.Test;
using Toybox.Time;
using Toybox.Time.Gregorian as Calendar;

class Line extends Rect {
  hidden const LINE_FONT_SIZE = Gfx.FONT_SMALL;
  hidden const LINE_TEXT_COLOR = Gfx.COLOR_WHITE;
  hidden const LINE_HORIZONTAL_PADDING = 2;
  hidden const TEXT_VERTICAL_PADDING = 2;
  hidden var mStopId = -1;
  hidden var mStopName = "";
  hidden var mLineId = -1;
  hidden var mLineName = "";
  hidden var mDestination = "";
  hidden var mColor = "";
  hidden var mDepartures = [];

  function initialize(stopId, stopName, lineId, lineName, destination, color,
                      departures) {
    Rect.initialize(0, 0, 0, 0);
    mStopId = stopId;
    mStopName = stopName;
    mLineId = lineId;
    mLineName = lineName;
    mDestination = destination;
    mColor = color;
    mDepartures = departures;
    Test.assert(mStopId);
    Test.assert(mStopName);
    Test.assert(mLineName);
    Test.assert(mDestination);
    Test.assert(mColor);
    Test.assert(mDepartures);
  }

  function getId() { return mLineName; }

  function getDestination() { return mDestination; }

  function getStopName() { return mStopName; }

  function getName() { return Lang.format("$1$ $2$", [mLineName, mDestination]); }

  function isFavorite() {
    return Storage.getFavorites().hasKey(getFavoriteKey());
  }

  function getFavoriteKey() {
    return Lang.format("$1$-$2$-$3$", [mStopId, mLineId, mDestination]);
  }

  function getFavoriteData() {
    return {
      "stopName" => mStopName,
      "stopId" => mStopId
    };
  }

  function addFavorite() {
    Storage.addFavorite(getFavoriteKey(), getFavoriteData());
  }

  function removeFavorite() {
    Storage.removeFavorite(getFavoriteKey());
  }

  function layoutAndDraw(dc) {
    var bounds = new Rect(x, y, width, height);
    var currentX = bounds.x;
    var currentY = bounds.y;
    var drawnBounds = Utils.drawTextWithBackground(
        dc, mLineName, LINE_FONT_SIZE, new Rect(currentX, currentY, 0, 0),
        LINE_TEXT_COLOR, mColor, LINE_HORIZONTAL_PADDING,
        Gfx.TEXT_JUSTIFY_LEFT);
    currentX += drawnBounds[:width];
    // Add padding between line number and destination.
    currentX += LINE_HORIZONTAL_PADDING * 2;
    // Paint destination background and text.
    drawnBounds = Utils.drawTextWithBackground(
        dc, mDestination, LINE_FONT_SIZE,
        new Rect(currentX, currentY, bounds.width - currentX, 0),
        LINE_TEXT_COLOR, mColor, LINE_HORIZONTAL_PADDING,
        Gfx.TEXT_JUSTIFY_LEFT);
    var starRadius = 9;
    if (isFavorite()) {
      Utils.drawStar(dc, bounds.right() - starRadius,
                     currentY + drawnBounds[:height] / 2,
                     starRadius);
    }
    // Draw departues.
    currentX = bounds.x;
    currentY += drawnBounds[:height];
    var nowMoment = Time.now();
    var departuresString = "";
    for (var i = 0; i < mDepartures.size(); i++) {
      var departure = mDepartures[i];
      var departureMoment = new Time.Moment(departure);
      var minuteDiff = nowMoment.subtract(departureMoment).value() / 60;
      if (minuteDiff < 0) {
        continue;
      } else if (minuteDiff == 0) {
        departuresString = "  now";
      } else if (minuteDiff < 10) {
        departuresString += Lang.format("  $1$ min", [minuteDiff]);
      } else {
        var timeInfo = Calendar.info(departureMoment, Time.FORMAT_SHORT);
        departuresString += Lang.format(
            "  $1$:$2$", [timeInfo[:hour], timeInfo[:min].format("%02d")]);
      }
    }
    Utils.drawTextWithBackground(
        dc, departuresString, LINE_FONT_SIZE,
        new Rect(currentX, currentY, bounds.width - currentX, 0),
        LINE_TEXT_COLOR, Gfx.COLOR_TRANSPARENT, LINE_HORIZONTAL_PADDING,
        Gfx.TEXT_JUSTIFY_LEFT);
  }
}
