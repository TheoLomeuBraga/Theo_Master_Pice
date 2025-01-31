#pragma once
#include "table.h"
#include "RecursosT.h"
#include "ManusearArquivos.h"
#include <algorithm>

#include <nlohmann/json.hpp>
#include <unordered_map>
#include <thread>
#include <mutex>

using json = nlohmann::json;

// vectors

vec2 table_vec2(Table t)
{
    return vec2(t.getFloat("x"), t.getFloat("y"));
}
Table vec2_table(vec2 v)
{
    Table t;
    t.setFloat("x", v.x);
    t.setFloat("y", v.y);
    return t;
}

vec3 table_vec3(Table t)
{
    return vec3(t.getFloat("x"), t.getFloat("y"), t.getFloat("z"));
}
Table vec3_table(vec3 v)
{
    Table t;
    t.setFloat("x", v.x);
    t.setFloat("y", v.y);
    t.setFloat("z", v.z);
    return t;
}

vec4 table_vec4(Table t)
{
    return vec4(t.getFloat("x"), t.getFloat("y"), t.getFloat("z"), t.getFloat("w"));
}
Table vec4_table(vec4 v)
{
    Table t;
    t.setFloat("x", v.x);
    t.setFloat("y", v.y);
    t.setFloat("z", v.z);
    t.setFloat("w", v.w);
    return t;
}

vec4 table_color(Table t)
{
    return vec4(t.getFloat("r"), t.getFloat("g"), t.getFloat("b"), t.getFloat("a"));
}
Table color_table(vec4 v)
{
    Table t;
    t.setFloat("r", v.x);
    t.setFloat("g", v.y);
    t.setFloat("b", v.z);
    t.setFloat("a", v.w);
    return t;
}

quat table_quat(Table t)
{
    return quat(t.getFloat("x"), t.getFloat("y"), t.getFloat("z"), t.getFloat("w"));
}
Table quat_table(quat q)
{
    Table t;
    t.setFloat("x", q.x);
    t.setFloat("y", q.y);
    t.setFloat("z", q.z);
    t.setFloat("w", q.w);
    return t;
}

// list vectors

vector<float> table_vFloat(Table t)
{
    vector<float> v;
    int i = 1;
    while (true)
    {
        if (t.haveFloat(to_string(i)))
        {
            v.push_back(t.getFloat(to_string(i)));
            i++;
        }
        else
        {
            break;
        }
    }
    return v;
}
Table vFloat_table(vector<float> v)
{
    Table t;
    for (int i = 0; i < v.size(); i++)
    {
        t.setFloat(to_string(i + 1), v[i]);
    }
    return t;
}

vector<std::string> table_vString(Table t)
{
    vector<std::string> v;
    int i = 1;
    while (true)
    {
        if (t.haveString(to_string(i)))
        {
            v.push_back(t.getString(to_string(i)));
            i++;
        }
        else
        {
            break;
        }
    }
    return v;
}
Table vString_table(vector<std::string> v)
{
    Table t;
    for (int i = 0; i < v.size(); i++)
    {
        t.setString(to_string(i + 1), v[i]);
    }
    return t;
}

vector<Table> table_vTable(Table t)
{
    vector<Table> v;
    int i = 1;
    while (true)
    {
        if (t.haveTable(to_string(i)))
        {
            v.push_back(t.getTable(to_string(i)));
            i++;
        }
        else
        {
            break;
        }
    }
    return v;
}
Table vTable_table(vector<Table> v)
{
    Table t;
    for (int i = 0; i < v.size(); i++)
    {
        t.setTable(to_string(i + 1), v[i]);
    }
    return t;
}

// Material

Material table_material(Table t)
{
    Material m;
    m.shader = t.getString("shader");
    m.lado_render = (char)t.getFloat("normal_direction");

    Table color = t.getTable("color");
    m.cor = vec4(color.getFloat("r"), color.getFloat("g"), color.getFloat("b"), color.getFloat("a"));

    Table position_scale = t.getTable("position_scale");
    m.uv_pos_sca = vec4(position_scale.getFloat("x"), position_scale.getFloat("y"), position_scale.getFloat("z"), position_scale.getFloat("w"));

    m.metalico = t.getFloat("metallic");
    m.suave = t.getFloat("softness");

    vector<string> textures = table_vString(t.getTable("textures"));
    for (int i = 0; i < std::min((int)NO_TEXTURAS, (int)textures.size()); i++)
    {
        m.texturas[i] = ManuseioDados::carregar_Imagem(textures[i]);
    }

    vector<float> filters = table_vFloat(t.getTable("texture_filter"));
    for (int i = 0; i < std::min((int)NO_TEXTURAS, (int)filters.size()); i++)
    {
        m.filtro[i] = (int)filters[i];
    }

    /*
    vector<float> inputs = table_vFloat(t.getTable("inputs"));
    for (int i = 0; i < std::min((int)NO_INPUTS, (int)inputs.size()); i++)
    {
        m.inputs[i] = inputs[i];
    }
    */
    m.inputs = {};
    for (pair<std::string, float> p : t.getTable("inputs").m_floatMap)
    {
        m.inputs[p.first] = p.second;
    }

    return m;
}

