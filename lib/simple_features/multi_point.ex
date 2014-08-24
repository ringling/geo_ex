defmodule SimpleFeatures.MultiPoint do
  import SimpleFeatures.Geometry
  alias SimpleFeatures.Point
  alias __MODULE__
  alias SimpleFeatures.GeometryHelper

  defdelegate as_ewkt(multi_point, allow_srid, allow_z, allow_m), to: GeometryHelper
  defstruct geometries: [], srid: default_srid, binary_geometry_type: 4, text_geometry_type: "MULTIPOINT", type: :multi_point

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
  def text_representation(multi_point, _allow_z, _allow_m) do
    "(" <> Enum.join(Enum.map(multi_point.geometries, fn(point) -> Point.text_representation(point) end), "),(") <> ")"
  end

  @doc """
  Returns `true` if at least one `Point` in the `MultiPoint` has a m-dimension
  """
  def with_m?(multi_point) do
    Enum.any?(multi_point.geometries, fn(geometry) -> Point.with_m?(geometry) end)
  end

  @doc """
  `MultiPoint` to coordinates, e.g. [[x1,y1,z1],[x2,y2,z2],...]
  """
  def to_coordinates(multi_point) do
    multi_point.geometries |> Enum.map fn(p) -> Point.to_coordinates(p) end
  end

  @doc """
  Returns `MultiPoint` as a `Map`
  """
  def as_map(multi_point) do
    %{type: "MultiPoint", coordinates: to_coordinates(multi_point) }
  end

  @doc """
  Returns `MultiPoint` as a JSON string
  """
  def to_json(multi_point) do
    multi_point
    |> as_map
    |> Poison.Encoder.encode([])
    |> IO.iodata_to_binary
  end
end
