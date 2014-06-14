defmodule PointTest do
  use ExUnit.Case, async: true

  # Creation
  def p1 do
    SimpleFeatures.Point.from_x_y(1,1)
  end

  def p2 do
    SimpleFeatures.Point.from_x_y(2,2)
  end

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
    assert point.x == 0.9999904099540153
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
    distance = SimpleFeatures.Point.euclidian_distance(p1, p2)
    assert distance == 1.4142135623730951
  end

  test "calculates spherical distance" do
    distance = SimpleFeatures.Point.spherical_distance(p1, p2)
    assert distance == 157225.35800318103
  end

  test "calculates ellipsoidal distance" do
    distance = SimpleFeatures.Point.ellipsoidal_distance(p1, p2)
    assert distance == 156876.1494007417
  end

  test "calculate the bearing from apoint to another in degrees 45" do
    assert SimpleFeatures.Point.bearing_to(p1,p2) == 45.00000000000001
  end

  test "calculate the bearing from apoint to another in degrees 180" do
    p3 = SimpleFeatures.Point.from_x_y(1,-1)
    assert SimpleFeatures.Point.bearing_to(p1,p3) == 180.0
  end

  test "calculate the bearing from apoint to another in degrees 225" do
    p3 = SimpleFeatures.Point.from_x_y(-1,-1)
    assert SimpleFeatures.Point.bearing_to(p1,p3) == 225.0
  end

  test "calculate the bearing from apoint to another in degrees 270" do
    p3 = SimpleFeatures.Point.from_x_y(-1,1)
    assert SimpleFeatures.Point.bearing_to(p1,p3) == 270.0
  end

  test "calculate the bearing from apoint to another in degrees 153" do
    p3 = SimpleFeatures.Point.from_x_y(2,-1)
    assert SimpleFeatures.Point.bearing_to(p1,p3) == 153.43494882292202
  end

  test "calculate the bearing from apoint to itself" do
    assert SimpleFeatures.Point.bearing_to(p1,p1) == 0.0
  end

  test "calculate the bearing from apoint to another in text ne" do
    assert SimpleFeatures.Point.bearing_text(p1,p2) == :ne
  end

  test "calculate the bearing from apoint to another in degrees w" do
    p3 = SimpleFeatures.Point.from_x_y(-1,1)
    assert SimpleFeatures.Point.bearing_text(p1,p3) == :w
  end


end
