#pragma once
#include "utils.h"

std::pair<std::unique_ptr<GLFWwindow, void(*)(GLFWwindow*)>, ImGuiIO&> SetUpGui(std::unique_ptr<GLFWwindow, void(*)(GLFWwindow*)> p_glfw_Window);

void RenderGui();