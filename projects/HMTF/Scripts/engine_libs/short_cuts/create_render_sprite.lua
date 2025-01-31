require("components.component_table")
require("objects.game_object")
require("components.transform")
require("components.render_sprite")

function create_sprite(father,is_ui,pos,rot,sca,mat,layer,sprite_id,tileset_local)
    ret = game_object(create_object(father))

    
    ret.components.transform.is_ui = is_ui
    ret.components.transform.position = deepcopy(pos)
    ret.components.transform.rotation = deepcopy(rot)
    ret.components.transform.scale = deepcopy(sca)
    ret.components.transform:set()

    
    
    ret.components.render_sprite.material = deepcopy(mat)
    ret.components.render_sprite.layer = layer
    ret.components.render_sprite.selected_tile = sprite_id
    ret.components.render_sprite.tile_set_local = tileset_local
    ret.components.render_sprite:set()
    
    
    return ret
end