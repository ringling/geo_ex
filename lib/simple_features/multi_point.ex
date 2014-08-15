defmodule SimpleFeatures.MultiPoint do
  import SimpleFeatures.Geometry
  alias SimpleFeatures.Point, as: Point
  alias __MODULE__
  alias SimpleFeatures.GeometryHelper, as: GeometryHelper

  defdelegate as_ewkt(multi_point, allow_srid, allow_z, allow_m), to: GeometryHelper
  defstruct geometries: [], srid: default_srid, binary_geometry_type: 4, text_geometry_type: "MULTIPOINT"

  def points(multi_point) do
    multi_point.geometries
  end

  @doc "Creates a new line string. Accept a sequence of coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinates, srid \\ default_srid) do
    points = Enum.map coordinates, fn(coordinate) -> Point.from_coordinates(coordinate, srid) end
    %MultiPoint{geometries: points, srid: srid}
  end

  @doc "Creates a new line string. Accept a sequence of coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinates, srid, with_m) do
    points = Enum.map coordinates, fn(coordinate) -> Point.from_coordinates(coordinate, srid, with_m) end
    %MultiPoint{geometries: points, srid: srid}
  end

  @doc "Creates a new line string. Accept a list of points as argument"
  def from_points(points, srid \\ default_srid) do
    %MultiPoint{geometries: points, srid: srid}
  end

  @doc "Text representation of a MultiPoint"
  def text_representation(multi_point, allow_z, allow_m) do
    "(" <> Enum.join(Enum.map(multi_point.geometries, fn(point) -> Point.text_representation(point, allow_z, allow_m) end), "),(") <> ")"
  end

  def with_m?(multi_point) do
    Enum.any?(multi_point.geometries, fn(geometry) -> Point.with_m?(geometry) end)
  end

  def to_coordinates(multi_point) do
    points(multi_point) |> Enum.map fn(p) -> Point.to_coordinates(p) end
  end

  def as_map(multi_point) do
    %{type: "MultiPoint", coordinates: to_coordinates(multi_point) }
  end

  def to_json(multi_point) do
    multi_point
    |> as_map
    |> Poison.Encoder.encode([])
    |> IO.iodata_to_binary
  end
end


#       # simple geojson representation
#       # TODO add CRS / SRID support?
#       def to_json(options = {})
#         as_json(options).to_json(options)
#       end
#       alias :as_geojson :to_json
