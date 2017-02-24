class Rect {
  var x;
  var y;
  var width;
  var height;

  function initialize(ax, ay, awidth, aheight) {
    x = ax;
    y = ay;
    width = awidth;
    height = aheight;
  }

  function setBounds(bounds) {
    x = bounds.x;
    y = bounds.y;
    width = bounds.width;
    height = bounds.height;
  }

  function right() { return x + width; }

  function bottom() { return y + height; }

  function contains(ax, ay) {
    return ax >= x && ax < right() && ay >= y && ay < bottom();
  }

  function inset(value) {
    x += value;
    y += value;
    width -= value * 2;
    height -= value * 2;
  }

  function offsetBy(left, top) {
    x += left;
    y += top;
  }
}
