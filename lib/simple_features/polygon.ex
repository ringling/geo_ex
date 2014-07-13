defmodule SimpleFeatures.Polygon do
  import Geometry

  defstruct rings: [], srid: default_srid, binary_geometry_type: 3, text_geometry_type: "POLYGON"

  @moduledoc """
  Represents a polygon. It is in 3D if the Z coordinate is not nil.
  """

  @doc "Creates a polygon. Accept a sequence of line_string coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinates, srid, with_m) do
    linear_rings =
      coordinates |> Enum.map fn(coordinate) -> SimpleFeatures.LineString.from_coordinates(coordinate, srid, with_m) end
    %SimpleFeatures.Polygon{rings: linear_rings, srid: srid}
  end

  @doc "Creates a polygon. Accept a sequence of line_string coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinates, srid \\ default_srid) do
    linear_rings =
      coordinates |> Enum.map fn(coordinate) -> SimpleFeatures.LineString.from_coordinates(coordinate, srid) end
    %SimpleFeatures.Polygon{rings: linear_rings, srid: srid}
  end

  def to_coordinates(polygon) do
    polygon.rings |> Enum.map fn(ring) -> SimpleFeatures.LineString.to_coordinates(ring) end
  end

  @doc "Does polygon contain point?"
  def contains_point?(polygon, point) do
    polygon.rings
    |> Enum.filter(fn(lr) -> SimpleFeatures.LineString.contains_point?(lr, point) end)
    |> Enum.empty?
    |> reverse
  end

  @doc "Bounding box in 2D/3D. Returns an array of 2 points"
  def bounding_box(polygon) do
    result = hd(polygon.rings) |> SimpleFeatures.LineString.bounding_box #valid for x and y
    unless with_z?(polygon) do
      result
    else
      [ min, max ] = result
      range(polygon)
      |> Enum.reduce({ max.z, min.z },
        fn(index, acc) ->
          Enum.at(polygon.rings, index)
          |> SimpleFeatures.LineString.bounding_box
          |> min_max(acc)
        end)
      |> bbox(result)
    end
  end

  def with_z?(polygon) do
    polygon.rings |> Enum.any? fn(ring) -> SimpleFeatures.LineString.with_z?(ring) end
  end

  def with_m?(polygon) do
    polygon.rings |> Enum.any? fn(ring) -> SimpleFeatures.LineString.with_m?(ring) end
  end

  defp range(polygon) do
    1..length(polygon.rings)-1
  end

  defp min_max([ sw,ne ], acc) do
    { max_z, min_z } = acc
    if ne.z > max_z, do: max_z = ne.z
    if sw.z < min_z, do: min_z = sw.z
    { max_z, min_z }
  end

  defp bbox({ max_z, min_z },[fst, sec] ) do
    a = SimpleFeatures.Point.from_x_y_z_m(fst.x, fst.y, min_z, fst.m, fst.srid)
    b = SimpleFeatures.Point.from_x_y_z_m(sec.x, sec.y, max_z, sec.m, sec.srid)
    [a,b]
  end
end

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

#       #binary representation of a polygon, without the headers neccessary for a valid WKB string
#       def binary_representation(allow_z=true,allow_m=true)
#         rep = [length].pack("V")
#         each {|linear_ring| rep << linear_ring.binary_representation(allow_z,allow_m)}
#         rep
#       end

#       #Text representation of a polygon
#       def text_representation(allow_z=true,allow_m=true)
#         @rings.collect{|line_string| "(" + line_string.text_representation(allow_z,allow_m) + ")" }.join(",")
#       end

#       #georss simple representation : outputs only the outer ring
#       def georss_simple_representation(options)
#         georss_ns = options[:georss_ns] || "georss"
#         geom_attr = options[:geom_attr]
#         "<#{georss_ns}:polygon#{geom_attr}>" + self[0].georss_poslist + "</#{georss_ns}:polygon>\n"
#       end

#       #georss w3c representation : outputs the first point of the outer ring
#       def georss_w3cgeo_representation(options)
#         w3cgeo_ns = options[:w3cgeo_ns] || "geo"

#         "<#{w3cgeo_ns}:lat>#{self[0][0].y}</#{w3cgeo_ns}:lat>\n<#{w3cgeo_ns}:long>#{self[0][0].x}</#{w3cgeo_ns}:long>\n"
#       end
#       #georss gml representation
#       def georss_gml_representation(options)
#         georss_ns = options[:georss_ns] || "georss"
#         gml_ns = options[:gml_ns] || "gml"

#         result = "<#{georss_ns}:where>\n<#{gml_ns}:Polygon>\n<#{gml_ns}:exterior>\n<#{gml_ns}:LinearRing>\n<#{gml_ns}:posList>\n" + self[0].georss_poslist + "\n</#{gml_ns}:posList>\n</#{gml_ns}:LinearRing>\n</#{gml_ns}:exterior>\n</#{gml_ns}:Polygon>\n</#{georss_ns}:where>\n"
#       end

#       #outputs the geometry in kml format : options are <tt>:id</tt>, <tt>:tesselate</tt>, <tt>:extrude</tt>,
#       #<tt>:altitude_mode</tt>. If the altitude_mode option is not present, the Z (if present) will not be output (since
#       #it won't be used by GE anyway: clampToGround is the default)
#       def kml_representation(options = {})
#         result = "<Polygon#{options[:id_attr]}>\n"
#         result += options[:geom_data] if options[:geom_data]
#         rings.each_with_index do |ring, i|
#           if i == 0
#             boundary = "outerBoundaryIs"
#           else
#             boundary = "innerBoundaryIs"
#           end
#           result += "<#{boundary}><LinearRing><coordinates>\n"
#           result += ring.kml_poslist(options)
#           result += "\n</coordinates></LinearRing></#{boundary}>\n"
#         end
#         result += "</Polygon>\n"
#       end

#       def as_json(options = {})
#         {:type => 'Polygon',
#          :coordinates => self.to_coordinates}
#       end

#       # simple geojson representation
#       # TODO add CRS / SRID support?
#       def to_json(options = {})
#         as_json(options).to_json(options)
#       end
#       alias :as_geojson :to_json

#       #creates a new polygon. Accepts an array of linear strings as argument
#       def self.from_linear_rings(linear_rings,srid = DEFAULT_SRID,with_z=false,with_m=false)
#         polygon = new(srid,with_z,with_m)
#         polygon.concat(linear_rings)
#         polygon
#       end

#       #creates a new polygon from a list of Points (pt1....ptn),(pti....ptj)
#       def self.from_points(point_sequences, srid=DEFAULT_SRID,with_z=false,with_m=false)
#         polygon = new(srid,with_z,with_m)
#         polygon.concat( point_sequences.map {|points| LinearRing.from_points(points,srid,with_z,with_m) } )
#         polygon
#       end

#     end

#   end
