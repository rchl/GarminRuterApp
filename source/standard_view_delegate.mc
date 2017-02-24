using Toybox.WatchUi as Ui;

class StandardViewDelegate extends Ui.BehaviorDelegate {
  hidden var mView;

  function initialize(view) {
    BehaviorDelegate.initialize();
    mView = view;
  }

  function onTap(event) {
    if (event.getType() == Ui.CLICK_TYPE_TAP) {
      var coordinates = event.getCoordinates();
      return mView.handleTap(coordinates[0], coordinates[1]);
    }
    return false;
  }

  function onSwipe(event) {
    return mView.handleSwipe(event.getDirection());
  }

  function onHold(event) {
    var coordinates = event.getCoordinates();
    return mView.handleHold(coordinates[0], coordinates[1]);
  }
}
