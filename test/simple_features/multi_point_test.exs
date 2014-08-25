defmodule MultiPointTest do
  use ExUnit.Case, async: true
  alias SimpleFeatures.MultiPoint, as: MultiPoint
  alias SimpleFeatures.Point, as: Point

  @multi_point MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444)

  test "multi_point creation" do

    [a, _b, c] = @multi_point.geometries
    assert a == Point.from_x_y(12.4, -123.3, 444)
    assert c == Point.from_x_y(123.55555555, 123, 444)
  end

  test "to_coordinates" do
    multi_point = MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444)
    assert MultiPoint.to_coordinates(multi_point) == [[12.4, -123.3], [-65.1, 123.4], [123.55555555, 123]]
  end

  test "multi_point ewkt" do
    multi_point = MultiPoint.from_coordinates([[12.4,-123.3],[-65.1,123.4],[123.55555555,123]],444)
    ewkt = MultiPoint.as_ewkt(multi_point, true, false, false)
    assert ewkt == "SRID=444;MULTIPOINT((12.4 -123.3),(-65.1 123.4),(123.55555555 123))"

    multi_point = MultiPoint.from_coordinates([[12.4,-123.3,4.5],[-65.1,123.4,6.7],[123.55555555,123,7.8]],444,true)
    ewkt = MultiPoint.as_ewkt(multi_point, true, false, false)
    assert ewkt == "SRID=444;MULTIPOINT((12.4 -123.3 4.5),(-65.1 123.4 6.7),(123.55555555 123 7.8))"
  end

  test "to json" do
    assert MultiPoint.to_json(@multi_point) == "{\"type\":\"MultiPoint\",\"coordinates\":[[12.4,-123.3],[-65.1,123.4],[123.55555555,123]]}"
  end

end
