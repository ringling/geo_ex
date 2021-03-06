defmodule SimpleFeatures.Polygon do
  import SimpleFeatures.Geometry
  alias SimpleFeatures.LineString
  alias SimpleFeatures.Point
  alias __MODULE__

  defstruct rings: [], srid: default_srid, binary_geometry_type: 3, text_geometry_type: "POLYGON"

  @moduledoc """
  Represents a polygon. It is in 3D if the Z coordinate is not nil.
  """

  @doc "Creates a polygon. Accept a sequence of line_string coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinates, srid, with_m) do
    linear_rings =
      coordinates |> Enum.map fn(coordinate) -> LineString.from_coordinates(coordinate, srid, with_m) end
    %Polygon{rings: linear_rings, srid: srid}
  end

  @doc "Creates a polygon. Accept a sequence of line_string coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinate_seq, srid \\ default_srid) do
    linear_rings =
      coordinate_seq |> Enum.map fn(coordinate) -> LineString.from_coordinates(coordinate, srid) end
    %Polygon{rings: linear_rings, srid: srid}
  end

  def from_points(points_seq, srid \\  default_srid) do
    linear_rings = points_seq |> Enum.map fn(points) -> LineString.from_points(points, srid) end
    %Polygon{rings: linear_rings, srid: srid}
  end

  def to_coordinates(polygon) do
    polygon.rings |> Enum.map fn(ring) -> LineString.to_coordinates(ring) end
  end

  @doc "Does polygon contain point?"
  def contains_point?(polygon, point) do
    polygon.rings
    |> Enum.filter(fn(lr) -> LineString.contains_point?(lr, point) end)
    |> Enum.empty?
    |> reverse
  end

  @doc "Bounding box in 2D/3D. Returns an array of 2 points"
  def bounding_box(polygon) do
    result = hd(polygon.rings) |> LineString.bounding_box #valid for x and y
    unless with_z?(polygon) do
      result
    else
      [ min, max ] = result
      range(polygon)
      |> Enum.reduce({ max.z, min.z },
        fn(index, acc) ->
          Enum.at(polygon.rings, index)
          |> LineString.bounding_box
          |> min_max(acc)
        end)
      |> bbox(result)
    end
  end

  def as_map(point) do
    %{ type: "Polygon", coordinates: to_coordinates(point) }
  end

  def to_json(point) do
    point
    |> as_map
    |> Poison.Encoder.encode([])
    |> IO.iodata_to_binary
  end


  def points(polygon) do
    polygon.rings
    |> Enum.map(fn(ring) -> ring.points end)
    |> List.flatten
  end

  def with_z?(polygon) do
    polygon.rings |> Enum.any? fn(ring) -> LineString.with_z?(ring) end
  end

  def with_m?(polygon) do
    polygon.rings |> Enum.any? fn(ring) -> LineString.with_m?(ring) end
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
    a = Point.from_x_y_z_m(fst.x, fst.y, min_z, fst.m, fst.srid)
    b = Point.from_x_y_z_m(sec.x, sec.y, max_z, sec.m, sec.srid)
    [a,b]
  end

  @doc "Text representation of a polygon"
  def text_representation(polygon, allow_z \\ true, allow_m \\ true) do
    polygon.rings |> Enum.map_join ",", fn(linestring) -> LineString.text_representation(linestring, allow_z, allow_m) end
  end
end
