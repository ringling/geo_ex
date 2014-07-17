defmodule MultiPointTest do
  use ExUnit.Case, async: true
  alias SimpleFeatures.MultiPoint, as: MultiPoint
  alias SimpleFeatures.Point, as: Point

  test "multi_point creation" do
    multi_point = MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444)
    [a, _b, c] = multi_point.geometries
    assert a == Point.from_x_y(12.4, -123.3, 444)
    assert c == Point.from_x_y(123.55555555, 123, 444)
  end

  # test "multi_point binary" do
  #   "IMPLEMENT"
  #   multi_point = MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444)
  #   ewkt = MultiPoint.as_hex_ewkb(multi_point, true, false, false)
  #   assert ewkt == "0104000020BC010000030000000101000000CDCCCCCCCCCC28403333333333D35EC0010100000066666666664650C09A99999999D95E4001010000001F97DD388EE35E400000000000C05E40"

  #   multi_point = MultiPoint.from_coordinates([[12.4,-123.3,4.5],[-65.1,123.4,1.2],[123.55555555,123,2.3]],444,true)
  #   # Apex.ap MultiPoint.to_coordinates multi_point
  #   # multi_point.as_hex_ewkb.should eql("01040000A0BC010000030000000101000080CDCCCCCCCCCC28403333333333D35EC00000000000001240010100008066666666664650C09A99999999D95E40333333333333F33F01010000801F97DD388EE35E400000000000C05E406666666666660240")
  # end

  test "to_coordinates" do
    "IMPLEMENT"
  end

  test "multi_point ewkt" do
    multi_point = MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444)
    ewkt = MultiPoint.as_ewkt(multi_point, true, false, false)
    assert ewkt == "SRID=444;MULTIPOINT((12.4 -123.3),(-65.1 123.4),(123.55555555 123))"

    multi_point = MultiPoint.from_coordinates([[12.4,-123.3,4.5],[-65.1,123.4,6.7],[123.55555555,123,7.8]],444,true)
    ewkt = MultiPoint.as_ewkt(multi_point, true, false, false)
    assert ewkt == "SRID=444;MULTIPOINT((12.4 -123.3 4.5),(-65.1 123.4 6.7),(123.55555555 123 7.8))"
  end

  test "respond to points" do
    mp = MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444)
    assert length(mp.geometries) == 3
    assert length(MultiPoint.points(mp)) == 3
  end

end
