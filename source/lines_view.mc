using Toybox.Attention;
using Toybox.Communications as Comm;
using Toybox.Graphics as Gfx;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

class LinesView extends Ui.View {
  hidden var mStop = null;
  hidden var mLoadingText = "";
  hidden var mLines =  null;
  hidden var mLastError = "";
  hidden var mUpdateTimer = null;

  function initialize(stop) {
    View.initialize();
    mStop = stop;
    mLoadingText = stop.getName() + "\nLoading...";
    getLines_(mStop.getId());
    mUpdateTimer = new Timer.Timer();
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {
    mUpdateTimer.start(method(:onTimer_),
                       Constants.VIEW_UPDATE_INTERVAL_SEC * 1000, true);
  }

  function onTimer_() { Ui.requestUpdate(); }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() { mUpdateTimer.stop(); }

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

    if (mLines != null && mLines.getItems().size() > 0) {
      mLines.layoutAndDraw(dc, new Rect(0, 0, dcWidth, dcHeight));
    } else {
      var status = mLoadingText;
      if (!mLastError.equals("")) {
        status = mLastError;
      } else if (mLines != null && mLines.getItems().size() == 0) {
        status = "No running lines!";
      }
      dc.drawText(centerH, centerV, Gfx.FONT_MEDIUM, status,
                  Constants.TEXT_CENTER);
    }
    Utils.drawClock(dc, Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
  }

  function getLineAtCoordinates(x, y) {
    var line = mLines.getItemAt(x, y);
    return line instanceof Line ? line : null;
  }

  function handleTap(eventX, eventY) {
    if (mLines) {
      var line = getLineAtCoordinates(eventX, eventY);
      if (line) {
        return true;
      }
    }
    return false;
  }

  function handleSwipe(direction) {
    if (mLines != null) {
      if (direction == Ui.SWIPE_LEFT) {
        mLines.nextPage();
      } else if (direction == Ui.SWIPE_RIGHT) {
        mLines.previousPage();
      }
      Ui.requestUpdate();
      return true;
    }
    return false;
  }

  function handleHold(eventX, eventY) {
    var line = getLineAtCoordinates(eventX, eventY);
    if (line) {
      var menu = line.isFavorite() ? new Rez.Menus.UnfavoriteLineMenu()
                                   : new Rez.Menus.FavoriteLineMenu();
      menu.setTitle(line.getName());
      var delegate = new LineMenuDelegate(line);
      Ui.pushView(menu, delegate, Ui.SLIDE_UP);
      return true;
    }
    return false;
  }

  function getLines_(stopId) {
    Comm.makeWebRequest(
      Constants.RUTER_API_HOST + Constants.GET_DEPARTURES_PATH,
      {
        "id" => stopId
      },
      {
        :method => Comm.HTTP_REQUEST_METHOD_GET,
        :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
      },
      method(:onLinesReceived_)
    );
  }

  function onLinesReceived_(responseCode, data) {
    mLastError = "";
    mLines = null;
    if (responseCode != 200) {
      var errorText = Constants.NETWORK_ERRORS.hasKey(responseCode) ?
                      Constants.NETWORK_ERRORS[responseCode] : responseCode;
      mLastError = Lang.format("Error fetching lines\n$1$", [errorText]);
    } else {
      var lines = [];
      var uniqueLines = {};
      var platformKeys = data.keys();
      for (var i = 0; i < platformKeys.size(); i++) {
        var platformKey = platformKeys[i];
        lines.add(new Platform(platformKey));
        var stopLines = data[platformKey];
        for (var j = 0; j < stopLines.size(); j++) {
          var line = stopLines[j];
          lines.add(
              new Line(mStop.getId(), mStop.getName(), line["id"], line["name"],
                       line["destination"], line["color"], line["departures"]));
        }
      }
      mLines = new PagedList(lines, Constants.LINES_PER_PAGE);
    }
    Attention.backlight(true);
    Ui.requestUpdate();
  }
}
