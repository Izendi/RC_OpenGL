
#include "utils.h"

#include <GLFW/glfw3.h>
#include "vendor\stb_image\stb_image.h"

#include "GUI.h"

#include <chrono>

void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void mouse_pos_callback(GLFWwindow* window, double xPos, double yPos);
void mouse_button_callback(GLFWwindow* window, int button, int action, int mods);

//int g_activeShader = 1;

GuiData g_GuiData;

float g_mouseX = 0.0f;
float g_mouseY = 0.0f;
float g_mouseClicked = 0.0f;

int g_xResolution = SCR_WIDTH;
int g_yResolution = SCR_HEIGHT;

int main()
{

	if (!glfwInit()) 
	{
		return -1;
	}

	//GLFWwindow* window;
	std::unique_ptr<GLFWwindow, void(*)(GLFWwindow*)> up_window
	(
		glfwCreateWindow(SCR_WIDTH, SCR_HEIGHT, "Radiance Cascades Demo", NULL, NULL),
		[](GLFWwindow* ptr)
		{
			if (ptr)
			{
				glfwDestroyWindow(ptr);
			}
		}
	);

	if (!up_window)
	{
		glfwTerminate();
		return -1;
	}

	//GLFWcursorposfun previousCursorPosCallback = nullptr;

	glfwMakeContextCurrent(up_window.get());

	glfwSetFramebufferSizeCallback(up_window.get(), framebuffer_size_callback);
	glfwSetCursorPosCallback(up_window.get(), mouse_pos_callback);
	glfwSetMouseButtonCallback(up_window.get(), mouse_button_callback);

	glfwSwapInterval(1); //0 = no vsync, 1 = vsync 2 = half frame rate double vsync thing (look more into later)

	if (glewInit() != GLEW_OK)
	{
		std::cout << "I'm am not GLEW_OK, I'm GLEW_SAD :(\n";
	}

	std::cout << "testing !" << std::endl;

	int width;
	int height;
	int channels;

	if (stbi_info("image.png", &width, &height, &channels))
	{
		std::cout << "Image loaded successfully!\n";
		std::cout << "Width: " << width << ", Height: " << height << ", Channels: " << channels << "\n";
	}
	else 
	{
		std::cerr << "Failed to load image: " << stbi_failure_reason() << "\n";
	}

	//IMGUI Setup:
	// Setup Dear ImGui context (use std::move to move up_window pointer to the function, then move it back to main in a pair)
	std::pair<std::unique_ptr<GLFWwindow, void(*)(GLFWwindow*)>, ImGuiIO&> windowPair = SetUpGui(std::move(up_window));

	up_window = std::move(windowPair.first);
	ImGuiIO& io = windowPair.second; (void)io;
	
	//Set Up Shaders:
	//std::vector<Shader> v_Shaders;


	Shader sh_Basic
		(
			"shaders/vs_Basic.glsl",
			"shaders/fs_Basic.glsl"
		);

	Shader sh_RCv1
		(
			"shaders/vs_RCv1.glsl",
			"shaders/fs_RCv1.glsl"
		);

	g_GuiData.activeShader = 1;
	g_GuiData.shaders.push_back(sh_Basic);
	g_GuiData.shaderNames.push_back("Basic Shader");
	g_GuiData.shaders.push_back(sh_RCv1);
	g_GuiData.shaderNames.push_back("RC V1");


	float quadVertices[] =
	{
		-1.0f, -1.0f, 0.0f,  0.0f, 0.0f,  // Bottom-left
		 1.0f, -1.0f, 0.0f,  1.0f, 0.0f,  // Bottom-right
		-1.0f,  1.0f, 0.0f,  0.0f, 1.0f,  // Top-left

		 1.0f, -1.0f, 0.0f,  1.0f, 0.0f,  // Bottom-right
		 1.0f,  1.0f, 0.0f,  1.0f, 1.0f,  // Top-right
		-1.0f,  1.0f, 0.0f,  0.0f, 1.0f   // Top-left
	};

	uint32_t VAO;
	uint32_t VBO;

	GLCALL(glGenVertexArrays(1, &VAO));
	GLCALL(glGenBuffers(1, &VBO));

	GLCALL(glBindVertexArray(VAO));
	GLCALL(glBindBuffer(GL_ARRAY_BUFFER, VBO));
	GLCALL(glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices, GL_STATIC_DRAW));

	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
	glEnableVertexAttribArray(0);
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
	glEnableVertexAttribArray(1);

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindVertexArray(0);

	auto startTime = std::chrono::high_resolution_clock::now();

	while (!glfwWindowShouldClose(up_window.get()))
	{
		/* Render here */
		glClear(GL_COLOR_BUFFER_BIT);
		glClearColor(0.2f, 0.3f, 0.3f, 1.0f); 

		Shader& activeShader = g_GuiData.shaders[g_GuiData.activeShader];

		activeShader.bindProgram();

		activeShader.setUniformFloat("uTime", std::chrono::duration<float>(std::chrono::high_resolution_clock::now() - startTime).count());
		activeShader.setUniformFloat("uMousePressed", g_mouseClicked);
		activeShader.setUniform2fv("uMousePos", g_mouseX, g_mouseY);
		activeShader.setUniform2fv("uResolution", g_xResolution, g_yResolution);

		glBindVertexArray(VAO);
		glDrawArrays(GL_TRIANGLES, 0, 6);

		RenderGui(g_GuiData);

		/* Swap front and back buffers */
		glfwSwapBuffers(up_window.get());

		/* Poll for and process events */
		glfwPollEvents();
	}

	ImGui_ImplOpenGL3_Shutdown();
	ImGui_ImplGlfw_Shutdown();
	ImGui::DestroyContext();

	glfwTerminate();


	return 0;
}


void framebuffer_size_callback(GLFWwindow* window, int width, int height)
{
	// make sure the viewport matches the new window dimensions; note that width and 
	// height will be significantly larger than specified on retina displays.

	//Set global values for shader input.
	g_xResolution = width;
	g_yResolution = height;

	glViewport(0, 0, width, height);
}

void mouse_pos_callback(GLFWwindow* window, double xPos, double yPos)
{
	int width, height;
	glfwGetWindowSize(window, &width, &height);

	// Normalize mouse position to range [0, 1]
	g_mouseX = static_cast<float>(xPos) / static_cast<float>(width);
	g_mouseY = 1.0f - static_cast<float>(yPos) / static_cast<float>(height); // Flip Y-axis

}

void mouse_button_callback(GLFWwindow* window, int button, int action, int mods)
{
	if (button == GLFW_MOUSE_BUTTON_LEFT) { // Check for left mouse button
		if (action == GLFW_PRESS) {
			g_mouseClicked = 1.0f; // Pressed
		}
		else if (action == GLFW_RELEASE) {
			g_mouseClicked = 0.0f; // Released
		}
	}
}
