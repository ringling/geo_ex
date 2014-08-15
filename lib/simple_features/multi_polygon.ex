defmodule SimpleFeatures.MultiPolygon do
  import SimpleFeatures.Geometry
  alias SimpleFeatures.GeometryHelper

  defstruct geometries: [], srid: default_srid, binary_geometry_type: 6, text_geometry_type: "MULTIPOLYGON"

  @doc "Creates a multi polygon from a list of polygons"
  def from_polygons(polygons, srid \\ default_srid) do
    %SimpleFeatures.MultiPolygon{geometries: polygons, srid: srid}
  end

  @doc "Creates a multi polygon from sequences of coordinates [[1,2],[2.3]]"
  def from_coordinates(coordinates_sequences, srid, with_m) do
    polygons =
      coordinates_sequences
      |> Enum.map fn(coordinates_sequence) -> SimpleFeatures.Polygon.from_coordinates(coordinates_sequence, srid, with_m) end
    %SimpleFeatures.MultiPolygon{geometries: polygons, srid: srid}
  end

  @doc "Creates a multi polygon from a sequence of point_sequences"
  def from_points(point_sequence_sequences, srid \\ default_srid) do
    polygons =
      point_sequence_sequences
      |> Enum.map fn(point_sequence) -> SimpleFeatures.Polygon.from_points(point_sequence, srid) end
    %SimpleFeatures.MultiPolygon{geometries: polygons, srid: srid}
  end

  def points(multi_polygon) do
    multi_polygon.geometries
    |> Enum.map(fn(geometry) -> GeometryHelper.points(geometry) end)
    |> List.flatten
  end

  @doc "Does multi_polygon contain point?"
  def contains_point?(multi_polygon, point) do
    multi_polygon.geometries
    |> Enum.any? fn(geometry) ->
      GeometryHelper.contains_point?(geometry, point)
    end
  end

  def to_coordinates(multi_polygon) do
    multi_polygon.geometries |> Enum.map fn(polygon) -> SimpleFeatures.Polygon.to_coordinates(polygon) end
  end

  def as_json(multi_polygon) do
    [
      type: "MultiPolygon",
      coordinates: to_coordinates(multi_polygon)
    ]
  end

end

# @doc "Text representation of a MultiPolygon"
# def text_representation(allow_z=true,allow_m=true) do
#   # @geometries.map {|polygon| "(" + polygon.text_representation(allow_z,allow_m) + ")"}.join(",")
# end


#       # simple geojson representation
#       # TODO add CRS / SRID support?
#       def to_json(options = {})
#         as_json(options).to_json(options)
#       end
#       alias :as_geojson :to_json
