import 'package:logging/logging.dart';
import 'package:mapsforge_flutter/src/paintelements/point/mapelementcontainer.dart';

import '../model/tile.dart';

/// The TileDependecies class tracks the dependencies between tiles for labels.
/// When the labels are drawn on a per-tile basis it is important to know where
/// labels overlap the tile boundaries. A single label can overlap several neighbouring
/// tiles (even, as we do here, ignore the case where a long or tall label will overlap
/// onto tiles further removed -- with line breaks for long labels this should happen
/// much less frequently now.).
/// For every tile drawn we must therefore enquire which labels from neighbouring tiles
/// overlap onto it and these labels must be drawn regardless of priority as part of the
/// label has already been drawn.
class TileDependencies {
  static final _log = new Logger('TileDependencies');

  ///
  /// Data which the first tile (outer [Map]) has identified which should be drawn on the second tile (inner [Map]).
  final Map<Tile, Set<MapElementContainer>> _overlapData = {};

  TileDependencies();

  /// stores an MapElementContainer that clashesWith from one tile (the one being drawn) to
  /// another (which must not have been drawn before).
  ///
  /// @param from    origin tile
  /// @param to      tile the label clashesWith to
  /// @param element the MapElementContainer in question
  bool addOverlappingElement(Tile neighbour, MapElementContainer element) {
    if (!_overlapData.containsKey(neighbour)) {
      // never seen this neighbour
      _overlapData[neighbour] = {};
    } else {
      if (_overlapData[neighbour]!.length == 0) {
        // seems we have already drawn that neighbour, return true and do NOT store this element
        return true;
      }
    }
    _overlapData[neighbour]!.add(element);
    return false;
  }

  /// If we want to draw an overlapping element and find out that this element
  /// overlaps to an neighbour which is already drawn (see [addOverlappingElement]
  /// We want to revert it and do not draw that element at all.
  void removeOverlappingElement(Tile neighbour, MapElementContainer element) {
    if (_overlapData[neighbour] == null) return;
    if (_overlapData[neighbour]!.length > 0) {
      _overlapData[neighbour]?.remove(element);
      if (_overlapData[neighbour]!.length == 0) {
        // we removed the last element, remove the key so that we treat the neighbour as "not yet seen"
        _overlapData.remove(neighbour);
      }
    }
  }

  /// Retrieves the overlap data from the neighbouring tiles and removes them from cache
  ///
  /// @param tileToDraw the tile which we want to draw now
  /// @param neighbour the tile the label clashesWith from. This is the originating tile where the label was not fully fit into
  /// @return a List of the elements
  Set<MapElementContainer>? getOverlappingElements(Tile tileToDraw) {
    Set<MapElementContainer>? map = _overlapData[tileToDraw];
    if (map == null) {
      // we do not have anything for this tile but mark it as "drawn" now
      _overlapData[tileToDraw] = {};
      return null;
    }
    Set<MapElementContainer> result = {};
    result.addAll(map);
    //map.remove(tileToDraw);
    map.clear();
    return result;
  }

  /**
   * Cache maintenance operation to remove data for a tile from the cache. This should be excuted
   * if a tile is removed from the TileCache and will be drawn again.
   *
   * @param from
   */
  // void removeTileData(Tile from, {Tile? to}) {
  //   if (to != null) {
  //     if (overlapData.containsKey(from)) {
  //       overlapData[from]!.remove(to);
  //     }
  //     return;
  //   }
  //   overlapData.remove(from);
  // }

  @override
  String toString() {
    return 'TileDependencies{overlapData: $_overlapData}';
  }

  void debug() {
    _overlapData.forEach((key, innerMap) {
      _log.info("OverlapData: $key with $innerMap");
    });
  }
}
