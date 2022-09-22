_ui_ = require("ui")
local frame = _ui_.classes["UI.Frame"]({
    x = 2,y=2,
    width = 20,height = 6,
    color = colors.lightGray,
    titleBar = _ui_.classes["UI.TitleBar"]({
        text = "Title Bar 1",
        color = colors.blue,
        text_color = colors.white
    })
})

local button = _ui_.classes["UI.Button"]({
    x = 2,y=2,
    width = 8,height = 1,
    color = colors.red,
    color_clicked = colors.green,
    text = "button 1",
    text_color = colors.white
})
frame:makeParent(button)

--table.insert(frame.children,button)

table.insert(_ui_.elements,frame)

_ui_.focus(frame)


local frame2 = _ui_.classes["UI.Frame"]({
    x = 2+21,y=2,
    width = 20,height = 17,
    color = colors.lightGray,
    titleBar = _ui_.classes["UI.TitleBar"]({
        text = "Title Bar 2",
        color = colors.blue,
        text_color = colors.white
    })
})

local button2 = _ui_.classes["UI.Button"]({
    x = 2,y=2,
    width = 8,height = 1,
    color = colors.red,
    color_clicked = colors.green,
    text = "button 2",
    text_color = colors.white
})
frame2:makeParent(button2)

local textfield = _ui_.classes["UI.TextField"]({
    x = 2,y=4,
    width = 12,height = 1,
    color = colors.red,
    color_clicked = colors.green,
    text = "",
    text_color = colors.white
})
frame2:makeParent(textfield)

local list = _ui_.classes["UI.List"]({
    x = 2,y=6,
    width = 12,height = 8,
    color = colors.gray,
    color_selected = colors.blue,
    color_text_selected = colors.white,
    color_text = colors.white
})
for i = 1,7 do
    list:addItem("item #" .. tostring(i))
end
frame2:makeParent(list)
button2:setOnClick(function()
    local text = textfield:getInput()
    if(#text > 0) then
        list:addItem(text)
        textfield:clearInput()
    end
end)

--table.insert(frame2.children,button2)

table.insert(_ui_.elements,frame2)

_ui_.focus(frame2)

_ui_.run()