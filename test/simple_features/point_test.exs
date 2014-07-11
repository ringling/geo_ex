defmodule PointTest do
  use ExUnit.Case, async: true

  @p1 SimpleFeatures.Point.from_x_y(1,1)
  @p2 SimpleFeatures.Point.from_x_y(2,2)
  @point SimpleFeatures.Point.from_x_y( -11.2431, 32.3141 )

  @line SimpleFeatures.LineString.from_coordinates([[0,0],[1,3]], 4326, false)
  @line2 SimpleFeatures.LineString.from_coordinates([[1,1],[1,2]], 4326, false)

  test "returns a 2d point" do
    point = SimpleFeatures.Point.from_x_y(10, -20.0, 123)
    assert point.x == 10
    assert point.y == -20
    assert point.srid == 123
  end

  test "has binary_geometry_type 1" do
    assert @p1.binary_geometry_type == 1
  end

  test "has text_geometry_type" do
    assert @p1.text_geometry_type == "POINT"
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
    point = SimpleFeatures.Point.from_coordinates([1.6, 2.8, 3],123, false)
    assert point.x == 1.6
    assert point.y == 2.8
    assert point.z == 3
    assert point.srid == 123
  end

  test "returns a point from coordinates x,y,z,m" do
    point = SimpleFeatures.Point.from_coordinates([1.6, 2.8, 3, 666], 123)
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
    distance = SimpleFeatures.Point.euclidian_distance(@p1, @p2)
    assert distance == 1.4142135623730951
  end

  test "calculates spherical distance" do
    distance = SimpleFeatures.Point.spherical_distance(@p1, @p2)
    assert distance == 157225.35800318103
  end

  test "calculates ellipsoidal distance" do
    distance = SimpleFeatures.Point.ellipsoidal_distance(@p1, @p2)
    assert distance == 156876.1494007417
  end

  # Orthogonal Distance


  test "calculate orthogonal distance from a line (90 deg)" do
    assert_in_delta SimpleFeatures.Point.orthogonal_distance(@p1, @line), 1.4142135623730951, 0.0001
  end

  test "should calculate orthogonal distance very close..." do
    assert_in_delta SimpleFeatures.Point.orthogonal_distance(@p1, @line2),0.0, 0.0001
  end

  test "calculate orthogonal distance2 from a line (90 deg)" do
    assert_in_delta SimpleFeatures.Point.orthogonal_distance(@p2, @line), 2.8284271247461903, 0.0001
  end

  test "should calcula orthogonal distance from a line (0 deg)" do
    assert_in_delta SimpleFeatures.Point.orthogonal_distance(@p2, @line2), 1.0, 0.0001
  end

  test "calculate the bearing from apoint to another in degrees 45" do
    assert_in_delta SimpleFeatures.Point.bearing_to(@p1,@p2), 45.00000000000001, 0.0001
  end

  test "calculate the bearing from apoint to another in degrees 180" do
    p3 = SimpleFeatures.Point.from_x_y(1,-1)
    assert SimpleFeatures.Point.bearing_to(@p1,p3) == 180.0
  end

  test "calculate the bearing from apoint to another in degrees 225" do
    p3 = SimpleFeatures.Point.from_x_y(-1,-1)
    assert SimpleFeatures.Point.bearing_to(@p1,p3) == 225.0
  end

  test "calculate the bearing from apoint to another in degrees 270" do
    p3 = SimpleFeatures.Point.from_x_y(-1,1)
    assert SimpleFeatures.Point.bearing_to(@p1,p3) == 270.0
  end

  test "calculate the bearing from a point to another in degrees 153" do
    p3 = SimpleFeatures.Point.from_x_y(2,-1)
    assert_in_delta SimpleFeatures.Point.bearing_to(@p1,p3), 153.43494882292202, 0.0001
  end

  test "calculate the bearing from apoint to itself" do
    assert SimpleFeatures.Point.bearing_to(@p1,@p1) == 0.0
  end

  test "calculate the bearing from apoint to another in text ne" do
    assert SimpleFeatures.Point.bearing_text(@p1,@p2) == :ne
  end

  test "calculate the bearing from apoint to another in degrees w" do
    p3 = SimpleFeatures.Point.from_x_y(-1,1)
    assert SimpleFeatures.Point.bearing_text(@p1,p3) == :w
  end

  # > Export Formats


  test "print nicely" do
    assert SimpleFeatures.Point.text_representation(@point) == "-11.2431 32.3141"
  end

  test "print as kml" do
    assert SimpleFeatures.Point.kml_representation(@point) == "<Point>\n<coordinates>-11.2431,32.3141</coordinates>\n</Point>\n"
  end

  # test "should print as html too" do
  #   point.html_representation.should eql("<span class='geo'><abbr class='latitude' title='-11.2431'>11°14′35″S</abbr><abbr class='longitude' title='32.3141'>32°18′51″E</abbr></span>")
  # end

  # test "should print as html too with opts" do
  #   point.html_representation(coord: false).should eql("<span class='geo'><abbr class='latitude' title='-11.2431'>-11°14′35″</abbr><abbr class='longitude' title='32.3141'>32°18′51″</abbr></span>")
  # end

  # test "should print as html too with opts" do
  #   point.html_representation(full: true).should eql("<span class='geo'><abbr class='latitude' title='-11.2431'>11°14′35.16″S</abbr><abbr class='longitude' title='32.3141'>32°18′50.76″E</abbr></span>")
  # end

  # test "should print as georss" do
  #   point.georss_simple_representation(:georss_ns => 'hey').should eql("<hey:point>32.3141 -11.2431</hey:point>\n")
  # end

  test "print r (polar coords)" do
    assert_in_delta SimpleFeatures.Point.r(@point), 34.214154, 0.0001
  end

  test "print theta as degrees" do
    assert_in_delta SimpleFeatures.Point.theta_deg(@point), 289.184406352127, 0.0001
  end

  test "should print theta as radians" do
    assert_in_delta SimpleFeatures.Point.theta_rad(@point), 5.04722003626982, 0.0001
  end

  test "print theta when x is zero y > 0" do
    point = SimpleFeatures.Point.from_x_y(0.0, 32.3141, 123)
    assert_in_delta SimpleFeatures.Point.theta_rad(point), 1.5707963267948966, 0.0001
  end

  test "should print theta when x is zero y < 0" do
    point = SimpleFeatures.Point.from_x_y(0.0, -32.3141, 123)
    assert_in_delta SimpleFeatures.Point.theta_rad(point), 4.71238898038469, 0.0001
  end

  test "output as polar" do
    polar = SimpleFeatures.Point.as_polar(@point)
    assert length(polar) == 2
    assert is_list(polar)
  end

end
