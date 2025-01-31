require("definitions")
require("components.extras")
require("components.component_index")

require("components.component_all")

require("objects.game_object")

require("objects.global_data")

local core_obj = nil



function set_target_point(name,point)
    if global_data.core_object_ptr ~= nil then
        if core_obj == nil then
            core_obj = game_object(global_data.core_object_ptr)
        end

        if speed == nil then
            speed = 1
        end

        core_obj.components.lua_scripts.scripts["game_scripts/managers/bullet_master"].functions.set_target_point({name,point})
    end
end

function remove_target_point(name)
    if global_data.core_object_ptr ~= nil then
        if core_obj == nil then
            core_obj = game_object(global_data.core_object_ptr)
        end

        if speed == nil then
            speed = 1
        end

        core_obj.components.lua_scripts.scripts["game_scripts/managers/bullet_master"].functions.remove_target_point({name})
    end
end

function summon_bullet(type,start,target,extra)
    if global_data.core_object_ptr ~= nil then
        if core_obj == nil then
            core_obj = game_object(global_data.core_object_ptr)
        end

        if speed == nil then
            speed = 1
        end

        core_obj.components.lua_scripts.scripts["game_scripts/managers/bullet_master"].functions.summon_bullet({type,start,target,extra})
    end
end

function clean_bullets()
    if global_data.core_object_ptr ~= nil then
        if core_obj == nil then
            core_obj = game_object(global_data.core_object_ptr)
        end

        core_obj.components.lua_scripts.scripts["game_scripts/managers/bullet_master"].functions.clean({})
    end
end