require("components.extras")
require("components.component_all")
require("components.component_index")
require("objects.global_data")
require("objects.time")
require("short_cuts.create_sound")
require("short_cuts.create_render_shader")
require("game_scripts.resources.entity_api")
require("function_sets.navmesh")

menus = {
    open_pause_menu = function()
        if global_data.open_pause_menu_ptr == nil then
            global_data.open_pause_menu_ptr = create_object(global_data.layers.hud)
            local menu_obj = game_object(create_object(global_data.layers.hud))
            menu_obj.components.transform:set()

            menu_obj.components.lua_scripts:add_script("game_scripts/menus")
            menu_obj.components.lua_scripts.scripts["game_scripts/menus"].variables.in_main_menu = 0
        end
    end,
}

loading_screen = {
    obj = nil,
    spin_obj = nil,
    cam = nil,

    open = function()
        loading_screen.obj = game_object(global_data.core_object_ptr)
        loading_screen.obj.components.lua_scripts:call_function("core", "set_background_image",
            { path = "Textures/white.png", color = { r = 0, g = 0, b = 0 } })
        loading_screen.cam = create_camera_perspective(layers.camera, { x = 0, y = 0, z = 0 }, { x = 0, y = 0, z = 0 },
            90, 0.1, 1000)
        set_lisener_object(loading_screen.cam.object_ptr)




        local mat = matreial:new()
        mat.shader = "sprite"
        mat.textures = { "Textures/spiral.svg" }
        loading_screen.spin_obj = create_render_shader(global_data.layers.hud, true, Vec3:new(0.8, -0.8, 0),
            Vec3:new(0, 0, 0), Vec3:new(0.2, 0.2, 0.2), 5, mat)


        loading_screen.obj.components.lua_scripts:add_script("game_scripts/loading_sreen_script")
        loading_screen.obj.components.lua_scripts:set_variable("game_scripts/loading_sreen_script",
            "obj_ptr_to_rotate", loading_screen.spin_obj.object_ptr)
    end,

    close = function()
        loading_screen.obj.components.lua_scripts:call_function("core", "set_background_image", {})
        loading_screen.obj.components.lua_scripts:remove_script("game_scripts/loading_sreen_script")
        remove_object(loading_screen.cam.object_ptr)
        remove_object(loading_screen.spin_obj.object_ptr)
    end,
}




