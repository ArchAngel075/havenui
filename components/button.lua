local button = newclass("UI.Button",ui.classes["UI.Element"])

function button:init(options)

    --x,y,width,height,color
    self.super:init(options)
    self.color = options.color
    self.text_color = options.text_color
    self.color_clicked = options.color_clicked
    self.text = options.text
    self.clicked = false
    self.onClick = options.onClick or false
    self.text_scale = options.text_scale or 1
end

function button:getTextScale()
    return self.text_scale
end

function button:setOnClick(func)
    if(func and type(func) == "function") then
        self.onClick = func
    else
        self.onClick = false
    end
end

function button:getText()
    return self.text
end

function button:setText(text)
    self.text = text
end

function button:setZ(z)
    self.z =z
end

function button:setParent(to)
    self.parent = to
    self.z = self.parent.z+1
end

function button:onMouseDown(x,y)
    if not self.visible then return false end
    local test = self:ABTest(x,y,self:X(),self:Y(),self.width-1,self.height-1)
    self.clicked = test;
    if(self.clicked and self.onClick and type(self.onClick) == "function") then
        self:onClick()
    end
end

function button:onMouseUp()
    self.clicked = false;
end

function button:setColor(color)
    self.color = color
end

function button:draw()
    if( not self.visible) then return false end
    --self.window.redraw()
    local textc = ui.monitor().getTextColor()
    local backc = ui.monitor().getBackgroundColor()
    --local scalec = ui.monitor().getTextScale()
    ui.monitor().setTextColor(self.color)
    if(self.clicked) then
        ui.monitor().setBackgroundColor(self.color_clicked)
    else
        ui.monitor().setBackgroundColor(self.color)
    end
    
    for y = 0,self.height-1 do
        ui.monitor().setCursorPos(self:X(),self:Y()+y)
        ui.monitor().write(string.rep(" ",self.width))
    end

    ui.monitor().setTextColor(self.text_color)
    if(type(self.text) == "table") then
        for k,v in pairs(self.text) do
            if(k <= self.height) then
                ui.monitor().setCursorPos(self:X(),self:Y()+k-1)
                local limit = math.min(self:getWidth(),#v)
                local text = string.sub(v,1,limit)
                ui.monitor().write(text)
            end
        end
    else
        ui.monitor().setCursorPos(self:X(),self:Y())
        local limit = math.min(self:getWidth(),#self.text)
        local text = string.sub(self.text,1,limit)
        ui.monitor().write(text)
    end
    ui.monitor().setTextColor(textc)
    ui.monitor().setBackgroundColor(backc)
end

function button:ABTest(a,b)
    return (a >= self:X() and a <= self:X()+self.width-1 and b >= self:Y() and b <= self:Y()+self.height-1)
end


return button;