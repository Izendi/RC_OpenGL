#version 430 core

layout(local_size_x = 2, local_size_y = 2, local_size_z = 1) in;

layout(rgba32f, binding = 1) uniform image2D imgOutput;

uniform float mouseX[20];
uniform float mouseY[20];

uniform int mouseIndex;

float sdfCircle(vec2 p, vec2 circelPos, float radius)
{
    return length(p - circelPos) - radius;
}

void main()
{
    uint iterationID = (gl_WorkGroupSize.x - 1 - gl_LocalInvocationID.x) + gl_LocalInvocationID.y * gl_WorkGroupSize.x;; //This means we start at the top right and go anticlockwise.

    float angle = radians((45 + (90 * iterationID)));
    vec2 dirVec = vec2(cos(angle), sin(angle)); //This vector is already normalized by default.

    vec4 value = vec4(dirVec.x, dirVec.y, 0.0, 1.0);

    ivec2 texelCoord = ivec2(gl_GlobalInvocationID.xy);

	float rayStartDistanceFromNode = 50.0;
    float lvl_0_interval = 50.0;

    // ADDED: + (dirVec * rayStartDistanceFromNode) //To very stange results...
    vec2 rayOrigin = vec2((gl_WorkGroupID.x * 2) + 1, (gl_WorkGroupID.y * 2) + 1) + (dirVec * rayStartDistanceFromNode); 

    vec2 ray = rayOrigin; 

    // ------

    value = vec4(0.1, 0.1, 0.1, 1.0); //Default value if ray does not hit a sphere.

    float distanceFromNearestSDF = 10.0;

    float radius = 20.0;

    for (int i = 0; i < 10; i++)
    {

        if (distanceFromNearestSDF < 0.1)
        {
            value = vec4(1.0, 0.0, 1.0, 1.0); //Make fragment red if ray intersects with a sphere.
            break;
        }

        if (distance(ray, rayOrigin) > lvl_0_interval)
        {
            break;
        }

        for (int ii = 0; ii < mouseIndex; ii++)
        {
            vec2 circlePosition = vec2(mouseX[ii]*512.0, mouseY[ii]*512.0);
            float newDistance = sdfCircle(ray, circlePosition, radius);
            
            distanceFromNearestSDF = min(distanceFromNearestSDF, newDistance);
        }

        ray = ray + dirVec * distanceFromNearestSDF;
    }

    // ------



    imageStore(imgOutput, texelCoord, value);
}


