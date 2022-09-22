local this = newclass("UI.List",ui.classes["UI.Element"])
local _label = "UI.Label"

function this:init(options)
    --x,y,width,height,color
    self.super:init(options)
    self.color = options.color
    self.color_text_selected = options.color_text_selected
    self.color_selected = options.color_selected
    self.color_text = options.color_text
    self.width = options.width
    self.height = options.height
    self.items = {}
    self.offset = 0
    self.multiselect = options.multiselect or false
    self.onSelect = function() end
end

function this:moveOffset(n)
    self.offset = self.offset + n
    self.offset = math.min(math.max(0,self.offset),math.max(#self.items-10,0))
end

function this:setOnSelect(to)
    self.onSelect = to
end

function this:deselectAll(except)
    for k,item in pairs(self.items) do
        if((except and except ~= k) or not except) then
            item.selected = false
        end
    end
end

function this:resolveItem(index)
    return self.items[index]
end

function this:selectItems(items)
    for k,itemIndex in pairs(items) do
        -- _error("index:" .. tostring(itemIndex))
        self.items[itemIndex].selected = true
    end
end

function this:deselectItems(items)
    for k,itemIndex in pairs(items) do
        self.items[itemIndex].selected = false
    end
end

function this:selectedItems()
    local out = {}
    for k,item in pairs(self.items) do
        if(item.selected) then table.insert(out,k) end
    end
    return out;
end

function this:selectedItem()
    local out = self:selectedItems()
    if(#out == 1) then return out[1] else return {} end
end

function this:getItems()
    return self.items
end

function this:getItem(index)
    return self.items[index].text
end

function this:onMouseScroll(dir)
    if(dir == 1) then --down
        self:moveOffset(1)
    elseif(dir == -1) then
       self:moveOffset(-1)
    end
end

function this:addItem(text)
    table.insert(self.items,{text=text,selected=false})
end

function this:removeItems(list)
    if(#list == 0) then return end
    for i = #list,1,-1 do
        local index = list[i]
        self:removeItem(index)
    end
end

function this:clearItems()
    for i = #self.items,1,-1 do
        self:removeItem(i)
    end
end

function this:removeItem(index)
    table.remove(self.items,index)
end

function this:onMouseDown(x,y)
    self.super:onMouseDown(x,y)
    --test the AB of each item:
    local itemIndex = false
    for k,item in pairs(self.items) do
        local itemY = self:Y()+k-1
        --_error("test:" .. tostring(self:ABTest(x,y)) .. " and equality " .. tostring(y+self.offset) .. " == " .. tostring(itemY) .. " and " .. tostring(itemIndex) .. " == falsey")
        if(self:ABTest(x,y) and y+self.offset == itemY and not itemIndex) then
            itemIndex = k
        end
    end
    if(itemIndex) then
        if(not self.multiselect) then self:deselectAll(itemIndex) end
        self.items[itemIndex].selected = not self.items[itemIndex].selected
        if(self.onSelect and type(self.onSelect) == "function") then
            self.onSelect(self,itemIndex,self.items[itemIndex].selected)
        end
    end
end



function this:onKeyDown(k)
    if(keys.getName(k) == "down") then
        self:moveOffset(1)
    elseif(keys.getName(k) == "up") then
        self:moveOffset(-1)
    end
end

function this:onMouseUp()
    self.clicked = false;
end

function this:draw()
    --self.window.redraw()
    local textc = ui.monitor().getTextColor()
    local backc = ui.monitor().getBackgroundColor()
    ui.monitor().setTextColor(self.color)
    ui.monitor().setBackgroundColor(self.color)
    
    for y = 1,self.height,1 do
        local item = self.items[self.offset+y]
        if(item and item.selected and self.color_selected) then
            ui.monitor().setBackgroundColor(self.color_selected)
        else
            ui.monitor().setBackgroundColor(self.color)
        end
        ui.monitor().setCursorPos(self:X(),self:Y()+y-1)
        ui.monitor().write(string.rep(" ",self.width))
    end
    for k = 1,self.height,1 do
        local item = self.items[self.offset+k]
        if(item) then
            if(item.selected and self.color_selected) then
                ui.monitor().setBackgroundColor(self.color_selected)
            else
                ui.monitor().setBackgroundColor(self.color)
            end
            if(item.selected and self.color_text_selected) then
                ui.monitor().setTextColor(self.color_text_selected)
            else
                ui.monitor().setTextColor(self.color_text)
            end
            ui.monitor().setCursorPos(self:X(),self:Y()+k-1)
            if(#item.text < self.width) then
                ui.monitor().write(string.sub(item.text,1,math.min(self.width-1,#item.text)))
            else
                local text = string.reverse(item.text)
                local text = string.sub(text,1,math.min(self.width-1,#text))
                ui.monitor().write(string.reverse(text))
            end
        end
    end
    ui.monitor().setTextColor(textc)
    ui.monitor().setBackgroundColor(backc)
end

function this:setZ(z)
    self.z =z
end

function this:ABTest(a,b)
    return (a >= self.x+self.parent.x and a <= self.x+self.parent.x+self.width-1 and b >= self.y+self.parent.y and b <= self.y+self.parent.y+self.height-1)
end


return this;