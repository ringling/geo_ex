defmodule SimpleFeatures.GeometryCollection do
  import SimpleFeatures.Geometry
  import SimpleFeatures.GeometryHelper
  alias SimpleFeatures.Point

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


  def to_json(geometry_collection) do
    geometry_maps = geometry_collection.geometries |> Enum.map fn(geometry) -> _as_map(geometry) end
    %{ type: "GeometryCollection", geometries: geometry_maps }
    |> Poison.Encoder.encode([])
    |> IO.iodata_to_binary
  end

  defp _as_map(geometry) do
    fun = :erlang.make_fun(geometry.__struct__, :as_map, 1)
    fun.(geometry)
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
