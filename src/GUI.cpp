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

void RenderGui(GuiData& guiData, float deltaTime, int mouseIndex, glm::vec3& g_currentColor, glm::vec4& storedColor, float& interval_0, float& interval_1, float& interval_2, float& interval_3)
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
		guiData.cmpShdRCLvl_0.recompile();
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

	ImGui::Text("Light & Interval Settings");

	ImGui::ColorEdit4("Select Color", &storedColor.r);

	g_currentColor.r = storedColor.r;
	g_currentColor.g = storedColor.g;
	g_currentColor.b = storedColor.b;


	//Use drag float instead to type or drag:
	//example:
	/*
	if (ImGui::DragFloat3("Position XYZ", &pos[0], v_speed))  
	{
	*/
	ImGui::SliderFloat("RC_0 Interval", &interval_0, 0.0f, 200.0f);
	ImGui::SliderFloat("RC_1 Interval", &interval_1, 0.0f, 200.0f);
	ImGui::SliderFloat("RC_2 Interval", &interval_2, 0.0f, 200.0f);
	ImGui::SliderFloat("RC_3 Interval", &interval_3, 0.0f, 200.0f);

	ImGui::Spacing();
	ImGui::Spacing();

	ImGui::SetWindowFontScale(1.5f);
	ImGui::Text("Performance:");
	ImGui::SetWindowFontScale(1.0f);

	ImGui::Spacing();

	ImGui::Text("Frame Time: %.3f ms", deltaTime);
	ImGui::Text("FPS: %.1f", 1000.0f / deltaTime);

	ImGui::Spacing();

	ImGui::Text("No. SDFs: ", mouseIndex);

	ImGui::End();

	ImGui::Render();
	ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
}

