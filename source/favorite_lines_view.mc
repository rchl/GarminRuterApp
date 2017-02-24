using Toybox.Communications as Comm;
using Toybox.Graphics as Gfx;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

class FavoriteLinesView extends Ui.View {
  hidden var mLines = null;
  hidden var mLastError = "";
  hidden var mUpdateTimer = null;
  hidden var mFavorites = {};

  function initialize() {
    View.initialize();
    mUpdateTimer = new Timer.Timer();
  }

  function onLayout(dc) {}

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() {
    reloadFavorites_();
    mUpdateTimer.start(method(:onTimer_),
                       Constants.VIEW_UPDATE_INTERVAL_SEC * 1000, true);
  }

  function reloadFavorites_() {
    mLines = null;
    mFavorites = Storage.getFavorites();
    var favoriteKeys = mFavorites.keys();
    if (favoriteKeys.size() > 0) {
      var queryString = "";
      for (var i = 0; i < favoriteKeys.size(); i++) {
        var favoriteKey = favoriteKeys[i];
        var favorite = mFavorites[favoriteKey];
        queryString += Lang.format("$1$,", [favoriteKey]);
      }
      fetchFavorites_(queryString);
    } else {
      mLastError = "No saved favorites";
    }
    Ui.requestUpdate();
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() { mUpdateTimer.stop(); }

  function onTimer_() { Ui.requestUpdate(); }

  function fetchFavorites_(queryString) {
    Comm.makeWebRequest(
        Constants.RUTER_API_HOST + Constants.GET_FAVORITES_PATH,
        {
          "favouritesRequest" => queryString
        },
        {
          :method => Comm.HTTP_REQUEST_METHOD_GET,
          :responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
        },
        method(:onFavoriteLinesReceived_)
    );
  }

  function onFavoriteLinesReceived_(responseCode, data) {
    mLastError = "";
    if (responseCode != 200) {
      var errorText = Constants.NETWORK_ERRORS.hasKey(responseCode) ?
                      Constants.NETWORK_ERRORS[responseCode] : responseCode;
      mLastError = Lang.format("Error fetching lines\n$1$", [errorText]);
    } else {
      var lines = [];
      for (var i = 0; i < data.size(); i++) {
        var line = data[i];
        var favoriteKey = Lang.format(
            "$1$-$2$-$3$",
            [line["stopId"], line["id"], line["destination"]]);
        var favoriteData = mFavorites.get(favoriteKey);
        lines.add(
            new FavoriteLine(line["stopId"], favoriteData["stopName"],
                             line["id"], line["name"], line["destination"],
                             line["color"], line["departures"]));
      }
      mLines = new PagedList(lines, Constants.FAVORITE_LINES_PER_PAGE);
    }
    Ui.requestUpdate();
  }

  // Update the view
  function onUpdate(dc) {
    // Erase the screen.
    dc.setColor(Gfx.COLOR_TRANSPARENT, Constants.BACKGROUND_COLOR);
    dc.clear();
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

    var dcWidth = dc.getWidth();
    var dcHeight = dc.getHeight();
    var bounds = new Rect(0, 0, dcWidth, dcHeight);

    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    var status = "";
    if (mLines != null) {
      mLines.layoutAndDraw(dc, bounds);
    } else if (!mLastError.equals("")) {
      status = mLastError;
    } else if (mLines == null) {
      status = "Fetching favorites...";
    } else if (mLines.size() == 0) {
      status = "No saved favorites";
    }
    if (!status.equals("")) {
      dc.drawText(bounds.x + bounds.width / 2, bounds.y + bounds.height / 2,
                  Gfx.FONT_MEDIUM, status, Constants.TEXT_CENTER);
    }

    Utils.drawClock(dc, Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
  }

  function handleTap(eventX, eventY) {
    if (mLines) {
      var line = mLines.getItemAt(eventX, eventY);
      if (line) {
      }
    }
    return false;
  }

  function handleHold(eventX, eventY) {
    var line = mLines.getItemAt(eventX, eventY);
    if (line) {
      var menu = line.isFavorite() ? new Rez.Menus.UnfavoriteLineMenu()
                                   : new Rez.Menus.FavoriteLineMenu();
      menu.setTitle(line.getName());
      Ui.pushView(menu, new LineMenuDelegate(line), Ui.SLIDE_UP);
      return true;
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
}
