require("TMP_libs.short_cuts.create_text")
require("TMP_libs.short_cuts.create_render_shader")
require("TMP_libs.short_cuts.create_ui")
require("TMP_libs.short_cuts.create_mesh")

local menu = {
    menu_obj = {},
}

function menu:START(father,pos,rot,sca)

end

function menu:UPDATE()

end

function menu:END()
    --remove_object(config_menu.menu_obj.object_ptr)
end

return menu