import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/src/graphics/resourcebitmap.dart';

import '../../datastore/pointofinterest.dart';
import '../../paintelements/shape/polylinecontainer.dart';
import '../rendercontext.dart';

/// A RenderInstruction is a basic graphical primitive to draw a map.
abstract class RenderInstruction {
  static final String ALIGN_CENTER = "align-center";
  static final String ALL = "all";
  static final String CAT = "cat";
  static final String DISPLAY = "display";
  static final String DY = "dy";
  static final String FILL = "fill";
  static final String FONT_FAMILY = "font-family";
  static final String FONT_SIZE = "font-size";
  static final String FONT_STYLE = "font-style";
  static final String ID = "id";
  static final String K = "k";
  static final String NONE = "none";
  static final String POSITION = "position";
  static final String PRIORITY = "priority";
  static final String R = "r";
  static final String RADIUS = "radius";
  static final String REPEAT = "repeat";
  static final String REPEAT_GAP = "repeat-gap";
  static final String REPEAT_START = "repeat-start";
  static final String ROTATE = "rotate";
  static final String SCALE = "scale";
  static final String SCALE_RADIUS = "scale-radius";
  static final String SRC = "src";
  static final String STROKE = "stroke";
  static final String STROKE_DASHARRAY = "stroke-dasharray";
  static final String STROKE_LINECAP = "stroke-linecap";
  static final String STROKE_LINEJOIN = "stroke-linejoin";
  static final String STROKE_WIDTH = "stroke-width";
  static final String SYMBOL_HEIGHT = "symbol-height";
  static final String SYMBOL_ID = "symbol-id";
  static final String SYMBOL_PERCENT = "symbol-percent";
  static final String SYMBOL_SCALING = "symbol-scaling";
  static final String SYMBOL_WIDTH = "symbol-width";

  String? category;

  RenderInstruction();

  String? getCategory() {
    return this.category;
  }

  /// @param renderCallback a reference to the receiver of all render callbacks.
  /// @param renderContext
  /// @param poi
  Future<void> renderNode(final RenderContext renderContext,
      PointOfInterest poi, SymbolCache symbolCache);

  /// @param renderCallback a reference to the receiver of all render callbacks.
  /// @param renderContext
  /// @param way
  Future<void> renderWay(final RenderContext renderContext,
      PolylineContainer way, SymbolCache symbolCache);

  Scale scaleFromValue(String value) {
    if (value == (ALL)) {
      return Scale.ALL;
    } else if (value == (NONE)) {
      return Scale.NONE;
    }
    return Scale.STROKE;
  }

  /// Scales the stroke width of this RenderInstruction by the given factor.
  void prepareScale(int zoomLevel);
}

/////////////////////////////////////////////////////////////////////////////

enum Scale { ALL, NONE, STROKE }
