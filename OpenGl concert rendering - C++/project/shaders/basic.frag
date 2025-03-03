#version 410 core

in vec3 fPosition;
in vec3 fNormal;
in vec2 fTexCoords;
in vec4 fragPosLightSpace;

out vec4 fColor;

//matrices
uniform mat4 model;
uniform mat4 view;
uniform mat3 normalMatrix;

//lighting
uniform vec3 lightDir;
uniform vec3 lightColor;
uniform vec3 lightPosEye;

// textures
uniform sampler2D diffuseTexture;
uniform sampler2D specularTexture;
uniform sampler2D shadowMap;

// point light
uniform vec3 lightPosEye1;
uniform vec3 lightPosEye2;

//spot light
uniform vec3 spotlightPos1;
uniform vec3 spotlightDir1;

uniform vec3 spotlightPos2;
uniform vec3 spotlightDir2;
uniform float spotlightCutOff;

// night and fog toggle
uniform float night;
uniform float fog;

//components
vec3 ambient;
float ambientStrength = 0.2f;
vec3 diffuse;
vec3 specular;
float specularStrength = 0.5f;
float shadow;

float constant = 1.0f;
float linear = 0.0045f;
float quadratic = 0.0075f;

void computeDirLight()
{
    	//compute eye space coordinates
    	vec4 fPosEye = view * model * vec4(fPosition, 1.0f);
    	vec3 normalEye = normalize(normalMatrix * fNormal);

    	//normalize light direction
	vec3 lightDirN = normalize(lightDir);

	//compute view direction
	vec3 viewDirN = normalize( - fPosEye.xyz);

	//compute half vector
	vec3 halfVector = normalize(lightDirN + viewDirN);
	
	//compute ambient light
	ambient = ambientStrength * lightColor;
	
	//compute diffuse light
	diffuse = max(dot(normalEye, lightDirN), 0.0f) * lightColor;

	//compute specular light
	float specCoeff = pow(max(dot(normalEye, halfVector), 0.0f), 32);
	specular = specularStrength * specCoeff * lightColor;	
}

void computePointLight(vec3 lightPosEyeX)
{
	vec4 fPosEye = view * model * vec4(fPosition, 1.0f);
    	vec3 normalEye = normalize(normalMatrix * fNormal);

	vec3 lightDirN = normalize(lightPosEyeX - fPosEye.xyz);
    	vec3 viewDir = normalize(lightPosEyeX-fPosEye.xyz);
    	vec3 halfVector = normalize(lightDirN + viewDir);
	
	float dist = length(lightPosEyeX - fPosEye.xyz);
    	float att = 1.0f / (constant + linear * dist + quadratic * (dist * dist));

    	ambient += att * ambientStrength * lightColor;
    	diffuse += att * max(dot(normalEye, lightDirN), 0.0f) * lightColor;
    	float specCoeff = pow(max(dot(normalEye, halfVector), 0.0f), 32);
    	specular += att * specularStrength * specCoeff * lightColor;
}

void computeSpotlight(vec3 lightPosX, vec3 lightDirX, float cutOffAngle) {
    	vec4 fPosEye = view * model * vec4(fPosition, 1.0f);
    	vec3 normalEye = normalize(normalMatrix * fNormal);

    	vec3 lightDirN = normalize(lightPosX - fPosEye.xyz);

    	float theta = dot(lightDirN, normalize(-lightDirX));

    	if (theta > cutOffAngle) {
        	vec3 viewDir = normalize(-fPosEye.xyz);
        	vec3 halfVector = normalize(lightDirN + viewDir);

        	float dist = length(lightPosX - fPosEye.xyz);
        	float att = 1.0f / (constant + linear * dist + quadratic * (dist * dist));

        	ambient += att * ambientStrength * lightColor;
        	diffuse += att * max(dot(normalEye, lightDirN), 0.0f) * lightColor;

        	float specCoeff = pow(max(dot(normalEye, halfVector), 0.0f), 32);
        	specular += att * specularStrength * specCoeff * lightColor;
    	}
}


float computeShadow() 
{
	// perform perspective divide
	vec3 normalizedCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;

	// Transform to [0,1] range
	normalizedCoords = normalizedCoords * 0.5 + 0.5;

	// Eliminre supra-esantionare
	if (normalizedCoords.z > 1.0f)
		return 0.0f;
	
	// Get closest depth value from light's perspective
	float closestDepth = texture(shadowMap, normalizedCoords.xy).r;

	// Get depth of current fragment from light's perspective
	float currentDepth = normalizedCoords.z;

	// Check whether current frag pos is in shadow
	float bias = 0.005f;
	float shadow = currentDepth - bias > closestDepth ? 1.0f : 0.0f;

	return shadow;
}

float computeFog()
{
	float fogDensity = 0.05f;
	vec4 fPosEye = view * model * vec4(fPosition, 1.0f);
	float fragmentDistance = length(fPosEye);
	float fogFactor = exp(-pow(fragmentDistance * fogDensity, 2));
	return clamp(fogFactor, 0.0f, 1.0f);
}

void main() 
{	
	if (night < 0.01f) {
    		computeDirLight();
	} else {
		//computePointLight(lightPosEye1);
		//computePointLight(lightPosEye2);
		computeSpotlight(spotlightPos1, spotlightDir1, spotlightCutOff);
    		computeSpotlight(spotlightPos2, spotlightDir2, spotlightCutOff);
	}
	
	shadow = computeShadow();

    	//compute final vertex color
    	// vec3 color = min((ambient + (1.0f - shadow) * diffuse) * texture(diffuseTexture, fTexCoords).rgb + (1.0f - shadow) * specular * texture(specularTexture, fTexCoords).rgb, 1.0f);
	vec3 color = min((ambient + diffuse) * texture(diffuseTexture, fTexCoords).rgb + specular * texture(specularTexture, fTexCoords).rgb, 1.0f);	

	if (fog > 0.01f) {
		float fogFactor = computeFog();
		vec4 fogColor = vec4(0.5f, 0.5f, 0.5f, 1.0f);
		fColor = fogColor * (1.0f - fogFactor) + vec4(color, 1.0f) * fogFactor;
	} else {
    		fColor = vec4(color, 1.0f);
	}
}