Table material_table(Material m)
{
    Table t;
    t.setString("shader", m.shader);
    t.setFloat("normal_direction", (float)m.lado_render);

    Table color;
    color.setFloat("r", m.cor.x);
    color.setFloat("g", m.cor.y);
    color.setFloat("b", m.cor.z);
    color.setFloat("a", m.cor.w);
    t.setTable("color", color);

    Table position_scale;
    position_scale.setFloat("x", m.uv_pos_sca.r);
    position_scale.setFloat("y", m.uv_pos_sca.g);
    position_scale.setFloat("z", m.uv_pos_sca.b);
    position_scale.setFloat("w", m.uv_pos_sca.a);
    t.setTable("position_scale", position_scale);

    t.setFloat("metallic", m.metalico);
    t.setFloat("softness", m.suave);

    vector<std::string> textures;
    for (int i = 0; i < NO_TEXTURAS; i++)
    {
        if (m.texturas[i] != NULL)
        {
            textures.push_back(m.texturas[i]->local);
        }
    }
    t.setTable("textures", vString_table(textures));

    vector<float> filters;
    for (int i = 0; i < NO_TEXTURAS; i++)
    {
        filters.push_back(m.filtro[i]);
    }
    t.setTable("texture_filter", vFloat_table(filters));

    /*
    vector<float> inputs;
    for (int i = 0; i < NO_INPUTS; i++)
    {
        inputs.push_back(m.inputs[i]);
    }
    t.setTable("inputs", vFloat_table(inputs));
    */
    Table inputs;
    for (pair<std::string, float> p : m.inputs)
    {
        inputs.setFloat(p.first, p.second);
    }
    t.setTable("inputs", inputs);
    return t;
}

instrucoes_render table_instrucoes_render(Table t)
{
    instrucoes_render ret;
    ret.camera = t.getFloat("camera_selected");
    ret.iniciar_render = t.getFloat("start_render");
    ret.limpar_buffer_cores = t.getFloat("clean_color");
    ret.limpar_buffer_profundidade = t.getFloat("clean_deep");
    ret.desenhar_objetos = t.getFloat("enable");
    ret.terminar_render = t.getFloat("end_render");
    ret.usar_profundidade = t.getFloat("use_deep");
    return ret;
}

Table table_instrucoes_render(instrucoes_render ir)
{
    Table ret;
    ret.setFloat("camera_selected", ir.camera);
    ret.setFloat("start_render", ir.iniciar_render);
    ret.setFloat("clean_color", ir.limpar_buffer_cores);
    ret.setFloat("clean_deep", ir.limpar_buffer_profundidade);
    ret.setFloat("enable", ir.desenhar_objetos);
    ret.setFloat("end_render", ir.terminar_render);
    ret.setFloat("use_deep", ir.usar_profundidade);
    return ret;
}

info_camada table_info_camada(Table t)
{
    info_camada ret;
    ret.camada = t.getFloat("layer");
    vector<int> camada_colide;
    for (float i : table_vFloat(t.getTable("layers_can_colide")))
    {
        camada_colide.push_back(i);
    }
    ret.camada_colide = camada_colide;
    return ret;
}

Table info_camada_table(info_camada ic)
{
    Table ret;
    ret.setFloat("layer", ic.camada);
    vector<float> layers_can_colide;
    for (int i : ic.camada_colide)
    {
        layers_can_colide.push_back(i);
    }
    ret.setTable("layers_can_colide", vFloat_table(layers_can_colide));
    return ret;
}

Table colis_info_table(colis_info col)
{
    Table ret;
    // ret.setString("object", ponteiro_string(col.obj));
    ret.setString("collision_object", ponteiro_string(col.cos_obj));
    // ret.setFloat("triger", col.sensor);
    // ret.setFloat("colliding", col.colidindo);
    ret.setFloat("distance", col.distancia);
    ret.setTable("position", vec3_table(col.pos));
    ret.setFloat("speed", col.velocidade);
    ret.setTable("normal", vec3_table(col.nor));
    return ret;
}

