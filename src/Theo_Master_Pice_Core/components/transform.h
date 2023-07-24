#pragma once

#include <iostream>
#include <functional>
using namespace std;
#include "RecursosT.h"
#include "game_object.h"


mat4 MatrizMundi = glm::translate(glm::mat4(), glm::vec3(0.0f, 0.0f, 0.0f));

	class transform_ : public componente {
	public:






		transform_() {
			matrizTransform = MatrizMundi;
		}

		
		bool UI = false;
		transform_* paiTF;
		


		

		int local_hierarquia;

		bool usar_pai_matriz;
		mat4 pai_matriz;


		glm::vec3 pos, esca,rot;

		glm::mat4 matrizTransform;
		quat quater;




		


		glm::mat4 pegar_matriz() {
			glm::mat4 ret;

			if (paiTF == NULL) {
				ret = MatrizMundi;
			}
			else
			{
				ret = paiTF->matrizTransform;
			}



			ret = translate(ret, pos);

			ret *= toMat4(quater);
			ret = scale(ret, esca);

			matrizTransform = ret;




			return ret;
		}

		glm::vec3 pegar_pos_global() {
			vec3 nada;
			vec4 nada2;
			vec3 pos;
			quat nada3;
			glm::decompose(matrizTransform, nada, nada3, pos, nada, nada2);
			return pos;
		}
		glm::quat pegar_qua_global() {
			vec3 nada;
			vec4 nada2;
			vec3 nada3;
			quat qua;
			glm::decompose(matrizTransform, nada, qua, nada3, nada, nada2);
			return qua;
		}
		glm::vec3 pegar_graus_global() {
			return quat_graus(pegar_qua_global());
		}

		vec3 pegar_direcao_local(vec3 dir) {
			mat4 m = glm::translate(matrizTransform,dir);
			vec3 nada;
			vec4 nada2;
			vec3 escala;
			vec3 pos;
			quat qua;
			glm::decompose(m, escala, qua, pos, nada, nada2);

			vec3 ret = pos - pegar_pos_global();
			return  vec3(ret.x,-ret.y,ret.z);
		}

		
		vec3 mover_direcao(vec3 dir) {
			vec3 nada;
			vec4 nada2;
			vec3 escala;
			vec3 pos;
			quat qua;
			glm::decompose(glm::translate(matrizTransform,dir), escala, qua, pos, nada, nada2);

			return pos;
		}
		

		void reset(bool ui, transform_* pai, glm::vec3 p, glm::vec3 r, glm::vec3 e) {
			UI = ui;
			paiTF = pai;
			pos = p;
			quater = graus_quat(r);
			esca = e;
			pegar_matriz();
		}

		void atualizar_tf() {
			//OBS: o unico proposito dessa fun��o e eu n�o me confundir 
			pegar_matriz();
		}


		transform_(glm::vec3 p, glm::vec3 r, glm::vec3 e) {
			reset(false, NULL, p, r, e);
		}




		transform_(bool ui, glm::vec3 p, glm::vec3 r, glm::vec3 e) {
			reset(ui, NULL, p, r, e);
		}





		transform_(transform_* pai, glm::vec3 p, glm::vec3 r, glm::vec3 e) {
			reset(false, pai, p, r, e);
		}

		transform_(bool ui, transform_* pai, glm::vec3 p, glm::vec3 r, glm::vec3 e) {
			reset(ui, pai, p, r, e);
		}

		vec3 pegar_angulo_graus() {
			rot = quat_graus(quater);
			return rot;

		}
		void mudar_angulo_graus(vec3 ang) {
			rot = ang;
			quater = graus_quat(ang);
		}

	};




float tf_distance(glm::vec3 a, shared_ptr<transform_> tf) {
  return glm::length(a - tf->pos);
}

// Function to sort the input vector of vec3 points based on the distance from the given point
std::vector<shared_ptr<objeto_jogo>> tf_ordenate_by_distance(glm::vec3 point, std::vector<shared_ptr<objeto_jogo>> objs) {
  // Create a vector to store the distances
  std::vector<float> tf_distance(objs.size());

  // Calculate the distances from the given point to each of the points in the input vector
  for (int i = 0; i < objs.size(); i++) {
    tf_distance[i] = vec3_distance(point, objs[i]->pegar_componente<transform_>()->pos);
  }

  // Create an index vector and sort it based on the distances
  std::vector<int> indices(objs.size());
  std::iota(indices.begin(), indices.end(), 0);
  std::sort(indices.begin(), indices.end(), [&](int i, int j) {return tf_distance[i] < tf_distance[j];});

  // Create a new vector to store the sorted vec3 points
  std::vector<shared_ptr<objeto_jogo>> ret(objs.size());

  // Fill the new vector with the vec3 points in the order determined by the sorted index vector
  for (int i = 0; i < indices.size(); i++) {
    ret[i] = objs[indices[i]];
  }

  // Return the sorted vector of vec3 points
  return ret;
}




