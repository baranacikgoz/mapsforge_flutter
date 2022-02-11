import 'package:mapsforge_flutter/marker.dart';
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/special.dart';
// ignore: implementation_imports
import 'package:mapsforge_flutter/src/graphics/display.dart';
// ignore: implementation_imports
import 'package:mapsforge_flutter/src/model/mappoint.dart';

class CircleMarker<T> extends BasicMarker<T> {
  final ILatLong center;

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
    required this.center,
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
          rotation: 0,
          item: item,
          markerCaption: markerCaption,
        );

  @override
  Future<void> initResources(GraphicFactory graphicFactory) async {
    await super.initResources(graphicFactory);
    if (fill == null && fillColor != null) {
      fill = graphicFactory.createPaint();
      fill!.setColorFromNumber(fillColor!);
      fill!.setStyle(Style.FILL);
      fill!.setStrokeWidth(fillWidth);
      //this.stroke.setTextSize(fontSize);
    }
    if (stroke == null && strokeWidth > 0) {
      stroke = graphicFactory.createPaint();
      stroke!.setColorFromNumber(strokeColor);
      stroke!.setStyle(Style.STROKE);
      stroke!.setStrokeWidth(strokeWidth);
      //this.stroke.setTextSize(fontSize);
    }

    if (markerCaption != null && markerCaption!.latLong == null) {
      markerCaption!.latLong = center;
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
          center.latitude, center.longitude, radius, fill!);
    }
    if (stroke != null) {
      markerCallback.renderCircle(
          center.latitude, center.longitude, radius, stroke!);
    }
  }

  @override
  bool isTapped(
      MapViewPosition mapViewPosition, double tappedX, double tappedY) {
    Mappoint p1 = Mappoint(tappedX + mapViewPosition.leftUpper!.x,
        tappedY + mapViewPosition.leftUpper!.y);
    Mappoint p2 = mapViewPosition.projection!.latLonToPixel(center);

    return p2.distance(p1) >= radius;
  }
}