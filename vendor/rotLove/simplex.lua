local Simplex_PATH =({...})[1]:gsub("[%.\\/]simplex$", "") .. '/'
local class  =require (Simplex_PATH .. 'vendor/30log')

local Simplex=ROT.Noise:extends{ __name, _F2, _G2, _gradients, _perms, _indexes }

function Simplex:__init(gradients)
    self.__name='Simplex'
    Simplex.super.__init(self)

    self._F2=.5*(math.sqrt(3)-1)
    self._G2=(3-math.sqrt(3))/6

    self._gradients={
                     { 0,-1},
                     { 1,-1},
                     { 1, 0},
                     { 1, 1},
                     { 0, 1},
                     {-1, 1},
                     {-1, 0},
                     {-1,-1}
                    }
    local permutations={}
    local count       =gradients and gradients or 256
    for i=1,count do
        table.insert(permutations, i)
    end

    permutations=table.randomize(permutations)

    self._perms  ={}
    self._indexes={}

    for i=1,2*count do
        table.insert(self._perms, permutations[i%count+1])
        table.insert(self._indexes, self._perms[i] % #self._gradients +1)
    end
end

function Simplex:get(xin, yin)
    local perms  =self._perms
    local indexes=self._indexes
    local count  =#perms/2
    local G2     =self._G2

    local n0, n1, n2, gi=0, 0, 0

    local s =(xin+yin)*self._F2
    local i =math.floor(xin+s)
    local j =math.floor(yin+s)
    local t =(i+j)*G2
    local X0=i-t
    local Y0=j-t
    local x0=xin-X0
    local y0=yin-Y0

    local i1, j1
    if x0>y0 then
        i1=1
        j1=0
    else
        i1=0
        j1=1
    end

    local x1=x0-i1+G2
    local y1=y0-j1+G2
    local x2=x0-1+2*G2
    local y2=y0-1+2*G2

    local ii=i%count+1
    local jj=j%count+1

    local t0=.5- x0*x0 - y0*y0
    if t0>=0 then
        t0=t0*t0
        gi=indexes[ii+perms[jj]]
        local grad=self._gradients[gi]
        n0=t0*t0*(grad[1]*x0+grad[2]*y0)
    end

    local t1=.5- x1*x1 - y1*y1
    if t1>=0 then
        t1=t1*t1
        gi=indexes[ii+i1+perms[jj+j1]]
        local grad=self._gradients[gi]
        n1=t1*t1*(grad[1]*x1+grad[2]*y1)
    end

    local t2=.5- x2*x2 - y2*y2
    if t2>=0 then
        t2=t2*t2
        gi=indexes[ii+1+perms[jj+1]]
        local grad=self._gradients[gi]
        n2=t2*t2*(grad[1]*x2+grad[2]*y2)
    end
    return 70*(n0+n1+n2)
end

return Simplex