Table json_table(const json &j)
{
    Table table;
    for (auto &el : j.items())
    {
        if (el.value().is_number())
        {
            table.setFloat(el.key(), el.value().get<float>());
        }
        else if (el.value().is_string())
        {
            table.setString(el.key(), el.value().get<std::string>());
        }
        else if (el.value().is_object())
        {
            Table innerTable = json_table(el.value());
            table.setTable(el.key(), innerTable);
        }
    }
    return table;
}

json table_json(const Table &table)
{
    json j;
    for (const auto &kv : table.m_floatMap)
    {
        j[kv.first] = kv.second;
    }
    for (const auto &kv : table.m_stringMap)
    {
        j[kv.first] = kv.second;
    }
    for (const auto &kv : table.m_tableMap)
    {
        json innerJson = table_json(kv.second);
        j[kv.first] = innerJson;
    }
    return j;
}

Table object_3D_table(objeto_3D obj)
{
    Table ret;

    ret.setString("name", obj.nome);

    ret.setFloat("id", (int)obj.id + 1);

    ret.setTable("position", vec3_table(obj.posicao));
    ret.setTable("rotation", vec3_table(quat_graus(obj.quaternion)));
    ret.setTable("scale", vec3_table(obj.escala));

    vector<Table> meshes;
    for (shared_ptr<malha> p : obj.minhas_malhas)
    {
        Table this_mesh;
        this_mesh.setString("file", p->arquivo_origem);
        this_mesh.setString("name", p->nome);
        meshes.push_back(this_mesh);
    }
    ret.setTable("meshes", vTable_table(meshes));

    vector<Table> materials;
    for (Material p : obj.meus_materiais)
    {
        materials.push_back(material_table(p));
    }
    ret.setTable("materials", vTable_table(materials));

    ret.setTable("variables", obj.variaveis);

    vector<Table> children;
    for (objeto_3D o : obj.filhos)
    {
        children.push_back(object_3D_table(o));
    }
    ret.setTable("children", vTable_table(children));

    return ret;
}

Table scene_3D_table(cena_3D sceane)
{
    Table ret;

    ret.setString("path", sceane.nome);

    vector<Table> animations;
    Table animations_map;

    auto convert_animations = [=](vector<Table> &animations, Table &animations_map, Table &ret)
    {
        for (pair<string, animacao> p : sceane.animacoes)
        {
            Table animation;

            animation.setString("name", p.second.nome);
            animation.setFloat("start_time", p.second.start_time);
            animation.setFloat("duration", p.second.duration); 
            animations.push_back(animation);
        }

        for (Table t : animations)
        {
            animations_map.setTable(t.getString("name"), t);
        }
    }; 
    thread t4(convert_animations, std::ref(animations), std::ref(animations_map), std::ref(ret));

    vector<Table> meshes;
    auto convert_meshes = [&]()
    {
        for (pair<string, shared_ptr<malha>> p : sceane.malhas)
        {
            Table this_mesh;
            this_mesh.setString("file", p.second->arquivo_origem);
            this_mesh.setString("name", p.second->nome);
            meshes.push_back(this_mesh);
        }
        ret.setTable("meshes", vTable_table(meshes));
    };
    thread t1(convert_meshes);

    vector<Table> materials;
    auto convert_materials = [&]()
    {
        for (pair<string, Material> p : sceane.materiais)
        {
            materials.push_back(material_table(p.second));
        }
        ret.setTable("materials", vTable_table(materials));
    };
    thread t2(convert_materials);

    vector<string> textures;
    auto convetr_textures = [&]()
    {
        for (pair<string, shared_ptr<imagem>> p : sceane.texturas)
        {
            textures.push_back(p.first);
        }
        ret.setTable("textures", vString_table(textures));
    };
    thread t3(convetr_textures);

    t1.join();
    t2.join();
    t3.join();
    t4.join();

    ret.setTable("animations", animations_map);
    ret.setTable("objects", object_3D_table(sceane.objetos));
    ret.setTable("extra", sceane.extras);
    return ret;
}

