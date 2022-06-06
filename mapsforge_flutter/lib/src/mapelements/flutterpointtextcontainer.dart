import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:mapsforge_flutter/src/graphics/display.dart';
import 'package:mapsforge_flutter/src/graphics/filter.dart';
import 'package:mapsforge_flutter/src/graphics/mapcanvas.dart';
import 'package:mapsforge_flutter/src/graphics/mappaint.dart';
import 'package:mapsforge_flutter/src/graphics/maptextpaint.dart';
import 'package:mapsforge_flutter/src/graphics/matrix.dart';
import 'package:mapsforge_flutter/src/graphics/position.dart';
import 'package:mapsforge_flutter/src/mapelements/pointtextcontainer.dart';
import 'package:mapsforge_flutter/src/model/mappoint.dart';
import 'package:mapsforge_flutter/src/model/rectangle.dart';

import '../implementation/graphics/fluttercanvas.dart';
import '../implementation/graphics/flutterpaint.dart';

class FlutterPointTextContainer extends PointTextContainer {
  static final _log = new Logger('FlutterPointTextContainer');

//  StaticLayout backLayout;
//  StaticLayout frontLayout;

  late ui.Paragraph front;

  late ui.Paragraph back;

  FlutterPointTextContainer(
      Mappoint xy,
      Display display,
      int priority,
      String text,
      MapPaint paintFront,
      MapPaint paintBack,
      Position position,
      int maxTextWidth,
      MapTextPaint mapTextPaint)
      : super(xy, display, priority, text, paintFront, paintBack, position,
            maxTextWidth, mapTextPaint) {
    double boxWidth;
    double boxHeight;

    // TextPaint frontTextPaint = new TextPaint(AndroidGraphicFactory.getPaint(this.paintFront));
    //TextPaint backTextPaint = null;
    //backTextPaint = new TextPaint(AndroidGraphicFactory.getPaint(this.paintBack));

    ui.TextAlign alignment = ui.TextAlign.center;
    if (Position.LEFT == this.position ||
        Position.BELOW_LEFT == this.position ||
        Position.ABOVE_LEFT == this.position) {
      //alignment = Layout.Alignment.ALIGN_OPPOSITE;
    } else if (Position.RIGHT == this.position ||
        Position.BELOW_RIGHT == this.position ||
        Position.ABOVE_RIGHT == this.position) {
      //alignment = Layout.Alignment.ALIGN_NORMAL;
    }

    // strange Android behaviour: if alignment is set to center, then
    // text is rendered with right alignment if using StaticLayout

    ui.ParagraphBuilder frontBuilder =
        FlutterCanvas.buildParagraphBuilder(text, paintFront, mapTextPaint);
    front = frontBuilder.build()
      ..layout(ui.ParagraphConstraints(width: textWidth));

    //backTextPaint.setTextAlign(android.graphics.Paint.Align.LEFT);
    ui.ParagraphBuilder backBuilder =
        FlutterCanvas.buildParagraphBuilder(text, paintBack, mapTextPaint);
    back = backBuilder.build()
      ..layout(ui.ParagraphConstraints(width: textWidth));

//      frontLayout = new StaticLayout(
//          this.text,
//          frontTextPaint,
//          this.maxTextWidth,
//          alignment,
//          1,
//          0,
//          false);
//      backLayout = null;
//      if (this.paintBack != null) {
//        backLayout = new StaticLayout(
//            this.text,
//            backTextPaint,
//            this.maxTextWidth,
//            alignment,
//            1,
//            0,
//            false);
//      }

//      boxWidth = frontLayout.getWidth();
//      boxHeight = frontLayout.getHeight();

    boxWidth = textWidth;
    boxHeight = textHeight;

    switch (this.position) {
      case Position.CENTER:
        boundary = new Rectangle(
            -boxWidth / 2, -boxHeight / 2, boxWidth / 2, boxHeight / 2);
        break;
      case Position.BELOW:
        boundary = new Rectangle(-boxWidth / 2, 0, boxWidth / 2, boxHeight);
        break;
      case Position.BELOW_LEFT:
        boundary = new Rectangle(-boxWidth, 0, 0, boxHeight);
        break;
      case Position.BELOW_RIGHT:
        boundary = new Rectangle(0, 0, boxWidth, boxHeight);
        break;
      case Position.ABOVE:
        boundary = new Rectangle(-boxWidth / 2, -boxHeight, boxWidth / 2, 0);
        break;
      case Position.ABOVE_LEFT:
        boundary = new Rectangle(-boxWidth, -boxHeight, 0, 0);
        break;
      case Position.ABOVE_RIGHT:
        boundary = new Rectangle(0, -boxHeight, boxWidth, 0);
        break;
      case Position.LEFT:
        boundary = new Rectangle(-boxWidth, -boxHeight / 2, 0, boxHeight / 2);
        break;
      case Position.RIGHT:
        boundary = new Rectangle(0, -boxHeight / 2, boxWidth, boxHeight / 2);
        break;
      case Position.AUTO:
        boundary = new Rectangle(
            -boxWidth / 2, -boxHeight / 2, boxWidth / 2, boxHeight / 2);
        break;
    }
  }

