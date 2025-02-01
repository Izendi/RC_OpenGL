#pragma once

#include "utils.h"
#include <fstream>
#include <sstream>

class ComputeShader
{
public:
	unsigned int m_ID;
	std::string m_cmpShader_string;

	ComputeShader(const char* filePath)
	{

	}

	void readShaderCodeFromFile(const char* shaderCodePath)
	{
		std::ifstream cmpsFile;

		cmpsFile.open(shaderCodePath);

		if (!cmpsFile.is_open())
		{
			std::cerr << "\nError: Unable to open vertex shader file at: " << shaderCodePath << std::endl;
			ASSERT(false);
		}

		std::stringstream cmpsStream;

		cmpsStream << cmpsFile.rdbuf();

		cmpsFile.close();

		m_cmpShader_string = cmpsStream.str();
	}


};