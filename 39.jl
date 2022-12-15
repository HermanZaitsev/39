using HorizonSideRobots

@enum Directions Left=0 Right=1

HSR = HorizonSideRobots

abstract type SimpleRobot end

mutable struct Coordinates
    x :: Int
    y :: Int
end

mutable struct Area
    s :: Int
end

mutable struct Direction
    d :: HorizonSide
end

struct CoordRobot <: SimpleRobot
    robot :: Robot
    coord :: Coordinates
end

struct AroundRobot{TypeRobot} <: SimpleRobot
    robot :: TypeRobot
    direction :: Direction
    coord :: Coordinates
    function AroundRobot{TypeRobot}(robot::TypeRobot, direction::HorizonSide,coord:: Coordinates = Coordinates(0,0)) where TypeRobot
		new(robot, Direction(direction), coord)
    end
end

struct AreaRobot <: SimpleRobot
    robot :: Robot
    coord :: Coordinates
    s :: Area
end

get_robot(robot :: SimpleRobot) = robot.robot
get_coord(robot :: SimpleRobot) = robot.coord

HorizonSideRobots.move!(robot :: SimpleRobot, side :: HorizonSide)=move!(get_robot(robot), side)
HorizonSideRobots.putmarker!(robot :: SimpleRobot)=putmarker!(robot.robot)
HorizonSideRobots.isborder(robot :: SimpleRobot,side)=isborder(robot.robot,side)
HorizonSideRobots.putmarker!(robot:: SimpleRobot)=putmarker!(get_robot(robot))
HorizonSideRobots.ismarker(robot :: SimpleRobot)=ismarker(robot.robot)

function HSR.move!(robot :: AroundRobot{SimpleRobot}, side :: HorizonSide)
    move!(robot.robot, side)
    robot.coord.x += (Int(side) % 2) * (-1)^(Int(side) % 3)
    robot.coord.y -= ((Int(side)+1) % 2) * (-1)^((Int(side)+1) % 3)   
end

function HSR.move!(robot :: AreaRobot, side :: HorizonSide)
    if check(robot)== true
        if side == Ost && isborder(robot, Nord)
        robot.s.s-=robot.coord.y+1
        elseif side == West && isborder(r, Sud)
        robot.s.s+=robot.coord.y
        end
    end
    robot.coord.x += (Int(side) % 2) * (-1)^(Int(side) % 3)
    robot.coord.y -= ((Int(side)+1) % 2) * (-1)^((Int(side)+1) % 3)  
    move!(robot.robot, side)
end

function check(robot)
    for i in 0:3
        if isborder(robot, HorizonSide(i))
            return true
        end
    end
    return false
end

function HorizonSideRobots.move!(robot :: CoordRobot, side :: HorizonSide)
    move!(get_robot(robot), side)

    move!(get_coord(robot), side)
end

function try_move!(r :: AreaRobot, side :: HorizonSide)
    if check(r)== true
        if side == Ost && isborder(r, Nord)
        r.s.s-=r.coord.y+1
        elseif side == West && isborder(r, Sud)
        r.s.s+=r.coord.y
        end
    end
    if !isborder(r,side)
        move!(r,side)
    end
end
function try_move!(r::AroundRobot, side :: HorizonSide)
    try_move!(r.robot, side)
end

function HSR.move!(coord :: Coordinates, side :: HorizonSide)
    coord.x += (Int(side) % 2) * (-1)^(Int(side) % 3)
    coord.y -= ((Int(side)+1) % 2) * (-1)^((Int(side)+1) % 3)    
end

function GoAround(robot :: AroundRobot)
    side = robot.direction.d
    while true
        if isborder(robot, turn!(side, Right)) & isborder(r, side)
            side=turn!(side,Right)
            try_move!(robot,turn!(side,Right))
        elseif !isborder(robot, side)
            side=turn!(side, Left)
            move!(robot,turn!(side, Right))
        else
            move!(robot, turn!(side, Right))
        end 
        if (r.coord.x==0) & (r.coord.y==0) & (side==robot.direction.d)
            break
        end
    end
end

function turn!(side, direction :: Directions)
    if direction == Right return HorizonSide((Int(side)+3)%4)
    else return HorizonSide((Int(side)+1)%4) end
end

function Num3839(robot :: SimpleRobot)
    side=0
    for i in 0:3
        if isborder(robot, HorizonSide(i))
            side=HorizonSide(i)
            break
        end
    end
    initside=side
    r=AroundRobot{SimpleRobot}(robot, side, Coordinates(0,0))
    GoAround(r)
end