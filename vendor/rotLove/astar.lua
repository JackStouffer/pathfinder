local AStar_PATH=({...})[1]:gsub("[%.\\/]astar$", "") .. '/'
local class  =require (AStar_PATH .. 'vendor/30log')

local AStar=ROT.Path:extends { _toX, _toY, _fromX, _fromY, _done, _todo, _passableCallback, _options }

function AStar:__init(toX, toY, passableCallback, options)
    AStar.super.__init(self, toX, toY, passableCallback, options)
    self._todo={}
    self._done={}
    self._fromX=nil
    self._fromY=nil
end

function AStar:compute(fromX, fromY, callback)
    self._todo={}
    self._done={}
    self._fromX=fromX
    self._fromY=fromY
    self:_add(self._toX, self._toY, nil)

    while #self._todo>0 do
        local item=table.remove(self._todo, 1)
        if item.x == fromX and item.y == fromY then break end
        local neighbors=self:_getNeighbors(item.x, item.y)

        for i=1,#neighbors do
            local neighbor=neighbors[i]
            local x = neighbor[1]
            local y = neighbor[2]
            local id=x..','..y
            if not self._done[id] then
                self:_add(x, y, item)
            end
        end
    end

    local item=self._done[fromX..','..fromY]
    if not item then return end

    while item do
        callback(tonumber(item.x), tonumber(item.y))
        item=item.prev
    end
end

function AStar:_add(x, y, prev)
    local obj={}
    obj.x   =x
    obj.y   =y
    obj.prev=prev
    obj.g   =prev and prev.g+1 or 0
    obj.h   =self:_distance(x, y)
    self._done[x..','..y]=obj

    local f=obj.g+obj.h

    for i=1,#self._todo do
        local item=self._todo[i]
        if f<item.g+item.h then
            table.insert(self._todo, i, obj)
            return
        end
    end

    table.insert(self._todo, obj)
end

function AStar:_distance(x, y)
    if self._options.topology==4 then
        return math.abs(x-self._fromX)+math.abs(y-self._fromY)
    elseif self._options.topology==8 then
        return math.max(math.abs(x-self._fromX), math.abs(y-self._fromY))
    end
end

return AStar
