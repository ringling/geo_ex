defmodule SimpleFeatures.GeometryHelper do

  def with_z?(geometry_collection) do
    geometry_collection.geometries |> Enum.any? fn(geometry) ->
      fun = Module.function(geometry.__struct__, :with_z?, 1)
      fun.(geometry)
    end
  end

  def bounding_box_for_geometry(geometry) do
    fun = Module.function(geometry.__struct__, :bounding_box, 1)
    fun.(geometry)
  end

  def contains_point?(geometry, point) do
    fun = Module.function(geometry.__struct__, :contains_point?, 2)
    fun.(geometry, point)
  end

  def to_coordinates(geometry) do
    fun = Module.function(geometry.__struct__, :to_coordinates, 1)
    fun.(geometry)
  end

  def points(geometry) do
    fun = Module.function(geometry.__struct__, :points, 1)
    fun.(geometry)
  end

end
