#include "GUI.h"

std::pair<std::unique_ptr<GLFWwindow, void(*)(GLFWwindow*)>, ImGuiIO&> SetUpGui(std::unique_ptr<GLFWwindow, void(*)(GLFWwindow*)> p_glfw_Window)
{
	// Setup Dear ImGui context
	IMGUI_CHECKVERSION();
	ImGui::CreateContext();
	ImGuiIO& io = ImGui::GetIO(); (void)io;

	// Setup Platform/Renderer bindings
	ImGui_ImplGlfw_InitForOpenGL(p_glfw_Window.get(), true);
	ImGui_ImplOpenGL3_Init("#version 130"); // Use GLSL version 130

	// Setup Dear ImGui style
	ImGui::StyleColorsDark();

	return { std::move(p_glfw_Window), io };
}

void RenderGui(std::vector<std::shared_ptr<Shader>>& v_Shaders)
{
	// Start the Dear ImGui frame
	ImGui_ImplOpenGL3_NewFrame();
	ImGui_ImplGlfw_NewFrame();
	ImGui::NewFrame();

	//ImGui::ShowDemoWindow(); // Show demo window! :)

	ImGui::Begin("Example Window");

	// Button with a label "Call MyFunction"
	if (ImGui::Button("Recompile Shaders")) {
		// Call the C++ function once when the button is clicked
		for(int i = 0; i < v_Shaders.size(); i++)
		{
			v_Shaders[i]->recompile();
		}
	}

	ImGui::End();

	ImGui::Render();
	ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

