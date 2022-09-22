ui = {focused = false}
require("/ui/yaci")
ui.classes = {}
ui.elements = {}
ui._monitor = false
ui.monitor_touched = {}
ui.timers = {}

function ui.debug(x,y,write,t)
    local mon = peripheral.wrap("top")
    mon.clear()
    mon.setCursorPos(x or 1,y or 1)
    mon.write(write or math.random(1,100))
    os.sleep(t or 0.001)
end

function ui.timer(time,callback)
    local timer = {time=time,call=callback}
    table.insert(ui.timers,timer)
    return timer;
end

function ui.removeTimer(timer)
    for k,v in pairs(ui.timers) do
        if v == timer then table.remove(ui.timers,k); return end
    end
end

function ui.monitor()
    if(#ui.elements > 0) then
        local element = ui.elements[1]
        if(element.redirect) then return element.redirect end
    end
    if ui._monitor then return ui._monitor else return term end
end

term.clear()
term.setCursorPos(1,1)
term.clear()
local req = require("/ui/Element")
ui.classes[req:name()] = req;
print("registered component" .. req:name())

for k,f in pairs(fs.list("ui/components/")) do
    print(k,f)
    local req = require("/ui/components/" .. string.sub(f,0,#f-#".lua"))
    ui.classes[req:name()] = req;
    print("registered component" .. req:name())
end
os.sleep(1)

function ui.simpleABTest(a,b,x,y,width,height,crash)
    local test = (a >= x and a <= x+width and b >= y and b <= y+height)
    if(crash) then
        error("test if " .. tostring(a) .. ">=" ..tostring(x) .. " & " .. tostring(a) .. "<=" .. tostring(x+width) .. " && " .. tostring(b) .. ">=" ..tostring(y) .. " & " .. tostring(b) .. "<=" .. tostring(y+height))
    end
    return test
end

function _error(event)
    ui.monitor().clear()
    ui.monitor().setCursorPos(1,1)
    ui.monitor().setTextColor(colors.white)
    ui.monitor().setBackgroundColor(colors.black)
    error(event)

end

function ui.focus(element)
    if(ui.focus_locked_to and ui.focus_locked_to ~= element) then return end
    local index = -1
    for k,v in pairs(ui.elements) do
        if v == element then index = k end
    end
    local e = table.remove(ui.elements,index)
    table.insert(ui.elements,1,e);
    for k,v in pairs(ui.elements) do
        v:setZ(k)
    end
end

function ui.reorder()
    local next = {}
    for k,v in pairs(ui.elements) do
        table.insert(next,v)
    end
    --table.sort(next, function(a,b) return a.z > b.z end)
    ui.elements = next;
end

function ui.lockFocus(on)
    ui.focus(on)
    on:setFocusLock(true)
    ui.focus_locked_to = on;
end

function ui.unlockFocus(permit)
    if(ui.focus_locked_to and ui.focus_locked_to == permit) then
        ui.focus_locked_to:setFocusLock(false)
        ui.focus_locked_to = false
    else
        _error("unable to unlock")
    end
end

function ui.on(event)
    if(event[1] == "mouse_click" or event[1] == "monitor_touch") then
        if(event[1] == "monitor_touch") then
            ui.mouse_click = {event[3], event[4]}
        else
            ui.mouse_click = {event[3], event[4]}
        end
        --table.sort(ui.elements, function(a,b) return a.z > b.z end)
        local hit = false
        local index = false
        for k,element in pairs(ui.elements) do
            if(element.visible and element.onMouseDown) then
                if(element:ABTest(ui.mouse_click[1],ui.mouse_click[2]) and hit == false) then
                    hit = true
                    index = k
                end
            end
        end
        if(hit) then
            if(ui.elements[1] ~= element) then
                if(ui.elements[1].redirect) then ui.elements[1].redirect:clear() end
            end
            element = ui.elements[index]
            if((ui.focus_locked_to and ui.focus_locked_to == element) or not ui.focus_locked_to) then
                ui.focus(element)
                element:onMouseDown(event[3], event[4])
                if(event[1] == "monitor_touch") then
                    table.insert(ui.monitor_touched, {time=5,element = element})
                end
            end
        end
    elseif(event[1] == "mouse_up") then
        --table.sort(ui.elements, function(a,b) return a.z > b.z end)
        for k,element in pairs(ui.elements) do
            if(element.visible and element.onMouseUp) then
                element:onMouseUp()
                ui.mouse_click = false
            end
        end
    elseif(event[1] == "mouse_drag") then
        --table.sort(ui.elements, function(a,b) return a.z > b.z end)
        for k,element in pairs(ui.elements) do
            if(element.visible and element.onMouseDrag) then
                element:onMouseDrag(ui.mouse_click[1]-event[3],ui.mouse_click[2]-event[4])
                ui.mouse_click = {event[3],event[4]}
            end
        end
    elseif(event[1] == "key") then
        local list = {
            "leftShift", "rightShift"
        }
        if(_oneOf(keys.getName(event[2]),list) ) then
            ui.shiftKey = true
        end
        local list = {
            "leftCtrl", "rightCtrl"
        }
        if(_oneOf(keys.getName(event[2]),list) ) then
            ui.ctrlKey = true
        end
        --table.sort(ui.elements, function(a,b) return a.z > b.z end)
        --for k,element in pairs(ui.elements) do
        local element = ui.elements[1];
        if(element) then
            if(element.visible and element.onKeyDown) then
                element:onKeyDown(event[2],ui.shiftKey,ui.ctrlKey)
            end
        end
        --end
    elseif(event[1] == "mouse_scroll") then
        local element = ui.elements[1];
        if(element) then
            if(element.visible and element.onMouseScroll) then
                element:onMouseScroll(event[2])
            end
        end

    
    elseif(event[1] == "key_up") then
        local list = {
            "leftShift", "rightShift"
        }
        if(_oneOf(keys.getName(event[2]),list) ) then
            ui.shiftKey = false
        end
        local list = {
            "leftCtrl", "rightCtrl"
        }
        if(_oneOf(keys.getName(event[2]),list) ) then
            ui.ctrlKey = false
        end
        local element = ui.elements[1];
        if(element) then
            if(element.visible and element.onKeyUp) then
                element:onKeyUp(event[2],ui.shiftKey,ui.ctrlKey)
            end
        end
    elseif(event[1] == "paste") then
        local element = ui.elements[1];
        if(element) then
            if(element.visible and element.onPaste) then
                element:onPaste(event[2])
            end
        end
    else
        if(event[1] ~= "task_complete" and event[1] ~= "redstone" and event[1] ~= "monitor_touch" and event[1] ~= "char") then
            ui.debug(1,1,event[1] .."," ..tostring(event[2])..","..tostring(event[3])..","..tostring(event[4])..","..tostring(event[5]),3)
        end
    end
end

function ui.parseKey(k,shifted)
    local char = false
    local backspace = false
    if(keys.getName(k) == "space") then
        char = " "
    elseif(keys.getName(k) == "backspace") then
        backspace = true
        --self.text = string.sub(self.text,1,#self.text-1)
    else
        local list = {
            "leftCtrl", "rightCtrl", "leftShift", "rightShift",
            "leftAlt", "rightAlt", "enter", "escape", "capsLock", "backspace",
            "numPadEnter", "numLock","numPad0","numPad1","numPad2","numPad3","numPad4","numPad5","numPad6","numPad7","numPad8","numPad9",
            "leftSuper","rightSuper","delete"
        }
        if(not  _oneOf(keys.getName(k),list) ) then
            if(not shifted) then
                if(keys.getName(k) == "tab") then
                    char = "\t"
                elseif(keys.getName(k) == "minus" or keys.getName(k) == "numPadSubstract") then
                    char = "-"
                elseif(keys.getName(k) == "plus" or keys.getName(k) == "numPadAdd") then
                    char = "+"
                elseif(keys.getName(k) == "Multiply" or keys.getName(k) == "numPadMultiply") then
                    char = "*"
                elseif(keys.getName(k) == "slash" or keys.getName(k) == "numPadDivide") then
                    char = "/"
                elseif(keys.getName(k) == "backslash") then
                    char = "\\"
                elseif(keys.getName(k) == "semicolon") then
                    char = ";"
                elseif(keys.getName(k) == "equals") then
                    char = "="
                elseif(keys.getName(k) == "apostrophe") then
                    char = "'"
                elseif(keys.getName(k) == "period" or keys.getName(k) == "numPadDecimal") then
                    char = "."
                elseif(keys.getName(k) == "comma") then
                    char = ","
                elseif(keys.getName(k) == "leftBracket") then
                    char = "["
                elseif(keys.getName(k) == "rightBracket") then
                    char = "]"
                elseif(k >= 48 and k <= 57) then
                    char = tostring(k-48)
                else
                    char = keys.getName(k)
                end
            else
                if(keys.getName(k) == "minus") then
                    char = "_"
                elseif(keys.getName(k) == "semicolon") then
                    char = ":"
                elseif(keys.getName(k) == "leftBracket") then
                    char = "{"
                elseif(keys.getName(k) == "rightBracket") then
                    char = "}"
                elseif(keys.getName(k) == "equals") then
                    char = "+"
                elseif(keys.getName(k) == "slash") then
                    char = "?"
                elseif(keys.getName(k) == "backslash") then
                    char = "|"
                elseif(keys.getName(k) == "apostrophe") then
                    char = "\""
                elseif(keys.getName(k) == "period") then
                    char = ">"
                elseif(keys.getName(k) == "comma") then
                    char = "<"
                elseif(k >= 48 and k <= 57) then
                    local symbols = {")","!","@","#","$","%","^","&","*","("}
                    char = symbols[k-48+1]
                else
                    char = string.upper(keys.getName(k))
                end
            end
        else
            if(keys.getName(k) == "numPad0") then
                char = "0"
            elseif(keys.getName(k) == "numPad1") then
                char = "1"
            elseif(keys.getName(k) == "numPad2") then
                char = "2"
            elseif(keys.getName(k) == "numPad3") then
                char = "3"
            elseif(keys.getName(k) == "numPad4") then
                char = "4"
            elseif(keys.getName(k) == "numPad5") then
                char = "5"
            elseif(keys.getName(k) == "numPad6") then
                char = "6"
            elseif(keys.getName(k) == "numPad7") then
                char = "7"
            elseif(keys.getName(k) == "numPad8") then
                char = "8"
            elseif(keys.getName(k) == "numPad9") then
                char = "9"
            end
            --"numPad0","numPad1","numPad2","numPad3","numPad4","numPad5","numPad6","numPad7","numPad8","numPad9",
        end
    end
    return char,backspace
end

function _oneOf(this,of)
    for k,v in pairs(of) do
        if(v == this) then return true,k end
    end
    return false
end

function ui.update()
    for i = #ui.timers,1,-1 do
        local timer = ui.timers[i]
        timer.time = timer.time - 1
        if(timer.time <= 0) then
            timer.call()                
            table.remove(ui.timers,i)
        end
    end

    for i = #ui.monitor_touched,1,-1 do
        local v = ui.monitor_touched[i]
        v.time = v.time - 1
        if v.time <= 0 then
            v.element:onMouseUp()
            table.remove(ui.monitor_touched,i)
        end
    end
end

function ui.draw()
    --sort by Z
    --term.clear()
    --table.sort(ui.elements, function(a,b) return a.z < b.z end)
    for k = #ui.elements,1,-1 do
        local element = ui.elements[k]
        --_error(tostring(element) .. " has draw :" .. tostring(element.draw))
        if element.visible then
            element:draw()
        end
    end
end

function ui.run()
    ui.clock = os.startTimer(0.02)
    while true do
        local event = {os.pullEvent()}
        if(event[1] == "timer" and event[2] == ui.clock) then
            ui.update()
            ui.draw()
            ui.clock = os.startTimer(0.02)
        else
            if(event[1] ~= "timer") then
                ui.on(event)
            end
        end
    end
end










return ui