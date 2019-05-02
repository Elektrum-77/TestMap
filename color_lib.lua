local Color =
{
  White =    {255/255, 255/255, 255/255, 255/255},
  Black =    {0/255  , 0/255  , 0/255  , 255/255},
  Red =      {255/255, 0/255  , 0/255  , 255/255},
  Pink =     {220/255, 160/255, 160/255, 255/255},
  Green =    {0/255  , 255/255, 0/255  , 255/255},
  Blue =     {0/255  , 0/255  , 255/255, 255/255},
  BlueLite = {128/255, 220/255, 255/255, 255/255},
  Yellow =   {255/255, 255/255, 0/255  , 255/255},
  Purple =   {255/255, 0/255  , 255/255, 255/255},
  Orange =   {255/255, 128/255, 0/255  , 255/255},
  Grey =     {64/255 , 64/255 , 64/255 , 255/255},
  GreyLite = {128/255, 128/255, 128/255, 255/255},
  GreyDark = {32/255 , 32/255 , 32/255 , 255/255},
}
  
love.graphics.setBackgroundColor(Color.GreyDark)

Color.Set = love.graphics.setColor

Color.Alpha = function(color_value, a)
  local c = color_value
  c[4] = a
  return c
end

return Color
