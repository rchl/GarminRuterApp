using Toybox.Application as App;
using Toybox.Position;

class RuterApp extends App.AppBase {
  hidden var mView;

  function initialize() {
    AppBase.initialize();
    mView = new InitialView();
  }

  // onStart() is called on application start up
  function onStart(state) {
    Position.enableLocationEvents(Position.LOCATION_CONTINUOUS,
                                  method(:onPosition));
  }

  // onStop() is called when your application is exiting
  function onStop(state) {
    Position.enableLocationEvents(Position.LOCATION_DISABLE,
                                  method(:onPosition));
  }

  // Return the initial view of your application here
  function getInitialView() {
    var delegate = new StandardViewDelegate(mView);
    return [mView, delegate];
  }

  function onPosition(info) { mView.setPosition(info); }
}