ui_style table_advanced_ui_style(Table s){
    ui_style ret;

    ret.text_color = table_color(s.getTable("text_color"));
    ret.background_color = table_color(s.getTable("background_color"));
    ret.border_color = table_color(s.getTable("border_color"));

    ret.border_size = s.getFloat("border_size");
    ret.text_size = s.getFloat("text_size");
    ret.space_betwen_lines = s.getFloat("space_betwen_lines");
    ret.uniform_spaces_betwen_chars = s.getFloat("uniform_spaces_betwen_chars");
    

    ret.background_image = ManuseioDados::carregar_Imagem(s.getString("background_image"));
    ret.border_image = ManuseioDados::carregar_Imagem(s.getString("border_image"));

    ret.text_font = ManuseioDados::carregar_fonte(s.getString("text_font"));

    return ret;
}

Table advanced_ui_style_table(ui_style s){
    Table ret;

    ret.setTable("text_color",color_table(s.text_color));
    ret.setTable("background_color",color_table(s.background_color));
    ret.setTable("border_color",color_table(s.border_color));

    ret.setFloat("border_size",s.border_size);
    ret.setFloat("text_size",s.text_size);
    ret.setFloat("space_betwen_lines",s.space_betwen_lines);
    ret.setFloat("uniform_spaces_betwen_chars",s.uniform_spaces_betwen_chars);
    
    

    
    if(s.background_image != NULL){
        ret.setString("background_image",s.background_image->local);
    }
    if(s.border_image != NULL){
        ret.setString("border_image",s.border_image->local);
    }
    if(s.text_font != NULL){
        ret.setString("text_font",s.text_font->path);
    }
    

    return ret;
}

unordered_map<shared_ptr<cena_3D>, Table> scene_3D_table_cache;
std::mutex scene_3D_table_cache_mtx;

Table scene_3D_table_with_cache(shared_ptr<cena_3D> sceane)
{
    std::lock_guard<std::mutex> lock(scene_3D_table_cache_mtx);
    if (scene_3D_table_cache.find(sceane) == scene_3D_table_cache.end())
    {
        scene_3D_table_cache[sceane] = scene_3D_table(*sceane.get());
    }
    return scene_3D_table_cache[sceane];
}

Table text_style_change_table(text_style_change style){
    Table ret;
    ret.setString("font",style.font->path);
    ret.setTable("color",color_table(style.color));
    return ret;
}

text_style_change table_text_style_change(Table style){
    text_style_change ret;
    ret.color = table_color(style.getTable("color"));
    ret.font = ManuseioDados::carregar_fonte(style.getString("font"));
    return ret;
}


void register_scene_3D_table(shared_ptr<cena_3D> sceane)
{
    scene_3D_table_with_cache(sceane);
}

void clean_scene_3D_table_cache()
{
    std::lock_guard<std::mutex> lock(scene_3D_table_cache_mtx);
    scene_3D_table_cache.clear();
}

wstring string_wstring(string s){
	std::wstring_convert<std::codecvt_utf8<wchar_t>> converter;
	return converter.from_bytes(s.c_str());
}


ui_element_instruction ui_element_instruction_table(Table t){
    ui_element_instruction ret;
    ret.is_3D = t.getFloat("is_3D") > 0;
    ret.position = table_vec3(t.getTable("position"));
    ret.scale = table_vec3(t.getTable("scale"));
    ret.rotation = table_vec3(t.getTable("rotation"));

    ret.shader = t.getString("shader");
    ret.color = table_color(t.getTable("color"));
    ret.image = ManuseioDados::carregar_Imagem(t.getString("image"));
    for(pair<std::string, float> p : t.getTable("inputs").m_floatMap){
        ret.inputs.insert(pair<std::string, float>(p));
    }

    if(t.getFloat("is_mesh") > 0){
        Table mesh_table = t.getTable("mesh");
        ret.mesh = ManuseioDados::carregar_malha(mesh_table.getString("file"), mesh_table.getString("name"));
    }else{

        ret.roundnes = t.getFloat("roundnes");
        ret.skew = t.getFloat("skew");

        ret.border_size = t.getFloat("border_size");
        ret.border_color = table_color(t.getTable("border_color"));
        ret.border_image = ManuseioDados::carregar_Imagem(t.getString("border_image"));

        ret.text_font = ManuseioDados::carregar_fonte(t.getString("text_font"));
        ret.text_color = table_color(t.getTable("text_color"));
        ret.text_size = t.getFloat("text_size");
        ret.text = string_wstring(t.getString("text"));

    }
    return ret;
}

/*
table table_ui_element_instruction(ui_element_instruction t){
    table ret;
    return ret;
}
*/