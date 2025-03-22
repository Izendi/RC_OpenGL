
#include "utils.h"

#include "vendor\stb_image\stb_image.h"

#include "GUI.h"

#include <chrono>
#include "computeShader.h"

#include <utility>
#include <thread>

void framebuffer_size_callback(GLFWwindow* window, int width, int height);
void mouse_pos_callback(GLFWwindow* window, double xPos, double yPos);
void mouse_button_callback(GLFWwindow* window, int button, int action, int mods);

//int g_activeShader = 1;

float g_mouseX = 0.0f;
float g_mouseY = 0.0f;
float g_mouseClicked = 0.0f;
bool mouseClicked = false;
/*
float g_lvl_0_interval = 2.0f;
float g_lvl_1_interval = 4.0f;
float g_lvl_2_interval = 8.0f;
float g_lvl_3_interval = 16.0f;
float g_lvl_4_interval = 32.0f;
*/

float g_lvl_0_interval = 5.0f;
float g_lvl_1_interval = 10.0f;
float g_lvl_2_interval = 20.0f;
float g_lvl_3_interval = 40.0f;
//float g_lvl_4_interval = 0.0f;

int g_xResolution = SCR_WIDTH;
int g_yResolution = SCR_HEIGHT;

struct compShaderTexSize
{
	uint32_t x_size = 512;
	uint32_t y_size = 512;
};

