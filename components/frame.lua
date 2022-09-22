local frame = newclass("UI.Frame",ui.classes["UI.Element"])

function frame:init(options)
    --x,y,width,height,color
    self.super:init(options)
    self.color = options.color
    self.border = options.border
    self.border_color = options.border_color or options.color
    if(options.titleBar) then
        self.titleBar = options.titleBar
        self:makeParent(self.titleBar)
        self.titleBar:setX(0)
        self.titleBar:setY(0)
    end
    table.insert(ui.elements,self)
    --self.window = window.create(ui.monitor().current(), self.x, self.y, self.width, self.height)
end

function frame:dispose()
    -- self.super:dispose()
    for k,v in pairs(self.children) do
        if v.dispose then v:dispose() end
    end
    local index = false
    for k,v in pairs(ui.elements) do 
        if v == self then
            index = k
        end
    end
    if(index) then
        table.remove(ui.elements,index)
    end
end

function frame:getTitleBar()
    return self.titleBar
end

function frame:onPaste(pasted)
    if not self.visible then return end
    --_error("focused:" .. tostring(self.children[1]) .. " and onkeydown:" .. tostring(self.children[1].onKeyDown))
    if(self.children[1] and self.children[1].onPaste) then
        self.children[1]:onPaste(pasted)
    end
end

function frame:onKeyDown(k,shifted,ctrl)
    if not self.visible then return end
    --_error("focused:" .. tostring(self.children[1]) .. " and onkeydown:" .. tostring(self.children[1].onKeyDown))
    if(self.children[1] and self.children[1].onKeyDown) then
        self.children[1]:onKeyDown(k,shifted,ctrl)
    end
end

function frame:onMouseScroll(dir)
    if not self.visible then return end
    --_error("focused:" .. tostring(self.children[1]) .. " and onkeydown:" .. tostring(self.children[1].onKeyDown))
    if(self.children[1] and self.children[1].onMouseScroll) then
        self.children[1]:onMouseScroll(dir)
    end
end

function frame:onMouseDown(x,y)
    if not self.visible then return end
    local hit = self.super:onMouseDown(x,y)
    if(not hit) then
        if(self.titleBar) then
            self.titleBar:onMouseDown(x,y)
        end
    end
end

function frame:onMouseUp()
    if not self.visible then return end
    for k,child in pairs(self.children) do
        if(child.onMouseUp) then
            child:onMouseUp()
        end
    end
    if(self.titleBar) then
        self.titleBar:onMouseUp()
    end
end

function frame:onMouseDrag(x,y,z,w)
    if not self.visible then return end
    for k,child in pairs(self.children) do
        if(child.onMouseDraw) then
            child:onMouseDrag()
        end
    end
    if(self.titleBar) then
        self.titleBar:onMouseDrag(x,y,z,w)
    end
end

function frame:onFocus()
    
end

function frame:focusLost()
    
end

function frame:draw()

    if not self.visible then return end
    --self.window.redraw()
    local textc = ui.monitor().getTextColor()
    local backc = ui.monitor().getBackgroundColor()
    for y = 0,self.height-1 do
        ui.monitor().setTextColor(self.color)
        ui.monitor().setBackgroundColor(self.color)
        ui.monitor().setCursorPos(self:X(),self:Y()+y)
        if(self.border) then
            if(y == 0 or y == self.height-1) then
                if(y == 0 and not self.titleBar) then
                    ui.monitor().setCursorPos(self:X(),self:Y()+y-1)
                elseif(y == self.height-1) then
                    ui.monitor().setCursorPos(self:X(),self:Y()+y)
                end
                ui.monitor().setTextColor(self.border_color)
                ui.monitor().setBackgroundColor(self.border_color)
                ui.monitor().write(string.rep(" ",self.width))
            else
                ui.monitor().write(string.rep(" ",self.width))
            end
        else
            ui.monitor().write(string.rep(" ",self.width))
        end
        ui.monitor().setTextColor(self.color)
        ui.monitor().setBackgroundColor(self.color)
    end
    if(self.border) then
        ui.monitor().setTextColor(self.border_color)
        ui.monitor().setBackgroundColor(self.border_color)
        for y = 0,self.height-1 do
            for _,x in pairs({-1,self.width}) do
                if(y == 0 and not self.titleBar) then
                    ui.monitor().setCursorPos(self:X()+x,self:Y()+y-1)
                else
                    ui.monitor().setCursorPos(self:X()+x,self:Y()+y)
                end
                ui.monitor().write(" ")
            end
        end
    end
    ui.monitor().setTextColor(self.color)
    ui.monitor().setBackgroundColor(self.color)

    if(self.titleBar) then
        self.titleBar:draw()
    end
    self:drawChildren()
    if(self.children[1] and self.children[1].drawFocused) then
        self.children[1]:drawFocused()
    else
        ui.monitor().setCursorBlink(false)
        ui.monitor().setCursorPos(self:X(),self:Y())
    end
    ui.monitor().setTextColor(textc)
    ui.monitor().setBackgroundColor(backc)
end

function frame:drawChildren()
    if not self.visible then return false end
    for k,child in pairs(self.children) do
        child:draw()
    end
end

function frame:ABTest(a,b)
    if not self.visible then return false end
    return (a >= self.x and a <= self.x+self.width-1 and b >= self.y and b <= self.y+self.height-1)
end

return frame;