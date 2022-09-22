local this = newclass("UI.Label",ui.classes["UI.Element"])

function this:init(options)
    --x,y,width,height,color
    self.super:init(options)
    self.color = options.color
    self.text_color = options.text_color
    self.text = options.text
end

function this:setTextColor(color)
    self.text_color = color
end

function this:setBackgroundColor(color)
    self.color = color
end

function this:draw()
    --self.window.redraw()
    local textc = ui.monitor().getTextColor()
    local backc = ui.monitor().getBackgroundColor()
    ui.monitor().setTextColor(self.color)
    ui.monitor().setBackgroundColor(self.color)
    
    ui.monitor().setCursorPos(self:X(),self:Y())
    ui.monitor().write(string.rep(" ",self.width))

    ui.monitor().setTextColor(self.text_color)
    ui.monitor().setCursorPos(self:X() ,self:Y())
    if(#self.text < self.width) then
        ui.monitor().write(string.sub(self.text,1,math.min(self.width-1,#self.text)))
    else
        --reverse -
        --from start to limit
        --reverse back
        local text = string.reverse(self.text)
        local text = string.sub(text,1,math.min(self.width-1,#text))
        ui.monitor().write(string.reverse(text))
    end
    ui.monitor().setTextColor(textc)
    ui.monitor().setBackgroundColor(backc)
end

function this:setText(text)
    self.text = text
end

function this:ABTest(a,b)
    return (a >= self:X() and a <= self:X()+self.width-1 and b >= self:Y() and b <= self:Y())
end


return this;