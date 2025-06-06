#pragma once

#include <string>
#include <glm/glm.hpp>

class ComputeShader
{
public:

	unsigned int m_program_ID;
	unsigned int m_shader_ID;
	std::string m_cmpShader_string;
	const char* path;


	ComputeShader(const char* filePath);
	
	void recompile();

	void setUniformArray(std::string name, uint32_t size, float* array);
	void setUniformInt(std::string name, int val) const;
	void setUniformFloatValue(std::string name, float val) const;
	void setUniformTextureUnit(std::string name, unsigned int x);
	//void setUniformVec3Array(std::string name, uint32_t size, glm::vec3* array);
	void setUniformVec3Array(std::string name, uint32_t size, glm::vec3* array);


private:
	void readShaderCodeFromFile(const char* shaderCodePath);


	void checkComputeShaderCompileErrors(uint32_t computeShaderHandle);


	void checkComputeShaderProgramLinkErrors(uint32_t computeShaderProgramHandle);

};