float mouseXpos[95] = { 0 };
float mouseYpos[95] = { 0 };
int mouseIndex = 0;
unsigned int frameCount = 0;

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

	std::cout << "\n\nOpenGL Version: " << glGetString(GL_VERSION) << std::endl;

	//Compute Shader Setup: START --------------------------------------------

	compShaderTexSize cmpShTxSize;

	GuiData g_GuiData
	(
		"../../shaders/compute/cs_Basic.glsl", 
		"../../shaders/compute/rc_lvl_0.glsl", 
		"../../shaders/compute/rc_0.glsl", 
		"../../shaders/compute/rc_1.glsl", 
		"../../shaders/compute/rc_2.glsl",
		"../../shaders/compute/rc_3.glsl"
	);

	//Image 1 to write onto in compute shader:
	uint32_t cmpTexID;
	GLCALL(glGenTextures(1, &cmpTexID));
	GLCALL(glActiveTexture(GL_TEXTURE0));
	GLCALL(glBindTexture(GL_TEXTURE_2D, cmpTexID));
	GLCALL(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, cmpShTxSize.x_size, cmpShTxSize.y_size, 0, GL_RGBA, GL_FLOAT, NULL));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glBindImageTexture(0, cmpTexID, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F); //Uses image unit 0

	// Img Cascade Level 0 test data texture:
	uint32_t rcLvl_0_ID;
	GLCALL(glGenTextures(1, &rcLvl_0_ID));
	GLCALL(glActiveTexture(GL_TEXTURE2)); //The next call to glBindTexture will determine the texture assigned to this texture unit.
	GLCALL(glBindTexture(GL_TEXTURE_2D, rcLvl_0_ID));
	GLCALL(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, cmpShTxSize.x_size, cmpShTxSize.y_size, 0, GL_RGBA, GL_FLOAT, NULL));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glBindImageTexture(1, rcLvl_0_ID, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F); //Uses image unit 1

	// Img Cascade Level 0 real data texture:
	uint32_t rc_0_tex;
	GLCALL(glGenTextures(1, &rc_0_tex));
	GLCALL(glActiveTexture(GL_TEXTURE3)); //The next call to glBindTexture will determine the texture assigned to this texture unit.
	GLCALL(glBindTexture(GL_TEXTURE_2D, rc_0_tex));
	GLCALL(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, cmpShTxSize.x_size, cmpShTxSize.y_size, 0, GL_RGBA, GL_FLOAT, NULL));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glBindImageTexture(2, rc_0_tex, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F); //Uses image unit 2

	// Img Cascade Level 1 real data texture:
	uint32_t rc_1_tex;
	GLCALL(glGenTextures(1, &rc_1_tex));
	GLCALL(glActiveTexture(GL_TEXTURE4)); //The next call to glBindTexture will determine the texture assigned to this texture unit.
	GLCALL(glBindTexture(GL_TEXTURE_2D, rc_1_tex));
	GLCALL(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, cmpShTxSize.x_size, cmpShTxSize.y_size, 0, GL_RGBA, GL_FLOAT, NULL));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glBindImageTexture(3, rc_1_tex, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F); //Uses image unit 3

	// Img Cascade Level 2 real data texture:
	uint32_t rc_2_tex;
	GLCALL(glGenTextures(1, &rc_2_tex));
	GLCALL(glActiveTexture(GL_TEXTURE5)); //The next call to glBindTexture will determine the texture assigned to this texture unit.
	GLCALL(glBindTexture(GL_TEXTURE_2D, rc_2_tex));
	GLCALL(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, cmpShTxSize.x_size, cmpShTxSize.y_size, 0, GL_RGBA, GL_FLOAT, NULL));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glBindImageTexture(4, rc_2_tex, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F); //Uses image unit 4

	// Img Cascade Level 3 real data texture:
	uint32_t rc_3_tex;
	GLCALL(glGenTextures(1, &rc_3_tex));
	GLCALL(glActiveTexture(GL_TEXTURE6)); //The next call to glBindTexture will determine the texture assigned to this texture unit.
	GLCALL(glBindTexture(GL_TEXTURE_2D, rc_3_tex));
	GLCALL(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, cmpShTxSize.x_size, cmpShTxSize.y_size, 0, GL_RGBA, GL_FLOAT, NULL));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glBindImageTexture(5, rc_3_tex, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F); //Uses image unit 5

	// Img Cascade Level 4 real data texture:
	/*
	uint32_t rc_4_tex;
	GLCALL(glGenTextures(1, &rc_4_tex));
	GLCALL(glActiveTexture(GL_TEXTURE7)); //The next call to glBindTexture will determine the texture assigned to this texture unit.
	GLCALL(glBindTexture(GL_TEXTURE_2D, rc_4_tex));
	GLCALL(glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, cmpShTxSize.x_size, cmpShTxSize.y_size, 0, GL_RGBA, GL_FLOAT, NULL));
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glBindImageTexture(6, rc_4_tex, 0, GL_FALSE, 0, GL_WRITE_ONLY, GL_RGBA32F); //Uses image unit 6
	*/

	//Compute Shader Setup: END   --------------------------------------------

	//Set up texture data
	int width;
	int height;
	int channels;

	stbi_set_flip_vertically_on_load(true);
	unsigned char* data = stbi_load("../../res/cb.jpg", &width, &height, &channels, 0);
	if (!data)
	{
		std::cerr << "Failed to load texture" << std::endl;
		return -1;
	}

	uint32_t tex_twoByTwo;

	glGenTextures(1, &tex_twoByTwo);

	glActiveTexture(GL_TEXTURE1); // Activate texture unit 1
	glBindTexture(GL_TEXTURE_2D, tex_twoByTwo);

	// setup texture wrapping parameters:
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

	GLenum format = (channels == 3) ? GL_RGB : GL_RGBA;
	glTexImage2D(GL_TEXTURE_2D, 0, format, width, height, 0, format, GL_UNSIGNED_BYTE, data);

	stbi_image_free(data);

	//IMGUI Setup:
	// Setup Dear ImGui context (use std::move to move up_window pointer to the function, then move it back to main in a pair)
	std::pair<std::unique_ptr<GLFWwindow, void(*)(GLFWwindow*)>, ImGuiIO&> windowPair = SetUpGui(std::move(up_window));

	up_window = std::move(windowPair.first);
	ImGuiIO& io = windowPair.second; (void)io;

	//Set Up Shaders:
	//std::vector<Shader> v_Shaders;


	Shader sh_Basic
	(
		"../../shaders/vs_Basic.glsl",
		"../../shaders/fs_Basic.glsl"
	);

	Shader sh_RCv1
	(
		"../../shaders/vs_RCv1.glsl",
		"../../shaders/fs_RCv1.glsl"
	);
	Shader sh_RCv2
	(
		"../../shaders/vs_RCv2.glsl",
		"../../shaders/fs_RCv2.glsl"
	);

	Shader sh_SDFTest
	(
		"../../shaders/vs_SDF_test.glsl",
		"../../shaders/fs_SDF_test.glsl"
	);

	Shader sh_RCTexTest
	{
		"../../shaders/vs_RCTexTest.glsl",
		"../../shaders/fs_RCTexTest.glsl"
	};

	
	Shader sh_RCTexTest2
	{
		"../../shaders/vs_RCTexTest2.glsl",
		"../../shaders/fs_RCTexTest2.glsl"
	};
	
	/*
	Shader sh_RCFinal
	{
		"../../shaders/vs_RCFinal.glsl",
		"../../shaders/fs_RCFinal.glsl"
	};
	*/

	g_GuiData.activeShader = 0;
	g_GuiData.shaders.push_back(sh_Basic);
	g_GuiData.shaderNames.push_back("Basic Shader");
	g_GuiData.shaders.push_back(sh_RCv1);
	g_GuiData.shaderNames.push_back("RC V1");
	g_GuiData.shaders.push_back(sh_RCv2);
	g_GuiData.shaderNames.push_back("RC V2");
	g_GuiData.shaders.push_back(sh_SDFTest);
	g_GuiData.shaderNames.push_back("SDF Test");
	g_GuiData.shaders.push_back(sh_RCTexTest);
	g_GuiData.shaderNames.push_back("RC Tex Test");
	g_GuiData.shaders.push_back(sh_RCTexTest2);
	g_GuiData.shaderNames.push_back("RC Tex Test 2");
	//g_GuiData.shaders.push_back(sh_RCFinal);
	//g_GuiData.shaderNames.push_back("RC Final");


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
	float totalTime = 0.0f;
	float lastFrameTotalTime = 0.0f;
	float deltaTime = 0.0f;

	//Run compute Shader:
	glUseProgram(g_GuiData.cmpShader.m_program_ID);
	//glDispatchCompute(512, 512, 1);

	glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT); //Wait for compute shader to complete


	//System to capture mouse input positions and generate an SDF (setup):

	GLint maxUniformComponents;
	glGetIntegerv(GL_MAX_FRAGMENT_UNIFORM_COMPONENTS, &maxUniformComponents);
	std::cout << "\n\nMax uniform components: " << maxUniformComponents << std::endl;

	int maxInvocations, maxSizeX, maxSizeY, maxSizeZ;
	glGetIntegerv(GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS, &maxInvocations);
	glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_SIZE, 0, &maxSizeX);
	glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_SIZE, 1, &maxSizeY);
	glGetIntegeri_v(GL_MAX_COMPUTE_WORK_GROUP_SIZE, 2, &maxSizeZ);

	printf("\n\nMax Local Invocations: %d\n", maxInvocations);
	printf("Max Workgroup Size: (%d, %d, %d)\n\n\n", maxSizeX, maxSizeY, maxSizeZ);

	while (!glfwWindowShouldClose(up_window.get()))
	{

		//Run compute Shader (currently it is run every frame, even if it is not used):
		glUseProgram(g_GuiData.cmpShader.m_program_ID);
		glDispatchCompute(32, 32, 1);
		glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT); //Wait for compute shader to complete

		if (g_GuiData.activeShader == 4 || g_GuiData.activeShader == 5 || g_GuiData.activeShader == 6)
		{
			glUseProgram(g_GuiData.cmpShdRCLvl_0.m_program_ID);

			g_GuiData.cmpShdRCLvl_0.setUniformArray("mouseX", 95, mouseXpos);
			g_GuiData.cmpShdRCLvl_0.setUniformArray("mouseY", 95, mouseYpos);
			g_GuiData.cmpShdRCLvl_0.setUniformInt("mouseIndex", mouseIndex);

			glDispatchCompute(256, 256, 1);
			glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);
		

			// -----

			glUseProgram(g_GuiData.csRC_0.m_program_ID);
			glDispatchCompute(256, 256, 1); // Each dispatch is the number of probes in the x and y direction
			glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);

			g_GuiData.csRC_0.setUniformArray("mouseX", 95, mouseXpos);
			g_GuiData.csRC_0.setUniformArray("mouseY", 95, mouseYpos);
			g_GuiData.csRC_0.setUniformInt("mouseIndex", mouseIndex);
			g_GuiData.csRC_0.setUniformFloatValue("lvl_0_interval", g_lvl_0_interval);


			glUseProgram(g_GuiData.csRC_1.m_program_ID);
			glDispatchCompute(128, 128, 1); // 64, 32, 16
			glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);

			g_GuiData.csRC_1.setUniformArray("mouseX", 95, mouseXpos);
			g_GuiData.csRC_1.setUniformArray("mouseY", 95, mouseYpos);
			g_GuiData.csRC_1.setUniformInt("mouseIndex", mouseIndex);
			g_GuiData.csRC_1.setUniformFloatValue("lvl_0_interval", g_lvl_0_interval);

			glUseProgram(g_GuiData.csRC_3.m_program_ID);

			g_GuiData.csRC_3.setUniformArray("mouseX", 95, mouseXpos);
			g_GuiData.csRC_3.setUniformArray("mouseY", 95, mouseYpos);
			g_GuiData.csRC_3.setUniformInt("mouseIndex", mouseIndex);
			g_GuiData.csRC_3.setUniformFloatValue("lvl_0_interval", g_lvl_0_interval);
			g_GuiData.csRC_3.setUniformFloatValue("lvl_1_interval", g_lvl_1_interval);
			g_GuiData.csRC_3.setUniformFloatValue("lvl_2_interval", g_lvl_2_interval);
			g_GuiData.csRC_3.setUniformFloatValue("lvl_3_interval", g_lvl_3_interval);

			glDispatchCompute(32, 32, 1);
			glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);


		}
		/*
		else if (g_GuiData.activeShader == 5)
		{
			glUseProgram(g_GuiData.csRC_0.m_program_ID);
			glDispatchCompute(256, 256, 1);
			glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);

			g_GuiData.csRC_0.setUniformArray("mouseX", 100, mouseXpos);
			g_GuiData.csRC_0.setUniformArray("mouseY", 100, mouseYpos);
			g_GuiData.csRC_0.setUniformInt("mouseIndex", mouseIndex);
		}
		*/

		totalTime = std::chrono::duration<float>(std::chrono::high_resolution_clock::now() - startTime).count();
		deltaTime = totalTime - lastFrameTotalTime;

		/* Render here */
		glClear(GL_COLOR_BUFFER_BIT);
		glClearColor(0.2f, 0.3f, 0.3f, 1.0f); 

		Shader& activeShader = g_GuiData.shaders[g_GuiData.activeShader];

		activeShader.bindProgram();

		activeShader.setUniformFloat("uTime", totalTime);
		activeShader.setUniformFloat("uMousePressed", g_mouseClicked);
		activeShader.setUniform2fv("uMousePos", g_mouseX, g_mouseY);
		activeShader.setUniform2fv("uResolution", g_xResolution, g_yResolution);
		activeShader.setUniformArray("mouseX", 100, mouseXpos);
		activeShader.setUniformArray("mouseY", 100, mouseYpos);
		activeShader.setUniformInt("mouseIndex", mouseIndex);

		activeShader.setUniform2iv("screenRes", g_xResolution, g_yResolution);

		//Set texture:
		activeShader.setUniformTextureUnit("u_tex_0", 0);
		activeShader.setUniformTextureUnit("u_tex_1", 1);
		activeShader.setUniformTextureUnit("u_tex_2", 2);

		activeShader.setUniformTextureUnit("u_tex_rc0", 3);
		activeShader.setUniformTextureUnit("u_tex_rc1", 4);
		activeShader.setUniformTextureUnit("u_tex_rc2", 5);
		activeShader.setUniformTextureUnit("u_tex_rc3", 6);

		glBindVertexArray(VAO);
		glDrawArrays(GL_TRIANGLES, 0, 6);

		RenderGui(g_GuiData, deltaTime, mouseIndex);

		/* Swap front and back buffers */
		glfwSwapBuffers(up_window.get());

		/* Poll for and process events */
		glfwPollEvents();

		lastFrameTotalTime = totalTime;

		//This is for mouse input stuff: (A bit hacky, but it works):

		if (mouseIndex < 100 && g_mouseClicked == 0.0f && mouseClicked == true)
		{
			mouseXpos[mouseIndex] = (float)g_mouseX;
			mouseYpos[mouseIndex] = (float)g_mouseY;

			std::cout << "\nxPos[" << mouseIndex << "] = " << mouseXpos[mouseIndex] << std::endl;
			std::cout << "yPos[" << mouseIndex << "] = " << mouseYpos[mouseIndex] << "\n" << std::endl;


			std::cout << "\nmi = " << mouseIndex << std::endl;

			mouseIndex = mouseIndex + 1;

			g_mouseClicked = 1.0f;
		}
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

	//g_mouseX = g_mouseX * 2.0f - 1.0f;
	//g_mouseY = g_mouseY * 2.0f - 1.0f;

}

void mouse_button_callback(GLFWwindow* window, int button, int action, int mods)
{
	if (button == GLFW_MOUSE_BUTTON_LEFT) { // Check for left mouse button
		if (action == GLFW_PRESS) {
			//g_mouseClicked = 1.0f; // Pressed
			mouseClicked = true;
		}
		else if (action == GLFW_RELEASE) {
			g_mouseClicked = 0.0f; // Released
			mouseClicked = false;
		}
	}
}
