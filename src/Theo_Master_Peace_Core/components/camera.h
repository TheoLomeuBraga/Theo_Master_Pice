#pragma once

#include <iostream>
#include <functional>
using namespace std;
#include "components/transform.h"
#include "RecursosT.h"
#include "game_object.h"

#include <glm/gtc/matrix_inverse.hpp>

class camera : public componente
{
public:
	transform_ *paiTF;

	glm::vec3 pos, alvo, cima;

	bool ortografica = false;
	float zoom = 90;
	vec2 tamanho = vec2(20, 20), res = vec2(1, 1);
	float ncp = 0.01;
	float fcp = 100;
	glm::mat4 matrizVisao, matrizProjecao;

	int8_t prioridade = 0;

	imagem *alvo_render;

	camera() {}

	glm::mat4 getCameraViewMatrix(glm::mat4 transformMatrix)
	{
		// Remove a informação de escala da matriz de transformação
		glm::mat4 viewMatrix = glm::mat4(glm::mat3(transformMatrix));

		// Remove a informação de transladação da matriz de transformação
		viewMatrix[3] = glm::vec4(0.0f, 0.0f, 0.0f, 1.0f);

		// Inverte a matriz resultante
		viewMatrix = glm::affineInverse(viewMatrix);

		return viewMatrix;
	}

	void atualizar_tf()
	{

		if (paiTF != NULL)
		{


			vec3 nada;
			vec4 nada2;

			vec3 pos, pos_alvo, pos_cima;
			quat qua;
			glm::decompose(paiTF->matrizTransform, nada, qua, pos, nada, nada2);
			
			matrizVisao = getCameraViewMatrix(paiTF->matrizTransform);
			matrizVisao = translate(matrizVisao,vec3(pos.x,-pos.y,pos.z));
			
		}
	}

	glm::mat4 gerar_matriz_perspectiva(float zoom, int resX, int resY, float ncp, float fcp)
	{

		mat4 ret = glm::perspective(glm::radians(zoom), (float)(resX / resY), ncp, fcp);
		matrizProjecao = ret;
		res.x = resX;
		res.y = resY;
		this->fcp = fcp;
		this->ncp = ncp;
		return ret;
	}

	glm::mat4 gerar_matriz_ortografica(float tamanhoX, float tamanhoY, float ncp, float fcp)
	{

		mat4 ret = glm::ortho(-tamanhoX / 2, tamanhoX / 2, -tamanhoY / 2, tamanhoY / 2, ncp, fcp);
		matrizProjecao = ret;
		this->fcp = fcp;
		this->ncp = ncp;
		return ret;
	}

	void configurar_camera(glm::vec3 p, glm::vec3 a, glm::vec3 c, float ZooM, int resX, int resY, float ncp, float fcp)
	{
		pos = p;
		alvo = a;
		cima = c;

		//atualizar_tf();

		ortografica = false;
		zoom = ZooM;
		this->fcp = fcp;
		this->ncp = ncp;
		matrizProjecao = gerar_matriz_perspectiva(ZooM, resX, resY, ncp, fcp);

		atualizar_tf();
	}

	void configurar_camera(glm::vec3 p, glm::vec3 a, glm::vec3 c, float tamanhoX, float tamanhoY, float ncp, float fcp)
	{
		pos = p;
		alvo = a;
		cima = c;

		//atualizar_tf();
		

		ortografica = true;
		tamanho = vec2(tamanhoX, tamanhoY);
		this->fcp = fcp;
		this->ncp = ncp;
		matrizProjecao = gerar_matriz_ortografica(tamanhoX, tamanhoY, ncp, fcp);

		atualizar_tf();
	}

	camera(glm::vec3 p, glm::vec3 a, glm::vec3 c, float zoom, int resX, int resY, float ncp, float fcp)
	{
		configurar_camera(p, a, c, zoom, resX, resY, ncp, fcp);
	}

	camera(glm::vec3 p, glm::vec3 a, glm::vec3 c, float tamanhoX, float tamanhoY, float ncp, float fcp)
	{
		configurar_camera(p, a, c, tamanhoX, tamanhoY, ncp, fcp);
	}

	
};
