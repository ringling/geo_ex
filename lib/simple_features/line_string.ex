defmodule SimpleFeatures.LineString do
  import Geometry

  defstruct points: [], srid: default_srid

  @doc "Creates a new line string. Accept a sequence of coordinates as argument : ((x,y)...(x,y))"
  def from_coordinates(coordinates, srid \\ default_srid) do
    points = Enum.map coordinates, fn(coordinate) -> SimpleFeatures.Point.from_coordinates(coordinate) end
    %SimpleFeatures.LineString{points: points, srid: srid}
  end

end