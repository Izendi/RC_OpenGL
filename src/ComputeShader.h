#pragma once

#include "utils.h"

#include <string>
#include <fstream>
#include <sstream>

std::string readComputeShaderCodeFromFile(const char* cs_path)
{
	std::ifstream csFile;

	csFile.open(cs_path);

	if(!csFile.is_open())
	{
		std::cerr << "\nERROR: Unable to open vertex shader file at: " << cs_path << std::endl;
		ASSERT(false);
	}

	std::stringstream csStream;

	csStream << csFile.rdbuf();

	csFile.close();

	return csStream.str();
}

void checkComputeShaderCompileErrors(uint32_t computeShaderHandle)
{
	// check for shader compile errors
	int success;
	char infoLog[512];
	glGetShaderiv(computeShaderHandle, GL_COMPILE_STATUS, &success);
	if (!success)
	{
		glGetShaderInfoLog(computeShaderHandle, 512, NULL, infoLog);
		std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
	}
}

void checkComputeShaderProgramLinkErrors(uint32_t computeShaderProgramHandle)
{
	// check for shader compile errors
	int success;
	char infoLog[512];
	glGetShaderiv(computeShaderProgramHandle, GL_LINK_STATUS, &success);
	if (!success)
	{
		glGetShaderInfoLog(computeShaderProgramHandle, 512, NULL, infoLog);
		std::cout << "ERROR::SHADER::VERTEX::LINK_FAILED\n" << infoLog << std::endl;
	}
}