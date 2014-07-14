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


end