cenary_builders = {

    entity_part = function(father, entity_ret, layer, part_data, shader, use_oclusion, yield)
        local ret = game_object(create_object(father))
        entity_ret.parts_ptr_list[part_data.id] = ret.object_ptr

        if part_data.name ~= "" or part_data.name ~= nil then
            ret:get()
            ret.name = part_data.name
            ret:set()
        end

        ret.components.transform.position = deepcopy(part_data.position)
        ret.components.transform.rotation = deepcopy(part_data.rotation)

        if part_data.scale.x == 0 and part_data.scale.y == 0 and part_data.scale.z == 0 then
            ret.components.transform.scale = Vec3:new(1, 1, 1)
        else
            ret.components.transform.scale = deepcopy(part_data.scale)
        end

        ret.components.transform:set()

        for key, value in pairs(part_data.materials) do
            part_data.materials[key].shader = shader
        end

        if part_data.meshes ~= nil and part_data.materials ~= nil and math.min(#part_data.meshes, #part_data.materials) ~= 0 then --and math.min(#part_data.meshes, #part_data.materials) > 0 then
            ret.components.render_mesh.layer = layer
            ret.components.render_mesh.meshes_cout = math.min(#part_data.meshes, #part_data.materials)
            ret.components.render_mesh.meshes = part_data.meshes
            ret.components.render_mesh.materials = part_data.materials
            ret.components.render_mesh.use_oclusion = use_oclusion
            ret.components.render_mesh:set()
        end

        --print(part_data.variables.type)

        if part_data.variables.type == "texture_bone_y" then
            ret.components.lua_scripts:add_script("game_scripts/animation/texture_bone_y")
            ret.components.lua_scripts:set_variable("game_scripts/animation/texture_bone_y", "target_name",
                part_data.variables.target_name.name)
            ret.components.lua_scripts:set_variable("game_scripts/animation/texture_bone_y", "no_textures_y",
                part_data.variables.no_textures_y)
        end

        if yield == true then
            coroutine.yield()
        end

        for key, value in pairs(part_data.children) do
            cenary_builders.entity_part(ret.object_ptr, entity_ret, layer, value, shader, use_oclusion, yield)
        end

        return ret
    end,

    entity = function(father, layer, ceane_data, shader, use_oclusion, yield)
        local ret = {
            obj = {},
            parts_ptr_list = {},
            parts_list = {},
        }

        if yield == nil then yield = false end

        ret.obj = cenary_builders.entity_part(father, ret, layer, ceane_data.objects, shader, use_oclusion, yield)
        for key, value in pairs(ret.parts_ptr_list) do
            ret.parts_list[key] = game_object(value)
        end


        for index, value in ipairs(ret.parts_list) do
            value.components.lua_scripts:get()
            if value.components.lua_scripts.scripts["game_scripts/animation/texture_bone_y"] ~= nil then
                value.components.lua_scripts.scripts["game_scripts/animation/texture_bone_y"].variables.parts_ptr_list =
                ret.parts_ptr_list
            end
        end
        return ret
    end,

    scene_part = function(father, ptr_list, layer, part_data, yield)
        --local sp = stopwatch:new()

        local ret = game_object(create_object(father))
        ptr_list[part_data.id] = ret.object_ptr

        if part_data.name ~= "" or part_data.name ~= nil then
            ret:get()
            ret.name = part_data.name
            ret:set()
        end


        ret.components.transform.position = deepcopy(part_data.position)
        ret.components.transform.rotation = deepcopy(part_data.rotation)

        if part_data.scale.x == 0 and part_data.scale.y == 0 and part_data.scale.z == 0 then
            ret.components.transform.scale = Vec3:new(1, 1, 1)
        else
            ret.components.transform.scale = deepcopy(part_data.scale)
        end

        ret.components.transform:set()



        local add_physics = function(rb, is_triger)
            if part_data.meshes ~= nil and part_data.meshes[1] ~= nil then
                if rb then
                    ret.components[components.physics_3D].boady_dynamic = boady_dynamics.dynamic
                    ret.components[components.physics_3D].rotate_x = false
                    ret.components[components.physics_3D].rotate_y = false
                    ret.components[components.physics_3D].rotate_z = false
                else
                    ret.components[components.physics_3D].boady_dynamic = boady_dynamics.static
                end

                if part_data.variables.collision_shape == nil then
                    ret.components[components.physics_3D].collision_shape = collision_shapes.convex
                    ret.components[components.physics_3D].collision_mesh = deepcopyjson(part_data.meshes[1])
                elseif part_data.variables.collision_shape == "cube" then
                    ret.components[components.physics_3D].collision_shape = collision_shapes.cube
                elseif part_data.variables.collision_shape == "sphere" then
                    ret.components[components.physics_3D].elasticity = 1
                    ret.components[components.physics_3D].collision_shape = collision_shapes.sphere
                end


                ret.components[components.physics_3D].triger = is_triger
                ret.components[components.physics_3D].scale = deepcopyjson(part_data.scale)
                ret.components[components.physics_3D].friction = 2
                ret.components[components.physics_3D]:set()
            end
        end

        local add_mesh = function(color)
            if part_data.meshes ~= nil and part_data.materials ~= nil then
                if color ~= nil then
                    for key, value in pairs(part_data.materials) do
                        part_data.materials[key].color = deepcopy(color)
                        part_data.materials[key] = deepcopy(value)
                    end
                end


                ret.components.render_mesh.layer = layer
                ret.components.render_mesh.meshes_cout = math.min(#part_data.meshes, #part_data.materials)
                ret.components.render_mesh.meshes = deepcopy(part_data.meshes)
                ret.components.render_mesh.materials = deepcopy(part_data.materials)
                ret.components.render_mesh:set()
            end
        end

        local change_ret = function()
            local ret2 = game_object(create_object(father))

            ptr_list[part_data.id] = ret2.object_ptr


            ret2.components.transform.position = deepcopy(part_data.position)
            ret2.components.transform.rotation = deepcopy(part_data.rotation)

            if part_data.scale.x == 0 and part_data.scale.y == 0 and part_data.scale.z == 0 then
                ret2.components.transform.scale = Vec3:new(1, 1, 1)
            else
                ret2.components.transform.scale = deepcopy(part_data.scale)
            end

            ret2.components.transform:set()
        end

        if part_data.variables.type == "sb" then
            add_physics(false, false)
            add_mesh(nil)
        elseif part_data.variables.type == "rb" then
            add_physics(true, false)
            add_mesh(nil)
        elseif part_data.variables.type == "liquid" then
            
            for key, value in pairs(part_data.materials) do
                part_data.materials[key].shader = "mesh"
            end

            add_physics(false, true)
            add_mesh(nil)



        elseif part_data.variables.type == "grass" then
            for key, value in pairs(part_data.materials) do
                part_data.materials[key].shader = "grass_2D_mesh"
            end

            add_physics(false, false)
            add_mesh(nil)
        elseif part_data.variables.type == "item" then
            ret.components.transform.position = deepcopy(part_data.position)
            ret.components.transform.rotation = deepcopy(part_data.rotation)

            if part_data.scale.x == 0 and part_data.scale.y == 0 and part_data.scale.z == 0 then
                ret.components.transform.scale = Vec3:new(1, 1, 1)
            else
                ret.components.transform.scale = deepcopy(part_data.scale)
            end

            if part_data.meshes ~= nil and part_data.meshes[1] ~= nil then
                ret.components[components.physics_3D].boady_dynamic = boady_dynamics.kinematic

                ret.components[components.physics_3D].collision_shape = collision_shapes.convex
                ret.components[components.physics_3D].collision_mesh = deepcopyjson(part_data.meshes[1])

                ret.components[components.physics_3D].triger = true
                ret.components[components.physics_3D].scale = deepcopyjson(part_data.scale)
                ret.components[components.physics_3D].friction = 2
                ret.components[components.physics_3D].get_collision_info = true
                ret.components[components.physics_3D]:set()
            end

            if part_data.meshes ~= nil and part_data.materials ~= nil and math.min(#part_data.meshes, #part_data.materials) ~= 0 then
                ret.components.render_mesh.layer = layer
                ret.components.render_mesh.meshes_cout = math.min(#part_data.meshes, #part_data.materials)
                ret.components.render_mesh.meshes = deepcopy(part_data.meshes)
                ret.components.render_mesh.materials = deepcopy(part_data.materials)
                ret.components.render_mesh:set()
            end

            
            ret.components.lua_scripts:add_script("game_scripts/item")
            ret.components.lua_scripts:set_variable("game_scripts/item", "item_type", part_data.variables.item_type)
            ret.components.lua_scripts:set_variable("game_scripts/item", "item_name", part_data.variables.item_name)

            if part_data.variables.amount ~= nil then
                ret.components.lua_scripts:set_variable("game_scripts/item", "amount", part_data.variables.amount)
            end

            change_ret()
        elseif part_data.variables.type == "camera" then
            ret.components.camera:set()
        elseif part_data.variables.type == "player_start" then
            ret.components[components.physics_3D].get_collision_info = true
            ret.components[components.physics_3D]:set()

            ret.components.transform:get()
            ret.components.transform.position.y = ret.components.transform.position.y + 2
            ret.components.transform:set()

            ret.components.lua_scripts:add_script("game_scripts/player/charter_movement")
            ret.components.lua_scripts:add_script("game_scripts/player/charter_data")
            ret.components.lua_scripts:add_script("game_scripts/player/charter_interaction")
            ret.components.lua_scripts:add_script("game_scripts/player/charter_arcenal")

            deepprint(ret.components.lua_scripts.scripts["game_scripts/player/charter_movement"].varables)
            ret.components.lua_scripts.scripts["game_scripts/player/charter_movement"].variables.camera_rotation = {x=180 + part_data.rotation.y,y=0}
            change_ret()
        elseif part_data.variables.type == "music" then
            ret.components.audio_source.path = "Audio/musics/" ..
                part_data.variables.sound_source .. ".wav"
            ret.components.audio_source.loop = true
            ret.components.audio_source.volume = 10
            ret.components.audio_source.min_distance = 5
            ret.components.audio_source.atenuation = 1
            ret.components.audio_source:set()

            add_mesh(nil)
        elseif part_data.variables.type == "sound" then
            ret.components.audio_source.path = "Audio/sounds/" ..
                part_data.variables.sound_source .. ".wav"
            ret.components.audio_source.loop = true
            ret.components.audio_source.volume = 10
            ret.components.audio_source.min_distance = 5
            ret.components.audio_source.atenuation = 1
            ret.components.audio_source:set()

            add_mesh(nil)
        elseif part_data.variables.type == "background_music" then
            ret = game_object(create_object(father))


            ret.components.audio_source.path = "Audio/musics/" ..
                part_data.variables.sound_source .. ".wav"
            ret.components.audio_source.loop = true
            ret.components.audio_source.volume = 10
            ret.components.audio_source.min_distance = 5
            ret.components.audio_source.atenuation = 1
            ret.components.audio_source:set()

            add_mesh(nil)
        elseif part_data.variables.type == "mensage" then
            ret.components.lua_scripts:add_script("game_scripts/mensage")

            local mensage = part_data.variables.mensage
            local mensage_index = part_data.variables.mensage_index
            if mensage_index ~= nil then
                ret.components.lua_scripts:set_variable("game_scripts/mensage", "mensage_index", mensage_index)
            elseif mensage ~= nil then
                ret.components.lua_scripts:set_variable("game_scripts/mensage", "mensage", mensage)
            end

            add_mesh(nil)
            add_physics(false, false)
        elseif part_data.variables.type == "passage" then
            ret.components.lua_scripts:add_script("game_scripts/passage")
            ret.components.lua_scripts:set_variable("game_scripts/passage", "passage_target",
                part_data.variables.passage_target)

            add_mesh(nil)
            add_physics(false, true)
        elseif part_data.variables.type == "door_triger" then
            ret.components.lua_scripts:add_script("game_scripts/animation/door_triger")
            ret.components.lua_scripts:set_variable("game_scripts/animation/door_triger", "triger_target",
                part_data.variables.triger_target.name)

            if part_data.variables.key ~= nil or part_data.variables.key ~= "" then
                ret.components.lua_scripts:set_variable("game_scripts/animation/door_triger", "key_to_open",
                    part_data.variables.key)
            end

            if part_data.variables.stay_open ~= nil then
                ret.components.lua_scripts:set_variable("game_scripts/animation/door_triger", "stay_open",
                    part_data.variables.stay_open)
            end



            add_mesh(nil)
            add_physics(true, true)
        elseif part_data.variables.type == "entity" then
            if part_data.variables.entity_type == nil or part_data.variables.entity_type == "test_entity" then
                summon_entity(deepcopy(part_data.position), part_data.rotation.y, "test_entity")
            else
                summon_entity(deepcopy(part_data.position), part_data.rotation.y, part_data.variables.entity_type)
            end
            --print("entity_type",part_data.variables.entity_type)

            change_ret()
        elseif part_data.variables.type == "navmesh" then
            create_navmesh(part_data.position, part_data.rotation, part_data.scale, part_data.meshes[1],
                part_data.variables.tag)
            change_ret()
        elseif part_data.variables.type == "print" then
            --print(part_data.variables.menssage)
        elseif part_data.variables.type == nil then
            add_mesh(nil)
        end

        if yield == true then
            coroutine.yield()
        end


        for key, value in pairs(part_data.children) do
            cenary_builders.scene_part(ret.object_ptr, ptr_list, layer, value, yield)
        end

        --print("sp",sp:get())

        return ret
    end,

    scene = function(father, layer, ceane_data, yield)
        local ret = {
            obj = {},
            parts_ptr_list = {},
            parts_list = {},
        }



        --if yield == nil then yield = false end
        ret.obj = cenary_builders.scene_part(father, ret.parts_ptr_list, layer, ceane_data.objects, yield)
        for key, value in pairs(ret.parts_ptr_list) do
            ret.parts_list[key] = game_object(value)
        end


        for index, value in ipairs(ret.parts_list) do
            value.components.lua_scripts:get()
            if value.components.lua_scripts.scripts["game_scripts/animation/door_triger"] ~= nil then
                value.components.lua_scripts.scripts["game_scripts/animation/door_triger"].variables.level_animation_data = {
                    parts_ptr_list = ret.parts_ptr_list,
                    path = ceane_data.path
                }
            end
        end

        return ret
    end,

}
