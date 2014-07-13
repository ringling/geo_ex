defmodule Bearing do

  def bearing_to(p1, p2) do
    if p1 == p2, do: 0, else: bearing(p2.x - p1.x, p2.y - p1.y)
  end

  def bearing_text(bearing) when bearing in 1..22 or bearing in 337..360, do: :n
  def bearing_text(bearing) when bearing in 23..66, do: :ne
  def bearing_text(bearing) when bearing in 67..112, do: :e
  def bearing_text(bearing) when bearing in 113..146, do: :se
  def bearing_text(bearing) when bearing in 147..202, do: :s
  def bearing_text(bearing) when bearing in 203..246, do: :sw
  def bearing_text(bearing) when bearing in 247..292, do: :w
  def bearing_text(bearing) when bearing in 293..336, do: :nw

  defp bearing(a, b) when a < 0 do
    360 - degrees(a, b)
  end

  defp bearing(a, b) do
    degrees(a, b)
  end

  defp degrees(a,b) do
    :math.acos(b / :math.sqrt(a*a+b*b)) / :math.pi * 180
  end

end