using Toybox.Attention;
using Toybox.Communications as Comm;
using Toybox.Graphics as Gfx;
using Toybox.Position;
using Toybox.Time;
using Toybox.WatchUi as Ui;

class StopsView extends Ui.View {
  hidden var mStopList = null;
  hidden var mRange = 0;
  hidden var mLastError = "";

  function initialize(range, northing, easting) {
    View.initialize();
    mRange = range;
    getStops_(northing, easting);
  }

  function onLayout(dc) {}

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {}

  // Update the view
  function onUpdate(dc) {
    // Erase the screen.
    dc.setColor(Gfx.COLOR_TRANSPARENT, Constants.BACKGROUND_COLOR);
    dc.clear();
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

    var dcWidth = dc.getWidth();
    var dcHeight = dc.getHeight();
    var centerH = dcWidth / 2;
    var centerV = dcHeight / 2;

    var hasStops = mStopList != null && mStopList.getItems().size() > 0;
    if (hasStops) {
      mStopList.layoutAndDraw(dc, new Rect(0, 0, dcWidth, dcHeight));
      PageIndicator.drawLine(dc, new Rect(0, 0, dc.getWidth(), dc.getHeight()),
                             mStopList.getPageCount(),
                             mStopList.getCurrentPage());
    } else {
      var status = "Loading...";
      if (!mLastError.equals("")) {
        status = mLastError;
      } else if (mStopList != null) {
        status = Lang.format("No stops within $1$m!", [mRange]);
      }
      dc.drawText(centerH, centerV, Gfx.FONT_MEDIUM, status,
                  Constants.TEXT_CENTER);
    }
    Utils.drawClock(
        dc,
        hasStops ? Constants.STOP_TEXT_COLOR : Gfx.COLOR_WHITE,
        hasStops ? Constants.STOP_NAME_BACKGROUND_COLOR : Gfx.COLOR_BLACK);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {}

  function handleTap(eventX, eventY) {
    if (mStopList) {
      var stop = mStopList.getItemAt(eventX, eventY);
      if (stop) {
        var linesView = new LinesView(stop);
        var delegate = new StandardViewDelegate(linesView);
        Ui.pushView(linesView, delegate, Ui.SLIDE_LEFT);
      }
    }
    return false;
  }

  function handleHold(eventX, eventY) {
    return false;
  }

  function handleSwipe(direction) {
    if (mStopList != null) {
      if (direction == Ui.SWIPE_LEFT) {
        mStopList.nextPage();
      } else if (direction == Ui.SWIPE_RIGHT) {
        mStopList.previousPage();
      }
      Ui.requestUpdate();
      return true;
    }
    return false;
  }

  function getStops_(northing, easting) {
    Comm.makeWebRequest(
      Constants.RUTER_API_HOST + Constants.GET_STOPS_PATH,
      {
        "coordinates" => Lang.format("(x=$1$,y=$2$)", [easting, northing]),
        "maxdistance" => mRange.toString()
      },
      {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
      },
      method(:onStopsReceived_)
    );
  }

  function onStopsReceived_(responseCode, data) {
    mLastError = "";
    mStopList = null;
    if (responseCode != 200) {
      var errorText = Constants.NETWORK_ERRORS.hasKey(responseCode) ?
                      Constants.NETWORK_ERRORS[responseCode] : responseCode;
      mLastError = Lang.format("Error fetching stops\n$1$", [errorText]);
    } else {
      var stops = [];
      for (var i = 0; i < data.size(); i++) {
        var stopData = data[i];
        stops.add(
            new Stop(stopData["Name"], stopData["ID"], stopData["Lines"]));
      }
      mStopList = new PagedList(stops, Constants.STOPS_PER_PAGE);
    }
    Ui.requestUpdate();
  }
}
