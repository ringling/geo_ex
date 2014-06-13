defmodule PointTest do
  use ExUnit.Case

  # Creation

  test "returns a 2d point" do
    point = SimpleFeatures.Point.from_x_y(10, -20.0, 123)
    assert point.x == 10
    assert point.y == -20
    assert point.srid == 123
  end

  test "returns a 3d point" do
    point = SimpleFeatures.Point.from_x_y_z(10, 20, 30, 123)
    assert point.x == 10
    assert point.y == 20
    assert point.z == 30
    assert point.srid == 123
  end

  test "returns a 4d point" do
    point = SimpleFeatures.Point.from_x_y_z_m(10, 20, 30, 12.343, 123)
    assert point.x == 10
    assert point.y == 20
    assert point.z == 30
    assert point.m == 12.343
    assert point.srid == 123
  end

  test "returns a point from polar coordinates" do
    point = SimpleFeatures.Point.from_r_t(1.4142,45)
    assert point.y == 0.9999904099540157
    assert point.x == 0.9999904099540152
  end


  test "returns a point from coordinates x,y and default srid" do
    point = SimpleFeatures.Point.from_coordinates([1.6, 2.8])
    assert point.x == 1.6
    assert point.y == 2.8
    assert point.srid == 4326
  end

  test "returns a point from coordinates x,y" do
    point = SimpleFeatures.Point.from_coordinates([1.6, 2.8],123)
    assert point.x == 1.6
    assert point.y == 2.8
    assert point.srid == 123
  end

  test "returns a point from coordinates x,y,z" do
    point = SimpleFeatures.Point.from_coordinates([1.6, 2.8, 3],123)
    assert point.x == 1.6
    assert point.y == 2.8
    assert point.z == 3
    assert point.srid == 123
  end

  test "returns a point from coordinates x,y,z,m" do
    point = SimpleFeatures.Point.from_coordinates([1.6, 2.8, 3, 666],123)
    assert point.x == 1.6
    assert point.y == 2.8
    assert point.z == 3
    assert point.m == 666
    assert point.srid == 123
  end

  test "has a bbox" do
    point = SimpleFeatures.Point.from_x_y_z_m(-1.6,2.8,-3.4,15,123)
    bbox = point |> SimpleFeatures.Point.bounding_box
    assert length(bbox) == 2
    [first, last] = bbox
    assert first == point
    assert last == point

  end


  # > Distance & Bearing

  test "calculates euclidian distance" do
    p1 = SimpleFeatures.Point.from_x_y(1,1)
    p2 = SimpleFeatures.Point.from_x_y(2,2)
    distance = SimpleFeatures.Point.euclidian_distance(p1, p2)
    assert distance == 1.4142135623730951
  end

  test "calculates spherical distance" do
    p1 = SimpleFeatures.Point.from_x_y(1,1)
    p2 = SimpleFeatures.Point.from_x_y(2,2)
    distance = SimpleFeatures.Point.spherical_distance(p1, p2)
    assert distance == 157225.35800318103
  end

  test "calculates ellipsoidal distance" do
    p1 = SimpleFeatures.Point.from_x_y(1,1)
    p2 = SimpleFeatures.Point.from_x_y(2,2)
    distance = SimpleFeatures.Point.ellipsoidal_distance(p1, p2)
    assert distance == 156876.1494007417
  end


end
