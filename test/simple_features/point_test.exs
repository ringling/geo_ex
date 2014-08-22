defmodule PointTest do
  use ExUnit.Case, async: true
  alias SimpleFeatures.Point, as: Point

  @p1 Point.from_x_y(1,1)
  @p2 Point.from_x_y(2,2)
  @point Point.from_x_y( -11.2431, 32.3141 )

  @line SimpleFeatures.LineString.from_coordinates([[0,0],[1,3]], 4326, false)
  @line2 SimpleFeatures.LineString.from_coordinates([[1,1],[1,2]], 4326, false)

  test "returns a 2d point" do
    point = Point.from_x_y(10, -20.0, 123)
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

  test "to x y coordinates with m" do
    point = Point.from_x_y_m(10, 20, 123)
    assert Point.to_coordinates(point) == [10,20]
  end

  test "to x y coordinates without m" do
    point = Point.from_x_y(10, 20)
    assert Point.to_coordinates(point) == [10,20]
  end

  test "to x y z coordinates" do
    point = Point.from_x_y_z(10, 20, 30, 123)
    assert Point.to_coordinates(point) == [10,20,30]
  end

  test "to x y z m coordinates" do
    point = Point.from_x_y_z_m(10, 20, 30, 40, 123)
    assert Point.to_coordinates(point) == [10,20,30,40]
  end

  test "with z" do
    point = Point.from_x_y_z(10, 20, 30, 123)
    assert Point.with_z?(point) == true
  end

  test "without z" do
    point = Point.from_x_y(10, 20, 123)
    assert Point.with_z?(point) == false
  end

  test "with_m" do
    point = Point.from_x_y_z_m(10, 20, 30, 123)
    assert Point.with_m?(point) == true
  end

  test "without_m" do
    point = Point.from_x_y_z(10, 20, 30, 123)
    assert Point.with_m?(point) == false
  end

  test "returns a 3d point" do
    point = Point.from_x_y_z(10, 20, 30, 123)
    assert point.x == 10
    assert point.y == 20
    assert point.z == 30
    assert point.srid == 123
  end

  test "returns a 4d point" do
    point = Point.from_x_y_z_m(10, 20, 30, 12.343, 123)
    assert point.x == 10
    assert point.y == 20
    assert point.z == 30
    assert point.m == 12.343
    assert point.srid == 123
  end

  test "returns a point from polar coordinates" do
    point = Point.from_r_t(1.4142,45)
    assert_in_delta point.y, 0.9999904099540157, 0.001
    assert_in_delta point.x, 0.9999904099540153, 0.001
  end


  test "returns a point from coordinates x,y and default srid" do
    point = Point.from_coordinates([1.6, 2.8])
    assert point.x == 1.6
    assert point.y == 2.8
    assert point.srid == 4326
  end

  test "returns a point from coordinates x,y" do
    point = Point.from_coordinates([1.6, 2.8],123)
    assert point.x == 1.6
    assert point.y == 2.8
    assert point.srid == 123
  end

  test "returns a point from coordinates x,y,z" do
    point = Point.from_coordinates([1.6, 2.8, 3],123, false)
    assert point.x == 1.6
    assert point.y == 2.8
    assert point.z == 3
    assert point.srid == 123
  end

  test "returns a point from coordinates x,y,z,m" do
    point = Point.from_coordinates([1.6, 2.8, 3, 666], 123)
    assert point.x == 1.6
    assert point.y == 2.8
    assert point.z == 3
    assert point.m == 666
    assert point.srid == 123
  end

  test "has a bbox" do
    point = Point.from_x_y_z_m(-1.6,2.8,-3.4,15,123)
    bbox = point |> Point.bounding_box
    assert length(bbox) == 2
    [first, last] = bbox
    assert first == point
    assert last == point
  end

  # > Distance & Bearing
  test "calculates euclidian distance" do
    distance = Point.euclidian_distance(@p1, @p2)
    assert distance == 1.4142135623730951
  end

  test "calculates spherical distance" do
    distance = Point.spherical_distance(@p1, @p2)
    assert distance == 157225.35800318103
  end

  test "calculates ellipsoidal distance" do
    distance = Point.ellipsoidal_distance(@p1, @p2)
    assert distance == 156876.1494007417
  end

  # Orthogonal Distance

  test "calculate orthogonal distance from a line (90 deg)" do
    assert_in_delta Point.orthogonal_distance(@p1, @line), 1.4142135623730951, 0.0001
  end

  test "should calculate orthogonal distance very close..." do
    assert_in_delta Point.orthogonal_distance(@p1, @line2),0.0, 0.0001
  end

  test "calculate orthogonal distance2 from a line (90 deg)" do
    assert_in_delta Point.orthogonal_distance(@p2, @line), 2.8284271247461903, 0.0001
  end

  test "should calcula orthogonal distance from a line (0 deg)" do
    assert_in_delta Point.orthogonal_distance(@p2, @line2), 1.0, 0.0001
  end

  test "calculate the bearing from apoint to another in degrees 45" do
    assert_in_delta Point.bearing_to(@p1,@p2), 45.00000000000001, 0.0001
  end

  test "calculate the bearing from apoint to another in degrees 180" do
    p3 = Point.from_x_y(1,-1)
    assert Point.bearing_to(@p1,p3) == 180.0
  end

  test "calculate the bearing from apoint to another in degrees 225" do
    p3 = Point.from_x_y(-1,-1)
    assert Point.bearing_to(@p1,p3) == 225.0
  end

  test "calculate the bearing from apoint to another in degrees 270" do
    p3 = Point.from_x_y(-1,1)
    assert Point.bearing_to(@p1,p3) == 270.0
  end

  test "calculate the bearing from a point to another in degrees 153" do
    p3 = Point.from_x_y(2,-1)
    assert_in_delta Point.bearing_to(@p1,p3), 153.43494882292202, 0.0001
  end

  test "calculate the bearing from apoint to itself" do
    assert Point.bearing_to(@p1,@p1) == 0.0
  end

  test "calculate the bearing from apoint to another in text ne" do
    assert Point.bearing_text(@p1,@p2) == :ne
  end

  test "calculate the bearing from apoint to another in degrees w" do
    p3 = Point.from_x_y(-1,1)
    assert Point.bearing_text(@p1,p3) == :w
  end

   test "parses lat long" do
    point = Point.from_latlong("-20° 47' 26.37", "-20° 47' 26.37")
    assert_in_delta point.x, -20.790658, 0.00001
    assert_in_delta point.y, -20.790658, 0.00001
  end

  test "parse lat long w/o sec" do
    assert_in_delta Point.from_latlong("20°47′26″","20°47′26″").x, 20.790555, 0.00001
  end

  test "accepts with W or S notation" do
    point = Point.from_latlong("20° 47' 26.37 W","20° 47' 26.37 S")
    assert_in_delta point.x, -20.790658, 0.00001
    assert_in_delta point.y, -20.790658, 0.00001
  end

  test "should instantiate a point from positive degrees" do
    point = Point.from_latlong("47`20 06.09E","22`50 77.35N")
    assert_in_delta point.y, 22.8548194, 0.000001
    assert_in_delta point.x, 47.335025, 0.000001
  end

  test "should instantiate a point from negative degrees" do
    point = Point.from_latlong("47`20 06.09W","22`50 77.35S")
    assert_in_delta point.y, -22.8548194, 0.000001
    assert_in_delta point.x, -47.335025, 0.000001
  end

  test "print latlong out nicely" do
    point = Point.from_x_y(47.88, -20.1)
    assert Point.as_latlong(point) == "47°52′48″, -20°06′00″"
  end

  test "print latlong out nicely with options full" do
    point = Point.from_x_y(-20.78, 20.78)
    assert Point.as_latlong(point, %{full: true}) == "-20°46′48.00″, 20°46′48.00″"
  end

  test "print latlong out nicely with options full 2" do
    point = Point.from_x_y(47.11, -20.2)
    assert Point.as_latlong(point, %{full: true}) == "47°06′36.00″, -20°11′60.00″"
  end

  test "print latlong out nicely with options coord" do
    point = Point.from_x_y(47.11, -20.2)
    assert Point.as_latlong(point, %{coord: true}) == "47°06′36″N, 20°11′60″W"
  end

  test "print latlong out nicely with options coord and full" do
    point = Point.from_x_y(-47.11, 20.2)
    assert Point.as_latlong(point, %{coord: true, full: true}) == "47°06′36.00″S, 20°11′60.00″E"
  end

  test "print out nicely lat" do
    point = Point.from_x_y(-47.11, 20.2)
    assert Point.as_lat(point) == "-47°06′36″"
  end

  test "print out nicely lat with opts full" do
    point = Point.from_x_y(-47.11, 20.2)
    assert Point.as_lat(point, %{full: true}) == "-47°06′36.00″"
  end

  test "print out nicely lat with opts full and coord" do
    point = Point.from_x_y(-47.11, 20.2)
    assert Point.as_lat(point, %{coord: true, full: true}) == "47°06′36.00″S"
  end

  test "print out nicely long" do
    point = Point.from_x_y(-47.11, 20.2)
    assert Point.as_long(point) == "20°11′60″"
  end

  test "should print out nicely long with opts full" do
    point = Point.from_x_y(-47.11, 20.2)
    assert Point.as_long(point, %{full: true}) == "20°11′60.00″"
  end

  test "print out nicely long with opts full and coord" do
    point = Point.from_x_y(-47.11, 20.2)
    assert Point.as_long(point, %{coord: true, full: true}) == "20°11′60.00″E"
  end

  # > Export Formats
  test "print nicely" do
    assert Point.text_representation(@point) == "-11.2431 32.3141"
  end

  test "print as kml" do
    assert Point.kml_representation(@point) == "<Point>\n<coordinates>-11.2431,32.3141</coordinates>\n</Point>\n"
  end

  test "print as html too" do
    assert Point.html_representation(@point) == "<span class='geo'><abbr class='latitude' title='-11.2431'>11°14′35″S</abbr><abbr class='longitude' title='32.3141'>32°18′51″E</abbr></span>"
  end

  test "print as html too with opts" do
    assert Point.html_representation(@point, %{coord: false, full: false}) == "<span class='geo'><abbr class='latitude' title='-11.2431'>-11°14′35″</abbr><abbr class='longitude' title='32.3141'>32°18′51″</abbr></span>"
  end

  test "print as html too with opts2" do
    assert Point.html_representation(@point, %{coord: true, full: true}) == "<span class='geo'><abbr class='latitude' title='-11.2431'>11°14′35.16″S</abbr><abbr class='longitude' title='32.3141'>32°18′50.76″E</abbr></span>"
  end

  test "print as georss" do
    assert Point.georss_simple_representation(@point, %{georss_ns: "hey"}) == "<hey:point>32.3141 -11.2431</hey:point>\n"
  end

  test "print as georss_w3cgeo" do
    assert Point.georss_w3cgeo_representation(@point, %{w3cgeo_ns: "hey"}) == "<hey:lat>32.3141</hey:lat>\n<hey:long>-11.2431</hey:long>\n"
  end

  test "print as georss_gml_representation" do
    assert Point.georss_gml_representation(@point) == "<georss:where>\n<gml:Point>\n<gml:pos>32.3141 -11.2431</gml:pos>\n</gml:Point>\n</georss:where>\n"
  end

  test "print r (polar coords)" do
    assert_in_delta Point.r(@point), 34.214154, 0.0001
  end

  test "print theta as degrees" do
    assert_in_delta Point.theta_deg(@point), 289.184406352127, 0.0001
  end

  test "should print theta as radians" do
    assert_in_delta Point.theta_rad(@point), 5.04722003626982, 0.0001
  end

  test "print theta when x is zero y > 0" do
    point = Point.from_x_y(0.0, 32.3141, 123)
    assert_in_delta Point.theta_rad(point), 1.5707963267948966, 0.0001
  end

  test "should print theta when x is zero y < 0" do
    point = Point.from_x_y(0.0, -32.3141, 123)
    assert_in_delta Point.theta_rad(point), 4.71238898038469, 0.0001
  end

  test "output as polar" do
    polar = Point.as_polar(@point)
    assert length(polar) == 2
    assert is_list(polar)
  end

  test "to json" do
    assert Point.to_json(@p1) == "{\"type\":\"Point\",\"coordinates\":[1,1]}"
  end

end
