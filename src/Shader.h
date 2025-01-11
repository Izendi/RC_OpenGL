#pragma once
#include "utils.h"

#include <iostream>
#include <memory>
#include <vector>
#include <string>
#include <fstream>
#include <sstream>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

class Shader
{
private:
	unsigned int shaderProgHandle;
	unsigned int vShader;
	unsigned int fShader;
	std::string vs_string;
	std::string fs_string;
	const char* vs_filePath;
	const char* fs_filePath;

	unsigned int shaderArrayIndex = 0;

	void createAndCompileVertShader();
	void createAndCompileFragShader();
	void linkShaderPrograms();


public:
	Shader(const char* vs, const char* fs);

	void recompile();

	unsigned int getShaderHandle() const;
	void readShaderCodeFromFile(const char* vs_path, const char* fs_path);

	void setUniform4f(std::string name, float v1, float v2, float v3, float v4) const;
	void setUniform3fv(std::string name, glm::vec3& vec) const;
	void setUniformFloat(std::string name, float val) const;
	void setUniformInt(std::string name, int val) const;
	void setUniform3fv(std::string name, float v1, float v2, float v3) const;
	void setUniformTextureUnit(std::string name, unsigned int x);
	void setUniformMat4(std::string name, GLboolean transpose, const GLfloat* mat);
	void setUniform4fv(std::string name, glm::vec4& vec) const;

	void bindProgram() const;

	unsigned int getShaderArrayIndex();
	void setShaderArrayIndex(unsigned int index);

};