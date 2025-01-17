import 'package:logging/logging.dart';
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/src/graphics/graphicfactory.dart';
import 'package:mapsforge_flutter/src/graphics/mapcanvas.dart';
import 'package:mapsforge_flutter/src/graphics/mappaint.dart';
import 'package:mapsforge_flutter/src/graphics/matrix.dart';
import 'package:mapsforge_flutter/src/graphics/tilebitmap.dart';
import 'package:mapsforge_flutter/src/implementation/graphics/fluttercanvas.dart';
import 'package:mapsforge_flutter/src/layer/job/jobresult.dart';
import 'package:mapsforge_flutter/src/layer/job/jobset.dart';
import 'package:mapsforge_flutter/src/model/mappoint.dart';
import 'package:mapsforge_flutter/src/model/mapviewposition.dart';
import 'package:mapsforge_flutter/src/model/tile.dart';
import 'package:mapsforge_flutter/src/model/viewmodel.dart';

import 'job/job.dart';
import 'job/jobqueue.dart';
import 'tilelayer.dart';

///
/// this class presents the whole map by requesting the tiles and drawing them when available
class TileLayerImpl extends TileLayer {
  static final _log = new Logger('TileLayer');

  final JobQueue jobQueue;
  Matrix? _matrix;
  final MapPaint _paint;

  TileLayerImpl({
    required this.jobQueue,
    required displayModel,
  })  : assert(displayModel != null),
        _paint = GraphicFactory().createPaint(),
        super(displayModel);

  @override
  void draw(ViewModel viewModel, MapViewPosition mapViewPosition,
      MapCanvas canvas, JobSet jobSet) {
    //_log.info("tiles: ${tiles.toString()}");

    // In a rotation situation it is possible that drawParentTileBitmap sets the
    // clipping bounds to portrait, while the device is just being rotated into
    // landscape: the result is a partially painted screen that only goes away
    // after zooming (which has the effect of resetting the clip bounds if drawParentTileBitmap
    // is called again).
    // Always resetting the clip bounds here seems to avoid the problem,
    // I assume that this is a pretty cheap operation, otherwise it would be better
    // to hook this into the onConfigurationChanged call chain.
    //canvas.resetClip();

    canvas.setClip(
        0, 0, viewModel.viewDimension!.width, viewModel.viewDimension!.height);
    mapViewPosition.calculateBoundingBox(viewModel.viewDimension!);
    Mappoint? leftUpper = mapViewPosition.leftUpper;

    if (mapViewPosition.scale != 1 && mapViewPosition.focalPoint != null) {
      //_log.info("scaling to ${mapViewPosition.scale} around ${mapViewPosition.focalPoint}");
      (canvas as FlutterCanvas).uiCanvas.save();
      canvas.scale(mapViewPosition.focalPoint!, mapViewPosition.scale);
    }
    jobSet.results.forEach((Tile tile, JobResult jobResult) {
      Mappoint point = mapViewPosition.projection!.getLeftUpper(tile);
      _paint.setAntiAlias(true);
      if (jobResult.bitmap != null)
        canvas.drawBitmap(
          bitmap: jobResult.bitmap!,
          left: point.x - leftUpper!.x,
          top: point.y - leftUpper.y,
          paint: _paint,
        );
    });
    if (mapViewPosition.scale != 1 && mapViewPosition.focalPoint != null) {
      //(canvas as FlutterCanvas).uiCanvas.drawCircle(Offset.zero, 20, Paint());
      (canvas as FlutterCanvas).uiCanvas.restore();
      //(canvas as FlutterCanvas).uiCanvas.drawCircle(Offset.zero, 15, Paint()..color = Colors.amber);
    }
  }

  /**
   * Whether the tile is stale and should be refreshed.
   * <p/>
   * This method is called from {@link #draw(BoundingBox, byte, Canvas, Point)} to determine whether the tile needs to
   * be refreshed. Subclasses must override this method and implement appropriate checks to determine when a tile is
   * stale.
   * <p/>
   * Return {@code false} to use the cached copy without attempting to refresh it.
   * <p/>
   * Return {@code true} to cause the layer to attempt to obtain a fresh copy of the tile. The layer will first
   * display the tile referenced by {@code bitmap} and attempt to obtain a fresh copy in the background. When a fresh
   * copy becomes available, the layer will replace is and update the cache. If a fresh copy cannot be obtained (e.g.
   * because the tile is obtained from an online source which cannot be reached), the stale tile will continue to be
   * used until another {@code #draw(BoundingBox, byte, Canvas, Point)} operation requests it again.
   *
   * @param tile   A tile.
   * @param bitmap The bitmap for {@code tile} currently held in the layer's cache.
   */
  bool isTileStale(Tile tile, TileBitmap bitmap) {
    return false;
  }

  void retrieveLabelsOnly(Job job) {}

  void drawParentTileBitmap(MapCanvas canvas, Mappoint point, Tile tile) {
    Tile? cachedParentTile = getCachedParentTile(tile, 4);
    if (cachedParentTile != null) {
//      Bitmap bitmap = this.tileCache.getImmediately(
//          createJob(cachedParentTile));
//      if (bitmap != null) {
//        int tileSize = this.displayModel.getTileSize();
//        long translateX = tile.getShiftX(cachedParentTile) * tileSize;
//        long translateY = tile.getShiftY(cachedParentTile) * tileSize;
//        byte zoomLevelDiff = (byte)(
//            tile.zoomLevel - cachedParentTile.zoomLevel);
//        float scaleFactor = (float) Math.pow(2, zoomLevelDiff);
//
//        int x = (int) Math.round(point.x);
//        int y = (int) Math.round(point.y);
//
//        if (Parameters.PARENT_TILES_RENDERING ==
//            Parameters.ParentTilesRendering.SPEED) {
//          bool antiAlias = canvas.isAntiAlias();
//          bool filterBitmap = canvas.isFilterBitmap();
//
//          canvas.setAntiAlias(false);
//          canvas.setFilterBitmap(false);
//
//          canvas.drawBitmap(
//              bitmap,
//              (int)(translateX / scaleFactor),
//              (int)(translateY / scaleFactor),
//              (int)((translateX + tileSize) / scaleFactor),
//              (int)((translateY + tileSize) / scaleFactor),
//              x,
//              y,
//              x + tileSize,
//              y + tileSize,
//              this.displayModel.getFilter());
//
//          canvas.setAntiAlias(antiAlias);
//          canvas.setFilterBitmap(filterBitmap);
//        } else {
//          this.matrix.reset();
//          this.matrix.translate(x - translateX, y - translateY);
//          this.matrix.scale(scaleFactor, scaleFactor);
//
//          canvas.setClip(x, y, this.displayModel.getTileSize(),
//              this.displayModel.getTileSize());
//          canvas.drawBitmap(bitmap, this.matrix, this.displayModel.getFilter());
//          canvas.resetClip();
//        }
//
//        bitmap.decrementRefCount();
//      }
    }
  }

  /**
   * @return the first parent object of the given object whose tileCacheBitmap is cached (may be null).
   */
  Tile? getCachedParentTile(Tile tile, int level) {
    if (level == 0) {
      return null;
    }

    Tile? parentTile = tile.getParent();
    if (parentTile == null) {
      return null;
//    } else if (this.tileCache.containsKey(createJob(parentTile))) {
//      return parentTile;
    }

    return getCachedParentTile(parentTile, level - 1);
  }
}
