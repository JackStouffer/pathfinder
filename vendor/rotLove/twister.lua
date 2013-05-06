local Twister_PATH =({...})[1]:gsub("[%.\\/]twister$", "") .. '/'
local class  =require (Twister_PATH .. 'vendor/30log')

local Twister=ROT.RNG:extends { __name, mt, index, _seed }

function Twister:__init()
	self.__name='Twister'
    self.mt={}
    self.index=0
end

function Twister:randomseed(s)
    if not s then s = self:seed() end
    self._seed=s
    self.mt[0] = self:normalize(s)
    for i = 1, 623 do
        self.mt[i] = self:normalize(0x6c078965 * self:bit_xor(self.mt[i-1], math.floor(self.mt[i-1] / 0x40000000)) + i)
    end
end

function Twister:random(a, b)
    local y
    if self.index == 0 then
        for i = 0, 623 do
            --y = bit_or(math.floor(self.mt[i] / 0x80000000) * 0x80000000, self.mt[(i + 1) % 624] % 0x80000000)
            y = self.mt[(i + 1) % 624] % 0x80000000
            self.mt[i] = self:bit_xor(self.mt[(i + 397) % 624], math.floor(y / 2))
            if y % 2 ~= 0 then self.mt[i] = self:bit_xor(self.mt[i], 0x9908b0df) end
        end
    end
    y = self.mt[self.index]
    y = self:bit_xor(y, math.floor(y / 0x800))
    y = self:bit_xor(y, self:bit_and(self:normalize(y * 0x80), 0x9d2c5680))
    y = self:bit_xor(y, self:bit_and(self:normalize(y * 0x8000), 0xefc60000))
    y = self:bit_xor(y, math.floor(y / 0x40000))
    self.index = (self.index + 1) % 624
    if not a then return y / 0x80000000
    elseif not b then
        if a == 0 then return y
        else return 1 + (y % a)
        end
    else
        return a + (y % (b - a + 1))
    end
end

function Twister:getState()
	local newmt={}
	for i=0,623 do
		newmt[i]=self.mt[i]
	end
    return { mt=newmt, index=self.index, _seed=self._seed}
end

function Twister:setState(stateTable)
    assert(stateTable.mt, 'bad state table: need stateTable.mt')
    assert(stateTable.index, 'bad state table: need stateTable.index')
    assert(stateTable._seed, 'bad state table: need stateTable._seed')

    self.mt=stateTable.mt
    self.index=stateTable.index
    self._seed=stateTable._seed
end

return Twister
