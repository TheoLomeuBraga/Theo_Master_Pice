#pragma once

#include <iostream>
#include <functional>
using String = std::string;


#include "RecursosT.h"
#include "game_object.h"


class render_shader : public componente {
	public:
		Material mat;
		bool ligado = true;
		uint8_t camada = 0;
		
		uint8_t tamanho = 6;
		render_shader() {
			should_update = false;
		}
	};