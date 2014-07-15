defmodule GeometryCollectionTest do
  use ExUnit.Case, async: true

  test "geometry_collection creation" do
    point = SimpleFeatures.Point.from_x_y(4.67,45.4,256)
    geometry_collection = SimpleFeatures.GeometryCollection.from_geometries([point])
    assert hd(geometry_collection.geometries) == point
  end

  test "bounding box from polygon" do
    point1 = SimpleFeatures.Point.from_x_y_z(4.456,-45.3,2.4,4326)
    point2 = SimpleFeatures.Point.from_x_y_z(45.4,41.6,123.1,4326)
    polygon = SimpleFeatures.Polygon.from_coordinates([[[12.4,-45.3,15.2],[45.4,41.6,2.4],[4.456,1.0698,5.6],[12.4,-45.3,6.1]],[[2.4,5.3,4.5],[5.4,1.4263,4.2],[14.46,1.06,123.1],[2.4,5.3,4.4]]],4326,false)
    geometry_collection = SimpleFeatures.GeometryCollection.from_geometries([polygon])
    bbox = SimpleFeatures.GeometryCollection.bounding_box(geometry_collection)
    [first, last] = bbox
    assert first == point1
    assert last == point2
  end

  test "bounding box from points" do
    point1 = SimpleFeatures.Point.from_x_y(1,1,256)
    point2 = SimpleFeatures.Point.from_x_y(2,2,256)
    geometry_collection = SimpleFeatures.GeometryCollection.from_geometries([point1, point2])
    bbox = SimpleFeatures.GeometryCollection.bounding_box(geometry_collection)
    assert hd(bbox) == point1
  end

end


# describe GeoRuby::SimpleFeatures::GeometryCollection do

#   it "should test_geometry_collection_creation" do
#     geometry_collection = GeoRuby::SimpleFeatures::GeometryCollection::new(256)
#     geometry_collection << GeoRuby::SimpleFeatures::Point.from_x_y(4.67,45.4,256)

#     geometry_collection.length.should eql(1)
#     geometry_collection[0].should == GeoRuby::SimpleFeatures::Point.from_x_y(4.67,45.4,256)

#     geometry_collection[0]=GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)
#     geometry_collection << GeoRuby::SimpleFeatures::Polygon.from_coordinates([[[0,0],[4,0],[4,4],[0,4],[0,0]],[[1,1],[3,1],[3,3],[1,3],[1,1]]],256)
#     geometry_collection.length.should eql(2)
#     geometry_collection[0].should == GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)

#     geometry_collection = GeoRuby::SimpleFeatures::GeometryCollection.from_geometries([GeoRuby::SimpleFeatures::Point.from_x_y(4.67,45.4,256),GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256)
#     geometry_collection.class.should eql(GeoRuby::SimpleFeatures::GeometryCollection)
#     geometry_collection.srid.should eql(256)
#     geometry_collection.length.should eql(2)
#     geometry_collection[1].should == GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)

#     bbox = geometry_collection.bounding_box
#     bbox.length.should eql(2)
#     bbox[0].should == GeoRuby::SimpleFeatures::Point.from_x_y(4.67,12.45)
#     bbox[1].should == GeoRuby::SimpleFeatures::Point.from_x_y(67.55,54)
#   end

#   it "test_geometry_collection_equal" do
#     geometry_collection1 = GeoRuby::SimpleFeatures::GeometryCollection.from_geometries([GeoRuby::SimpleFeatures::Point.from_x_y(4.67,45.4,256),GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256)
#     geometry_collection2 = GeoRuby::SimpleFeatures::GeometryCollection.from_geometries([GeoRuby::SimpleFeatures::Point.from_x_y(4.67,45.4,256),GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45],[67.55,54]],256),GeoRuby::SimpleFeatures::Polygon.from_coordinates([[[0,0,2],[4,0,2],[4,4,2],[0,4,2],[0,0,2]],[[1,1,2],[3,1,2],[3,3,2],[1,3,2],[1,1,2]]],256)],256,true)
#     line_string=GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)

#     geometry_collection1.should == GeoRuby::SimpleFeatures::GeometryCollection.from_geometries([GeoRuby::SimpleFeatures::Point.from_x_y(4.67,45.4,256),GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256)
#     geometry_collection2.should_not == geometry_collection1
#     line_string.should_not == geometry_collection1
#   end

#   it "test_geometry_collection_binary" do
#     geometry_collection = GeoRuby::SimpleFeatures::GeometryCollection.from_geometries([GeoRuby::SimpleFeatures::Point.from_x_y(4.67,45.4,256),GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256)
#     geometry_collection.as_hex_ewkb.should eql("010700002000010000020000000101000000AE47E17A14AE12403333333333B34640010200000002000000CDCCCCCCCCCC16406666666666E628403333333333E350400000000000004B40")

#     geometry_collection = GeoRuby::SimpleFeatures::GeometryCollection.from_geometries([GeoRuby::SimpleFeatures::Point.from_x_y_z_m(4.67,45.4,45.67,2.3,256),GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45,4.56,98.3],[67.55,54,12.2,3.4]],256,true, true)],256,true, true)
#     geometry_collection.as_hex_ewkb.should eql("01070000E0000100000200000001010000C0AE47E17A14AE12403333333333B34640F6285C8FC2D54640666666666666024001020000C002000000CDCCCCCCCCCC16406666666666E628403D0AD7A3703D124033333333339358403333333333E350400000000000004B4066666666666628403333333333330B40")
#   end

#   it "should test_geometry_collection_text" do
#     geometry_collection = GeoRuby::SimpleFeatures::GeometryCollection.from_geometries([GeoRuby::SimpleFeatures::Point.from_x_y(4.67,45.4,256),GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45],[67.55,54]],256)],256)
#     geometry_collection.as_ewkt.should eql("SRID=256;GEOMETRYCOLLECTION(POINT(4.67 45.4),LINESTRING(5.7 12.45,67.55 54))")

#     geometry_collection = GeoRuby::SimpleFeatures::GeometryCollection.from_geometries([GeoRuby::SimpleFeatures::Point.from_x_y_m(4.67,45.4,45.6,256),GeoRuby::SimpleFeatures::LineString.from_coordinates([[5.7,12.45,5.6],[67.55,54,6.7]],256,false,true)],256,false,true)
#     geometry_collection.as_ewkt.should eql("SRID=256;GEOMETRYCOLLECTIONM(POINTM(4.67 45.4 45.6),LINESTRINGM(5.7 12.45 5.6,67.55 54 6.7))")
#   end

# end
