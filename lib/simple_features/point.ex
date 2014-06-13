defmodule SimpleFeatures do
  defmodule Point do

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
      %Point{x: x, y: y, lat: x, lng: y, srid: srid}
    end

    def from_x_y_z(x, y, z, srid \\ default_srid) do
      %Point{x: x, y: y, lat: x, lng: y, z: z, srid: srid}
    end

    def from_x_y_z_m(x, y, z, m, srid \\ default_srid) do
      %Point{x: x, y: y, lat: x, lng: y, z: z, m: m, srid: srid}
    end

    def from_r_t(r, t, srid \\ default_srid) do
      t = t * deg2rad
      x = r * :math.cos(t)
      y = r * :math.sin(t)
      %Point{x: x, y: y, lat: x, lng: y, srid: srid}
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

    defp from_coord([x, y], srid) do
      %Point{x: x, y: y, lat: x, lng: y, srid: srid}
    end

    defp from_coord([x, y, z], srid) do
      %Point{x: x, y: y, lat: x, lng: y, z: z, srid: srid}
    end

    defp from_coord([x,y,z,m], srid) do
      %Point{x: x, y: y, lat: x, lng: y, z: z,m: m, srid: srid}
    end

    defp default_srid do
      4326
    end

    def deg2rad do
      0.0174532925199433
    end

    def halfpi do
      1.5707963267948966
    end

  end
end

