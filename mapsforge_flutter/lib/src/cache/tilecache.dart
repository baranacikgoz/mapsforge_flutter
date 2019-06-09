import 'package:dcache/dcache.dart';
import 'package:mapsforge_flutter/src/model/tile.dart';
import 'package:mapsforge_flutter/src/projection/mercatorprojectionimpl.dart';
import 'package:mapsforge_flutter/src/utils/mercatorprojection.dart';

import '../model/observableinterface.dart';

/// Interface for tile image caches.
abstract class TileCache extends ObservableInterface {
  final Map<int, _ZoomLevelTileCache> _caches = Map();

  /**
   * Destroys this cache.
   * <p/>
   * Applications are expected to call this method when they no longer require the cache.
   * <p/>
   * In versions prior to 0.5.1, it was common practice to call this method but continue using the cache, in order to
   * empty it, forcing all tiles to be re-rendered or re-requested from the source. Beginning with 0.5.1,
   * {@link #purge()} should be used for this purpose. The earlier practice is now discouraged and may lead to
   * unexpected results when used with features introduced in 0.5.1 or later.
   */
  void destroy();

  /**
   * @return the capacity of the first level of a multi-level cache.
   */
  int getCapacityFirstLevel();

  /**
   * Purges this cache.
   * <p/>
   * Calls to {@link #get(Job)} issued after purging will not return any tiles added before the purge operation.
   * <p/>
   * Applications should purge the tile cache when map model parameters change, such as the render style for locally
   * rendered tiles, or the source for downloaded tiles. Applications which frequently alternate between a limited
   * number of map model configurations may want to consider using a different cache for each.
   *
   * @since 0.5.1
   */
  void purge();

  Tile getTile(int x, int y, int zoomLevel, double tileSize) {
    _ZoomLevelTileCache cache = _caches[zoomLevel];
    if (cache == null) {
      cache = _ZoomLevelTileCache(zoomLevel, tileSize);
      _caches[zoomLevel] = cache;
    }
    return cache.getTile(x, y);
  }
}

/////////////////////////////////////////////////////////////////////////////

class _ZoomLevelTileCache {
  Cache _tilePositions = new SimpleCache<int, Tile>(
      storage: new SimpleStorage<int, Tile>(size: 200),
      onEvict: (idx, tile) {
        tile.dispose();
      });

  int xCount;

  int yCount;

  final double tileSize;

  final int zoomLevel;

  _ZoomLevelTileCache(this.zoomLevel, this.tileSize)
      : assert(zoomLevel >= 0),
        assert(tileSize > 0) {
    _getTilePositions(zoomLevel, tileSize);
    //_bitmaps = List(_tilePositions.length);
  }

  void _getTilePositions(int zoomLevel, double tileSize) {
    MercatorProjectionImpl mercatorProjectionImpl = MercatorProjectionImpl(tileSize, zoomLevel);
    int tileLeft = 0;
    int tileTop = 0;
    int tileRight = mercatorProjectionImpl.longitudeToTileX(MercatorProjectionImpl.LONGITUDE_MAX);
    int tileBottom = mercatorProjectionImpl.latitudeToTileY(MercatorProjectionImpl.LATITUDE_MIN);

    xCount = tileRight - tileLeft + 1;
    yCount = tileBottom - tileTop + 1;
    assert(xCount >= 0);
    assert(yCount >= 0);

    //_tilePositions = List<Tile>(xCount * yCount);
  }

  Tile getTile(int x, int y) {
    Tile result = _tilePositions.get(y * xCount + x);
    if (result == null) {
      result = Tile(x, y, zoomLevel, tileSize);
      _tilePositions[y * xCount + x] = result;
    }
    //assert(result != null);
    return result;
  }
}
