defmodule SimpleFeatures.GeometryHelper do

  def with_z?(geometry_collection) do
    geometry_collection.geometries |> Enum.any? fn(geometry) ->
      fun = :erlang.make_fun(geometry.__struct__, :with_z?, 1)
      fun.(geometry)
    end
  end

  def bounding_box_for_geometry(geometry) do
    fun = :erlang.make_fun(geometry.__struct__, :bounding_box, 1)
    fun.(geometry)
  end

  def contains_point?(geometry, point) do
    fun = :erlang.make_fun(geometry.__struct__, :contains_point?, 2)
    fun.(geometry, point)
  end

  def to_coordinates(geometry) do
    fun = :erlang.make_fun(geometry.__struct__, :to_coordinates, 1)
    fun.(geometry)
  end

  def points(geometry) do
    fun = :erlang.make_fun(geometry.__struct__, :points, 1)
    fun.(geometry)
  end

  def with_m?(geometry) do
    fun = :erlang.make_fun(geometry.__struct__, :with_m?, 1)
    fun.(geometry)
  end

  def text_representation(geometry) do
    fun = :erlang.make_fun(geometry.__struct__, :text_representation, 3)
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

  defp m_text(geometry, allow_m, allow_z) do
    if with_m?(geometry) && allow_m && (!with_z?(geometry) || !allow_z), do: "M", else: ""
  end

end
