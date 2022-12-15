using HorizonSideRobots

include("39.jl")
r=Robot("38.sit", animate=true)
r=AreaRobot(r, Coordinates(0,0), Area(0))
# r=PutmarkersRobot(r)
# Numsix!(r, 1)
# get_home!(r)
Num3839(r)
print(r.s)