#pragma once
#include <GL/glew.h>
#include <GLFW/glfw3.h>

#include <iostream>
#include <utility>
#include <vector>

#include "debugAssert.h"

#include "Shader.h"

#include "imgui/imgui.h"
#include "imgui/imgui_impl_glfw.h"
#include "imgui/imgui_impl_opengl3.h"

#include "computeShader.h"


//Basic Error Checking
#define ASSERT(x) if (!(x)) __debugbreak();
#define GLCALL(x) GLClearError();\
	x;\
	ASSERT(GLLogCall(#x, __FILE__, __LINE__))

struct GuiData
{
	GuiData(const char* cmpShaderPath, const char* cmpShaderRCLvl_0_path, const char* csRC_0_path, const char* csRC_1_path, const char* csRC_4_path) :
		cmpShader(cmpShaderPath), 
		cmpShdRCLvl_0(cmpShaderRCLvl_0_path), 
		csRC_0(csRC_0_path),
		csRC_1(csRC_1_path),
		csRC_4(csRC_4_path)
		{ }

	int activeShader = 0;
	std::vector<Shader> shaders;
	std::vector<std::string> shaderNames;
	ComputeShader cmpShader;
	ComputeShader cmpShdRCLvl_0;
	ComputeShader csRC_0;
	ComputeShader csRC_1;
	ComputeShader csRC_4;
};

// settings
const unsigned int SCR_WIDTH = 512;
const unsigned int SCR_HEIGHT = 512;

static void GLClearError()
{
	while (glGetError() != GL_NO_ERROR);
}

static bool GLLogCall(const char* function, const char* file, int line)
{
	while (GLenum error = glGetError())
	{
		std::cout << "[OpenGL Error] (" << error << ") \nFunction: "
			<< function << "\nFile: "
			<< file << "\nLine: "
			<< line << "\n"
			<< std::endl;

		return false;
	}

	return true;
}