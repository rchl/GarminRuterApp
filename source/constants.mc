using Toybox.Communications as Comm;
using Toybox.Graphics as Gfx;

class Constants {
  // Ruter API.
  // static const RUTER_API_HOST = "https://reisapi.ruter.no";
  static const RUTER_API_HOST = "http://84.214.74.119:3456/ruter";
  static const GET_STOPS_PATH = "/Place/GetClosestStops";
  static const GET_DEPARTURES_PATH = "/StopVisit/GetDepartures";
  static const GET_FAVORITES_PATH = "/Favourites/GetFavourites";
  static const CLOSEST_STOPS_RANGE = 1400;  // meters
  static const VIEW_UPDATE_INTERVAL_SEC = 5;

  // UI.
  static const NETWORK_ERRORS = {
    Comm.BLE_CONNECTION_UNAVAILABLE => "BLE_CONNECTION_UNAVAILABLE",
    Comm.NETWORK_REQUEST_TIMED_OUT => "NETWORK_REQUEST_TIMED_OUT",
    Comm.INVALID_HTTP_BODY_IN_NETWORK_RESPONSE => "INVALID_HTTP_BODY_IN_NETWORK_RESPONSE",
    Comm.NETWORK_RESPONSE_TOO_LARGE => "NETWORK_RESPONSE_TOO_LARGE"
  };
  static const BACKGROUND_COLOR = Gfx.COLOR_BLACK;
  static const TINY_FONT_HEIGHT = Gfx.getFontHeight(Gfx.FONT_TINY);
  static const SMALL_FONT_HEIGHT = Gfx.getFontHeight(Gfx.FONT_SMALL);
  static const CLOCK_SIZE = Gfx.FONT_TINY;
  static const TEXT_CENTER = Gfx.TEXT_JUSTIFY_CENTER + Gfx.TEXT_JUSTIFY_VCENTER;

  // Stops view.
  static const STOPS_PER_PAGE = 3;
  static const STOP_NAME_FONT = Gfx.FONT_MEDIUM;
  static const STOP_TEXT_COLOR = Gfx.COLOR_BLACK;
  static const STOP_NAME_BACKGROUND_COLOR = Gfx.COLOR_LT_GRAY;
  static const STOP_NAME_LEFT_PADDING = 10;

  // Lines view.
  static const LINES_PER_PAGE = 3;
  static const LINE_FONT_SIZE = Gfx.FONT_SMALL;
  static const LINE_NAME_FONT = Gfx.FONT_SMALL;
  static const LINE_TEXT_COLOR = Gfx.COLOR_WHITE;
  static const LINE_NAME_HORIZONTAL_PADDING = 4;

  // Favorite lines view.
  static const FAVORITE_LINES_PER_PAGE = 2;
}
