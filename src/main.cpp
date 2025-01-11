
#include "utils.h"

#include <GLFW/glfw3.h>

#include "GUI.h"

#include "Shader.h"

#include "vendor\stb_image\stb_image.h"

void framebuffer_size_callback(GLFWwindow* window, int width, int height);

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
	std::vector<std::shared_ptr<Shader>> v_Shaders;


	std::shared_ptr<Shader> sh_Basic = std::make_shared<Shader>
		(
			"shaders/vs_Basic.glsl",
			"shaders/fs_Basic.glsl"
		);

	v_Shaders.push_back(sh_Basic);


	float quadVertices[] =
	{
		-1.0f,-1.0f, 0.0f,  0.0f, 0.0f, // Bottom-left
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



	/* Loop until the user closes the window */
	while (!glfwWindowShouldClose(up_window.get()))
	{
		/* Render here */
		glClear(GL_COLOR_BUFFER_BIT);
		glClearColor(0.2f, 0.3f, 0.3f, 1.0f); // Set a dark greenish clear color

		v_Shaders[0]->bindProgram();
		glBindVertexArray(VAO);
		glDrawArrays(GL_TRIANGLES, 0, 6);

		RenderGui(v_Shaders);

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
	glViewport(0, 0, width, height);
}
