#include "Shader.h"
#include "utils.h"

Shader::Shader(const char* vs, const char* fs) : vs_filePath(vs), fs_filePath(fs)
{
	readShaderCodeFromFile(vs_filePath, fs_filePath);
	createAndCompileVertShader();
	createAndCompileFragShader();
	linkShaderPrograms();
}

void Shader::recompile()
{
	readShaderCodeFromFile(vs_filePath, fs_filePath);
	createAndCompileVertShader();
	createAndCompileFragShader();
	linkShaderPrograms();
}

unsigned int Shader::getShaderHandle() const
{
	return shaderProgHandle;
}

unsigned int Shader::getShaderArrayIndex()
{
	return shaderArrayIndex;
}

void Shader::setShaderArrayIndex(unsigned int index)
{
	shaderArrayIndex = index;
}

void Shader::readShaderCodeFromFile(const char* vs_path, const char* fs_path)
{

	std::ifstream vsFile;
	std::ifstream fsFile;

	vsFile.open(vs_path);
	fsFile.open(fs_path);

	if (!vsFile.is_open())
	{
		std::cerr << "\nError: Unable to open vertex shader file at: " << vs_path << std::endl;
		ASSERT(false);
	}
	if (!fsFile.is_open())
	{
		std::cerr << "\nError: Unable to open fragment shader file at: " << fs_path << std::endl;
		ASSERT(false);
	}

	std::stringstream vsStream;
	std::stringstream fsStream;

	vsStream << vsFile.rdbuf();
	fsStream << fsFile.rdbuf();

	vsFile.close();
	fsFile.close();

	vs_string = vsStream.str();
	fs_string = fsStream.str();
}

void Shader::setUniform4f(std::string name, float v1, float v2, float v3, float v4) const
{
	const char* n = name.c_str();
	GLCALL(glUniform4f(glGetUniformLocation(shaderProgHandle, n), v1, v2, v3, v4));
}

void Shader::setUniform2fv(std::string name, glm::vec2& vec) const
{
	const char* n = name.c_str();
	GLCALL(glUniform2fv(glGetUniformLocation(shaderProgHandle, n), 1, &vec[0]));
}

void Shader::setUniform3fv(std::string name, glm::vec3& vec) const
{
	const char* n = name.c_str();
	GLCALL(glUniform3fv(glGetUniformLocation(shaderProgHandle, n), 1, &vec[0]));
}

void Shader::setUniform4fv(std::string name, glm::vec4& vec) const
{
	const char* n = name.c_str();
	GLCALL(glUniform4fv(glGetUniformLocation(shaderProgHandle, n), 1, &vec[0]));
}


void Shader::setUniformArray(std::string name, uint32_t size, float* array)
{
	const char* n = name.c_str();
	GLCALL(glUniform1fv(glGetUniformLocation(shaderProgHandle, n), size, array));
}

void Shader::setUniform3fv(std::string name, float v1, float v2, float v3) const
{
	const char* n = name.c_str();
	GLCALL(glUniform3f(glGetUniformLocation(shaderProgHandle, n), v1, v2, v3));
}

void Shader::setUniform2fv(std::string name, float v1, float v2) const
{
	const char* n = name.c_str();
	GLCALL(glUniform2f(glGetUniformLocation(shaderProgHandle, n), v1, v2));
}

void Shader::setUniform2iv(std::string name, int v1, int v2) const
{
	const char* n = name.c_str();
	GLCALL(glUniform2i(glGetUniformLocation(shaderProgHandle, n), v1, v2));
}

void Shader::setUniformFloat(std::string name, float val) const
{
	const char* n = name.c_str();
	GLCALL(glUniform1f(glGetUniformLocation(shaderProgHandle, n), val));
}

void Shader::setUniformInt(std::string name, int val) const
{
	const char* n = name.c_str();
	GLCALL(glUniform1i(glGetUniformLocation(shaderProgHandle, n), val));
}

void Shader::setUniformTextureUnit(std::string name, unsigned int x)
{
	const char* n = name.c_str();
	auto val = glGetUniformLocation(shaderProgHandle, n);
	GLCALL(glUniform1i(val, x));
}

void Shader::setUniformMat4(std::string name, GLboolean transpose, const GLfloat* mat)
{
	const char* n = name.c_str();

	GLCALL(glUniformMatrix4fv(glGetUniformLocation(shaderProgHandle, n), 1, transpose, mat));
}

void Shader::bindProgram() const
{
	GLCALL(glUseProgram(shaderProgHandle));
}

void Shader::createAndCompileVertShader()
{
	const char* vss = vs_string.c_str();

	vShader = glCreateShader(GL_VERTEX_SHADER);

	if (vShader == 0)
	{
		std::cout << "vShader could not be created" << std::endl;
		ASSERT(false);
	}

	GLCALL(glShaderSource(vShader, 1, &vss, NULL));
	GLCALL(glCompileShader(vShader));

	// check for shader compile errors
	int success;
	char infoLog[512];
	glGetShaderiv(vShader, GL_COMPILE_STATUS, &success);
	if (!success)
	{
		glGetShaderInfoLog(vShader, 512, NULL, infoLog);
		std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
	}
}

void Shader::createAndCompileFragShader()
{
	const char* fss = fs_string.c_str();

	fShader = glCreateShader(GL_FRAGMENT_SHADER);

	if (fShader == 0)
	{
		std::cout << "fShader could not be created" << std::endl;
		ASSERT(false);
	}

	glShaderSource(fShader, 1, &fss, NULL);
	glCompileShader(fShader);

	// check for shader compile errors
	int success;
	char infoLog[512];
	glGetShaderiv(fShader, GL_COMPILE_STATUS, &success);
	if (!success)
	{
		glGetShaderInfoLog(fShader, 512, NULL, infoLog);
		std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n" << infoLog << std::endl;
	}
}

void Shader::linkShaderPrograms()
{
	shaderProgHandle = glCreateProgram();
	GLCALL(glAttachShader(shaderProgHandle, vShader));
	GLCALL(glAttachShader(shaderProgHandle, fShader));
	GLCALL(glLinkProgram(shaderProgHandle));

	GLCALL(glDeleteShader(vShader));
	GLCALL(glDeleteShader(fShader));
}
