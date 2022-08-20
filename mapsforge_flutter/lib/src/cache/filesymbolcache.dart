import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ecache/ecache.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mapsforge_flutter/core.dart';
import 'package:mapsforge_flutter/src/exceptions/symbolnotfoundexception.dart';
import 'package:mapsforge_flutter/src/graphics/resourcebitmap.dart';
import 'package:mapsforge_flutter/src/implementation/graphics/flutterresourcebitmap.dart';
import 'package:mapsforge_flutter/src/utils/filehelper.dart';

///
/// A cache for symbols (small bitmaps used in the map, eg. stopsigns, arrows). The [src] parameter specifies the filename including the
/// extension starting from the assets-path. eg. "patterns/arrow.png"
///
class FileSymbolCache extends SymbolCache {
  static final String PREFIX_JAR = "jar:";

  static final String PREFIX_JAR_V1 =
      "jar:/org/mapsforge/android/maps/rendertheme";

  final AssetBundle? bundle;

  final String? relativePathPrefix;

  LruCache<String, ResourceBitmap> _cache =
      new LruCache<String, ResourceBitmap>(
    storage: StatisticsStorage<String, ResourceBitmap>(onEvict: (key, item) {
      item.dispose();
    }),
    capacity: 500,
  );

  ///
  /// Creates a new FileSymbolCache. If the [relativePathPrefix] is not null the symbols will be loaded given by the [relativePathPrefix] first and if
  /// not found there the symbols will be loaded by the bundle.
  ///
  FileSymbolCache(AssetBundle this.bundle, [this.relativePathPrefix]);

  FileSymbolCache.withRelativePathPrefix(String this.relativePathPrefix)
      : bundle = null;

  @override
  void dispose() {
    print("Statistics for FileSymbolCache: ${_cache.storage.toString()}");
    _cache.clear();
  }

  //Future? future;
  @override
  Future<ResourceBitmap?> getSymbol(String? src, int width, int height) async {
    // if (future == null) {
    //   future = Future.delayed(const Duration(minutes: 1), () {
    //     print("now:");
    //     _cache.storage.entries.forEach((element) {
    //       print("  cached: ${element.key} ${element.value}");
    //       element.value?.debugGetOpenHandleStackTraces();
    //     });
    //     future = null;
    //   });
    // }
    if (src == null || src.length == 0) {
// no image source defined
      return null;
    }
    String key = "$src-$width-$height";
    ResourceBitmap? resourceBitmap = _cache.get(key);
    if (resourceBitmap != null) {
      return resourceBitmap.clone();
    }

    resourceBitmap = await _createSymbol(src, width, height);
    //bitmap.incrementRefCount();
    _cache.set(key, resourceBitmap);
    return resourceBitmap.clone();
  }

  Future<ResourceBitmap> _createSymbol(
      String src, int width, int height) async {
// we need to hash with the width/height included as the same symbol could be required
// in a different size and must be cached with a size-specific hash
    if (src.toLowerCase().endsWith(".svg")) {
      return _createSvgSymbol(src, width, height);
    } else if (src.toLowerCase().endsWith(".png")) {
      return _createPngSymbol(src, width, height);
    } else {
      throw Exception("Unknown resource fileformat $src");
    }
  }

  ///
  /// Returns the content of the symbol given as [src] as [ByteData]. This method reads the file or resource and returns the requested bytes.
  ///
  @protected
  Future<ByteData?> fetchResource(String src) async {
    // compatibility with mapsforge
    if (src.startsWith(PREFIX_JAR)) {
      src = src.substring(PREFIX_JAR.length);
      src = "packages/mapsforge_flutter/assets/" + src;
    } else if (src.startsWith(PREFIX_JAR_V1)) {
      src = src.substring(PREFIX_JAR_V1.length);
      src = "packages/mapsforge_flutter/assets/" + src;
    }
    if (relativePathPrefix != null) {
      String dir = await FileHelper.findLocalPath();
      src = dir + "/" + relativePathPrefix! + src;
      //_log.info("Trying to load symbol from $src");
      File file = File(src);
      if (await file.exists()) {
        Uint8List bytes = await file.readAsBytes();
        return ByteData.view(bytes.buffer);
      }
    }
    if (bundle != null) {
      ByteData content = await bundle!.load(src);
      return content;
    }
    return null;
  }

  Future<FlutterResourceBitmap> _createPngSymbol(
      String src, int width, int height) async {
    ByteData? content = await fetchResource(src);
    if (content == null) throw SymbolNotFoundException(src);
    Uint8List bytes = content.buffer.asUint8List();
    if (width != 0 && height != 0) {
      var codec = await ui.instantiateImageCodec(bytes,
          targetHeight: height, targetWidth: width);
      // add additional checking for number of frames etc here
      var frame = await codec.getNextFrame();
      ui.Image img = frame.image;

      FlutterResourceBitmap result = FlutterResourceBitmap(img, src);
      return result;
    } else {
      var codec = await ui.instantiateImageCodec(bytes);
      // add additional checking for number of frames etc here
      var frame = await codec.getNextFrame();
      ui.Image img = frame.image;

      FlutterResourceBitmap result = FlutterResourceBitmap(img, src);
      return result;
    }

    //Image img = Image.memory(content.buffer.asUint8List());
    //MemoryImage image = MemoryImage(content.buffer.asUint8List());
  }

  Future<FlutterResourceBitmap> _createSvgSymbol(
      String src, int width, int height) async {
    ByteData? content = await fetchResource(src);
    if (content == null) throw SymbolNotFoundException(src);
    DrawableRoot svgRoot =
        await svg.fromSvgBytes(content.buffer.asUint8List(), src);

// If you only want the final Picture output, just use
    final ui.Picture picture =
        svgRoot.toPicture(size: ui.Size(width.toDouble(), height.toDouble()));
    ui.Image image = await picture.toImage(width, height);
    //print("image: " + image.toString());
    FlutterResourceBitmap result = FlutterResourceBitmap(image, src);
    return result;
  }
}
