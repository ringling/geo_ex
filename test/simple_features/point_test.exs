defmodule PointTest do
  use ExUnit.Case, async: true

  # Creation
  def p1 do
    SimpleFeatures.Point.from_x_y(1,1)
  end

  def p2 do
    SimpleFeatures.Point.from_x_y(2,2)
  end

  def point do
    SimpleFeatures.Point.from_x_y( -11.2431, 32.3141 )
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



  # Orthogonal Distance

  def line do
    SimpleFeatures.LineString.from_coordinates([[0,0],[1,3]], 4326)
  end

  def line2 do
    SimpleFeatures.LineString.from_coordinates([[1,1],[1,2]], 4326)
  end

  test "calcula orthogonal distance from a line (90 deg)" do
    # assert SimpleFeatures.Point.orthogonal_distance(p1, line2) == 0.0
    # assert SimpleFeatures.Point.orthogonal_distance(p2, line) == 0.0
    assert SimpleFeatures.Point.orthogonal_distance(p1, line) == 1.4142135623730951
  end

  # test "should calcula orthogonal distance very close..." do
  #   p1.orthogonal_distance(line2).should be_zero
  # end

  # test "should calcula orthogonal distance from a line (90 deg)" do
  #   p2.orthogonal_distance(line).should be_within(0.001).of(2.828)
  # end

  # test "should calcula orthogonal distance from a line (0 deg)" do
  #   p2.orthogonal_distance(line2).should be_within(0.1).of(1.0)
  # end

  # test "should calcula orthogonal distance from a line (0 deg)" do
  #   p2.orthogonal_distance(line2).should be_within(0.1).of(1.0)
  # end

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

  # > Export Formats

  test "print nicely" do
    assert SimpleFeatures.Point.text_representation(point) == "-11.2431 32.3141"
  end

  test "print as kml" do
    assert SimpleFeatures.Point.kml_representation(point) == "<Point>\n<coordinates>-11.2431,32.3141</coordinates>\n</Point>\n"
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

  # test "should print r (polar coords)" do
  #   point.r.should be_within(0.000001).of(34.214154)
  # end

  # test "should print theta as degrees" do
  #   point.theta_deg.should be_within(0.0001).of(289.184406352127)
  # end

  # test "should print theta as radians" do
  #   point.theta_rad.should be_within(0.0001).of(5.04722003626982)
  # end

  # test "should print theta when x is zero y > 0" do
  #   pt = GeoRuby::SimpleFeatures::Point.from_x_y(0.0, 32.3141)
  #   pt.theta_rad.should be_within(0.0001).of(1.5707963267948966)
  # end

  # test "should print theta when x is zero y < 0" do
  #   pt = GeoRuby::SimpleFeatures::Point.from_x_y(0.0, -32.3141)
  #   pt.theta_rad.should be_within(0.0001).of(4.71238898038469)
  # end

  # test "should output as polar" do
  #   point.as_polar.should be_instance_of(Array)
  #   point.should have(2).as_polar #.length.should eql(2)
  # end

end
