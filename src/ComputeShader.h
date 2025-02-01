#pragma once

#include <string>

class ComputeShader
{
public:

	unsigned int m_program_ID;
	unsigned int m_shader_ID;
	std::string m_cmpShader_string;
	const char* path;


	ComputeShader(const char* filePath);
	
	void recompile();

private:
	void readShaderCodeFromFile(const char* shaderCodePath);


	void checkComputeShaderCompileErrors(uint32_t computeShaderHandle);


	void checkComputeShaderProgramLinkErrors(uint32_t computeShaderProgramHandle);

};