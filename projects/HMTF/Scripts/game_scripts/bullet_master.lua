require("definitions")
require("components.extras")
require("components.component_all")
require("components.component_index")

require("objects.game_object")
require("objects.time")

require("objects.material")
require("objects.global_data")
require("objects.vectors")
require("objects.gravity")
require("objects.scene_3D")
require("objects.time")

require("short_cuts.create_collision")
require("short_cuts.create_mesh")




bullet_list = {}

target_points = {}

local bullet_types = {
    ray = 0,
    fast = 1,
    big = 2,
    missile = 3,

    prediction_ray = 4,
    prediction_fast = 5,
    prediction_big = 6,
    prediction_missile = 7,
}

local bullet_groups = {
    friend = 0,
    foe = 1,
    hazard = 2
}

layers = nil
function START()
    layers = global_data.layers

end

--[[
    obj
    type
    group
    start
    target_direction
    speed
    color
]]

function distance(a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    local dz = b.z - a.z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

function midpoint(a, b)
    local mx = (a.x + b.x) / 2
    local my = (a.y + b.y) / 2
    local mz = (a.z + b.z) / 2
    return {x = mx, y = my, z = mz}
end

function normalize(vector)
    local length = math.sqrt(vector.x^2 + vector.y^2 + vector.z^2)
    return {
        x = vector.x / length,
        y = vector.y / length,
        z = vector.z / length
    }
end

function calculate_next_position(a, b, t)
    -- Calcula o vetor direção do ponto a para o ponto b
    local direction = {x = b.x - a.x, y = b.y - a.y, z = b.z - a.z}
    
    -- Normaliza o vetor direção
    local normalized_direction = normalize(direction)
    
    -- Calcula a próxima posição do objeto
    local next_position = {
        x = a.x + normalized_direction.x * t,
        y = a.y + normalized_direction.y * t,
        z = a.z + normalized_direction.z * t
    }
    
    return next_position
end


update_per_type = {
    [bullet_types.ray] = function (bullet)

        local bcomps = bullet.obj.components

        bullet.timer = bullet.timer - time.delta

        if bullet.timer <= 0 then
            bullet.dead = true
            return
        end

        bcomps.transform:change_scale(1 * bullet.timer,1 * bullet.timer,bullet.distance)
        
    end,
    [bullet_types.fast] = function (bullet)
        local obj_comp = bullet.obj.components
        local last_pos = obj_comp.transform:get_global_position()
        local distance = distance(last_pos, bullet.target)

        local next_pos = calculate_next_position(last_pos,bullet.target, bullet.speed * time.delta)
        if distance <= bullet.speed * time.delta then
            bullet.dead = true
        end

        obj_comp.transform:change_position(next_pos.x,next_pos.y,next_pos.z)

        local hit = false
        local hit_info = {}
        hit,hit_info = raycast_3D(last_pos,next_pos)
        if hit then
            print(hit)
            bullet.dead = true
        end

        --[[
            process damage
        ]]

        
    end
}

function UPDATE()
    time:get()
    
    for index, value in pairs(bullet_list) do
        update_per_type[value.type](value)
        if value.dead then
            remove_object(value.obj.object_ptr)
            table.remove(bullet_list,index)
        end
    end

end

function COLLIDE(collision_info)
end

function END()
end

function set_target_point(args)
    target_points[args[1]] = args[2]
    return {}
end

function remove_target_point(args)
    target_points[args[1]] = nil
    return {}
end

local mesh_mat = matreial:new()
mesh_mat.shader = "mesh"
mesh_mat.textures[1] = "Textures/white.png"

local sprite_mat = matreial:new()
sprite_mat.shader = "sprite"
sprite_mat.textures[1] = "Textures/white.png"




start_per_type = {
    [bullet_types.ray] = function (bullet)

        bullet.timer = 1
        
        local bcomps = bullet.obj.components

        local start = bullet.start
        local start_effect = bullet.start.effect
        if start_effect == nil then
            start_effect = bullet.start
        end

        local target = bullet.target
        local hit = false
        local hit_info = {}
        hit,hit_info = raycast_3D(start,target)
        if hit then
            target = hit_info.position
        end
        bullet.target = target

        --damage

        local dist = distance(start_effect,bullet.target)

        
        local mp = midpoint(start_effect, bullet.target)
        bcomps.transform:change_position(mp.x,mp.y,mp.z)

        bcomps.transform:look_at(bullet.target)

        bullet.distance = dist
        bcomps.transform:change_scale(1,1,bullet.distance)

        local extra_rot = math.random(0, 360)

        local sb1 = game_object(create_object(bullet.obj.object_ptr)).components
        sb1.transform:change_rotation(90,0,extra_rot)
        sb1.render_shader.material = deepcopy(sprite_mat)
        sb1.render_shader.material.color = bullet.color
        sb1.render_shader.material.color.a = sb1.render_shader.material.color.a - 0.001
        sb1.render_shader.material.textures[1] = "Textures/energy_ray.svg"
        sb1.render_shader.material.position_scale = Vec4:new(0,0,1,dist)
        sb1.render_shader.layer = 2
        sb1.render_shader:set()

        local sb2 = game_object(create_object(bullet.obj.object_ptr)).components
        sb2.transform:change_rotation(90,0,90 + extra_rot)
        sb2.render_shader.material = sb1.render_shader.material
        sb2.render_shader.layer = 2
        sb2.render_shader:set()
        
    end,
    [bullet_types.fast] = function (bullet)

        local target = bullet.target
        local hit = false
        local hit_info = {}
        hit,hit_info = raycast_3D(bullet.start,target)
        if hit then
            target = hit_info.position
        end
        bullet.target = target

        local obj_comp = bullet.obj.components

        obj_comp.transform.billboarding = 2
        obj_comp.transform.position = bullet.start
        obj_comp.transform.scale.x = 0.25
        obj_comp.transform.scale.y = 0.25
        obj_comp.transform:set()

        obj_comp.render_shader.material = deepcopy(sprite_mat)
        obj_comp.render_shader.material.color = bullet.color
        obj_comp.render_shader.material.color = {r=1,g=0.1,b=0.1,a=obj_comp.render_shader.material.color.a - 0.001}
        obj_comp.render_shader.material.textures[1] = "Textures/energy_buble.png"
        obj_comp.render_shader.material.position_scale = Vec4:new(0,0,1,1)
        obj_comp.render_shader.layer = 2
        obj_comp.render_shader:set()
        
    end
}

function summon_bullet(args)

   

    local bullet_type = args[1]
    local damage_type = args[2]
    local group = args[3]
    local start = args[4]
    local target_direction_position = args[5]
    local speed = args[6]
    local color = args[7]
    local distance = args[8]
    local damage = args[9]
    local effect = args[10]
    local obj = game_object(create_object(layers.main))

    local bullet_data = {
        obj = obj,
        type = bullet_type,
        damage_type = damage_type,
        group = group,
        start = start,
        target = target_direction_position,
        speed = speed,
        color = color,
        distance = distance,
        damage = damage,
        effect = effect
    }

    start_per_type[bullet_data.type](bullet_data)

    table.insert(bullet_list,bullet_data)

    return {}
end

function clean(args)
    for index, value in pairs(bullet_list) do
        remove_object(value.obj.object_ptr)
    end
    entitys_list = {}
    target_points = {}
    return {}
end