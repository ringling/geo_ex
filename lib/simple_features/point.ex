defmodule SimpleFeatures.Point do
  import SimpleFeatures.Geometry
  import ExPrintf
  alias __MODULE__
  alias :math, as: Math

  @moduledoc """
  Represents a point. It is in 3D if the Z coordinate is not nil.
  """

  defdelegate as_ewkt(point), to: Geometry
  defstruct x: nil, y: nil, z: nil, m: nil, srid: nil, lat: nil, lng: nil, binary_geometry_type: 1, text_geometry_type: "POINT"

  @doc "Retuns bounding box in 2D/3D. Returns a list of 2 points"
  def bounding_box(point) do
    [point, point]
  end

  @doc """
  Returns `true` if point has a z-coordinate"
  """
  def with_z?(point) do
    point.z != nil
  end

  @doc """
  Returns `true` if point has a measurement dimension"
  """
  def with_m?(point) do
    point.m != nil
  end

  @doc """
  Returns 2D `Point`
  """
  def from_x_y(x, y, srid \\ 0) do
    %Point{x: x, y: y, lat: x, lng: y, srid: srid}
  end

  @doc """
  Returns 3D `Point`
  """
  def from_x_y_z(x, y, z, srid \\ default_srid) do
    %Point{x: x, y: y, lat: x, lng: y, z: z, srid: srid}
  end

  @doc """
  Returns 2D `Point` with a measurement dimension
  """
  def from_x_y_m(x, y, m, srid \\ default_srid) do
    %Point{x: x, y: y, lat: x, lng: y, m: m, srid: srid}
  end

  @doc """
  Returns 3D `Point` with a measurement dimension
  """
  def from_x_y_z_m(x, y, z, m, srid \\ default_srid) do
    %Point{x: x, y: y, lat: x, lng: y, z: z, m: m, srid: srid}
  end

  @doc """
  Returns 2D `Point` from vector function `r(t)`
  """
  def from_r_t(r, t, srid \\ default_srid) do
    t = t * deg2rad
    x = r * Math.cos(t)
    y = r * Math.sin(t)
    %Point{x: x, y: y, lat: x, lng: y, srid: srid}
  end

  @doc """
  Returns `Point` as `Map`
  """
  def as_map(point) do
    %{ type: "Point", coordinates: to_coordinates(point) }
  end


  @doc """
  Returns `Point` as jsom

  Simple geojson representation

  *TODO:* add CRS / SRID support?
  """
  def to_json(point) do
    point
    |> as_map
    |> Poison.Encoder.encode([])
    |> IO.iodata_to_binary
  end

  @doc """
  Returns `Point` from `List` of coordinates
  """
  def from_coordinates(coordinates) do
    from_coord(coordinates, default_srid, false)
  end

  @doc """
  Returns `Point` with srid from `List` of coordinates
  """
  def from_coordinates(coordinates, srid) do
    from_coord(coordinates, srid, false)
  end

  @doc """
  Returns `Point` with srid and measurement dimension from `List` of coordinates
  """
  def from_coordinates(coordinates, srid, with_m) do
    from_coord(coordinates, srid, with_m)
  end

  @doc """
  Returns euclidian distance between 2 points
  """
  def euclidian_distance(p1, p2) do
    Math.sqrt(Math.pow(p2.x - p1.x, 2) + Math.pow(p2.y - p1.y, 2))
  end

  @doc """
  Returns spherical distance in meters between 2 points
  """
  def spherical_distance(p1, p2, r \\ 6370997.0) do
    dlat = (p2.lat - p1.lat) * deg2rad / 2
    dlon = (p2.lng - p1.lng) * deg2rad / 2

    a = Math.pow(Math.sin(dlat),2) + Math.cos(p1.lat * deg2rad) *
      Math.cos(p2.lat * deg2rad) * Math.pow(Math.sin(dlon),2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    r * c
  end

  @doc """
  Returns ellipsoidal distance in meters between 2 points
  """
  def ellipsoidal_distance(p1, p2, a \\ 6378137.0, b \\ 6356752.3142) do
    EllipsoidalCalculations.distance(p1, p2, a, b)
  end

  @doc """
  Returns orthogonal distance

  *Possible BUG*, I'm not sure calculates correct (Thomas Ringling - 20140713)

  Based http://www.allegro.cc/forums/thread/589720
  """
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

  @doc """
  Returns `Point` as theta radians
  """
  def theta_rad(p) do
    _theta_rad(p.x, p.y)
  end

  @doc """
  Returns `Point` as theta degrees
  """
  def theta_deg(p) do
    theta_rad(p) / deg2rad
  end

  @doc "Outputs an array containing polar distance and theta"

  @doc """
  Returns `Point` as polar coordinates
  """
  def as_polar(p) do
    [r(p), theta_deg(p)]
  end

  @doc """
  Returns distance from origin to `Point`

  http://www.engineeringtoolbox.com/converting-cartesian-polar-coordinates-d_1347.html

  http://rcoordinate.rubyforge.org/svn/point.rb
  """
  def r(p) do
    r(p.x,p.y)
  end

  @doc """
  Returns distance from origin to x,y coordinate

  http://www.engineeringtoolbox.com/converting-cartesian-polar-coordinates-d_1347.html

  http://rcoordinate.rubyforge.org/svn/point.rb
  """
  def r(x,y) do
    Math.sqrt(Math.pow(x,2) + Math.pow(y,2))
  end

  @doc """
  Bearing from a `Point` to another, in degrees.
  """
  def bearing_to(p1, p2) do
    Bearing.bearing_to(p1, p2)
  end

  @doc """
  Bearing from a `Point` to another, in text e.g. :w, :s or :sw
  """
  def bearing_text(p1, p2) do
    bearing = Point.bearing_to(p1,p2)
    Bearing.bearing_text(bearing)
  end

  @doc """
  `Point` to coordinates, e.g. [x,y,z]

  TODO Should support 'with_m' analogous to from_coordinates
  """
  def to_coordinates(point) do
    if with_z?(point), do: [point.x, point.y, point.z], else: [point.x, point.y]
  end


  @doc """
  `Point` as text, e.g. "-11.2431 32.3141 34.5445"
  """
  def text_representation(point) do
    String.rstrip text_representation(point, nil?(point.z), nil?(point.m))
  end

  defp text_representation(point, false, false) do
    "#{point.x} #{point.y}"
  end

  defp text_representation(point, true, false) do
    String.rstrip "#{point.x} #{point.y} #{point.z}"
  end

  defp text_representation(point, false, true) do
    String.rstrip "#{point.x} #{point.y} #{point.m}"
  end

  defp text_representation(point, true, true) do
    String.rstrip "#{point.x} #{point.y} #{point.z} #{point.m}"
  end

  @doc "georss simple representation"
  def georss_simple_representation(point, options \\ %{}) do
    georss_ns = if Map.has_key?(options, :georss_ns), do: options.georss_ns, else: "georss"
    geom_attr = if Map.has_key?(options, :geom_attr), do: options.geom_attr
    "<#{georss_ns}:point#{geom_attr}>#{point.y} #{point.x}</#{georss_ns}:point>\n"
  end

  @doc "georss w3c representation"
  def georss_w3cgeo_representation(point, options \\ %{}) do
    w3cgeo_ns = if Map.has_key?(options, :w3cgeo_ns), do: options.w3cgeo_ns, else: "geo"
    "<#{w3cgeo_ns}:lat>#{point.y}</#{w3cgeo_ns}:lat>\n<#{w3cgeo_ns}:long>#{point.x}</#{w3cgeo_ns}:long>\n"
  end

  @doc "georss gml representation"
  def georss_gml_representation(point, options \\ %{}) do
    georss_ns = if Map.has_key?(options, :georss_ns), do: options.georss_ns, else: "georss"
    gml_ns = if Map.has_key?(options, :gml_ns), do: options.gml_ns, else: "gml"
    out = "<#{georss_ns}:where>\n<#{gml_ns}:Point>\n<#{gml_ns}:pos>"
    out = out <> "#{point.y} #{point.x}"
    out <> "</#{gml_ns}:pos>\n</#{gml_ns}:Point>\n</#{georss_ns}:where>\n"
  end

  @doc "html representation"
  def html_representation(point, options \\ %{coord: true, full: false}) do
    out =  "<span class='geo'>"
    out = out <> "<abbr class='latitude' title='#{point.x}'>#{as_lat(point, options)}</abbr>"
    out = out <> "<abbr class='longitude' title='#{point.y}'>#{as_long(point, options)}</abbr>"
    out <> "</span>"
  end

  @doc "Creates a point using coordinates like 22`34 23.45N"
  def from_latlong(lat, lon, srid \\ default_srid) do
    [x,y] = [lat, lon] |> Enum.map  fn(l) ->
       [ _, sig, deg, min, sec, cen, _] = l |> scan |> parse_ll
      if Regex.match?(~r/W|S/, l), do: sig = true
      {sec_cen, _} = Float.parse("0#{sec}#{cen}")
      {deg,_} = Integer.parse("#{deg}")
      {min,_} = Integer.parse(min)
      deg = trunc deg
      min = trunc min
      dec = deg + (min * 60 + sec_cen) / 3600
      if sig, do: (dec * -1), else: dec
    end
    Point.from_x_y(x, y, srid)
  end

  defp scan(l) do
    List.flatten Regex.scan(~r/(-)?(\d{1,2})\D*(\d{2})\D*(\d{2})(\D*(\d{1,3}))?/, l)
  end

  defp parse_ll([ _, sig, deg, min, sec, cen, _]) do
    [ nil, parse_sig(sig), deg, min, sec, cen, nil]
  end

  defp parse_ll([ _, sig, deg, min, sec]) do
    [ nil, parse_sig(sig), deg, min, sec, "", nil]
  end

  defp parse_sig(sig) do
    if String.length(sig) == 0, do: false, else: true
  end

  @doc """
  Outputs the geometry coordinate in human format: 47°52′48″N
  """
  def as_lat(point, options \\ %{}) do
    human_representation(%{ x: point.x }, options) |> Enum.join ""
  end

  @doc """
  Outputs the geometry coordinate in human format: -20°06′00W″
  """
  def as_long(point, options \\ %{}) do
    human_representation(%{ y: point.y }, options) |> Enum.join ""
  end

  def as_lng(y, options \\ %{}) do
    as_long(y, options)
  end

  @doc """
  Outputs the geometry in coordinates format: 47°52′48″, -20°06′00″
  """
  def as_latlong(point, options \\ %{}) do
    human_representation(%{ x: point.x, y: point.y }, options) |> Enum.join ", "
  end

  def as_ll(point, options \\ %{}) do
    as_latlong(point, options)
  end

  @doc """
  Human representation of the geom, don't use directly, use:
  as_lat, #as_long, #as_latlong
  """
  def human_representation(struct, options) do
    struct
    |> Enum.map(fn({k, v}) ->
        deg = abs(trunc(v))
        min = trunc(60 * (abs(v) - deg))
        labs = abs(v * 1_000_000) / 1_000_000
        sec = ((((labs - trunc(labs)) * 60) - trunc((labs - trunc(labs)) * 60)) * 100_000) * 60 / 100_000
        sec = if Map.has_key?(options, :full) && options.full, do: sprintf("%.2f", [sec]), else: sprintf("%02i", [round(sec)])
        min = sprintf("%02i", [min])
        str = "~w°~s′~s″"
        sec = to_string(sec)
        if Map.has_key?(options, :coord) && options.coord do
          out = :io_lib.format(str, [deg,min,sec]) # TODO refactor to use exprintf
          out = out ++ cardinal_direction(k, v)
          :erlang.iolist_to_binary(out)
        else
          :erlang.iolist_to_binary(:io_lib.format(str, [trunc(v),min,sec]))
        end
      end)
  end

  defp cardinal_direction(key, value) when key == :x do
    if value > 0, do:  "N", else: "S"
  end

  defp cardinal_direction(key, value) when key == :y do
    if value > 0, do: "E", else: "W"
  end

  @doc """
  outputs the geometry in kml format : options are
  <tt>:id</tt>, <tt>:tesselate</tt>, <tt>:extrude</tt>,
  <tt>:altitude_mode</tt>.
  If the altitude_mode option is not present, the Z (if present)
  will not be output (since it won't be used by GE anyway:
  clampToGround is the default)
  """
  def kml_representation(point, options \\ %{}) do
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
    %Point{x: x, y: y, lat: x, lng: y, srid: srid}
  end

  defp from_coord([x, y, m], srid, true) do
    %Point{x: x, y: y, lat: x, lng: y, m: m, srid: srid}
  end

  defp from_coord([x, y, z], srid, false) do
    %Point{x: x, y: y, lat: x, lng: y, z: z, srid: srid}
  end

  defp from_coord([x,y,z,m], srid, _with_m) do
    %Point{x: x, y: y, lat: x, lng: y, z: z, m: m, srid: srid}
  end

    defp head_tail(line, tail)  when tail != nil do
    [line, tail]
  end

  defp head_tail(line, tail) when tail == nil do
    [ List.first(line.points), List.last(line.points) ]
  end

  defp calculate_ort_dist(res, head, tail, c, d, point) do
    [xx, yy] = calc_xx_yy(res, head, tail, c, d)
    Math.sqrt(
      Math.pow((point.x - xx), 2) +
      Math.pow((point.y - yy), 2)
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


  defp _theta_rad(0.0, y) do
    if y < 0, do: 3 * halfpi, else: halfpi
  end

  defp _theta_rad(x, y) do
    th = Math.atan(y/x)
    if r(x, y) > 0, do: th + 2 * Math.pi, else: th
  end

end
