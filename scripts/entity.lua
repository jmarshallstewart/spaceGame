drawCollision = false

function CreateEntity(image, x, y, frameWidth, frameHeight)
    e = AllocEntity()
    SetEntity(e, image, x, y, frameWidth, frameHeight)
    return e
end

function AllocEntity()
    e = {}
    e.position = CreateZeroVector()
    e.velocity = CreateZeroVector()
    e.acceleration = CreateZeroVector()
    e.animations = {}
    ResetEntity(e)
    return e
end

function SetEntity(e, image, x, y, frameWidth, frameHeight)
    e.image = image
    
    SetVector(e.position, x, y)
        
    e.frameWidth = frameWidth
    e.frameHeight = frameHeight
    e.width = math.floor(e.frameWidth * e.scale)
    e.height = math.floor(e.frameHeight * e.scale)
end

function ResetEntity(e)
    e.frame = 0
    e.currentAnimation = nil
    e.r = 255
    e.g = 255
    e.b = 255
    e.a = 255
    e.drag = 0.9
    e.maxSpeed = 16
    e.speed = 10
    e.frameDuration = 1000 / 4
    e.frameTimer = e.frameDuration
    e.angle = 0
    e.scale = 1.0    
    e.collisionRadius = 32
    SetVector(e.position, 0, 0)
    SetVector(e.velocity, 0, 0)
    SetVector(e.acceleration, 0, 0)
        
    ClearTable(e.animations)
    
    --used for wobble seek
    e.turnRate = 4
    e.wobbleLimit = 15
    e.wobbleSpeed = 11
end

function UpdateEntity(e)
    -- update velocity
    e.velocity.x = e.velocity.x + e.acceleration.x
    e.velocity.y = e.velocity.y + e.acceleration.y
        
    -- remove very small x velocities
    if math.abs(e.velocity.x) < 0.2 then
        e.velocity.x = 0
    end
    
    -- clamp velocity to maxSpeed
    if Magnitude(e.velocity.x, e.velocity.y) > e.maxSpeed then
        e.velocity.x, e.velocity.y = Normalize(e.velocity.x, e.velocity.y)
        e.velocity.x, e.velocity.y = Scale(e.velocity.x, e.velocity.y, e.maxSpeed)
    end
    
    -- apply drag
    e.velocity.x, e.velocity.y = Scale(e.velocity.x, e.velocity.y, e.drag)
   
    -- update position
    e.position.x = e.position.x + e.velocity.x
    e.position.y = e.position.y + e.velocity.y
    
    --update animation
    if e.currentAnimation ~= nil then
        e.frameTimer = e.frameTimer - GetFrameTime()
        if e.frameTimer <= 0 then
            e.frameTimer = e.frameTimer + e.frameDuration
            e.frame = e.frame + 1
            if e.frame > #(e.animations[e.currentAnimation]) then
                e.frame = 1
            end
        end
    end
end

function UpdateWobbleSeek(e)
    if e.target ~= nil then
        e.wobble = math.sin(os.clock() * e.wobbleSpeed) * e.wobbleLimit 

        local targetX = e.target.position.x
        local targetY = e.target.position.y
        
        x, y = VectorTo(e.position.x, e.position.y, targetX, targetY)
        angleToTarget = math.deg(math.atan(y, x)) + e.wobble
            
        if e.angle ~= angleToTarget then
            delta = angleToTarget - e.angle
            
            -- wrap to smaller angle
            if delta > 180 then
                delta = delta - 360
            end
            
            if delta < -180 then
                delta = delta + 360
            end
            
            -- apply delta clamped by turn rate
            if delta > 0 then
                e.angle = e.angle + e.turnRate
            else
                e.angle = e.angle - e.turnRate
            end
            
            -- slam to target if close
            if math.abs(delta) < e.turnRate then
                e.angle = angleToTarget
            end
        end
                
        e.velocity.x = math.cos(math.rad(e.angle)) * e.speed
        e.velocity.y = math.sin(math.rad(e.angle)) * e.speed
    end
        
    UpdateEntity(e)
end

function DrawEntity(e)
    if e.currentAnimation == nil then
        DrawImageFrame(e.image, e.position.x - e.width * 0.5, e.position.y - e.height * 0.5, e.frameWidth, e.frameHeight, e.frame, e.angle, e.scale, e.r, e.g, e.b, e.a)
    else
        DrawImageFrame(e.image, e.position.x - e.width * 0.5, e.position.y - e.height * 0.5, e.frameWidth, e.frameHeight, e.animations[e.currentAnimation][e.frame], e.angle, e.scale, e.r, e.g, e.b, e.a)
    end
    --DrawImage(e.image, e.position.x - e.width * 0.5, e.position.y - e.height * 0.5, e.angle, e.scale, e.r, e.g, e.b, e.a)

    if drawCollision then
        SetDrawColor(255, 0, 255, 255)
        DrawCircle(e.position.x, e.position.y, e.collisionRadius)
    end
end

function GetEntityRect(e)
    box = {}
    box.x = e.position.x - e.width * 0.5
    box.y = e.position.y - e.height * 0.5
    box.w = e.width
    box.h = e.height
    return box
end

function SetEntityScale(e, scale)
    e.scale = scale
    e.width = math.floor(e.frameWidth * e.scale)
    e.height = math.floor(e.frameHeight * e.scale)
end

function AddAnimationFrame(e, clipName, frameIndex)
    if e.animations[clipName] == nil then
        e.animations[clipName] = {}
    end
    
    e.animations[clipName][#(e.animations[clipName]) + 1] = frameIndex
    --Log(string.format("Adding animation %i", #(e.animations[clipName])))
end

function StartAnimation(e, clipName)
    e.currentAnimation = clipName
    e.frame = 1
    e.frameTimer = e.frameDuration
end