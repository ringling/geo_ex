defmodule SimpleFeatures.LineString do
  import Geometry

  defstruct x: 0.0, y: 0.0, z: 0.0, m: 0.0, srid: 4326, lat: nil, lng: nil

  #Creates a new line string. Accept a sequence of points as argument : ((x,y)...(x,y))
  def from_coordinates(points, srid \\ default_srid) do
  #   line_string = new(srid,with_z,with_m)
  #   # line_string.concat( points.map {|p| Point.from_coordinates(p,srid,with_z,with_m) } )
  #   line_string
  end

  defp from_coord([x, y], srid) do
    %SimpleFeatures.LineString{x: x, y: y, lat: x, lng: y, srid: srid}
  end


end