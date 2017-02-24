using Toybox.Application as App;
using Toybox.System;
using Toybox.Test;

class Storage {
  static const FAVORITES_KEY = "favorites";

  static function getFavorites() {
    var favorites = get_(FAVORITES_KEY);
    return favorites == null ? {} : favorites;
  }

  static function addFavorite(key, data) {
    var favorites = getFavorites();
    Test.assert(!favorites.hasKey(key));
    favorites.put(key, data);
    set_(Storage.FAVORITES_KEY, favorites);
  }

  static function removeFavorite(key) {
    var favorites = getFavorites();
    Test.assert(favorites.hasKey(key));
    favorites.remove(key);
    set_(Storage.FAVORITES_KEY, favorites);
  }

  static function set_(key, value) {
    App.getApp().setProperty(key, value);
  }

  static function get_(key) {
    return App.getApp().getProperty(key);
  }
}
