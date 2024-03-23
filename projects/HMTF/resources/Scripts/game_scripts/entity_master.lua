require("components.extras")
require("components.component_all")
require("components.component_index")
require("objects.global_data")
require("objects.time")
require("short_cuts.create_sound")
require("short_cuts.create_mesh")
require("short_cuts.create_collision")
require("game_scripts.resources.playable_scene")



entitys_list = {}


player_position = { x = 0, y = 0, z = 0 }

function walk(obj, direction)
    obj.components.transform:get()
    local pos = deepcopy(obj.components.transform.position)
    time:get()
    pos.x = pos.x + (direction.x * time.delta)
    pos.y = pos.y + (direction.y * time.delta)
    pos.z = pos.z + (direction.z * time.delta)
    obj.components.transform:change_position(pos.x, pos.y, pos.z)
end

frames_to_new_path = 10
timer_to_new_path = 0

--[[
    local pre_calculated_paths_ret = {
        path = {},
        progression = 0
    }
]]
pre_calculated_paths = {}

function walk_to(obj, hight, speed, target)


    
end

function START()
end

local update_entity_map = {
    test_entity = function(entity)
        --path = generate_navmesh_path({x=-21, y=40.5, z=-138},{x=67.0, y=80.5, z=-296.0},"")
        --walk(entity.obj,{x=0,y=0,z=10})
        walk_to(entity.obj, 2, 10, {x=67.0, y=80.5, z=-296.0})
    end,
}

function UPDATE()
    player_position = { x = 0, y = 0, z = 0 }

    if global_data.player_object_ptr ~= nil then
        local player = game_object(global_data.player_object_ptr)

        if player ~= nil then
            player.components.transform:get()
            player_position = player.components.transform.position
            --print("player_position",player_position.x,player_position.y,player_position.z)
        end
    end



    for index, value in ipairs(entitys_list) do
        update_entity_map[value.type](value)
        --print(value.type)
    end

    timer_to_new_path = timer_to_new_path + 1
    if timer_to_new_path >= frames_to_new_path then
        --pre_calculated_paths = {}
    end
end

function COLLIDE(collision_info)
end

function END()
end

local actions_per_type = {
    test_entity = function(entity)
        local model_path = "resources/3D Models/test_enimy.gltf"

        local entity_physics_3D = entity.obj.components.physics_3D
        entity_physics_3D.boady_dynamic = boady_dynamics.kinematic
        entity_physics_3D.collision_shape = collision_shapes.capsule
        entity_physics_3D.scale = Vec3:new(1, 2, 1)
        entity_physics_3D.rotate_x = false
        entity_physics_3D.rotate_y = false
        entity_physics_3D.rotate_z = false
        entity_physics_3D.friction = 0
        entity_physics_3D.gravity_scale = 0
        entity_physics_3D.density = 1
        entity_physics_3D.triger = false
        entity_physics_3D:set()

        local entity_data = get_scene_3D(model_path)
        local entity_structures = cenary_builders.entity(entity.obj.object_ptr, 2, entity_data, "resources/Shaders/mesh",
            true, false)

        entity.rig_obj = entity_structures.obj
        entity.rig_obj.components.transform.position.y = -1.5
        entity.rig_obj.components.transform:set()
        entity.parts_ptr_list = entity_structures.parts_ptr_list
    end,
}

function summon_entity(args)
    local pos = args.pos
    local rot_y = args.rot_y
    local type = args.type

    local obj = game_object(create_object(global_data.layers.main))
    obj.components.transform.position = deepcopy(pos)
    --print("AAAAA",pos.x,pos.y,pos.z)
    obj.components.transform.rotation = { x = 0, y = rot_y, z = 0 }
    obj.components.transform:set()

    local entity = {
        type = type,
        obj = obj,
        rig_obj = nil,
        parts_ptr_list = nil,
        animation = "",
        animation_time = 0,
    }



    actions_per_type[type](entity)



    table.insert(entitys_list, entity)

    return {}
end

function remove_entity(adres)
    remove_object(entitys_list[adres].obj.object_ptr)
    table.remove(entitys_list, adres)
end

function clear(args)
    while #entitys_list > 0 do
        remove_entity(1)
    end
    return {}
end
