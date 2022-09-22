local this = newclass("UI.Table",ui.classes["UI.Element"])
local _label = "UI.Label"
local _List = "UI.List"

function this:init(options)
    --x,y,width,height,color
    self.super:init(options)
    self.color = options.color
    self.color_text_selected = options.color_text_selected
    self.color_selected = options.color_selected
    self.color_text = options.color_text
    self.width = options.width
    self.height = options.height
    self.offset = 0
    self.multiselect = options.multiselect or false
    self.onSelect = function() end
    self.columns = {}
    self:setWidth(0)
    local accumulatedX = -1
    local first = true
    local table = self;
    for columnID,column in pairs(options.columns) do
        if(not first) then
            self:setWidth(self:getWidth()+1)
        end
        local list = ui.classes["UI.List"]({
            x=accumulatedX,y=1,
            width = column.width,height = self.height,
            color = self.color,
            color_selected = self.color_selected,
            color_text_selected = self.color_text_selected,
            color_text = self.color_text
        })

        list:setOnSelect(function(origin,index,selected) table:InternalOnSelect(columnID,index,selected); end)

        label = ui.classes["UI.Label"]({
            x = accumulatedX,y=0,
            width = column.width,
            color = colors.blue,
            color_selected = self.color_selected,
            color_text_selected = self.color_text_selected,
            text_color = self.color_text,
            text = column.name,
        });

        accumulatedX = accumulatedX + column.width+1
        self:makeParent(list)
        self:makeParent(label)
        self.columns[columnID] = {element=list,displayName=column.name, header=label}
        self:setWidth(self:getWidth()+column.width)
        first = false
    end
end

function this:rawitems()
    for k,v in pairs(self.columns) do return v.items end
end

function this:InternalOnSelect(origin,index,state)
    -- _error("origin.." .. tostring(origin) .. ". index.." .. tostring(index) .. ". state.." .. tostring(state))
    for columnID,column in pairs(self.columns) do
        column.element:deselectAll()
        if(state) then
            column.element:selectItems({index})
        else
            column.element:deselectItems({index})
        end
    end
    if(self.onSelect and type(self.onSelect) == "function") then
        self.onSelect(self,origin,index,state)
    end
end

function this:setOnSelect(to)
    self.onSelect = to
end

function this:deselectAll()
    for columnID,column in pairs(self.columns) do
        column.element:deselectAll()
    end
end

function this:resolveItem(index)
    for columnID,column in pairs(self.columns) do
        return column.element:resolveItem(index)
    end
    return false
end

function this:selectedItems()
    for columnID,column in pairs(self.columns) do
        return column.element:selectedItems()
    end
    return {}
end

function this:selectedItem()
    local out = self:selectedItems()
    return out[1] or {}
end

function this:items()
    local items = {}
    for columnID,column in pairs(self.columns) do
        for index,item in pairs(column.element.items) do
            items[index] = items[index] or {}
            items[index][columnID] = item.text
        end
    end
    return items
end

function this:addItem(item)
    for columnID,column in pairs(self.columns) do
        column.element:addItem(tostring(item[columnID]))
    end
end

function this:removeItems(list)
    if(#list == 0) then return end
    for i = #list,1,-1 do
        local index = list[i]
        for columnID,column in pairs(self.columns) do
            column.element:removeItem(index)
        end
    end
end

function this:clearItems()
    for i = #self:items(),1,-1 do
        self:removeItem(i)
    end
end

function this:removeItem(index)
    for columnID,column in pairs(self.columns) do
        column.element:removeItem(index)
    end
end

function this:onMouseDown(x,y)
    self.super:onMouseDown(x,y)
    --test the AB of each item:
    -- local itemIndex = false
    -- for k,item in pairs(self.items) do
    --     local itemY = self:Y()+k-1
    --     --_error("test:" .. tostring(self:ABTest(x,y)) .. " and equality " .. tostring(y+self.offset) .. " == " .. tostring(itemY) .. " and " .. tostring(itemIndex) .. " == falsey")
    --     if(self:ABTest(x,y) and y+self.offset == itemY and not itemIndex) then
    --         itemIndex = k
    --     end
    -- end
    -- if(itemIndex) then
    --     if(not self.multiselect) then self:deselectAll(itemIndex) end
    --     self.items[itemIndex].selected = not self.items[itemIndex].selected
    --     if(self.onSelect and type(self.onSelect) == "function") then
    --         self.onSelect(self,itemIndex,self.items[itemIndex].selected)
    --     end
    -- end
end

function this:onMouseScroll(dir)
    if(dir == 1) then --down
        for k,v in pairs(self.columns) do
            v.element:moveOffset(1)
        end
    elseif(dir == -1) then
        for k,v in pairs(self.columns) do
            v.element:moveOffset(-1)
        end
    end
end

function this:getColumn(columnID)
    return this.columns[columnID]
end

function this:onKeyDown(k)
    --_error(tostring(self))
    if(keys.getName(k) == "down") then
        for k,v in pairs(self.columns) do
            v.element:moveOffset(1)
        end
        --self.offset = math.min(self.offset + 1,math.ceil(#self.items-self.height/2))
    elseif(keys.getName(k) == "up") then
        for k,v in pairs(self.columns) do
            v.element:moveOffset(-1)
        end
        --self.offset = math.min(self.offset + 1,math.ceil(#self.items-self.height/2))
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
    for y = 0,self.height do
        ui.monitor().setBackgroundColor(self.color)
        ui.monitor().setCursorPos(self:X(),self:Y()+y)
        ui.monitor().write(string.rep(" ",self.width))
    end
    self:drawChildren() --draw columns now
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