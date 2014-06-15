defmodule SimpleFeatures.Point do
  import Geometry

  defstruct x: 0.0, y: 0.0, z: 0.0, m: 0.0, srid: 4326, lat: nil, lng: nil

  # alias :lon :x
  # alias :lng :x
  # alias :lat :y
  # alias :rad :r
  # alias :tet :t
  # alias :tetha :t

  def bounding_box(point) do
    [point, point]
  end

  def from_x_y(x, y, srid \\ 0) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, srid: srid}
  end

  def from_x_y_z(x, y, z, srid \\ default_srid) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, z: z, srid: srid}
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
    from_coord(coordinates, default_srid)
  end

  def from_coordinates(coordinates, srid) do
    from_coord(coordinates, srid)
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

  def ellipsoidal_distance(p1, p2, a \\ 6378137.0, b \\ 6356752.3142) do
    EllipsoidalCalculations.distance(p1, p2, a, b)
  end

  # # Orthogonal Distance
  # # Based http://www.allegro.cc/forums/thread/589720
  def orthogonal_distance(point, line, tail \\ nil) do
    1.414
  #   head, tail  = tail ?  [line, tail] : [line[0], line[-1]]
  #   a, b = @x - head.x, @y - head.y
  #   c, d = tail.x - head.x, tail.y - head.y

  #   dot = a * c + b * d
  #   len = c * c + d * d
  #   return 0.0 if len.zero?
  #   res = dot / len

  #   xx, yy =\
  #   if res < 0
  #     [head.x, head.y]
  #   elsif res > 1
  #     [tail.x, tail.y]
  #   else
  #     [head.x + res * c, head.y + res * d]
  #   end
  #   # todo benchmark if worth creating an instance
  #   # euclidian_distance(Point.from_x_y(xx, yy))
  #   Math.sqrt((@x - xx) ** 2 + (@y - yy) ** 2)
  end

  # Bearing from a point to another, in degrees.
  def bearing_to(p1, p2) do
    Bearing.bearing_to(p1, p2)
  end

  def bearing_text(p1, p2) do
    bearing = SimpleFeatures.Point.bearing_to(p1,p2)
    Bearing.bearing_text(bearing)
  end

  def text_geometry_type do
    'POINT'
  end

  def text_representation(point, true, false) do #:nodoc:
    "#{point.x} #{point.y} #{point.z}"
  end

  def text_representation(point, false, true) do #:nodoc:
    "#{point.x} #{point.y} #{point.m}"
  end

  def text_representation(point, true, true) do #:nodoc:
    "#{point.x} #{point.y} #{point.z} #{point.m}"
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

  defp from_coord([x, y], srid) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, srid: srid}
  end

  defp from_coord([x, y, z], srid) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, z: z, srid: srid}
  end

  defp from_coord([x,y,z,m], srid) do
    %SimpleFeatures.Point{x: x, y: y, lat: x, lng: y, z: z,m: m, srid: srid}
  end

end
