require("definitions")
require("components.extras")
require("components.component_all")
require("components.component_index")
require("objects.game_object")
require("objects.time")
require("objects.material")
require("objects.global_data")
require("objects.local_data")
require("objects.vectors")
require("objects.input")
require("objects.gravity")
require("objects.scene_3D")
require("game_scripts.resources.playable_scene")
require("short_cuts.create_collision")
require("game_scripts.resources.bullet_api")

require("math")

this_object = nil
camera = nil
base_arms = nil

arms_data = nil
arms_objs = nil


function change_spel_style(r, g, b, r2, g2, b2, speed)
    for index, value in ipairs(arms_objs.parts_ptr_list) do
        local obj = game_object(value)
        if obj.components.render_mesh then
            obj.components.render_mesh:get()

            for index, value in pairs(obj.components.render_mesh.materials) do
                obj.components.render_mesh.materials[index].color = { r = r, g = g, b = b, a = 1 }
                obj.components.render_mesh.materials[index].inputs.color_2_r = r2;
                obj.components.render_mesh.materials[index].inputs.color_2_g = g2;
                obj.components.render_mesh.materials[index].inputs.color_2_b = b2;
                obj.components.render_mesh.materials[index].inputs.perlin_speed = speed
            end

            obj.components.render_mesh:set()
        end
    end
end

function START()
    this_object = game_object(this_object_ptr)
    camera = game_object(this_object.components.lua_scripts:get_variable("game_scripts/player/charter_movement",
        "camera_ptr"))
    base_arms = game_object(create_object(camera.object_ptr))
    base_arms.components.transform:set()

    arms_data = get_scene_3D("3D Models/charters/magic_arms.glb")
    arms_objs = cenary_builders.entity(base_arms.object_ptr, 4, arms_data, "arm_mesh", false, false)
    set_keyframe("3D Models/charters/magic_arms.glb", arms_objs.parts_ptr_list, true, "normal", 0)

    
    change_spel_style(0,0,0,0,0,0,0)
end

inputs_last_frame = {}
current_hand_use = "atack_R"
current_element = ""
loked_hands = 0

animations_progresion = {
    --prepare_hands = -1.0,
    atack_L = -1.0,
    atack_R = -1.0,
    walk = -1.0,
    normal = -1.0,
}

animations_order = {
    --[1] = "prepare_hands",
    [1] = "normal",
    [2] = "walk",
    [3] = "atack_L",
    [4] = "atack_R",
}

function atack_loop()
    if global_data["items"] ~= nil and global_data["items"]["normal_atack"] == 1 then
        change_spel_style(1, 0.75, 0, 0.75, 0.5, 0, 5)
        --if true then
        if inputs.action_1 > 0 and inputs_last_frame.action_1 < 1 and animations_progresion["atack_L"] == -1 and animations_progresion["atack_R"] == -1 then
            if current_hand_use == "atack_R" then
                current_hand_use = "atack_L"
                animations_progresion["atack_L"] = 0
            elseif current_hand_use == "atack_L" then
                current_hand_use = "atack_R"
                animations_progresion["atack_R"] = 0
            end

            --camera
            local start = camera.components.transform:get_global_position(0, 0, 1)
            local target = camera.components.transform:get_global_position(0, 0, 5)
            summon_bullet("normal", start, target)
            
        end

        if animations_progresion["atack_R"] >= 0 then
            animations_progresion["atack_R"] = animations_progresion["atack_R"] + (time.delta * 2)
            if animations_progresion["atack_R"] > arms_data.animations["atack_R"].duration then
                animations_progresion["atack_R"] = -1
            end
        end
        if animations_progresion["atack_L"] >= 0 then
            animations_progresion["atack_L"] = animations_progresion["atack_L"] + (time.delta * 2)
            if animations_progresion["atack_L"] > arms_data.animations["atack_L"].duration then
                animations_progresion["atack_L"] = -1
            end
        end
    end
end

function UPDATE()
    if global_data.pause < 1 then
        time:get()



        inputs = global_data.inputs
        inputs_last_frame = global_data.inputs_last_frame
        local rot_cam_x = math.min((inputs.mouse_view_x * 100) + inputs.analog_view_x, 10)
        rot_cam_x = math.max(rot_cam_x, -10)

        local rot_cam_y = math.min((inputs.mouse_view_y * 100) + inputs.analog_view_y, 10)
        rot_cam_y = math.max(rot_cam_y, -10)

        base_arms.components.transform:get()
        base_arms.components.transform.rotation.y = -rot_cam_x
        base_arms.components.transform.rotation.x = rot_cam_y
        base_arms.components.transform:set()



        --[[]]



        local walk_speed = math.min(1, math.max(0, math.abs(inputs.left) + math.abs(inputs.foward)))
        if walk_speed > 0 --[[ser false enquanto o pulo]] then
            if animations_progresion.walk < 0 then
                animations_progresion.walk = 0
            end
            animations_progresion.walk = animations_progresion.walk + (time.delta * walk_speed)
        else
            animations_progresion.walk = -1
        end

        if walk_speed == 0 then
            if animations_progresion.normal < 0 then
                animations_progresion.normal = 0
            end
            animations_progresion.normal = animations_progresion.normal + time.delta
            animations_progresion.normal = -1
            
        else
            animations_progresion.normal = -1
        end

        if global_data["items"] ~= nil and global_data["items"]["normal_atack"] == 1 then
            atack_loop()
        end


        for key, value in ipairs(animations_order) do
            local value2 = animations_progresion[value]
            if value2 > arms_data.animations[value].duration then
                animations_progresion[value] = 0
            end
            if value2 > -1 then
                set_keyframe("3D Models/charters/magic_arms.glb", arms_objs.parts_ptr_list, true, value, value2)
                break
            end
        end





        --set_keyframe("3D Models/charters/magic_arms.glb", arms_objs.parts_ptr_list, true, "atack_L",0.2)
        --set_keyframe("3D Models/charters/magic_arms.glb", arms_objs.parts_ptr_list, true, "atack_R", 0.2)
    end
end

function COLLIDE(collision_info)
end

function END()
end
