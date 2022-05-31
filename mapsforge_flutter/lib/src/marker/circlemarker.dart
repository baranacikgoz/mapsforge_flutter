import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/marker.dart';
import 'package:mapsforge_flutter/special.dart';
import 'package:mapsforge_flutter/src/graphics/display.dart';
import 'package:mapsforge_flutter/src/model/mappoint.dart';

/// A marker which draws a circle specified by its center as lat/lon and by its radius in pixels.
class CircleMarker<T> extends BasicPointMarker<T> {
  MapPaint? fill;

  double fillWidth;

  int? fillColor;

  MapPaint? stroke;

  final double strokeWidth;

  final int strokeColor;

  final double radius;

  final int? percent;

  CircleMarker({
    display = Display.ALWAYS,
    minZoomLevel = 0,
    maxZoomLevel = 65535,
    item,
    markerCaption,
    required ILatLong center,
    this.radius = 3,
    this.percent,
    this.fillWidth = 1.0,
    this.fillColor,
    this.strokeWidth = 1.0,
    this.strokeColor = 0xff000000,
  })  : assert(display != null),
        assert(minZoomLevel >= 0),
        assert(maxZoomLevel <= 65535),
        assert(strokeWidth >= 0),
        assert(fillWidth >= 0),
        super(
          display: display,
          minZoomLevel: minZoomLevel,
          maxZoomLevel: maxZoomLevel,
          item: item,
          markerCaption: markerCaption,
          latLong: center,
        );

  Future<void> initResources(SymbolCache? symbolCache) async {
    if (fill == null && fillColor != null) {
      fill = GraphicFactory().createPaint();
      fill!.setColorFromNumber(fillColor!);
      fill!.setStyle(Style.FILL);
      fill!.setStrokeWidth(fillWidth);
      //this.stroke.setTextSize(fontSize);
    }
    if (stroke == null && strokeWidth > 0) {
      stroke = GraphicFactory().createPaint();
      stroke!.setColorFromNumber(strokeColor);
      stroke!.setStyle(Style.STROKE);
      stroke!.setStrokeWidth(strokeWidth);
      //this.stroke.setTextSize(fontSize);
    }

    if (markerCaption != null && markerCaption!.latLong == null) {
      markerCaption!.latLong = latLong;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool shouldPaint(BoundingBox? boundary, int zoomLevel) {
    return minZoomLevel <= zoomLevel && maxZoomLevel >= zoomLevel;
  }

  @override
  void renderBitmap(MarkerCallback markerCallback) {
    if (fill != null) {
      markerCallback.renderCircle(
          latLong.latitude, latLong.longitude, radius, fill!);
    }
    if (stroke != null) {
      markerCallback.renderCircle(
          latLong.latitude, latLong.longitude, radius, stroke!);
    }
  }

  @override
  bool isTapped(TapEvent tapEvent) {
    Mappoint p1 = Mappoint(
        tapEvent.x + tapEvent.leftUpperX, tapEvent.y + tapEvent.leftUpperY);
    Mappoint p2 = tapEvent.projection.latLonToPixel(latLong);

    return p2.distance(p1) <= radius;
  }
}
