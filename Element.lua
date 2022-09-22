local this = newclass("UI.Element")

function this:init(options)
    self.parent = nil
    self.focused = false
    self.children = {}
    self.z = 0
    self.visible = true
    self.redirect = options.redirect or false;
    if(self.redirect) then
        self.redirect = peripheral.wrap(self.redirect)
    end
    self.focus_lock = false
    if options.x then
        self:setX(options.x)
    end
    if(options.width) then
        self:setWidth(options.width)
    end
    if(options.height) then
        self:setHeight(options.height)
    end
    if(options.y) then
        self:setY(options.y)
    end
end

function this:setFocusLock(to)
    self.focus_lock = to
end
this:virtual("setFocusLock")

function this:getWidth()
    if(self.parent) then
        return self.width or self.parent.width or 0
    else
        return self.width or 0
    end
end
this:virtual("getWidth")

function this:setWidth(w)
    self.width = w
end
this:virtual("setWidth")

function this:getHeight()
    return self.height
end
this:virtual("getHeight")


function this:setHeight(h)
    self.height = h
end
this:virtual("setHeight")


function this:getX()
    return self.x
end
this:virtual("getX")

function this:setX(x)
    self.x = x
end
this:virtual("setX")

function this:getY()
    return self.y
end
this:virtual("getY")


function this:setY(y)
    self.y = y
end
this:virtual("setY")


function this:setVisible(to)
    self.visible = to
end

function this:getVisible()
    return self.visible
end

function this:unlockFocus()
    ui.unlockFocus(self)
end
this:virtual("unlockFocus")


function this:lockFocus()
    ui.lockFocus(self)
end
this:virtual("lockFocus")


function this:dispose()
    for k,v in pairs(self.children) do
        if v.dispose then v:dispose() end
    end
    if(self.focus_lock) then
        self:unlockFocus()
    end
end
this:virtual("dispose")

function this:makeParent(of)
    assert(of ~= self,"cant parent to self")
    for k,v in pairs(self.children) do if v == of then error("Already parent of") end end
    table.insert(self.children,of)
    of:setParent(self);
    self:focusChild(of)
end
this:virtual("makeParent")

function this:X()
    if(self.parent) then
        return (self.x or 0) + self.parent:X()
    else return self.x or 0
    end
end
this:virtual("X")

function this:Y()
    if(self.parent) then
        return (self.y or 0) + self.parent:Y()
    else return self.y or 0
    end
end
this:virtual("Y")

function this:drawChildren()
    if not self.visible then return false end
    for k,child in pairs(self.children) do
        child:draw()
    end
end
this:virtual("drawChildren")

function this:onMouseDown(x,y)
    if not self.visible then return end
    local hit = false
    local index = false
    for k,element in pairs(self.children) do
        if(element) then
            if(element:ABTest(x,y) and hit == false) then
                hit = true
                index = k
            end
        end
    end
    if(hit) then
        element = self.children[index]
        self:focusChild(element,c)
        if(element.onMouseDown) then
            element:onMouseDown(x, y)
        end
    end
    return hit
end
-- this:virtual("onMouseDown")

function this:setZ(z)
    self.z = z
end
this:virtual("setZ")

function this:setParent(to)
    self.parent = to
    self.z = self.parent.z+1
end
this:virtual("setParent")

function this:focusChild(element,c)
    if(#self.children > 0) then
        local old = self.children[1];
        if(old.focusLost) then
            old:focusLost()
        end
    end
    local index = -1
    for k,v in pairs(self.children) do
        if v == element then index = k end
    end
    local e = table.remove(self.children,index)
    table.insert(self.children,1,e);
    for k,v in pairs(self.children) do
        if(v.setZ) then
            v:setZ(k+self.z)
        end
    end
    if(element.onFocus) then
        element:onFocus()
    end
    if(c) then
        _error(tostring(e))
    end
end
this:virtual("focusChild")


function this:ABTest(a,b)
    _error("Elements must define their own ABTest() methods")
    if not self.visible then return false end
end

return this