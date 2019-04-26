io.stdout:setvbuf("no")
love.graphics.setDefaultFilter("nearest")



function love.keypressed(key)
end

function love.keyreleased(key)
end

function love.mousepressed(x, y, button)
  
end

function love.mousereleased(x, y, button)
  
end

function love.wheelmoved(x, y)
  
end

function love.load()
  
  Color = dofile "color_lib.lua"
  
  love.window.setMode(1024,640)
  ScreenWidth, ScreenHeight = love.graphics.getDimensions()
  
  mainFont = love.graphics.newFont(20)
  love.graphics.setFont(mainFont)
  
  KeyDown = love.keyboard.isDown
  Game = 
  {
    Player = 
    {
      X = 0,
      Y = 0,
      Speed = 128,
      Angle = {0, math.pi/2, math.pi/4,math.pi, nil, 3*math.pi/4, math.pi/2, 3*math.pi/2, 7*math.pi/4, nil, 0, 5*math.pi/4, 3*math.pi/2, math.pi, nil},
      Draw = function(self)
        SetColor(Color.Green)
        love.graphics.rectangle("fill", ScreenWidth/2 - 8, ScreenHeight/2 -28, 16, 32)
      end,
      Update = function(self, dt)
        
        local direction, NextX, NextY = 0, 0, 0
        local var1, var2
        
        if KeyDown("d") then
          direction = direction +1
        end
        if KeyDown("z") then
          direction = direction +2
        end
        if KeyDown("q") then
          direction = direction +4
        end
        if KeyDown("s") then
          direction = direction +8
        end
        
        if direction % 5 ~= 0 then
          
          NextX = self.X + math.cos(self.Angle[direction]) * self.Speed * dt
          NextY = self.Y + math.sin(self.Angle[direction]) * self.Speed * dt * -1
          
          self.X = NextX
          self.Y = NextY
          
        end
      end,
    },
    Train = 
    {
      X=0,
      Y=0,
      IsTurning = false,
      NextStop = {X=0,Y=0},
      Speed = 32,
      Step = 5,
      TurningSpeed = math.pi/4, --in rad/sec
      Angle = 0,
      Draw = function(self)
        SetColor(Color.White)
        love.graphics.rectangle("fill", self.NextStop.X - Game.Player.X-1, self.NextStop.Y - Game.Player.Y-1, 3, 3)
        love.graphics.circle("fill", self.X - Game.Player.X, self.Y - Game.Player.Y, 8)
      end,
      Update = function(self, dt)
        
        if self.IsTurning then
          local angle = math.atan2(self.NextStop.Y - self.Y, self.NextStop.X - self.X)
          local NextAngle = self.Angle + dt * self.TurningSpeed * (angle - self.Angle)/math.abs(angle - self.Angle)
          if (angle - self.Angle)^2 < (angle - NextAngle)^2 then
            self.IsTurning  = false
            self.Angle = angle
          else self.Angle = NextAngle end
        end
        
        
        
        local NextX = self.X + dt * self.Speed * math.cos(self.Angle)
        local NextY = self.Y + dt * self.Speed * math.sin(self.Angle)
        
        if (self.X - self.NextStop.X)^2 + (self.Y - self.NextStop.Y)^2 < (NextX - self.NextStop.X)^2 + (NextY - self.NextStop.Y)^2 and not self.IsTurning then
          self.X = self.NextStop.X
          self.Y = self.NextStop.Y
          if self.Step >= #Game.Map.Path then self.Step = 1 else self.Step = self.Step +1 end
          self:Init()
        else
          self.X = NextX
          self.Y = NextY
          --self.Angle = math.atan2(self.NextStop.Y - self.Y, self.NextStop.X - self.X)
        end
        
      end,
      Init = function(self)
        self.IsTurning = true
        self.NextStop.X = Game.Map.Path[self.Step].X
        self.NextStop.Y = Game.Map.Path[self.Step].Y
        
        --self.Angle = math.atan2(self.NextStop.Y - self.Y, self.NextStop.X - self.X)
      end,
    },
    Map = 
    {
      Timer = 0,
      Path = dofile "Path.lua",
      Draw = function(self)
        SetColor(Color.Orange)
        for k,v in ipairs(self.Path) do
          love.graphics.rectangle("fill", v.X - Game.Player.X, v.Y - Game.Player.Y, 1, 1)
        end
      end,
      Update = function(self, dt)
        self.Timer = self.Timer - dt
        while self.Timer <= 0 do
          self.Timer = self.Timer + 10
          self.Path = dofile "Path.lua"
        end
      end,
    },
  }
  
  for k,v in pairs(Game) do
    if v.Init ~= nil then v:Init() end
  end
  
end

function love.update(dt)
  
  for k,v in pairs(Game) do
    if v.Update ~= nil then v:Update(dt) end
  end
  
end

function love.draw()
  
  for k,v in pairs(Game) do
    if v.Draw ~= nil then v:Draw() end
  end
  
  
  SetColor(Color.White)
  love.graphics.rectangle("fill", ScreenWidth/2, ScreenHeight/2, 1, 1)
end
