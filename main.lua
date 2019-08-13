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
        Color.Set(Color.Green)
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
    Robot = 
    {
      X=90,
      Y=135,
      NextNodePathID = 2,
      MoveTimer = 0,
      Speed = 1, --
      StepLenght = 30, --how much pixel i can go with one loop of MoveTimer/Speed
      StepMaxNumber = 1,
      StepCompletition = 0, --between 0 and 1
      Step = {},
      
      Draw = function(self)
        Color.Set(Color.White)
        for k,v in ipairs(self.Step) do love.graphics.rectangle("fill", v.X+v.VX*self.StepLenght - Game.Player.X-1, v.Y+v.VY*self.StepLenght - Game.Player.Y-1, 3, 3) end
        love.graphics.circle("fill", self.X - Game.Player.X, self.Y - Game.Player.Y, 8)
      end,
      
      Update = function(self, dt)
        --Timer
        self.MoveTimer = self.MoveTimer + dt * self.Speed
        
        --Movements
        if #self.Step > 0 then
          while self.MoveTimer > 1 do
            self.MoveTimer = self.MoveTimer - 1
            self.X = self.Step[1].X + self.Step[1].VX * self.StepLenght
            self.Y = self.Step[1].Y + self.Step[1].VY * self.StepLenght
            table.remove(self.Step, 1)
            self:StepGeneration()
          end
          self.X = self.Step[1].X + self.Step[1].VX * self.MoveTimer * self.StepLenght
          self.Y = self.Step[1].Y + self.Step[1].VY * self.MoveTimer * self.StepLenght
        else self:StepGeneration() end
        
      end,
        
      StepGeneration = function(self)
        
        local Node = Game.Map.Path[self.NextNodePathID]
        local StepX, StepY
        if #self.Step > 0 then
          StepX = self.Step[#self.Step].X+ self.Step[#self.Step].VX*self.StepLenght
          StepY = self.Step[#self.Step].Y+ self.Step[#self.Step].VY*self.StepLenght
        else
          StepX = self.X
          StepY = self.Y
        end
        
        while (StepX - Node.X)^2 + (StepY - Node.Y)^2 > self.StepLenght^2 and #self.Step < self.StepMaxNumber do
          local Angle = math.atan2(Node.Y - StepY, Node.X - StepX)
          local VX, VY = math.cos(Angle), math.sin(Angle)
          local Step = {X = StepX,Y = StepY,VX = VX,VY = VY}
          table.insert(self.Step, Step)
          StepX = StepX+VX*self.StepLenght
          StepY = StepY+VY*self.StepLenght
          print(StepX, StepY)
        end
        
        if #self.Step < self.StepMaxNumber then
          local Decimal = 0
          local max = 0
          if self.NextNodePathID < #Game.Map.Path then self.NextNodePathID=self.NextNodePathID+1 else self.NextNodePathID=1 end
          local NextNode = Game.Map.Path[self.NextNodePathID]
          --Node = NextNode
          --if self.NextNodePathID < #Game.Map.Path then NextNode = Game.Map.Path[self.NextNodePathID+1] else NextNode = Game.Map.Path[1] end
          
          local Angle = math.atan2(NextNode.Y - Node.Y, NextNode.X - Node.X)
          
          local VX, VY = math.cos(Angle), math.sin(Angle)
          local t = 1
          
          while Decimal < 3 do
            while max < self.StepLenght^2 do
              if #self.Step > 0 then
                max = (self.Step[#self.Step].X - (Node.X + VX*t))^2 + (self.Step[#self.Step].Y - (Node.Y + VY*t))^2
              else max = (self.X - (Node.X + VX*t))^2 + (self.Y - (Node.Y + VY*t))^2 end
              t= t + 10^(-Decimal)
            end
            Decimal = Decimal+1
          end
          local X, Y
          if #self.Step > 0 then X, Y = self.Step[#self.Step].X, self.Step[#self.Step].Y else X, Y = self.X, self.Y end
          local Angle2 = math.atan2((Node.Y + VY*t-1) - Y, (Node.X + VX*t-1) - X)
          local VX2, VY2 = math.cos(Angle2), math.sin(Angle2)
          local Step = {
            X = X,
            Y = Y,
            VX = VX2,
            VY = VY2}
          print(X, Y, 2)
          table.insert(self.Step, Step)
        end
        
      end,
    },
    Map = 
    {
      Timer = 0,
      Path = dofile "Path.lua",
      Draw = function(self)
        Color.Set(Color.Orange)
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
  
  
  Color.Set(Color.White)
  love.graphics.rectangle("fill", ScreenWidth/2, ScreenHeight/2, 1, 1)
end
