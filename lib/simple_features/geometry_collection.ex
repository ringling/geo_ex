defmodule SimpleFeatures.GeometryCollection do
  import SimpleFeatures.Geometry
  import SimpleFeatures.GeometryHelper
  alias SimpleFeatures.Point, as: Point

  defstruct geometries: [], srid: default_srid, binary_geometry_type: 7, text_geometry_type: "GEOMETRYCOLLECTION"

  @doc "creates a new GeometryCollection from an array of geometries"
  def from_geometries(geometries, srid \\ default_srid) do
    %SimpleFeatures.GeometryCollection{geometries: geometries, srid: srid}
  end

  # TODO Ugly code
  @doc "Bounding box in 2D/3D. Returns an list of 2 points"
  def bounding_box(geometry_collection) do
    srid = hd(geometry_collection.geometries).srid
    if with_z?(geometry_collection) do
      { max_x, min_x, max_y, min_y, max_z, min_z } = geometry_collection.geometries |> _reduce({ nil, nil, nil, nil, nil, nil })
      [Point.from_x_y_z(min_x,min_y,min_z, srid),Point.from_x_y_z(max_x,max_y,max_z, srid)]
    else
      { max_x, min_x, max_y, min_y } = geometry_collection.geometries |> _reduce({ nil, nil, nil, nil })
      [Point.from_x_y(min_x,min_y, srid),Point.from_x_y(max_x,max_y, srid)]
    end
  end

  defp _reduce(geometries, init_values) do
    geometries |> Enum.reduce init_values, fn(geometry, acc) -> find_min_max(geometry, acc) end
  end

  defp find_min_max(geometry, { max_x, min_x, max_y, min_y }) do
    [ sw, ne ] = bounding_box_for_geometry(geometry)
    if ne.y > max_y || max_y == nil, do: max_y = ne.y
    if sw.y < min_y || min_y == nil, do: min_y = sw.y
    if ne.x > max_x || max_x == nil, do: max_x = ne.x
    if sw.x < min_x || min_x == nil, do: min_x = sw.x
    { max_x, min_x, max_y, min_y }
  end

  defp find_min_max(geometry, { max_x, min_x, max_y, min_y, max_z, min_z }) do
    [ sw, ne ] = bounding_box_for_geometry(geometry)
    if ne.y > max_y || max_y == nil, do: max_y = ne.y
    if sw.y < min_y || min_y == nil, do: min_y = sw.y
    if ne.x > max_x || max_x == nil, do: max_x = ne.x
    if sw.x < min_x || min_x == nil, do: min_x = sw.x
    if ne.z > max_z || max_z == nil, do: max_z = ne.z
    if sw.z < min_z || min_z == nil, do: min_z = sw.z
    { max_x, min_x, max_y, min_y, max_z, min_z }
  end

end



# module GeoRuby
#   module SimpleFeatures
#     #Represents a collection of arbitrary geometries
#     class GeometryCollection < Geometry
#       attr_reader :geometries

#       def m_range
#         if with_m
#           max_m, min_m = -Float::MAX, Float::MAX
#           each do |lr|
#             lrmr = lr.m_range
#             max_m = lrmr[1] if lrmr[1] > max_m
#             min_m = lrmr[0] if lrmr[0] < min_m
#           end
#           [min_m,max_m]
#         else
#           [0,0]
#         end
#       end

#       #Binary representation of the collection
#       def binary_representation(allow_z=true,allow_m=true) #:nodoc:
#         rep = [length].pack("V")
#         #output the list of geometries without outputting the SRID first and with the same setting regarding Z and M
#         each {|geometry| rep << geometry.as_ewkb(false,allow_z,allow_m) }
#         rep
#       end

#       #Text representation of a geometry collection
#       def text_representation(allow_z=true,allow_m=true) #:nodoc:
#         @geometries.collect{|geometry| geometry.as_ewkt(false,allow_z,allow_m)}.join(",")
#       end

#       def as_json(options = {})
#         {:type => 'GeometryCollection',
#          :geometries => self.geometries}
#       end

#       # simple geojson representation
#       # TODO add CRS / SRID support?
#       def to_json(options = {})
#         as_json(options).to_json(options)
#       end
#       alias :as_geojson :to_json

#       #georss simple representation : outputs only the first geometry of the collection
#       def georss_simple_representation(options)#:nodoc:
#         self[0].georss_simple_representation(options)
#       end
#       #georss w3c representation : outputs the first point of the outer ring
#       def georss_w3cgeo_representation(options)#:nodoc:
#         self[0].georss_w3cgeo_representation(options)
#       end
#       #georss gml representation : outputs only the first geometry of the collection
#       def georss_gml_representation(options)#:nodoc:
#         self[0].georss_gml_representation(options)
#       end

#       #outputs the geometry in kml format
#       def kml_representation(options = {}) #:nodoc:
#         result = "<MultiGeometry#{options[:id_attr]}>\n"
#         options[:id_attr] = "" #the subgeometries do not have an ID
#         each do |geometry|
#           result += geometry.kml_representation(options)
#         end
#         result += "</MultiGeometry>\n"
#       end

#     end
#   end
# end
