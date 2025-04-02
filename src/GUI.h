#pragma once
#include "utils.h"

std::pair<std::unique_ptr<GLFWwindow, void(*)(GLFWwindow*)>, ImGuiIO&> SetUpGui(std::unique_ptr<GLFWwindow, void(*)(GLFWwindow*)> p_glfw_Window);

void RenderGui(GuiData& guiData, float deltaTime, int mouseIndex, glm::vec3& g_currentColor, glm::vec4 &storedColor, float& interval_0, float& interval_1, float& interval_2, float& interval_3);