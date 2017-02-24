using Toybox.WatchUi as Ui;

class LineMenuDelegate extends Ui.MenuInputDelegate {
  hidden var mLine = null;

  function initialize(line) {
    MenuInputDelegate.initialize();
    mLine = line;
  }

  function onMenuItem(item) {
    if (item == :add_favorite_line) {
      mLine.addFavorite();
      Ui.requestUpdate();
    } else if (item == :remove_favorite_line) {
      mLine.removeFavorite();
      Ui.requestUpdate();
    }
  }
}
