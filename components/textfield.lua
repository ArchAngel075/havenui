local textfield = newclass("UI.TextField",ui.classes["UI.Element"])

function textfield:init(options)
    --x,y,width,height,color
    self.super:init(options)
    self.color = options.color
    self.text_color = options.text_color
    self.color_clicked = options.color_clicked
    self.text = options.text
    self.clicked = false
    self.charat = 0;
    self.mask_start = 1;
    self.mask_end = self.width-1
    self.current_prediction = false
    self.prediction_index = 1
    self.predictions = {}
    self.prediction_options = options.predictions or {}
    self.timer = false
    self.isWarning = false
end

function textfield:warn(t)
    if(self.timer) then ui.removeTimer(self.timer); self.timer = false end
    self.timer = ui.timer(t or 15,function() self.timer = false; self.isWarning = false end)
    self.isWarning = true;
end

function textfield:cancelWarn()
    if(self.isWarning or self.timer) then
        self.isWarning = false
        if(self.timer) then
            ui.removeTimer(self.timer)
        end
    end
end

function textfield:onKeyDown(k,shifted,ctrl)
    local char,backspace = ui.parseKey(k,shifted)
    if(char) then
        if(char == "left") then
            self:charatBackwards()
        elseif(char == "right") then
            self:charatForwards()
        elseif(keys.getName(k) == "up") then
            self:prevPrediction()
        elseif(keys.getName(k) == "down") then
            self:nextPrediction()
        else
            self:setText(string.sub(self.text,1,self.charat) .. char .. string.sub(self.text,self.charat+1))
            self:charatForwards(#char)
        end
    elseif(backspace and #self.text > 0 and self.charat > 1) then
        self:charatBackwards()
        self:setText(string.sub(self.text,1,self.charat) .. string.sub(self.text,self.charat+2))
    elseif(backspace and #self.text > 0 and self.charat == 1) then
        self:setText(string.sub(self.text,1,self.charat-1) .. string.sub(self.text,self.charat+1))
        self:charatForwards(0)
    elseif(keys.getName(k) == "enter" and self:currentPrediction()) then
        local prediction = self:currentPrediction();
        self:setText(string.sub(self.text,1,self.charat) .. prediction .. string.sub(self.text,self.charat+1))
        self:charatForwards(#prediction)
    end
end

function textfield:setText(to)
    self.text = to or "";
    self:makePredictions()
end

function textfield:makePredictions()
    self.predictions = {}
    if(#self.text > 3) then
        local options = self.prediction_options
        if(type(self.prediction_options) == "function") then
            options = self.prediction_options()
        end
        for k,v in pairs(options) do
            local occuranceFrom,occuranceTo = string.find(self.text,string.sub(v,1,#self.text),1,true);
            if(occuranceFrom) then
                local prediction = string.sub(v,occuranceTo+1);
                table.insert(self.predictions,prediction)
            end
        end
    end
    self.prediction_index = math.max(1,math.min(self.prediction_index,#self.predictions))
end

function textfield:currentPrediction()
    if(#self.predictions > 0) then
        return self.predictions[self.prediction_index]
    end
    return false
end

function textfield:nextPrediction()
   self.prediction_index = self.prediction_index + 1
   self.prediction_index = math.max(1,math.min(self.prediction_index,#self.predictions)) 
end

function textfield:prevPrediction()
   self.prediction_index = self.prediction_index - 1
   self.prediction_index = math.max(1,math.min(self.prediction_index,#self.predictions)) 
end

function textfield:charatForwards(by)
    for i = 1,(by or 1) do
        self.charat = math.min(self.charat+1,#self.text)
        if(self.charat > self.mask_end-1) then
            self.mask_end = self.mask_end + 1
            self.mask_start = self.mask_start + 1
        end
    end
end

function textfield:charatBackwards()
    self.charat = math.max(self.charat-1,1)
    if(self.charat < self.mask_start) then
        self.mask_start = self.mask_start - 1
        self.mask_end = self.mask_end - 1
    end
    self.mask_start = math.max(self.mask_start,0)
    self.mask_end = self.mask_start+self.width-1
end

function textfield:resetCharat()
    for i = 1,self.charat do
        self:charatBackwards()
    end
end

function textfield:getText()
    return self.text
end

function textfield:clearInput()
    self.text = ""
end

function textfield:setParent(to)
    self.parent = to
    self.z = self.parent.z+1
end

function textfield:onPaste(pasted)
    self.text = string.sub(self.text,1,self.charat) .. pasted .. string.sub(self.text,self.charat+1)
    self:charatForwards(#pasted)
end

function textfield:onMouseDown(x,y)
    local test = self:ABTest(x,y,self:X(),self:Y(),self.width-1,self.height-1)
    if test then
        --clicked inside the text field :
    end
    self.clicked = test;
end

function textfield:onMouseUp()
    self.clicked = false;
end

function textfield:getBackgroundColor()
    if(self.isWarning) then 
        return colors.red 
    elseif(self.clicked) then
        return self.color_clicked 
    else 
        return self.color 
    end
end

function textfield:onFocus()

end

function textfield:focusLost()
    self:resetCharat()
    self:warn(2)
end

function textfield:drawFocused()
    local textc = ui.monitor().getTextColor()
    local backc = ui.monitor().getBackgroundColor()
    ui.monitor().setTextColor(self.color)
    ui.monitor().setBackgroundColor(self:getBackgroundColor())

    ui.monitor().setCursorPos(self:X()+(self.charat +1 - self.mask_start ),self:Y())
    ui.monitor().setCursorBlink(true)
end

function textfield:draw()
    local textc = ui.monitor().getTextColor()
    local backc = ui.monitor().getBackgroundColor()
    ui.monitor().setTextColor(self.color)
    ui.monitor().setBackgroundColor(self:getBackgroundColor())
    
    for y = 0,self.height-1 do
        ui.monitor().setCursorPos(self:X(),self:Y()+y)
        ui.monitor().write(string.rep(" ",self.width))
    end

    ui.monitor().setTextColor(self.text_color)
    ui.monitor().setCursorPos(self:X() ,self:Y())
    local text = string.sub(self.text,self.mask_start,self.mask_end)
    local predicted = self:currentPrediction()
    
    ui.monitor().write(text)

    if(predicted and #self.text < self.width) then
        ui.monitor().setCursorPos(self:X()+#self.text ,self:Y())
        ui.monitor().setTextColor(colors.lightGray)
        ui.monitor().setBackgroundColor(colors.gray)
        ui.monitor().write(string.sub(predicted,1,math.min(#self.text+#predicted,self.width-#self.text)))
    end
    --ui.monitor().setCursorPos(self:X() ,self:Y()+1)
    --ui.monitor().write("[" .. tostring(self.charat) .. "," .. tostring(self.mask_start) .. "," .. tostring(self.mask_end) .. "," .. tostring(#self.text) .. "] " .. tostring(self.mask_end - self.mask_start))

    ui.monitor().setTextColor(textc)
    ui.monitor().setBackgroundColor(backc)
end

function textfield:setZ(z)
    self.z =z
end

function textfield:ABTest(a,b)
    return (a >= self:X() and a <= self:X()+self.width-1 and b >= self:Y() and b <= self:Y()+self.height-1)
end


return textfield;