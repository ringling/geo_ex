defmodule SimpleFeatures.LineString do
  import SimpleFeatures.Geometry
  alias SimpleFeatures.Point
  alias __MODULE__

  @moduledoc """
  Represents a line string as an list of points (see `Point`).
  """

  defstruct points: [], srid: default_srid, binary_geometry_type: 2, text_geometry_type: "LINESTRING", type: :line_string

  @doc "Creates a new line string. Accept a sequence of coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinates, srid \\ default_srid) do
    points = Enum.map coordinates, fn(coordinate) -> Point.from_coordinates(coordinate, srid) end
    %LineString{points: points, srid: srid}
  end

  @doc "Creates a new line string. Accept a sequence of coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinates, srid, with_m) do
    points = Enum.map coordinates, fn(coordinate) -> Point.from_coordinates(coordinate, srid, with_m) end
    %LineString{points: points, srid: srid}
  end

  @doc "Creates a new line string. Accept a list of points as argument"
  def from_points(points, srid \\ default_srid) do
    %LineString{points: points, srid: srid}
  end

  @doc "Text representation of a polygon"
  def text_representation(line) do
    Enum.map_join(line.points, ",", &(Point.text_representation(&1)))
  end

  @doc """
  `LineString` to coordinates, e.g. [[x1,y1,z1],[x2,y2,z2],...]
  """
  def to_coordinates(line_string) do
    line_string.points |> Enum.map fn(point) -> Point.to_coordinates(point) end
  end

  @doc """
  Does this linear string contain the given point?  We use the
  algorithm described here:
  http://www.ecse.rpi.edu/Homepages/wrf/Research/Short_Notes/pnpoly.html
  """
  def contains_point?(linear_ring, point) do
    if !linear_ring?(linear_ring), do: raise "Not a linear ring"
    [x, y] = [point.x, point.y]
    [ head | tail ] = linear_ring.points
    tuples = List.zip([linear_ring.points, List.flatten([tail, head])])
    crossings = Enum.filter(tuples, fn(tuple) ->
      {a, b} = tuple;
      (b.y > y != a.y > y) && (x < (a.x - b.x) * (y - b.y) / (a.y - b.y) + b.x)
    end)

    rem(length(crossings), 2) == 1
  end

  @doc """
  is it linear_ring, alias closed?
  """
  def linear_ring?(line_string) do
    closed?(line_string)
  end

  @doc """
  tests if the line_string is closed
  """
  def closed?(line_string) do
    #a bit naive...
    List.first(line_string.points) == List.last(line_string.points)
  end

  @doc """
  Returns `true` if the orientation of the linestring is clockwise
  """
  def clockwise?(linestring) do
    list = linestring.points
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

  @doc """
  Returns the spherical distance between all points in the linestring
  """
  def spherical_distance(line) do
    fun = :erlang.make_fun(Point, :spherical_distance, 2)
    {_, total } = Enum.reduce(line.points, { nil, 0 }, fn(point, acc) -> add_point(point, acc, fun) end)
    total
  end

  @doc """
  Returns the euclidian distance between all points in the linestring
  """
  def euclidian_distance(line) do
    fun = :erlang.make_fun(Point, :euclidian_distance, 2)
    {_, total } = Enum.reduce(line.points, { nil, 0 }, fn(point, acc) -> add_point(point, acc, fun) end)
    total
  end

  @doc """
  Simplify linestring (Douglas Peucker Algorithm)
  http://en.wikipedia.org/wiki/Ramer-Douglas-Peucker_algorithm
  """
  def simplify(line, epsilon \\ 1) do
    line.points |> do_simplify(epsilon) |> from_points
  end

  defp do_simplify(list, epsilon) do
    _do_simplify(list, dmax(list), epsilon)
  end

  @doc "Outputs the geometry as an EWKT string."
  def as_ewkt(line, allow_srid \\ true, allow_z \\ true, allow_m \\ true) do
    srid = srid_text(line, allow_srid)
    m = m_text(line, allow_m, allow_z)
    text_rep = text_representation(line)
    "#{srid}#{line.text_geometry_type}#{m}(#{text_rep})"
  end

  @doc """
  Returns `true` if at least one `Point` in the linstring has a z-dimension
  """
  def with_z?(line) do
    Enum.any?(line.points, fn(point) -> Point.with_z?(point) end)
  end

  @doc """
  Returns `true` if at least one `Point`in the linstring has a m-dimension
  """
  def with_m?(line) do
    Enum.any?(line.points, fn(point) -> Point.with_m?(point) end)
  end

  @doc "Bounding box in 2D/3D. Returns an array of 2 points"
  def bounding_box(line) do
    { max_x, min_x, max_y, min_y, max_z, min_z } =
    Enum.reduce(line.points, { nil, nil, nil, nil, nil, nil },
      fn(point, current) ->
        min_max(current, { point.x, point.y, point.z })
      end)
    [to_point(min_x, min_y, min_z), to_point(max_x, max_y, max_z)]
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
    Point.orthogonal_distance(
      Enum.at(list,i),
      List.first(list),
      List.last(list)
    )
  end

  defp srid_text(line, allow_srid) do
    if allow_srid, do: "SRID=#{line.srid};", else: ""
  end

  defp m_text(line, allow_m, allow_z) do
    if with_m?(line) && allow_m && (!with_z?(line) || !allow_z), do: "M", else: ""
  end

  defp to_point(x, y, nil) do
    Point.from_x_y(x, y)
  end

  defp to_point(x, y, z) do
    Point.from_x_y_z(x, y, z)
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
