using Toybox.Graphics as Gfx;
using Toybox.System;

class PageIndicator {
  hidden static const HEIGHT = 4;
  hidden static const INACTIVE_COLOR = Gfx.COLOR_LT_GRAY;
  hidden static const ACTIVE_COLOR = Gfx.COLOR_BLACK;
  hidden static const BORDER_COLOR = Gfx.COLOR_DK_GRAY;

  static function drawLine(dc, bounds, pageCount, currentPage) {
    if (pageCount <= 1) {
      return;
    }
    var width = bounds.width;
    var height = bounds.height;
    var drawX = bounds.x;
    var drawY = bounds.bottom() - HEIGHT;
    var indicatorWidth = width / pageCount;
    var remainingPixels = width % pageCount;
    for (var i = 0; i < pageCount; i++) {
      var notLastPage = i < (pageCount - 1);
      var extraPixels = notLastPage ? 1 : 0;
      if (remainingPixels > 0) {
        extraPixels += 1;
        remainingPixels -= 1;
      }
      var isActive = currentPage == (i + 1);
      dc.setColor(BORDER_COLOR, Gfx.COLOR_TRANSPARENT);
      dc.fillRectangle(drawX, drawY, indicatorWidth + extraPixels, HEIGHT);
      dc.setColor(isActive ? ACTIVE_COLOR : INACTIVE_COLOR,
                  Gfx.COLOR_TRANSPARENT);
      dc.fillRectangle(drawX + 1, drawY + 1, indicatorWidth + extraPixels - 2,
                       HEIGHT - 2);
      drawX += indicatorWidth + extraPixels - 1;
    }
  }

  static function drawCircle(dc, bounds, pageCount, currentPage) {
    var width = bounds.width;
    var height = bounds.height;
    var drawY = height - BOTTOM_PADDING - INDICATOR_RADIUS;
    var widgetWidth = pageCount * (INDICATOR_RADIUS * 2);
    var drawX = (width - widgetWidth) / 2;
    for (var i = 0; i < pageCount; i++) {
      drawX += INDICATOR_RADIUS / 2;
      var isActive = currentPage == (i + 1);
      dc.setColor(BORDER_COLOR, Gfx.COLOR_TRANSPARENT);
      dc.fillCircle(drawX, drawY, INDICATOR_RADIUS);
      dc.setColor(isActive ? ACTIVE_COLOR : INACTIVE_COLOR,
                  Gfx.COLOR_TRANSPARENT);
      dc.fillCircle(drawX, drawY, INDICATOR_RADIUS - 1);
      drawX += INDICATOR_RADIUS * 2;
    }
  }
}
