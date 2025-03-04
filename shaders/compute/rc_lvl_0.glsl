#version 430 core

layout(local_size_x = 2, local_size_y = 2, local_size_z = 1) in;

layout(rgba32f, binding = 1) uniform image2D imgOutput;

uniform float mouseX[100];
uniform float mouseY[100];

uniform int mouseIndex;

/*
vec2 rotateVecAntiClockwise(vec2 v, float radians)
{
    float c = cos(radians);
    float s = sin(radians);

    return vec2
    (
        c * v.x - s * v.y,
        s * v.x + c * v.y
    );
}
*/

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

    vec2 rayOrigin = vec2((gl_WorkGroupID.x * 2) + 1, (gl_WorkGroupID.y * 2) + 1);

    vec2 ray = rayOrigin + dirVec; 

    /*
    if (gl_GlobalInvocationID.x < 100)
    {
        value = vec4(1.0, 0.0, 0.0, 1.0);
    }
    else
    {
        value == vec4(0.0, 0.0, 1.0, 1.0);
    }
    */

    // ------

    value = vec4(0.1, 0.1, 0.1, 1.0); //Default value if ray does not hit a sphere.

    float distanceFromNearestSDF = 10.0;

    //vec2 circlePositions[11];

    //Remember, canvas will be 512 by 512 in this test
    /*
    circlePositions[0] = vec2(256.0, 256.0);
    circlePositions[1] = vec2(50.0 , 50.0);
    circlePositions[2] = vec2(100.0, 300.0);
    circlePositions[3] = vec2(50.0 , 300.0);
    circlePositions[4] = vec2(450.0, 450.0);
    circlePositions[5] = vec2(450.0, 65.0);
    circlePositions[6] = vec2(500.0, 345.0);
    circlePositions[7] = vec2(134.0, 28.0);
    circlePositions[8] = vec2(380.0, 200.0);
    circlePositions[9] = vec2(30.0 , 478.0);
    circlePositions[10] = vec2(256, 300.0);
    */

    /*
    circlePositions[0] = vec2(0.0, 0.0);
    circlePositions[1] = vec2(0.0, 0.0);
    circlePositions[2] = vec2(0.0, 0.0);
    circlePositions[3] = vec2(256.0, 240.0);
    circlePositions[4] = vec2(256.0, 356.0);
    circlePositions[5] = vec2(356.0, 356.0);
    circlePositions[6] = vec2(356.0, 256.0);
    circlePositions[7] = vec2(0.0, 0.0);
    circlePositions[8] = vec2(0.0, 0.0);
    circlePositions[9] = vec2(0.0, 0.0);
    circlePositions[10]= vec2(0.0, 0.0);
    */

    //ray equation = O + Pt

    float radius = 20.0;

    for (int i = 0; i < 10; i++)
    {
        
        if (distanceFromNearestSDF > 10.1)
        {
            break;
        }
        

        if (distanceFromNearestSDF < 0.1)
        {
            value = vec4(1.0, 0.0, 1.0, 1.0); //Make fragment red if ray intersects with a sphere.
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


