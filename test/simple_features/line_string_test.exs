defmodule LineStringTest do
  use ExUnit.Case, async: true

  @line SimpleFeatures.LineString.from_points(
    [ SimpleFeatures.Point.from_x_y(1,1),
      SimpleFeatures.Point.from_x_y(2,2),
      SimpleFeatures.Point.from_x_y(3,3)
    ])

  test "that it returns a line" do
    assert @line != nil
  end

  test "has points" do
    assert @line.points == [ SimpleFeatures.Point.from_x_y(1,1),
      SimpleFeatures.Point.from_x_y(2,2),
      SimpleFeatures.Point.from_x_y(3,3)
    ]
    assert length(@line.points) == 3
  end

  test "has binary_geometry_type 2" do
    assert @line.binary_geometry_type == 2
  end

  test "has text_geometry_type" do
    assert @line.text_geometry_type == "LINESTRING"
  end

  test "has a points list" do
    assert is_list(@line.points)
  end

  test "has not clockwise orientation" do
    assert SimpleFeatures.LineString.clockwise?(@line) == false
  end

  test "has clockwise orientation" do
    l = SimpleFeatures.LineString.from_points(
      [ SimpleFeatures.Point.from_x_y(20,20),
        SimpleFeatures.Point.from_x_y(10,10),
        SimpleFeatures.Point.from_x_y(-10,10)
      ], 4326
    )

    assert SimpleFeatures.LineString.clockwise?(l) == true
  end

  test "returns bbox" do
    l = SimpleFeatures.LineString.from_coordinates([[12.4,-45.3,123],[45.4,41.6,333],[4.456,1.0698,987]],256, false)
    bb = SimpleFeatures.LineString.bounding_box(l)
    [a,b] = bb
    assert length(bb) == 2
    assert a == SimpleFeatures.Point.from_x_y_z(4.456, -45.3, 123)
    assert b == SimpleFeatures.Point.from_x_y_z(45.4, 41.6, 987)
  end

  test "test_line_string_text" do
    line_string = SimpleFeatures.LineString.from_coordinates([[12.4,-45.3],[45.4,41.6]],256)
    assert SimpleFeatures.LineString.as_ewkt(line_string) == "SRID=256;LINESTRING(12.4 -45.3,45.4 41.6)"

    line_string = SimpleFeatures.LineString.from_coordinates([[12.4,-45.3,35.3],[45.4,41.6,12.3]],256)
    assert SimpleFeatures.LineString.as_ewkt(line_string, true) == "SRID=256;LINESTRING(12.4 -45.3 35.3,45.4 41.6 12.3)"

    line_string = SimpleFeatures.LineString.from_coordinates([[12.4,-45.3,35.3],[45.4,41.6,12.3]], 256, true)
    assert SimpleFeatures.LineString.as_ewkt(line_string, true, true, true) == "SRID=256;LINESTRINGM(12.4 -45.3 35.3,45.4 41.6 12.3)"

    line_string = SimpleFeatures.LineString.from_coordinates([[12.4,-45.3,35.3,25.2],[45.4,41.6,12.3,13.75]],256)
    assert SimpleFeatures.LineString.as_ewkt(line_string) == "SRID=256;LINESTRING(12.4 -45.3 35.3 25.2,45.4 41.6 12.3 13.75)"
  end

  test "closed if the last point equals the first" do
    line_string = SimpleFeatures.LineString.from_coordinates([[0,0],[1,1],[2,1],[0,0]],256)
    assert SimpleFeatures.LineString.closed?(line_string)
  end

  test "is not closed" do
    line_string = SimpleFeatures.LineString.from_coordinates([[0,0],[1,1],[2,1],[4,0]],256)
    assert SimpleFeatures.LineString.closed?(line_string) == false
  end

  test "print spherical_distance" do
    line_string = SimpleFeatures.LineString.from_coordinates([[0,0],[1,1],[2,1],[4,0]],256)
    SimpleFeatures.LineString.spherical_distance(line_string)
  end

  test "print euclidian_distance" do
    line_string = SimpleFeatures.LineString.from_coordinates([[0,0],[1,0],[1,1],[0,1],[0,0]],256)
    assert SimpleFeatures.LineString.euclidian_distance(line_string) == 4.0
  end

  # "Simplify"
  test "simplify a simple linestring" do
    line_string = SimpleFeatures.LineString.from_coordinates([[6,0],[4,1],[3,4],[4,6],[5,8],[5,9],[4,10],[6,15]], 4326)
    assert length(SimpleFeatures.LineString.simplify(line_string, 1).points) == 7
    assert length(SimpleFeatures.LineString.simplify(line_string,6).points) == 6
    assert length(SimpleFeatures.LineString.simplify(line_string,7).points) == 5
    assert length(SimpleFeatures.LineString.simplify(line_string, 9).points) == 4
    assert length(SimpleFeatures.LineString.simplify(line_string, 10).points) == 3
    assert length(SimpleFeatures.LineString.simplify(line_string, 11).points) == 2
  end

  test "the first and last in a flatten" do
    line_string = SimpleFeatures.LineString.from_coordinates([[6,0],[4,1],[3,4],[4,6],[5,8],[5,9],[4,10],[6,15]], 4326)
    simplified_string = SimpleFeatures.LineString.simplify(line_string, 11)
    [ first, second ] = simplified_string.points
    assert first == SimpleFeatures.Point.from_coordinates([6,0], 4326)
    assert second == SimpleFeatures.Point.from_coordinates([6,15], 4326)
  end

  # end

  test "linear_ring_creation" do
    #testing just the constructor helpers since the rest is the same as for line_string
    # linear_ring = SimpleFeatures.LinearRing.from_coordinates([[12.4,-45.3],[45.4,41.6],[4.456,1.0698],[12.4,-45.3]],345)
    # linear_ring.class.should eql(GeoRuby::SimpleFeatures::LinearRing)
    # linear_ring.length.should eql(4)
    # linear_ring.should be_closed
    # linear_ring[1].should == GeoRuby::SimpleFeatures::Point.from_x_y(45.4,41.6,345)
  end

  # describe "tu converted" do

  #   it "should concat points" do
  #     line_string = GeoRuby::SimpleFeatures::LineString::new
  #     line_string.concat([GeoRuby::SimpleFeatures::Point.from_x_y(12.4,45.3),GeoRuby::SimpleFeatures::Point.from_x_y(45.4,41.6)])

  #     line_string.length.should eql(2)
  #     line_string[0].should == GeoRuby::SimpleFeatures::Point.from_x_y(12.4,45.3)

  #     point=GeoRuby::SimpleFeatures::Point.from_x_y(123,45.8777)
  #     line_string[0]=point
  #     line_string[0].should == point

  #     points=[GeoRuby::SimpleFeatures::Point.from_x_y(123,45.8777),GeoRuby::SimpleFeatures::Point.from_x_y(45.4,41.6)]
  #     line_string.each_index {|i| line_string[i].should == points[i] }

  #     point=GeoRuby::SimpleFeatures::Point.from_x_y(22.4,13.56)
  #     line_string << point
  #     line_string.length.should eql(3)
  #     line_string[2].should eql(point)
  #   end

  #   it "should test_line_string_binary" do
  #     line_string = GeoRuby::SimpleFeatures::LineString.from_coordinates([[12.4,-45.3],[45.4,41.6]],256)
  #     line_string.as_hex_ewkb.should eql("01020000200001000002000000CDCCCCCCCCCC28406666666666A646C03333333333B34640CDCCCCCCCCCC4440")

  #     line_string = GeoRuby::SimpleFeatures::LineString.from_coordinates([[12.4,-45.3,35.3],[45.4,41.6,12.3]],256,true)
  #     line_string.as_hex_ewkb.should eql("01020000A00001000002000000CDCCCCCCCCCC28406666666666A646C06666666666A641403333333333B34640CDCCCCCCCCCC44409A99999999992840")

  #     line_string = GeoRuby::SimpleFeatures::LineString.from_coordinates([[12.4,-45.3,35.3,45.1],[45.4,41.6,12.3,40.23]],256,true,true)
  #     line_string.as_hex_ewkb.should eql("01020000E00001000002000000CDCCCCCCCCCC28406666666666A646C06666666666A64140CDCCCCCCCC8C46403333333333B34640CDCCCCCCCCCC44409A999999999928403D0AD7A3701D4440")
  #   end
  # end


  #   it "should print the text representation" do
  #     line.text_representation.should eql("0 0,1 1,2 2,3 3,4 4,5 5,6 6")
  #   end

  #   it "should print the georss_simple_representation" do
  #     line.georss_simple_representation({:geom_attr => nil}).
  #       should eql("<georss:line>0 0 1 1 2 2 3 3 4 4 5 5 6 6</georss:line>\n")
  #   end

  #   it "should map the georss_poslist" do
  #     line.georss_poslist.should eql("0 0 1 1 2 2 3 3 4 4 5 5 6 6")
  #   end

  #   it "should print the kml_representation" do
  #     line.kml_representation.should
  #       eql("<LineString>\n<coordinates>0,0 1,1 2,2 3,3 4,4 5,5 6,6</coordinates>\n</LineString>\n")
  #   end

  #   it "should print the kml_poslist without reverse or z" do
  #     line.kml_poslist({}).should eql("0,0 1,1 2,2 3,3 4,4 5,5 6,6")
  #   end

  #   it "should print the kml_poslist reverse" do
  #     line.kml_poslist({:reverse => true}).should eql("6,6 5,5 4,4 3,3 2,2 1,1 0,0")
  #   end
  # end


end
