defmodule SimpleFeatures.LineString do
  import Geometry

  @moduledoc """
  Represents a line string as an array of points (see Point).
  """

  # defdelegate as_ewkt(line_string, allow_srid, allow_z, allow_m), to: Geometry

  defstruct points: [], srid: default_srid, binary_geometry_type: 2, text_geometry_type: "LINESTRING"

  @doc "Creates a new line string. Accept a sequence of coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinates, srid \\ default_srid) do
    points = Enum.map coordinates, fn(coordinate) -> SimpleFeatures.Point.from_coordinates(coordinate, srid) end
    %SimpleFeatures.LineString{points: points, srid: srid}
  end

  @doc "Creates a new line string. Accept a sequence of coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinates, srid, with_m) do
    points = Enum.map coordinates, fn(coordinate) -> SimpleFeatures.Point.from_coordinates(coordinate, srid, with_m) end
    %SimpleFeatures.LineString{points: points, srid: srid}
  end

  #Creates a new line string. Accept an array of points as argument
  def from_points(points, srid \\ default_srid) do
    %SimpleFeatures.LineString{points: points, srid: srid}
  end

  #Text representation of a line string
  def text_representation(line, allow_z \\ true, allow_m \\ true) do
    Enum.map_join(line.points, ",", &(SimpleFeatures.Point.text_representation(&1, allow_z, allow_m)))
  end

  @doc """
  tests if the line_string is closed
  """
  def closed?(line_string) do
    #a bit naive...
    List.first(line_string.points) == List.last(line_string.points)
  end

  def clockwise?(line) do
    list = line.points
    [ first | [ second | _tail ] ] = list
    length = length(list)
    x = Enum.to_list(Stream.take(list, -(length-1)))
    y = Enum.to_list(Stream.take(list, -(length-2)))
    a = List.flatten [x, [first]]
    b = List.flatten [y, [first, second]]
    tuples = Enum.map(List.zip([list, a, b]), fn(tuple) -> {a, b, c} = tuple; b.x * (c.y - a.y) end)
    sum = Enum.reduce(tuples, 0.0, fn(x, acc) -> x + acc end)
    sum < 0.0
  end

  def spherical_distance(line) do
    fun = Module.function(SimpleFeatures.Point, :spherical_distance, 2)
    {_, total } = Enum.reduce(line.points, { nil, 0 }, fn(point, acc) -> add_point(point, acc, fun) end)
    total
  end

  def euclidian_distance(line) do
    fun = Module.function(SimpleFeatures.Point, :euclidian_distance, 2)
    {_, total } = Enum.reduce(line.points, { nil, 0 }, fn(point, acc) -> add_point(point, acc, fun) end)
    total
  end

  defp add_point(current_point, 0, _) do
    { current_point, 0 }
  end

  defp add_point(current_point, { nil, sum }, _) do
    { current_point, sum }
  end

  defp add_point(current_point, { previous_point, sum }, fun) do
    { current_point, fun.(previous_point, current_point) + sum }
  end

  # Simplify linestring (Douglas Peucker Algorithm)
  # http://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm
  def simplify(line, epsilon \\ 1) do
    from_points(do_simplify(line.points, epsilon))
  end

  def do_simplify(list, epsilon) do
    _do_simplify(list, dmax(list), epsilon)
  end

  defp _do_simplify(list, { index, dmax }, epsilon) when dmax >= epsilon do
    res1 = list |> Enum.slice(0..index) |> do_simplify(epsilon) |> Enum.slice(0..-2)
    res2 = list |> Enum.slice(index..-1) |> do_simplify(epsilon) |> Enum.slice(0..-1)
    [res1, res2] |> Enum.concat
  end

  defp _do_simplify(list, { _index, _dmax }, _epsilon) do
    [ List.first(list), List.last(list) ]
  end

  defp dmax(list) when length(list) <= 2 do
    { 0,0 }
  end

  defp dmax(list) do
    Enum.reduce(2..length(list)-1, { 0, 0 },
      fn(i, acc) ->
        { _index, dmax } = acc
        d = orthogonal_distance(i, list)
        if d > dmax, do: { i, d }, else: acc
      end
    )
  end

  defp orthogonal_distance(i, list) do
    SimpleFeatures.Point.orthogonal_distance(
      Enum.at(list,i),
      List.first(list),
      List.last(list)
    )
  end

  #
  # Outputs the geometry as an EWKT string.
  #
  def as_ewkt(line, allow_srid \\ true, allow_z \\ true, allow_m \\ true) do
    srid = srid_text(line, allow_srid)
    m = m_text(line, allow_m, allow_z)
    text_rep = text_representation(line, with_z(line), with_m(line))
    "#{srid}#{line.text_geometry_type}#{m}(#{text_rep})"
  end

  defp srid_text(line, allow_srid) do
    if allow_srid, do: "SRID=#{line.srid};", else: ""
  end

  defp m_text(line, allow_m, allow_z) do
    if with_m(line) && allow_m && (!with_z(line) || !allow_z), do: "M", else: ""
  end

  defp with_z(line) do
    Enum.any?(line.points, fn(point) -> point.z != nil end)
  end

  defp with_m(line) do
    Enum.any?(line.points, fn(point) -> point.m != nil end)
  end

  #Bounding box in 2D/3D. Returns an array of 2 points
  def bounding_box(line) do
    { max_x, min_x, max_y, min_y, max_z, min_z } = Enum.reduce(line.points, { nil, nil, nil, nil, nil, nil },
      fn(point, current) ->
        min_max(current, { point.x, point.y, point.z }) end
    )
    [to_point(min_x, min_y, min_z), to_point(max_x, max_y, max_z)]
  end

  defp to_point(x, y, nil) do
    SimpleFeatures.Point.from_x_y(x, y)
  end

  defp to_point(x, y, z) do
    SimpleFeatures.Point.from_x_y_z(x, y, z)
  end

  defp min_max({ max_x, min_x, max_y, min_y, max_z, min_z }, {x, y, z}) do
    if y > max_y || max_y == nil, do: max_y = y
    if y < min_y || min_y == nil, do: min_y = y
    if x > max_x || max_x == nil, do: max_x = x
    if x < min_x || min_x == nil, do: min_x = x
    if z > max_z || max_z == nil, do: max_z = z
    if z < min_z || min_z == nil, do: min_z = z
    { max_x, min_x, max_y, min_y, max_z, min_z }
  end

end