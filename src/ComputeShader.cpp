#include "computeShader.h"

#include "utils.h"

#include <fstream>
#include <sstream>

ComputeShader::ComputeShader(const char* filePath) : path(filePath)
{
	readShaderCodeFromFile(filePath);

	const char* css = m_cmpShader_string.c_str();

	m_shader_ID = glCreateShader(GL_COMPUTE_SHADER);
	GLCALL(glShaderSource(m_shader_ID, 1, &css, NULL));

	GLCALL(glCompileShader(m_shader_ID));


	checkComputeShaderCompileErrors(m_shader_ID);

	m_program_ID = glCreateProgram();
	GLCALL(glAttachShader(m_program_ID, m_shader_ID));
	GLCALL(glLinkProgram(m_program_ID));

	checkComputeShaderProgramLinkErrors(m_program_ID);

	glDeleteShader(m_shader_ID);
}

void ComputeShader::readShaderCodeFromFile(const char* shaderCodePath)
{
	std::ifstream cmpsFile;

	cmpsFile.open(shaderCodePath);

	if (!cmpsFile.is_open())
	{
		std::cerr << "\nError: Unable to open compute shader file at: " << shaderCodePath << std::endl;
		ASSERT(false);
	}

	std::stringstream cmpsStream;

	cmpsStream << cmpsFile.rdbuf();

	cmpsFile.close();

	m_cmpShader_string = cmpsStream.str();
}


void ComputeShader::checkComputeShaderCompileErrors(uint32_t computeShaderHandle)
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


void ComputeShader::checkComputeShaderProgramLinkErrors(uint32_t computeShaderProgramHandle)
{
	// check for shader compile errors
	int success;
	char infoLog[512];
	glGetProgramiv(computeShaderProgramHandle, GL_LINK_STATUS, &success);
	if (!success)
	{
		glGetShaderInfoLog(computeShaderProgramHandle, 512, NULL, infoLog);
		std::cout << "ERROR::SHADER::VERTEX::LINK_FAILED\n" << infoLog << std::endl;
	}
}

void ComputeShader::recompile()
{
	readShaderCodeFromFile(path);

	const char* css = m_cmpShader_string.c_str();

	m_shader_ID = glCreateShader(GL_COMPUTE_SHADER);
	GLCALL(glShaderSource(m_shader_ID, 1, &css, NULL));

	GLCALL(glCompileShader(m_shader_ID));


	checkComputeShaderCompileErrors(m_shader_ID);

	m_program_ID = glCreateProgram();
	GLCALL(glAttachShader(m_program_ID, m_shader_ID));
	GLCALL(glLinkProgram(m_program_ID));

	checkComputeShaderProgramLinkErrors(m_program_ID);

	glDeleteShader(m_shader_ID);
}

void ComputeShader::setUniformArray(std::string name, uint32_t size, float* array)
{
	const char* n = name.c_str();
	GLCALL(glUniform1fv(glGetUniformLocation(m_program_ID, n), size, array));

}

void ComputeShader::setUniformInt(std::string name, int val) const
{
	const char* n = name.c_str();
	GLCALL(glUniform1i(glGetUniformLocation(m_program_ID, n), val));

}

void ComputeShader::setUniformFloatValue(std::string name, float val) const
{
	const char* n = name.c_str();
	GLCALL(glUniform1f(glGetUniformLocation(m_program_ID, n), val));
}
