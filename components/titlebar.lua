local titlebar = newclass("UI.TitleBar",ui.classes["UI.Element"])

function titlebar:ABTest(a,b)
    return (a >= self.parent.x and a <= self.parent.x+self.parent.width and b >= self.parent.y and b <= self.parent.y+1)
end

function titlebar:init(options)
    --x,y,width,height,color
    self.super:init(options)
    self.color = options.color
    self.text_color = options.text_color
    self.text = options.text
    self.clicked = false
    self.locked = options.locked or false
    self.height = 1
end

function titlebar:addButton(button)
    -- _error("test")
    mon = peripheral.wrap("monitor_0")
    mon.clear()
    mon.setCursorPos(1,1)

    if(ui.classes["UI.Button"]:made(button)) then
        self:makeParent(button)
        --lets organize the buttons positions according to rules :
        --each button is after the titlebar title label, so xoffset+text.length-1
        --each button is the padded with one grey pixel before itself
        --widths are locked to text length
        --the width+1 of each button is appended to xoffset
        --y is locked to 0
        local xoffset = #self.text+1
        local yoffset = 0
        button:setWidth(#button:getText())
        button:setY(0)
        button:setHeight(1)
        for i = #self.children,1,-1 do
            local child = self.children[i]
            child:setX(xoffset)
            xoffset = xoffset+child:getWidth()+1
        end
    else
        _error("can only add buttons to titlebar (for now) got '" .. tostring(button) .. "'")
    end
end

function titlebar:onMouseDown(x,y)
    if not self.visible or not self.parent:getVisible() then return end
    local test = self:ABTest(x,y,self.parent.x,self.parent.y,self.parent.width-1,1)
    --is any buttons hit ?
    local anyButtonHit = false
    for k,butt in pairs(self.children) do
        if(not anyButtonHit and butt:ABTest(x,y)) then
            anyButtonHit = true;
            butt:onMouseDown(x,y);
        end
    end
    if not anyButtonHit then
        self.clicked = test;
    end
end

function titlebar:onMouseDrag(dx,dy)
    if(self.clicked and not self.locked) then
        -- error("drag (" .. tostring(dx) .. "," .. tostring(dy) ..")")
        self.parent.x = self.parent.x+(dx*-1)
        self.parent.y = self.parent.y+(dy*-1)
    end
end

function titlebar:onMouseUp()
    self.clicked = false;
    for k,butt in pairs(self.children) do
        butt:onMouseUp();
    end
end

function titlebar:draw()
    --self.window.redraw()
    local textc = ui.monitor().getTextColor()
    local backc = ui.monitor().getBackgroundColor()
    ui.monitor().setTextColor(self.color)
    ui.monitor().setBackgroundColor(self.color)
    ui.monitor().setCursorPos(self:X(),self:Y())
    ui.monitor().write(string.rep(" ",self.parent.width))
    ui.monitor().setTextColor(self.text_color)
    ui.monitor().setCursorPos(self:X(),self:Y())
    ui.monitor().write(string.sub(self.text,1,math.min(self.parent.width,#self.text)))
    -- self:drawChildren()
    for k,child in pairs(self.children) do
        child:draw()
    end
    for k,butt in pairs(self.children) do
        ui.monitor().setCursorPos(butt:getX()-1+self:X(),self:Y())
        ui.monitor().setTextColor(self.color)
        ui.monitor().setBackgroundColor(colors.lightGray)
        ui.monitor().write("|")
    end
    ui.monitor().setTextColor(textc)
    ui.monitor().setBackgroundColor(backc)
end

return titlebar;