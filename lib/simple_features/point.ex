defmodule SimpleFeatures.Point do
  import Geometry

  @moduledoc """
  Represents a point. It is in 3D if the Z coordinate is not nil.
  """

  defdelegate as_ewkt(point), to: Geometry
  defstruct x: nil, y: nil, z: nil, m: nil, srid: nil, lat: nil, lng: nil, binary_geometry_type: 1, text_geometry_type: "POINT"

  # alias :lon :x
  # alias :lng :x
  # alias :lat :y
  # alias :rad :r
  # alias :tet :t
  # alias :tetha :t

  def bounding_box(point) do
    [point, point]
  end

  def with_z?(point) do
    point.z != nil
  end

  def with_m?(point) do
    point.m != nil
  end

  def from_x_y(x, y, srid \\ 0) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, srid: srid}
  end

  def from_x_y_z(x, y, z, srid \\ default_srid) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, z: z, srid: srid}
  end

  def from_x_y_m(x, y, m, srid \\ default_srid) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, m: m, srid: srid}
  end

  def from_x_y_z_m(x, y, z, m, srid \\ default_srid) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, z: z, m: m, srid: srid}
  end

  def from_r_t(r, t, srid \\ default_srid) do
    t = t * deg2rad
    x = r * :math.cos(t)
    y = r * :math.sin(t)
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, srid: srid}
  end

  def from_coordinates(coordinates) do
    from_coord(coordinates, default_srid, false)
  end

  def from_coordinates(coordinates, srid) do
    from_coord(coordinates, srid, false)
  end

  def from_coordinates(coordinates, srid, with_m) do
    from_coord(coordinates, srid, with_m)
  end

  def euclidian_distance(p1, p2) do
    :math.sqrt(:math.pow(p2.x - p1.x, 2) + :math.pow(p2.y - p1.y, 2))
  end

  def spherical_distance(p1, p2, r \\ 6370997.0) do
    dlat = (p2.lat - p1.lat) * deg2rad / 2
    dlon = (p2.lng - p1.lng) * deg2rad / 2

    a = :math.pow(:math.sin(dlat),2) + :math.cos(p1.lat * deg2rad) *
      :math.cos(p2.lat * deg2rad) * :math.pow(:math.sin(dlon),2)
    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1-a))
    r * c
  end

  # Outputs theta - TODO ugly code
  def theta_rad(p) do
    _theta_rad(p.x, p.y)
  end

  defp _theta_rad(0.0, y) do
    if y < 0, do: 3 * halfpi, else: halfpi
  end

  defp _theta_rad(x, y) do
    th = :math.atan(y/x)
    if r(x, y) > 0, do: th + 2 * :math.pi, else: th
  end

  # Outputs theta in degrees
  def theta_deg(p) do
    theta_rad(p) / deg2rad
  end

  # Outputs an array containing polar distance and theta
  def as_polar(p) do
    [r(p), theta_deg(p)]
  end

  # Polar stuff
  #
  # http://www.engineeringtoolbox.com/converting-cartesian-polar-coordinates-d_1347.html
  # http://rcoordinate.rubyforge.org/svn/point.rb
  # outputs radium
  def r(p) do
    r(p.x,p.y)
  end

  def r(x,y) do
    :math.sqrt(:math.pow(x,2) + :math.pow(y,2))
  end

  def ellipsoidal_distance(p1, p2, a \\ 6378137.0, b \\ 6356752.3142) do
    EllipsoidalCalculations.distance(p1, p2, a, b)
  end


  # Possible BUG, I'm not sure calculates correct
  # # Orthogonal Distance
  # # Based http://www.allegro.cc/forums/thread/589720
  def orthogonal_distance(point, line, tail \\ nil) do # TODO tail not nil, is not tested
    [head, tail] = head_tail(line, tail)
    [a, b] = [point.x - head.x, point.y - head.y]
    [c, d] = [tail.x - head.x, tail.y - head.y]
    dot = (a * c) + (b * d)
    len = (c * c) + (d * d)

    if len == 0 do
      0.0
    else
      res = div(dot,len)
      calculate_ort_dist(res, head, tail, c, d, point)
    end
  end

  defp head_tail(line, tail)  when tail != nil do
    [line, tail]
  end

  defp head_tail(line, tail) when tail == nil do
    [ List.first(line.points), List.last(line.points) ]
  end

  defp calculate_ort_dist(res, head, tail, c, d, point) do
    [xx, yy] = calc_xx_yy(res, head, tail, c, d)
    # todo benchmark if worth creating an instance
    # euclidian_distance(Point.from_x_y(xx, yy))
    :math.sqrt(
      :math.pow((point.x - xx), 2) +
      :math.pow((point.y - yy), 2)
    )

  end

  defp calc_xx_yy(res, _head, tail, _c, _d) when res > 1 do
    [tail.x, tail.y]
  end

  defp calc_xx_yy(res, head, _tail, _c, _d) when res < 0 do
    [head.x, head.y]
  end

  defp calc_xx_yy(res, head, _tail, c, d) do
    [head.x + res * c, head.y + res * d]
  end

  # Bearing from a point to another, in degrees.
  def bearing_to(p1, p2) do
    Bearing.bearing_to(p1, p2)
  end

  def bearing_text(p1, p2) do
    bearing = SimpleFeatures.Point.bearing_to(p1,p2)
    Bearing.bearing_text(bearing)
  end

  # TODO Perhaps should support with_m analogous to from_coordinates?
  def to_coordinates(point) do
    if with_z?(point) do
      [point.x, point.y, point.z]
    else
      [point.x, point.y]
    end
  end

  def text_representation(point, true, false) do #:nodoc:
    String.rstrip "#{point.x} #{point.y} #{point.z}"
  end

  def text_representation(point, false, true) do #:nodoc:
    String.rstrip "#{point.x} #{point.y} #{point.m}"
  end

  def text_representation(point, true, true) do #:nodoc:
    String.rstrip "#{point.x} #{point.y} #{point.z} #{point.m}"
  end

  def text_representation(point, false, false) do #:nodoc:
    text_representation(point)
  end

  def text_representation(point) do #:nodoc:
    "#{point.x} #{point.y}"
  end

  # outputs the geometry in kml format : options are
  # <tt>:id</tt>, <tt>:tesselate</tt>, <tt>:extrude</tt>,
  # <tt>:altitude_mode</tt>.
  # If the altitude_mode option is not present, the Z (if present)
  # will not be output (since it won't be used by GE anyway:
  # clampToGround is the default)
  def kml_representation(point, options \\ %{}) do #:nodoc:
    out = "<Point#{id_attr(options)}>\n"
    if options[:geom_data], do: out = out <> options[:geom_data]
    out = out <> "<coordinates>#{point.x},#{point.y}"
    if options[:allow_z], do: out = out <> ",#{options[:fixed_z] || point.z ||0}"
    out = out <> "</coordinates>\n"
    out = out <> "</Point>\n"
    out
  end

  def id_attr(options) do
    if options[:id], do: " id=\"#{options[:id]}\"", else: ""
  end

  defp from_coord([x, y], srid, _with_m) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, srid: srid}
  end

  defp from_coord([x, y, m], srid, true) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, m: m, srid: srid}
  end

  defp from_coord([x, y, z], srid, false) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, z: z, srid: srid}
  end

  defp from_coord([x,y,z,m], srid, _with_m) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, z: z, m: m, srid: srid}
  end

end
