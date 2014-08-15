defmodule MultiPolygonTest do
  use ExUnit.Case, async: true

  alias SimpleFeatures.MultiPolygon

  @coordinates [12.4,-45.3]
  @polygon_coordinates1 [[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]]
  @polygon_coordinates2 [[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]]
  @polygon_coordinates_sequence [@polygon_coordinates1, @polygon_coordinates2]
  @point SimpleFeatures.Point.from_coordinates(@coordinates,256)
  @poly1 SimpleFeatures.Polygon.from_coordinates([[@coordinates,[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256)
  @poly2 SimpleFeatures.Polygon.from_coordinates(@polygon_coordinates1, 256)
  @mp MultiPolygon.from_polygons([@poly1, @poly2],256)

  @polygon_coordinates3 [[[0,0],[0,2],[2,2],[2,0],[0,0]]]
  @polygon_coordinates4 [[[0,4],[4,4],[4,8],[0,8],[0,4]]]
  @poly3 SimpleFeatures.Polygon.from_coordinates(@polygon_coordinates3,256)
  @poly4 SimpleFeatures.Polygon.from_coordinates(@polygon_coordinates4, 256)
  @multi_poly MultiPolygon.from_polygons([@poly3, @poly4],256)


  test "multi_polygon from polygons creation" do
    multi_polygon1 = MultiPolygon.from_polygons([@poly1, @poly2],256)
    assert length(multi_polygon1.geometries) == 2
    assert hd(multi_polygon1.geometries) == @poly1
    assert hd(multi_polygon1.geometries) == SimpleFeatures.Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256)
  end

  test "multi_polygon from coordinates creation" do
    multi_polygon1 = MultiPolygon.from_coordinates(@polygon_coordinates_sequence, 256, false)
    assert length(multi_polygon1.geometries) == 2
    assert hd(multi_polygon1.geometries) == SimpleFeatures.Polygon.from_coordinates(@polygon_coordinates1, 256)
  end

  test "multi_polygon from points creation" do
    polygon_points1 = @polygon_coordinates1 |> coordinate_seq_to_point_seq(256)
    polygon_points2 = @polygon_coordinates2 |> coordinate_seq_to_point_seq(256)
    polygon_point_sequence_sequences = [polygon_points1, polygon_points2]

    multi_polygon = MultiPolygon.from_points(polygon_point_sequence_sequences, 256)
    assert length(multi_polygon.geometries) == 2
    assert hd(multi_polygon.geometries) == SimpleFeatures.Polygon.from_coordinates(@polygon_coordinates1, 256)
  end

  test "returns points" do
    points = MultiPolygon.points(@mp)
    assert hd(points) == @point
  end

  test "flatten points right" do
    points = MultiPolygon.points(@mp)
    assert length(points) == 18
  end

  test "contains point" do
    inside = SimpleFeatures.Point.from_coordinates([0,0],256)
    assert MultiPolygon.contains_point?(@multi_poly, inside) == true
  end

  test "doesn't contains point" do
    on_border = SimpleFeatures.Point.from_coordinates([4.0,4.0],256)
    outside = SimpleFeatures.Point.from_coordinates([4.1,4.1],256)
    assert MultiPolygon.contains_point?(@multi_poly, on_border) == false
    assert MultiPolygon.contains_point?(@multi_poly, outside) == false
  end

  test "to coordinates" do
    assert MultiPolygon.to_coordinates(@multi_poly) == [@polygon_coordinates3, @polygon_coordinates4]
  end


  test "as json" do
    json = "{\"type\":\"MultiPolygon\",\"coordinates\":[[[[0,0],[0,2],[2,2],[2,0],[0,0]]],[[[0,4],[4,4],[4,8],[0,8],[0,4]]]]}"
    assert MultiPolygon.to_json(@multi_poly) == json
  end

  defp coordinate_seq_to_point_seq(coordinates_sequence, srid) do
    coordinates_sequence
    |> Enum.map fn(coordinates) ->
      coordinates |> Enum.map fn(coordinate) ->
        SimpleFeatures.Point.from_coordinates(coordinate, srid)
      end
    end
  end

end

#   it "test_multi_polygon_binary" do
#     multi_polygon = GeoRuby::SimpleFeatures::MultiPolygon.from_polygons([GeoRuby::SimpleFeatures::Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256),GeoRuby::SimpleFeatures::Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)],256)
#     multi_polygon.as_hex_ewkb.should eql("0106000020000100000200000001030000000200000004000000CDCCCCCCCCCC28406666666666A646C03333333333B34640CDCCCCCCCCCC44406DE7FBA9F1D211403D2CD49AE61DF13FCDCCCCCCCCCC28406666666666A646C004000000333333333333034033333333333315409A999999999915408A8EE4F21FD2F63FEC51B81E85EB2C40F6285C8FC2F5F03F3333333333330340333333333333154001030000000200000005000000000000000000000000000000000000000000000000001040000000000000000000000000000010400000000000001040000000000000000000000000000010400000000000000000000000000000000005000000000000000000F03F000000000000F03F0000000000000840000000000000F03F00000000000008400000000000000840000000000000F03F0000000000000840000000000000F03F000000000000F03F")

#     multi_polygon = GeoRuby::SimpleFeatures::MultiPolygon.from_polygons([GeoRuby::SimpleFeatures::Polygon.from_coordinates([[[12.4,-45.3,1.2],[45.4,41.6,1.2],[4.456,1.0698,1.2],[12.4,-45.3,1.2]],[[2.4,5.3,1.2],[5.4,1.4263,1.2],[14.46,1.06,1.2],[2.4,5.3,1.2]]],256,false,true),GeoRuby::SimpleFeatures::Polygon.from_coordinates([[[0,0,1.2],[4,0,1.2],[4,4,2.3],[0,4,1.2],[0,0,1.2]],[[1,1,2.2],[3,1,3.3],[3,3,1.1],[1,3,2.4],[1,1,2.2]]],256,false,true)],256,false,true)
#     multi_polygon.as_hex_ewkb.should eql("0106000020000100000200000001030000400200000004000000CDCCCCCCCCCC28406666666666A646C0333333333333F33F3333333333B34640CDCCCCCCCCCC4440333333333333F33F6DE7FBA9F1D211403D2CD49AE61DF13F333333333333F33FCDCCCCCCCCCC28406666666666A646C0333333333333F33F0400000033333333333303403333333333331540333333333333F33F9A999999999915408A8EE4F21FD2F63F333333333333F33FEC51B81E85EB2C40F6285C8FC2F5F03F333333333333F33F33333333333303403333333333331540333333333333F33F0103000040020000000500000000000000000000000000000000000000333333333333F33F00000000000010400000000000000000333333333333F33F00000000000010400000000000001040666666666666024000000000000000000000000000001040333333333333F33F00000000000000000000000000000000333333333333F33F05000000000000000000F03F000000000000F03F9A999999999901400000000000000840000000000000F03F6666666666660A40000000000000084000000000000008409A9999999999F13F000000000000F03F00000000000008403333333333330340000000000000F03F000000000000F03F9A99999999990140")
#   end

#   it "test_multi_polygon_text" do
#     multi_polygon = GeoRuby::SimpleFeatures::MultiPolygon.from_polygons([GeoRuby::SimpleFeatures::Polygon.from_coordinates([[[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],[[2.4,5.3],[5.4,1.4263],[14.46,1.06],[2.4,5.3]]],256),GeoRuby::SimpleFeatures::Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)],256)
#     multi_polygon.as_ewkt.should eql("SRID=256;MULTIPOLYGON(((12.4 -45.3,45.4 41.6,4.456 1.0698,12.4 -45.3),(2.4 5.3,5.4 1.4263,14.46 1.06,2.4 5.3)),((0 0,4 0,4 4,0 4,0 0),(1 1,3 1,3 3,1 3,1 1)))")

#     multi_polygon = GeoRuby::SimpleFeatures::MultiPolygon.from_polygons([GeoRuby::SimpleFeatures::Polygon.from_coordinates([[[12.4,-45.3,2],[45.4,41.6,3],[4.456,1.0698,4],[12.4,-45.3,2]],[[2.4,5.3,1],[5.4,1.4263,3.44],[14.46,1.06,4.5],[2.4,5.3,1]]],4326,true),GeoRuby::SimpleFeatures::Polygon.from_coordinates([[[0,0,5.6],[4,0,5.4],[4,4,1],[0,4,23],[0,0,5.6]],[[1,1,2.3],[3,1,4],[3,3,5],[1,3,6],[1,1,2.3]]],4326,true)],4326,true)
#     multi_polygon.as_ewkt.should eql("SRID=4326;MULTIPOLYGON(((12.4 -45.3 2,45.4 41.6 3,4.456 1.0698 4,12.4 -45.3 2),(2.4 5.3 1,5.4 1.4263 3.44,14.46 1.06 4.5,2.4 5.3 1)),((0 0 5.6,4 0 5.4,4 4 1,0 4 23,0 0 5.6),(1 1 2.3,3 1 4,3 3 5,1 3 6,1 1 2.3)))")
#   end
