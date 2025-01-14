#version 330 core

in vec2 texCoord;

out vec4 FragColor;

uniform vec4 ourColor;

uniform vec2 uMousePos;
uniform vec2 uResolution;
uniform float uMousePressed;
uniform float uTime;

vec3 YELLOW = vec3(1.0 , 1.0 , 0.5 );
vec3 BLUE   = vec3(0.25, 0.25, 1.0 );
vec3 RED    = vec3(1.0 , 0.25, 0.25);
vec3 GREEN  = vec3(0.25, 1.0 , 0.25);
vec3 PURPLE = vec3(1.0 , 0.25, 1.0 );
vec3 BLACK  = vec3(0.0 , 0.0 , 0.0 );
vec3 WHITE  = vec3(1.0 , 1.0 , 1.0 );
vec3 GREY   = vec3(0.6 , 0.6 , 0.6 );

float inverseLerp(float v, float minValue, float maxValue) {
  return (v - minValue) / (maxValue - minValue);
}

float remap(float v, float inMin, float inMax, float outMin, float outMax) {
  float t = inverseLerp(v, inMin, inMax);
  return mix(outMin, outMax, t);
}

vec3 BackgroundColor()
{
  float distFromCenter = length(abs(texCoord - 0.5));

  float vignette = 1.0 - distFromCenter;

  vignette = smoothstep(0.0, 0.7, vignette);
  vignette = remap(vignette, 0.0, 1.0, 0.3, 1.0);

  return vec3(vignette);
}

vec3 drawGrid(vec3 color, vec3 lineColor, float cellSpacing, float lineWidth) 
{
  vec2 center = texCoord - 0.5;
  vec2 cells = abs(fract(center * uResolution / cellSpacing) - 0.5);
  float distToEdge = (0.5 - max(cells.x, cells.y)) * cellSpacing;
  float lines = smoothstep(0.0, lineWidth, distToEdge);

  color = mix(lineColor, color, lines);

  return color;
}

float sdfCircle(vec2 fragPos, float r, float offset_y, float offset_x)
{
  fragPos.x = fragPos.x + offset_x;
  fragPos.y = fragPos.y + offset_y;
  return length(fragPos) - r;
}

float sdfSphere(vec3 pos, vec3 center, float r)
{
  return distance(pos, center) - r;
}

float sdfLine(vec2 p, vec2 a, vec2 b)
{
  vec2 pa = p - a;
  vec2 ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);

  return length(pa - ba * h);
}

float sdfBox(vec2 p, vec2 b)
{
  vec2 d = abs(p) - b;
  return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
}

mat2 rotate2D(float angle)
{
  float s = sin(angle);
  float c = cos(angle);

  return mat2(c, -s, s, c);
}

  vec3 rotateAroundY(vec3 v, float angle) 
  {
    float cosTheta = cos(angle);
    float sinTheta = sin(angle);

    return vec3(
        v.x * cosTheta + v.z * sinTheta, // New X
        v.y,                             // New Y (unchanged)
        v.z * cosTheta - v.x * sinTheta  // New Z
    );
  }

void main() 
{
  vec2 pixelCoords = (texCoord - 0.5) * uResolution;
  vec2 NDC_2d = (texCoord - 0.5) * 2.0;


  float x = step((abs(mod(texCoord.x, 0.025))), 0.004); // if value is less than 0.004 return 1
  float y = step((abs(mod(texCoord.y, 0.025))), 0.004);

  //Combine the x and y values, we can use max for this:
  //Here if at least 1 is black it will return 1.0
  float isBlack = max(x, y);

  vec4 black = vec4(BLACK, 1.0);
  vec4 white = vec4(WHITE, 1.0);

  //gl_FragColor = mix(vec4(BackgroundColor(), 1.0), black, isBlack);
 
  vec3 finalColor = BackgroundColor();
  finalColor = drawGrid(finalColor, GREY, 10.0, 1.0);
  finalColor = drawGrid(finalColor, BLACK, 100.0, 1.5);

  float d = sdfCircle(pixelCoords, 50.0, -100.0, 150.0);
  finalColor = mix(RED, finalColor, step(0.0, d));

  d = sdfCircle(pixelCoords, 50.0, -100.0, -150.0);
  finalColor = mix(RED, finalColor, step(0.0, d));

  vec2 pos = pixelCoords - vec2(200.0, 300.0);
  pos *= rotate2D(uTime * 1.55);
  d = sdfBox(pos, vec2(100.0, 50.0));
  finalColor = mix(PURPLE, finalColor, step(0.0, d));

  float d2 = sdfLine(pixelCoords, vec2(-200.0, -200.0), vec2(200.0, -120.0));
  finalColor = mix(RED, finalColor, step(5.0, d2));
  
  //gl_FragColor = vec4(finalColor, 1.0);

  //Ray Marching in 3D

  vec3 fc = BackgroundColor();

  float distanceFromSphere = 100.0;

  float sphereRadius = 1.0;
  vec3 sphereCenter = vec3(0.0, 0.0, -3.0);
  vec3 cameraPos = vec3(0.0, 0.0, 1.0);
  vec3 pointLight = vec3(-2.0, 2.0, -1.0);

  pointLight = sphereCenter + rotateAroundY(vec3(-2.0, 1.0, 0.0), uTime);

  //ray equation = O + Pt

  vec3 rayDir = vec3(NDC_2d.xy, 0.0) - cameraPos;
  vec3 ray = rayDir;
  rayDir = normalize(ray);

  vec3 lightDirVec;

  for(int i = 0; i < 10; i++)
  {
    if(distanceFromSphere < 0.1)
    {
      lightDirVec = pointLight - ray;
      lightDirVec = normalize(lightDirVec);

      vec3 surfaceNormal = normalize((ray - sphereCenter));

      float diffuseLight = dot(lightDirVec, surfaceNormal);

      diffuseLight = max(0.0, diffuseLight);

      fc = RED * diffuseLight;
      break;
    }
    distanceFromSphere = sdfSphere(ray, sphereCenter, sphereRadius);
    ray = ray + rayDir*distanceFromSphere;
  }

  //float sphere_d = sdfSphere(vec3(NDC_2d.xy, 1.0), vec3(0.0, 0.0, 3.0), 1.0);
  //vec3 rmColor = mix(RED, fc, step(5.0, sphere_d));
  
  FragColor = vec4(fc.xyz, 1.0);
  //FragColor = vec4(0.5, 0.0, 0.0, 1.0);

  //FragColor = vec4(texCoord.y, texCoord.y, 0.5, 1.0);



  // if((abs(mod(vUvs.x, 0.025)) < 0.004) || abs(mod(vUvs.y, 0.025)) < 0.004 )
  // {
  //   gl_FragColor = vec4(BLACK, 1.0);
  // }
  // else
  // {
  //   gl_FragColor = vec4(WHITE, 1.0);
  // }
}

