using Toybox.Graphics as Gfx;

class FavoriteLine extends Line {
  function initialize(stopId, stopName, lineId, lineName, destination, color,
                      departures) {
    Line.initialize(stopId, stopName, lineId, lineName, destination, color,
                    departures);
  }

  function layoutAndDraw(dc) {
    var stopNameHeight = height / 2 - 5;
    dc.drawText(4, y + stopNameHeight / 2, Gfx.FONT_SMALL,
              "From " + getStopName(),
              Gfx.TEXT_JUSTIFY_LEFT + Gfx.TEXT_JUSTIFY_VCENTER);
    offsetBy(0, stopNameHeight);
    Line.layoutAndDraw(dc);
    offsetBy(0, -stopNameHeight);
  }
}
