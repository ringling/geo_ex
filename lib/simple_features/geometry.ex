defmodule Geometry do

  def default_srid do
    4326
  end

  def deg2rad do
    0.0174532925199433
  end

  def halfpi do
    1.5707963267948966
  end

  def reverse(boolean) do
    !boolean
  end

end
