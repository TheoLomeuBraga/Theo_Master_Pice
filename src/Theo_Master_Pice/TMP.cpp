/*
 * AAAAA.cpp
 *
 *  Created on: 19 de jun de 2022
 *      Author: theo
 */

//*

#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"

#include "implementacao_glfw.h"

void InitImGui() {
    // Setup Dear ImGui context
	IMGUI_CHECKVERSION();
	ImGui::CreateContext();
	ImGuiIO &io = ImGui::GetIO();
	// Setup Platform/Renderer bindings
	ImGui_ImplGlfw_InitForOpenGL(janela, true);
	ImGui_ImplOpenGL3_Init("#version 330");
	// Setup Dear ImGui style
	ImGui::StyleColorsDark();
}

// Function to update the ImGui UI
void UpdateImGuiUI() {
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();
}

void ShutdownImGui() {
    ImGui::Begin("Demo window");
    ImGui::Button("Hello!");
    ImGui::End();
    ImGui::Render();
    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}
//*/

#include <iostream>
#include <fstream>
#include <functional>
#include <stdlib.h>
#include <thread>
#include <fstream>
#include <type_traits>
#include <iterator>

#include "args.h"

#include "Tempo.h"
#include "LoopPrincipal.h"
#include "Config.h"
#include "Console_Comando.h"
#include "ManusearArquivos.h"
#include "core.h"
#include "box_2d.h"
#include "camera.h"
#include "transform.h"
#include "bullet.h"
#include "input.h"

#include "read_map_file.h"

#include "init_lib_functions.h"

#include <bitset>





void configuracaoInicial()
{

    Iniciar_Render_Func.push_back(start_lua_global_data);
    Iniciar_Render_Func.push_back(iniciarTeste3);
    Iniciar_Render_Func.push_back(iniciar_global_bullet);

    Antes_Render_Func.push_back(atualisar_global_box2D);
    Antes_Render_Func.push_back(atualisar_global_bullet);
    Antes_Render_Func.push_back(get_input_using_threads);
    Antes_Render_Func.push_back(teste3);

    /*
    Iniciar_Render_Func.push_back(InitImGui);
    Antes_Render_Func.push_back(UpdateImGuiUI);
    Depois_Render_Func.push_back(ShutdownImGui);
    */
}
void comecar()
{

    configuracaoInicial();

    thread temp(Tempo::IniciarTempo);
    temp.detach();

    //gerente_janela = new gerenciador_janela_glfw(true);
    start_window_lib();

    thread grafi(loop_principal::loop_principal);
    //start_input_geter();

    grafi.join();
}

int main(int argc, char **argv)
{

    escrever(pegar_estencao_arquivo("arquivo.abc"));
    aplicar_argumentos(argc, argv);

    escrever("argumentos{");
    for (string s : argumentos)
    {
        cout << "	";
        escrever(s);
    }
    escrever("}");

    if (argumentos.size() > 1)
    {
        setar_diretorio_aplicacao(argumentos[1]);
    }
    else
    {
        setar_diretorio_aplicacao("/home/theo/Cpp/TMP_TECH_DEMO_2D");
    }
    
    escrever(pegar_local_aplicacao());

    comecar();

    return 0;
}
