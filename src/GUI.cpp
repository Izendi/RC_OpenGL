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

void RenderGui(GuiData& guiData, float deltaTime)
{
	// Start the Dear ImGui frame
	ImGui_ImplOpenGL3_NewFrame();
	ImGui_ImplGlfw_NewFrame();
	ImGui::NewFrame();

	//ImGui::ShowDemoWindow(); // Show demo window! :)

	ImGui::Begin("Settings");

	// Button with a label "Call MyFunction"
	if (ImGui::Button("Recompile Shaders")) {
		// Call the C++ function once when the button is clicked
		for(int i = 0; i < guiData.shaders.size(); i++)
		{
			guiData.shaders[i].recompile();
		}

		guiData.cmpShader.recompile();
	}

	ImGui::Spacing();

	for(int i = 0; i < guiData.shaders.size(); i++)
	{
		std::string label = std::to_string(i) + " - " + guiData.shaderNames[i];

		if (ImGui::Selectable(label.c_str(), i == guiData.activeShader))
		{
			guiData.activeShader = i;
		}
	}

	ImGui::Spacing();
	ImGui::Spacing();

	ImGui::SetWindowFontScale(1.5f);
	ImGui::Text("Performance:");
	ImGui::SetWindowFontScale(1.0f);

	ImGui::Spacing();

	ImGui::Text("Frame Time: %.3f ms", deltaTime);
	ImGui::Text("FPS: %.1f", 1000.0f / deltaTime);

	ImGui::End();

	ImGui::Render();
	ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

