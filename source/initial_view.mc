using Toybox.Attention;
using Toybox.Communications as Comm;
using Toybox.Graphics as Gfx;
using Toybox.Position;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

class FakePositionInfo extends Position.Info {
  function initialize(latitude, longitude) {
    Info.initialize();
    accuracy = Position.QUALITY_LAST_KNOWN;
    position = new Position.Location({
      :latitude => latitude,
      :longitude => longitude,
      :format => :degrees
    });
  }
}

class InitialView extends Ui.View {
  hidden const GPS_STATUS_MESSAGES = {
    Position.QUALITY_LAST_KNOWN => "Using last position",
    Position.QUALITY_POOR => "Poor signal",
    Position.QUALITY_USABLE => "Good signal",
    Position.QUALITY_GOOD => "Excellent signal"
  };

  hidden var mIsHidden = true;
  hidden var mPositionInfo = null;
  hidden var mPositionAvailable = false;
  hidden var mShowStopsButtonBounds = new Rect(0, 0, 0, 0);
  hidden var mShowFavoritesButtonBounds = new Rect(0, 0, 0, 0);

  function initialize() {
    View.initialize();
  }

  function onLayout(dc) {}

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() { mIsHidden = false; }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() {
    mIsHidden = true;
  }

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
    var thirdHeight = dcHeight / 3;

    var gpsStatus = "Searching...";
    if (mPositionInfo != null) {
      if (mPositionInfo.accuracy > Position.QUALITY_NOT_AVAILABLE) {
        gpsStatus = GPS_STATUS_MESSAGES[mPositionInfo.accuracy];
      }
    }
    gpsStatus = Lang.format("GPS: $1$", [gpsStatus]);
    dc.drawText(4, 0, Gfx.FONT_SMALL, gpsStatus, Gfx.TEXT_JUSTIFY_LEFT);

    mShowStopsButtonBounds = new Rect(0, thirdHeight, dcWidth, thirdHeight);
    dc.drawLine(0, mShowStopsButtonBounds.y,
                mShowStopsButtonBounds.width, mShowStopsButtonBounds.y);
    Utils.drawTextWithBackground(
        dc, "Show nearby stops", Gfx.FONT_MEDIUM, mShowStopsButtonBounds,
        mPositionAvailable ? Gfx.COLOR_WHITE : Gfx.COLOR_DK_GRAY,
        Gfx.COLOR_TRANSPARENT, 0, Constants.TEXT_CENTER);

    mShowFavoritesButtonBounds =
        new Rect(0, thirdHeight * 2, dcWidth, thirdHeight);
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    dc.drawLine(0, mShowFavoritesButtonBounds.y,
                mShowFavoritesButtonBounds.width, mShowFavoritesButtonBounds.y);
    Utils.drawTextWithBackground(
        dc, "Show favorites", Gfx.FONT_MEDIUM, mShowFavoritesButtonBounds,
        Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT, 0, Constants.TEXT_CENTER);
    dc.drawLine(0, mShowFavoritesButtonBounds.bottom(),
                mShowFavoritesButtonBounds.width,
                mShowFavoritesButtonBounds.bottom());

    Utils.drawClock(dc, Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
  }

  function setPosition(info) {
    if (mIsHidden) {
      return;
    }
    var previousAccuracy =
        mPositionInfo != null ? mPositionInfo.accuracy
                              : Position.QUALITY_NOT_AVAILABLE;
    var newAccuracy = info != null ? info.accuracy
                                   : Position.QUALITY_NOT_AVAILABLE;
    mPositionInfo = info;
    if (newAccuracy != previousAccuracy) {
      if (previousAccuracy == Position.QUALITY_NOT_AVAILABLE) {
        mPositionAvailable = true;
        Attention.vibrate([new Attention.VibeProfile(100, 200)]);
        Attention.backlight(true);
      }
      Ui.requestUpdate();
    }
  }

  function handleTap(eventX, eventY) {
    if (mShowStopsButtonBounds.contains(eventX, eventY) && mPositionAvailable) {
      showStops_();
      return true;
    } else if (mShowFavoritesButtonBounds.contains(eventX, eventY)) {
      showFavorites_();
      return true;
    }
    return false;
  }

  function handleHold(eventX, eventY) {
    return false;
  }

  function handleSwipe(direction) {
    return false;
  }

  function showStops_() {
    // setPosition(newAccuracy FakePositionInfo(59.933091, 10.7980681));
    // setPosition(new FakePositionInfo(59.9122615, 10.6342641));
    var positionInfo = mPositionInfo.position.toDegrees();
    var latitude = positionInfo[0];
    var longitude = positionInfo[1];
    var utm = CoordinateConverter.latlongToUTM(latitude, longitude);
    var view = new StopsView(
        Constants.CLOSEST_STOPS_RANGE, utm[:northing], utm[:easting]);
    var delegate = new StandardViewDelegate(view);
    Ui.pushView(view, delegate, Ui.SLIDE_LEFT);
  }

  function showFavorites_() {
    var view = new FavoriteLinesView();
    var delegate = new StandardViewDelegate(view);
    Ui.pushView(view, delegate, Ui.SLIDE_UP);
  }
}
