class PagedList {
  hidden var mItems = [];
  hidden var mMaxItemsPerPage = 1;
  hidden var mPageCount = 0;
  hidden var mCurrentPage = 1;

  function initialize(items, maxItemsPerPage) {
    mItems = items;
    mMaxItemsPerPage = maxItemsPerPage;
    mPageCount =
        mItems.size() > 0 ? ((mItems.size() - 1) / mMaxItemsPerPage) + 1 : 1;
  }

  function getItems() { return mItems; }

  function getCurrentPage() { return mCurrentPage; }

  function getPageCount() { return mPageCount; }

  function nextPage() {
    if (mCurrentPage < mPageCount) {
      mCurrentPage += 1;
    }
  }

  function previousPage() {
    if (mCurrentPage > 1) {
      mCurrentPage -= 1;
    }
  }

  function getItemAt(x, y) {
    var startIndex = mCurrentPage * mMaxItemsPerPage - mMaxItemsPerPage;
    var currentPageItems = mItems.slice(
        startIndex, startIndex + mMaxItemsPerPage);
    return Utils.hitTest(x, y, currentPageItems);
  }

  function layoutAndDraw(dc, bounds) {
    var currentX = bounds.x;
    var currentY = bounds.y;
    var lineHeight = bounds.height / mMaxItemsPerPage;
    var startIndex = mCurrentPage * mMaxItemsPerPage - mMaxItemsPerPage;
    for (var i = startIndex; i < mItems.size(); i++) {
      var item = mItems[i];
      item.setBounds(new Rect(currentX, currentY, bounds.width, lineHeight));
      item.layoutAndDraw(dc);
      var isLast = (i - startIndex) == (mMaxItemsPerPage - 1);
      if (isLast) {
        break;
      }
      currentY += lineHeight;
    }
    PageIndicator.drawLine(dc, bounds, getPageCount(), getCurrentPage());
  }
}