  @mustCallSuper
  @override
  dispose() {}

  @override
  void draw(MapCanvas canvas, Mappoint origin, Matrix matrix, Filter filter) {
    ui.Canvas? flutterCanvas = (canvas as FlutterCanvas).uiCanvas;

    // the origin of the text is the base line, so we need to make adjustments
    // so that the text will be within its box
    double textOffset = 0;
    switch (this.position) {
      case Position.CENTER:
      case Position.LEFT:
      case Position.RIGHT:
        //textOffset = textHeight / 2;
        break;
      case Position.BELOW:
      case Position.BELOW_LEFT:
      case Position.BELOW_RIGHT:
        //textOffset = textHeight.toDouble();
        break;
      default:
        break;
    }

    double adjustedX = (this.xy.x - origin.x) + boundary!.left;
    double adjustedY = (this.xy.y - origin.y) + textOffset + boundary!.top;

//    _log.info("Adjusted is $adjustedX/$adjustedY and witdht is $textWidth for $text");
//    Paint p = Paint();
//    p.color = Colors.amber;
//    p.strokeWidth = 2;
//    p.style = PaintingStyle.stroke;
//    flutterCanvas.drawRect(Rect.fromLTWH(adjustedX, adjustedY, textWidth.toDouble(), textHeight.toDouble()), p);
//    flutterCanvas.drawLine(Offset(adjustedX, adjustedY), Offset(adjustedX + textWidth, adjustedY - 20), (paintFront as FlutterPaint).paint);

    {
//      int color = this.paintBack.getColor();
//      if (filter != Filter.NONE) {
//        this.paintBack.setColor(GraphicUtils.filterColor(color, filter));
//      }
      flutterCanvas.drawParagraph(back, Offset(adjustedX, adjustedY));
//      if (filter != Filter.NONE) {
//        this.paintBack.setColor(color);
//      }
    }
//    int color = this.paintFront.getColor();
//    if (filter != Filter.NONE) {
//      this.paintFront.setColor(GraphicUtils.filterColor(color, filter));
//    }
    flutterCanvas.drawParagraph(front, Offset(adjustedX, adjustedY));
    // print(
    //     "FlutterPointTextContainer for $text: $adjustedX / $adjustedY and boundary $boundary and offset $textOffset, textHeight: $textHeight, textWidth: $textWidth");
//    if (filter != Filter.NONE) {
//      this.paintFront.setColor(color);
//    }
  }

  @override
  String toString() {
    return 'FlutterPointTextContainer{front: $front, back: $back, ${super.toString()}';
  }
}
