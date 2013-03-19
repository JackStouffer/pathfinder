--------------------------------------------------------------------------------------------------------------------
--[[
    LuAstar - Pathfinding A-Star Library For Lua
    Copyright (C) 2011.
    Written by Roland Yonaba - E-mail: roland[dot]yonaba[at]gmail[dot]com
    Version 2
--]]
--------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------
--                                               INTERNAL NODE CLASS                                              --
--------------------------------------------------------------------------------------------------------------------
-- Internal Node class
local Node = {}
setmetatable(Node,{__call = function(self,...) return self:new(...) end})
Node.__index = Node

-- Set of arithmetic methamethods to enable the use of operators.
function Node.__eq (a,b)  -- Comparison of Nodes: Node1 == Node2 ?
    return ((a.x == b.x) and (a.y == b.y))
end

function Node.__lt(a,b) -- Comparison of Nodes: Node1 < Node2 ?
    return a.G < b.G
end

function Node.__le(a,b) -- Comparison of Nodes: Node1 <= Node2 ?
    return a.G <= b.G
end

-- Node constructor
function Node:new(x,y,G,H,F,parent)
    local node = {x = x, y = y, F = F or 0, G = G or 0, H = H or 0, parent = parent or {}}
    return setmetatable(node,Node)
end

-- Checks if a node is in a domain
function Node:inBound(domain)
    return ((self.x > 0 and self.x <= #domain[(next(domain))]) and (self.y > 0 and self.y <= #domain))
end

-- Computes the distance from self node to another node
-- Uses custom heuristic to speed up the process.
function Node:getDistanceTo(node)
    return (10*(1+math.abs(self.x-node.x))+10*(1+math.abs(self.y-node.y)))
end

-- Computes the self node G,H,F costs
function Node:computeHeuristicsTo(node,final)
    local cost = 10 
        if (self.x ~= node.x and self.y ~= node.y) then 
        cost = 15
        end
    self.G = cost + node.G
    self.H = self:getDistanceTo(final)
    self.F = self.G + self.H
    self.parent = node
end

--------------------------------------------------------------------------------------------------------------------
--                                               INTERNAL FUNCTIONS SET                                           --
--------------------------------------------------------------------------------------------------------------------

-- Internal function for searching a Node in a list of nodes.
local function isListed(list,node)
    for k,v in pairs(list) do
        if v == node then return true,k end
    end
return false,nil
end

-- Internal fonction which checks new nodes to study around self node.
-- Adjacent moves are optional
local function addNode(self)
    local lowerCostNode = self.currentNode  -- We refer to the current node as the lowerCostOne
    for y = self.currentNode.y-1,self.currentNode.y+1,1 do
        if (y>=1) and (y<=self.mapSizeY) then
            for x=self.currentNode.x-1,self.currentNode.x+1,1 do
                if (x>=1) and (x<=self.mapSizeX) then
                local left,right = false,false
                    if not self.diagonalMove then  -- Diagonal Moves, optional!
                    left = (y==self.currentNode.y-1) and ((x==self.currentNode.x-1) or (x==self.currentNode.x+1))
                    right = (y==self.currentNode.y+1) and ((x==self.currentNode.x-1) or (x==self.currentNode.x+1))
                    end
                    if not left and not right then
                    --Computes a node to study
                    local tmpNode = Node(x,y)
                        if self:isWalkable(tmpNode) then
                        tmpNode:computeHeuristicsTo(self.currentNode,self.finalNode)
                        --We do not consider nodes already stored Closed List
                        local enclosed = isListed(self.cList,tmpNode)
                            if not enclosed then
                            --We update if necessay nodes already stored in Open List
                            local opened,pos = isListed(self.oList,tmpNode)
                                if opened then
                                    if (tmpNode < self.oList[pos]) then
                                    self.oList[pos] = tmpNode
                                    end
                                else
                            --else we add the studied node in OpenList
                                    if tmpNode <= lowerCostNode  then
                                    lowerCostNode = tmpNode   
                                    table.insert(self.oList,1,tmpNode) --The lowercost node is always at #1 in the OpenList
                                    else
                                    table.insert(self.oList,tmpNode)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Looks for a new walkable destination in the search area around the finalNode
local function getNewFreeNode(self,node)
    local depth = 0
    
    repeat
    depth = depth+1
        local y,x
        y = node.y-depth
            for x = node.x-depth,node.x+depth do
                local tmpNode = Node(x,y)
                if tmpNode:inBound(self.map) and self:isWalkable(tmpNode) then return tmpNode end
            end
        y=node.y+depth
            for x = node.x-depth,node.x+depth do
                local tmpNode = Node(x,y)
                if tmpNode:inBound(self.map) and self:isWalkable(tmpNode) then return tmpNode end
            end
        x = node.x-depth
            for y = node.y-depth,node.y+depth do
                local tmpNode = Node(x,y)
                if tmpNode:inBound(self.map) and self:isWalkable(tmpNode) then return tmpNode end
            end
        x=node.x+depth
            for y = node.y-depth,node.y+depth do
                local tmpNode = Node(x,y)
                if tmpNode:inBound(self.map) and self:isWalkable(tmpNode) then return tmpNode end
            end 
    until (depth == self.searchDepth)
    
    return nil
end

-- Computes a path from initial to final nodes
-- Returns the path as a table of nodes
local function computePath(self)
        if not self.initialNode or not self.finalNode then
        error('Set initial and final locations first!',2)
        end
    self.path={}
    self.currentNode = Node (self.initialNode.x,self.initialNode.y,0,0,0,Node(self.initialNode.x,self.initialNode.y))
    self.cList = {}
    self.oList = {}
    table.insert(self.cList,self.currentNode)
        if self.finalNode == self.initialNode then
        self.path = self.cList
        return
        end
        
        repeat
        addNode(self)
        local bestPos = next(self.oList)
            if bestPos then
            self.currentNode = self.oList[bestPos]
            table.remove(self.oList,bestPos)
            table.insert(self.cList,self.currentNode)
            else self.cList = nil
                break
            end
        until (self.currentNode == self.finalNode)

    self.path = self.cList

end

--------------------------------------------------------------------------------------------------------------------
--                                                      ASTAR CLASS                                               --
--------------------------------------------------------------------------------------------------------------------

-- The Astar class
local Astar = {}
setmetatable(Astar, {__call = function(self,...) return self:init(...) end})
Astar.__index = Astar

-- Loads the map, sets the unwalkable value, inits pathfinding
function Astar:init(map,obstvalue)
    self.map = map
    self.OBST_VALUE = obstvalue or 1
    self.cList = {}
    self.oList = {}
    self.initialNode = false
    self.finalNode = false
    self.currentNode = false
    self.path = {}
    self.mapSizeX = #self.map[1]
    self.mapSizeY = #self.map
    self.diagonalMove = false
    self.searchDepth = 0
end

-- Sets the unwalkable value
function Astar:setObstValue(value)  self.OBST_VALUE = value end

-- Returns the unwalkable value
function Astar:getObstValue() return self.OBST_VALUE end

-- Enables diagonal moves
function Astar:enableDiagonalMove() self.diagonalMove = true end

-- Disables diagonal moves
function Astar:disableDiagonalMove() self.diagonalMove = false end

-- Sets the search area depth
function Astar:setSearchDepth(value)
    if math.abs(value) >= math.min(self.mapSizeX,self.mapSizeY) then
        error ('Depth '..math.abs(value)..' should be lower than '..math.min(mapSizeX,mapSizeY))
    else
    self.searchDepth = math.abs(value)
    end
end

-- Returns the search area depth
function Astar:getSearchDepth() return self.searchDepth end

-- Sets the initial node
function Astar:setInitialNode (x,y)
    local node = Node(x,y)
    if not node:inBound(self.map) or not self:isWalkable(node) then
    error ('Location ('..node.x..','..node.y..') is unwalkable or not valid!',2)
    end
    self.initialNode = node
end

-- Returns initial Node x,y values or false
function Astar:getInitialNode() 
    if self.initialNode then return self.initialNode.x,self.initialNode.y end
    return false
end

-- Sets the final node
function Astar:setFinalNode (x,y)
    local node = Node(x,y)
        if not node:inBound(self.map) then
        error ('Location ('..node.x..','..node.y..') is out of the map!',2)
        end
        if not self:isWalkable(node) then
            if self:getSearchDepth() > 0 then
            local newLocation = getNewFreeNode(self,node)
                if not newLocation then
                error ('No walkable location found in the search area around Location ('..node.x..','..node.y..') !',2)
                else 
                self.finalNode = newLocation
                end
            else        
                error ('Location ('..node.x..','..node.y..') is unwalkable!',2) 
            end
        else
        self.finalNode = node
        end
end

-- Returns final Node x,y values or false
function Astar:getFinalNode() 
    if self.finalNode then return self.finalNode.x,self.finalNode.y end
    return false
end

-- Checks if a node is walkable
function Astar:isWalkable(node)
    -- for table_value = 1, #self.OBST_VALUE do
    --     print(self.OBST_VALUE[table_value])
    --     if self.map[node.y][node.x] == self.OBST_VALUE[table_value] then
    --         return false
    --     end
    -- end
    return not (self.map[node.y][node.x] == self.OBST_VALUE)
end

-- Returns the reordered path from the starting node to the final node
-- As a list of nodes
function Astar:getPath()
    computePath(self)
    if self.path then
        if #self.path == 0 then
            error ('Path was not found!',2)
        end
    local way={}
    local nxt=Node(self.finalNode.x,self.finalNode.y)
    table.insert(way,1,nxt)
    nxt=self.path[#self.path].parent
    table.insert(way,1,nxt)
    -- Tracing backward the computed path to the starting node
        repeat
        local bool,pos = isListed(self.path,nxt)
            if bool then
            nxt = self.path[pos].parent
            table.insert(way,1,nxt)
            end
        until (nxt == self.initialNode)
        
        return way
    else
        return nil
    end
end

-- Resets Astar parameters
-- Ready to compute a new path on the same map
function Astar:reset(obstvalue)
    self.OBST_VALUE = obstvalue or 1
    self.cList = {}
    self.oList = {}
    self.initialNode = false
    self.finalNode = false
    self.currentNode = false
    self.path = {}
end

return Astar