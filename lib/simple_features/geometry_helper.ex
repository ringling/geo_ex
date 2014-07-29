defmodule SimpleFeatures.GeometryHelper do

  def with_z?(geometry_collection) do
    geometry_collection.geometries |> Enum.any? fn(geometry) ->
      fun = Module.function(geometry.__struct__, :with_z?, 1)
      fun.(geometry)
    end
  end

  def within_bounding_box?(point, bounding_box) do
    [a,b] = bounding_box
    _contains?([point.x,point.y], [a,b])
  end

  def contains?(bounding_box = [sw, ne], point) do
    point.x >= sw.x &&
    point.y >= sw.y &&
    point.x <= ne.x &&
    point.y <= ne.y
  end

  def contains_point?(geometry, point) do
    fun = Module.function(geometry.__struct__, :contains_point?, 2)
    fun.(geometry, point)
  end

  defp _contains?([x,y], [a,b]) do
    (b.y > y != a.y > y) && (x < (a.x - b.x) * (y - b.y) / (a.y - b.y) + b.x)
  end


  def to_coordinates(geometry) do
    fun = Module.function(geometry.__struct__, :to_coordinates, 1)
    fun.(geometry)
  end

  def points(geometry) do
    fun = Module.function(geometry.__struct__, :points, 1)
    fun.(geometry)
  end

  def with_m?(geometry) do
    fun = Module.function(geometry.__struct__, :with_m?, 1)
    fun.(geometry)
  end

  def text_representation(geometry) do
    fun = Module.function(geometry.__struct__, :text_representation, 3)
    fun.(geometry, with_z?(geometry), with_m?(geometry))
  end

  @doc """
  Outputs the geometry as an EWKT string.
  """
  def as_ewkt(geometry, allow_srid \\ true, allow_z \\ true, allow_m \\ true) do
    if allow_srid do
      ewkt = "SRID=#{geometry.srid};"
    else
      ewkt = ""
    end
    ewkt = ewkt <> geometry.text_geometry_type
    ewkt = ewkt <> m_text(geometry, allow_m, allow_z)
    ewkt <> "(" <> text_representation(geometry) <> ")"
  end

  # @doc """
  # Outputs the geometry as a HexEWKB string.
  # It is almost the same as a WKB string, except that each byte of a WKB
  # string is replaced by its hexadecimal 2-character representation in a HexEWKB string.
  # """
  # def as_hex_ewkb(geometry, allow_srid \\ true, allow_z \\ true, allow_m \\ true) do
  #   as_ewkb(allow_srid, allow_z, allow_m).unpack('H*').join('').upcase
  # end

  # @doc "Outputs the geometry as a strict HexWKB string"
  # def as_hex_wkb(geometry) do
  #   as_hex_ewkb(geometry, false,false,false)
  # end

  defp m_text(geometry, allow_m, allow_z) do
    if with_m?(geometry) && allow_m && (!with_z?(geometry) || !allow_z), do: "M", else: ""
  end

end
