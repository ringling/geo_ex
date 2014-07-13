defmodule EllipsoidalCalculations do
  import Geometry

  @doc """
  Ellipsoidal distance in m using Vincenty's formula. Lifted entirely from Chris Veness's code at http://www.movable-type.co.uk/scripts/LatLongVincenty.html and adapted for Ruby. Assumes the x and y are the lon and lat in degrees.
  a is the semi-major axis (equatorial radius) of the ellipsoid
  b is the semi-minor axis (polar radius) of the ellipsoid
  Their values by default are set to the ones of the WGS84 ellipsoid
  """
  def distance(p1, p2, a, b) do

    f = (a - b) / a
    l = (p2.lng - p1.lng) * deg2rad

    u1 = :math.atan((1-f) * :math.tan(p1.lat * deg2rad))
    u2 = :math.atan((1-f) * :math.tan(p2.lat * deg2rad))

    sinU1 = :math.sin(u1)
    cosU1 = :math.cos(u1)
    sinU2 = :math.sin(u2)
    cosU2 = :math.cos(u2)

    lambda = l
    lambdaP = 2 * :math.pi
    iterLimit = 20

    calc(a, b, f, l, lambda, lambdaP, cosU1, cosU2, sinU1, sinU2, 0, 0, 0, 0, 0, iterLimit)
  end

  defp calc(a, b, f, l, lambda, lambdaP, cosU1, cosU2, sinU1, sinU2, sigma, _sinSigma, cosSqAlpha, cosSigma, cos2SigmaM, iterLimit) when abs(lambda - lambdaP) > 1.0e-12 and iterLimit > 0 do
    sinLambda =:math.sin(lambda)
    cosLambda =:math.cos(lambda)
    sinSigma  = sin_sigma(cosU1, cosU2, sinU1, sinU2, cosLambda, sinLambda)

    # coincident points
    if sinSigma == 0 do
      0
    else
      cosSigma   = cos_sigma(cosU1, cosU2, sinU1, sinU2, cosLambda)

      sigma      =:math.atan2(sinSigma, cosSigma)
      sinAlpha   = cosU1 * cosU2 * sinLambda / sinSigma
      cosSqAlpha = 1 - sinAlpha * sinAlpha
      cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha

      # equatorial line: cosSqAlpha=0
      unless is_number(cos2SigmaM), do: cos2SigmaM = 0

      c = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha))
      lambdaP = lambda
      lambda = lambda(l, c,f,sinAlpha, sigma, cosSigma, sinSigma, cos2SigmaM)

      calc(a, b, f, l, lambda, lambdaP, cosU1, cosU2, sinU1, sinU2, sigma,sinSigma, cosSqAlpha, cosSigma, cos2SigmaM, iterLimit - 1)
    end

  end

  defp calc(a, b, _f, _l, _lambda, _lambdaP, _cosU1, _cosU2, _sinU1, _sinU2, sigma, sinSigma, cosSqAlpha, cosSigma, cos2SigmaM, iterLimit) do
    result(cosSqAlpha, a, b, sigma, sinSigma, cos2SigmaM, cosSigma, iterLimit)
  end

  defp result(_cosSqAlpha, _a, _b, _sigma, _sinSigma, _cos2SigmaM, _cosSigma, 0) do
    "Nan"
  end

  defp result(cosSqAlpha,a,b, sigma, sinSigma, cos2SigmaM, cosSigma, _iterLimit) do
    uSq = cosSqAlpha * (a*a - b*b) / (b*b)
    a_bis = a_bis(uSq)
    b_bis = b_bis(uSq)
    deltaSigma = delta_sigma(b_bis, sinSigma, cos2SigmaM, cosSigma, sinSigma)
    b * a_bis * (sigma - deltaSigma)
  end

  defp lambda(l, c, f ,sinAlpha, sigma, cosSigma, sinSigma, cos2SigmaM) do
    l + (1 - c) * f * sinAlpha * (sigma + c * sinSigma *
      (cos2SigmaM + c * cosSigma * (-1 + 2 * cos2SigmaM *
          cos2SigmaM)))
  end

  defp cos_sigma(cosU1, cosU2, sinU1, sinU2, cosLambda) do
    sinU1 * sinU2 + cosU1 * cosU2 * cosLambda
  end

  defp sin_sigma(cosU1, cosU2, sinU1, sinU2, cosLambda, sinLambda) do
    :math.sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda) +
              (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) *
              (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda))
  end

  defp delta_sigma(b_bis, sinSigma, cos2SigmaM, cosSigma, sinSigma) do
    b_bis * sinSigma * (cos2SigmaM + b_bis / 4 *
    (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) - b_bis / 6 *
      cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 *
        cos2SigmaM * cos2SigmaM)))
  end

  defp a_bis(uSq) do
    1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)))
  end

  defp b_bis(uSq) do
    uSq/1024 * (256+uSq*(-128 + uSq * (74 - 47 * uSq)))
  end

end
