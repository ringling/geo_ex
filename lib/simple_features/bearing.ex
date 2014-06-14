defmodule Bearing do

  def bearing_to(p1, p2) do
    if p1 == p2 do
      0
    else
      {a, b} =  {p2.x - p1.x, p2.y - p1.y}
      res =  :math.acos(b / :math.sqrt(a*a+b*b)) / :math.pi * 180;
      if a < 0 do
        360 - res
      else
        res
      end
    end
  end

  def bearing_text(bearing) when bearing in 1..22 or bearing in 337..360  do
    :n
  end

  def bearing_text(bearing) when bearing in 23..66  do
    :ne
  end

  def bearing_text(bearing) when bearing in 67..112  do
    :e
  end

  def bearing_text(bearing) when bearing in 113..146  do
    :se
  end

  def bearing_text(bearing) when bearing in 147..202  do
    :s
  end

  def bearing_text(bearing) when bearing in 203..246  do
    :sw
  end

  def bearing_text(bearing) when bearing in 247..292  do
    :w
  end

  def bearing_text(bearing) when bearing in 293..336  do
    :nw
  end

end