#if defined (__APPLE__)
    #define GLFW_INCLUDE_GLCOREARB
    #define GL_SILENCE_DEPRECATION
#else
    #define GLEW_STATIC
    #include <GL/glew.h>
#endif

#include <GLFW/glfw3.h>

#include <glm/glm.hpp> //core glm functionality
#include <glm/gtc/matrix_transform.hpp> //glm extension for generating common transformation matrices
#include <glm/gtc/matrix_inverse.hpp> //glm extension for computing inverse matrices
#include <glm/gtc/type_ptr.hpp> //glm extension for accessing the internal data structure of glm types

#include "Window.h"
#include "Shader.hpp"
#include "Camera.hpp"
#include "Model3D.hpp"
#include "SkyBox.hpp"

#include <iostream>
#include <cstdlib>  
#include <ctime>    

// window
gps::Window myWindow;

const unsigned int SHADOW_WIDTH = 2048;
const unsigned int SHADOW_HEIGHT = 2048;

// matrices
glm::mat4 model;
glm::mat4 view;
glm::mat4 projection;
glm::mat3 normalMatrix;
glm::mat4 lightRotation;

// light parameters
glm::vec3 lightDir;
glm::vec3 lightColor;
glm::vec3 lightPosEye;

glm::vec3 lightPosEye1;
glm::vec3 lightPosEye2;

glm::vec3 spotlightPos1;
glm::vec3 spotlightPos2;
glm::vec3 spotlightDir1;
glm::vec3 spotlightDir2;
float spotlightCutOff;

// shader uniform locations
GLint modelLoc;
GLint viewLoc;
GLint projectionLoc;
GLint normalMatrixLoc;
GLint lightDirLoc;
GLint lightColorLoc;
GLuint lightPosEyeLoc;

GLint nightLoc;
GLint fogLoc;
GLuint lightPosEye1Loc;
GLuint lightPosEye2Loc;

GLuint spotlightPos1Loc;
GLuint spotlightPos2Loc;
GLuint spotlightDir1Loc;
GLuint spotlightDir2Loc;
GLuint spotlightCutOffLoc;


GLuint shadowMapFBO;
GLuint depthMapTexture;

// camera
gps::Camera myCamera(
    glm::vec3(0.0f, 0.0f, 1.0f),
    glm::vec3(0.0f, 0.0f, -10.0f),
    glm::vec3(0.0f, 1.0f, 0.0f));

GLfloat cameraSpeed = 0.1f;
GLfloat lightAngle;
float night = 0.0f;
float fog = 0.0f;

GLboolean pressedKeys[1024];

// models
gps::Model3D ground;
gps::Model3D stage;
gps::Model3D casualMan;
gps::Model3D lightCube;
gps::Model3D screenQuad;
gps::Model3D streetLamp;
gps::Model3D sun;
GLfloat angle;

// shaders
gps::Shader myBasicShader;
gps::Shader lightShader;
gps::Shader depthMapShader;
gps::Shader screenQuadShader;

gps::SkyBox mySkyBox;
gps::Shader skyboxShader;

bool showDepthMap;
bool runAnimation = false;
float startTime = 0.0f;

float randomOffset(float range) {
    return (static_cast<float>(rand()) / RAND_MAX) * 2.0f * range - range;
}

struct CollisionBox {
    glm::vec3 position; 
    glm::vec3 size;     
};

std::vector<CollisionBox> objects = {
    { glm::vec3(7.0f, 0.0f, 1.0f), glm::vec3(2.0f, 5.0f, 2.0f) },
    { glm::vec3(-7.0f, 0.0f, 1.0f), glm::vec3(2.0f, 5.0f, 2.0f) }, 
    { glm::vec3(0.0f, -1.0f, -4.5f), glm::vec3(20.0f, 1.0f, 20.0f) }, 
    { glm::vec3(10.0f, 4.0f, 0.0f), glm::vec3(1.0f, 20.0f, 20.0f) },
    { glm::vec3(-10.0f, 4.0f, 0.0f), glm::vec3(1.0f, 20.0f, 20.0f) },
    { glm::vec3(0.0f, 4.0f, -13.0f), glm::vec3(20.0f, 20.0f, 5.0f) },
    { glm::vec3(0.0f, 4.0f, 8.0f), glm::vec3(20.0f, 20.0f, 5.0f) },
    { glm::vec3(0.0f, 12.0f, 0.0f), glm::vec3(20.0f, 1.0f, 20.0f) }
};

bool checkCollision(const glm::vec3& cameraPos, const CollisionBox& box) {
    float cameraRadius = 0.5f; // some space around the camera


    glm::vec3 boxMin = box.position - box.size / 2.0f; 
    glm::vec3 boxMax = box.position + box.size / 2.0f; 

    if (cameraPos.x + cameraRadius > boxMin.x && cameraPos.x - cameraRadius < boxMax.x &&
        cameraPos.y + cameraRadius > boxMin.y && cameraPos.y - cameraRadius < boxMax.y &&
        cameraPos.z + cameraRadius > boxMin.z && cameraPos.z - cameraRadius < boxMax.z) {

        return true; 
    }

    return false; 
}

void initSkyBox() {
    std::vector<const GLchar*> faces;
    faces.push_back("skybox/right.tga");
    faces.push_back("skybox/left.tga");
    faces.push_back("skybox/top.tga");
    faces.push_back("skybox/bottom.tga");
    faces.push_back("skybox/back.tga");
    faces.push_back("skybox/front.tga");

    mySkyBox.Load(faces);

}

enum RenderingMode {
    SOLID,
    WIREFRAME,
    POLYGONAL,
    SMOOTH,
};

RenderingMode currentMode = SOLID; 

void setRenderingMode(RenderingMode mode) {
    switch (mode) {
    case SOLID:
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        break;
    case WIREFRAME:
        glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        break;
    case POLYGONAL:
        glPolygonMode(GL_FRONT_AND_BACK, GL_POINT);
        break;
    case SMOOTH:
        glEnable(GL_BLEND);
        glEnable(GL_MULTISAMPLE);
        glEnable(GL_SMOOTH);
        glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        break;
    }
}

GLenum glCheckError_(const char *file, int line)
{
	GLenum errorCode;
	while ((errorCode = glGetError()) != GL_NO_ERROR) {
		std::string error;
		switch (errorCode) {
            case GL_INVALID_ENUM:
                error = "INVALID_ENUM";
                break;
            case GL_INVALID_VALUE:
                error = "INVALID_VALUE";
                break;
            case GL_INVALID_OPERATION:
                error = "INVALID_OPERATION";
                break;
            case GL_OUT_OF_MEMORY:
                error = "OUT_OF_MEMORY";
                break;
            case GL_INVALID_FRAMEBUFFER_OPERATION:
                error = "INVALID_FRAMEBUFFER_OPERATION";
                break;
        }
		std::cout << error << " | " << file << " (" << line << ")" << std::endl;
	}
	return errorCode;
}
#define glCheckError() glCheckError_(__FILE__, __LINE__)

void windowResizeCallback(GLFWwindow* window, int width, int height) {
	fprintf(stdout, "Window resized! New width: %d , and height: %d\n", width, height);
	//TODO
    WindowDimensions windowDim = { width, height };

    myWindow.setWindowDimensions(windowDim);

    glViewport(0, 0, windowDim.width, windowDim.height);

    myBasicShader.useShaderProgram();

    projection = glm::perspective(glm::radians(45.0f), (float)width / (float)height, 0.1f, 1000.0f);

    projectionLoc = glGetUniformLocation(myBasicShader.shaderProgram, "projection");
    glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, glm::value_ptr(projection));
}

void keyboardCallback(GLFWwindow* window, int key, int scancode, int action, int mode) {
	if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GL_TRUE);
    }

    if (key == GLFW_KEY_M && action == GLFW_PRESS)
        showDepthMap = !showDepthMap;

    if (pressedKeys[GLFW_KEY_N]) {
        night = (night == 0.0f) ? 1.0f : 0.0f;
        myBasicShader.useShaderProgram();
        glUniform1f(nightLoc, night);
    }

    if (pressedKeys[GLFW_KEY_F]) {
        fog = (fog == 0.0f) ? 1.0f : 0.0f;
        myBasicShader.useShaderProgram();
        glUniform1f(fogLoc, fog);
    }

    if (pressedKeys[GLFW_KEY_P]) {
        runAnimation = !runAnimation;
        startTime = glfwGetTime();
    }

    if (glfwGetKey(window, GLFW_KEY_1) == GLFW_PRESS) {
        currentMode = SOLID;
        setRenderingMode(currentMode);
    }
    if (glfwGetKey(window, GLFW_KEY_2) == GLFW_PRESS) {
        currentMode = WIREFRAME;
        setRenderingMode(currentMode);
    }
    if (glfwGetKey(window, GLFW_KEY_3) == GLFW_PRESS) {
        currentMode = POLYGONAL;
        setRenderingMode(currentMode);
    }
    if (glfwGetKey(window, GLFW_KEY_4) == GLFW_PRESS) {
        currentMode = SMOOTH;
        setRenderingMode(currentMode);
    }

	if (key >= 0 && key < 1024) {
        if (action == GLFW_PRESS) {
            pressedKeys[key] = true;
        } else if (action == GLFW_RELEASE) {
            pressedKeys[key] = false;
        }
    }
}

float speed = 0.002f;

bool firstMove = true;
float lastX = 400, lastY = 300;
float offsetX = 0.0f, offsetY = 0.0f;
float yaw = 0.0f, pitch = 0.0f;
float sensitivity = 0.1f;

void mouseCallback(GLFWwindow* window, double xpos, double ypos) {
    //TODO
    if (firstMove) {
        lastX = xpos;
        lastY = ypos;
        firstMove = false;
    }

    offsetX = (lastX - xpos) * sensitivity;
    offsetY = -(ypos - lastY) * sensitivity;

    lastX = xpos;
    lastY = ypos;

    yaw += offsetX;
    pitch += offsetY;

    if (pitch > 89.0f)
        pitch = 89.0f;
    if (pitch < -89.0f)
        pitch = -89.0f;

    myCamera.rotate(pitch, yaw);
    view = myCamera.getViewMatrix();
    glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
}


void processMovement() {

    bool collisionDetected = false;
    glm::vec3 newCameraPos;

	if (pressedKeys[GLFW_KEY_W]) {
        newCameraPos = myCamera.getPosition() + cameraSpeed * myCamera.getFrontDirection();

        for (const auto& box : objects) {
            if (checkCollision(newCameraPos, box)) {
                collisionDetected = true;
                break;
            }
        }

        if (!collisionDetected) {
            myCamera.move(gps::MOVE_FORWARD, cameraSpeed);
            //update view matrix
            view = myCamera.getViewMatrix();
            myBasicShader.useShaderProgram();
            glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
            // compute normal matrix for teapot
            normalMatrix = glm::mat3(glm::inverseTranspose(view * model));
            glUniform3fv(spotlightPos1Loc, 1, glm::value_ptr(glm::vec3(view * glm::vec4(spotlightPos1, 1.0f))));
            glUniform3fv(spotlightDir1Loc, 1, glm::value_ptr(glm::normalize(glm::vec3(view * glm::vec4(glm::normalize(glm::vec3(0.0f, 0.0f, 0.0f) - spotlightPos1), 0.0f)))));
        }
	}

	if (pressedKeys[GLFW_KEY_S]) {
        newCameraPos = myCamera.getPosition() - cameraSpeed * myCamera.getFrontDirection();

        for (const auto& box : objects) {
            if (checkCollision(newCameraPos, box)) {
                collisionDetected = true;
                break;
            }
        }

        if (!collisionDetected) {
            myCamera.move(gps::MOVE_BACKWARD, cameraSpeed);
            //update view matrix
            view = myCamera.getViewMatrix();
            myBasicShader.useShaderProgram();
            glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
            // compute normal matrix for teapot
            normalMatrix = glm::mat3(glm::inverseTranspose(view * model));
            glUniform3fv(spotlightPos1Loc, 1, glm::value_ptr(glm::vec3(view * glm::vec4(spotlightPos1, 1.0f))));
            glUniform3fv(spotlightDir1Loc, 1, glm::value_ptr(glm::normalize(glm::vec3(view * glm::vec4(glm::normalize(glm::vec3(0.0f, 0.0f, 0.0f) - spotlightPos1), 0.0f)))));
        }
	}

	if (pressedKeys[GLFW_KEY_A]) {
        newCameraPos = myCamera.getPosition() - cameraSpeed * myCamera.getRightDirection();

        for (const auto& box : objects) {
            if (checkCollision(newCameraPos, box)) {
                collisionDetected = true;
                break;
            }
        }

        if (!collisionDetected) {
            myCamera.move(gps::MOVE_LEFT, cameraSpeed);
            //update view matrix
            view = myCamera.getViewMatrix();
            myBasicShader.useShaderProgram();
            glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
            // compute normal matrix for teapot
            normalMatrix = glm::mat3(glm::inverseTranspose(view * model));
            glUniform3fv(spotlightPos1Loc, 1, glm::value_ptr(glm::vec3(view * glm::vec4(spotlightPos1, 1.0f))));
            glUniform3fv(spotlightDir1Loc, 1, glm::value_ptr(glm::normalize(glm::vec3(view * glm::vec4(glm::normalize(glm::vec3(0.0f, 0.0f, 0.0f) - spotlightPos1), 0.0f)))));
        }
	}

	if (pressedKeys[GLFW_KEY_D]) {
        newCameraPos = myCamera.getPosition() + cameraSpeed * myCamera.getRightDirection();

        for (const auto& box : objects) {
            if (checkCollision(newCameraPos, box)) {
                collisionDetected = true;
                break;
            }
        }

        if (!collisionDetected) {
            myCamera.move(gps::MOVE_RIGHT, cameraSpeed);
            //update view matrix
            view = myCamera.getViewMatrix();
            myBasicShader.useShaderProgram();
            glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));
            // compute normal matrix for teapot
            normalMatrix = glm::mat3(glm::inverseTranspose(view * model));
            glUniform3fv(spotlightPos1Loc, 1, glm::value_ptr(glm::vec3(view * glm::vec4(spotlightPos1, 1.0f))));
            glUniform3fv(spotlightDir1Loc, 1, glm::value_ptr(glm::normalize(glm::vec3(view * glm::vec4(glm::normalize(glm::vec3(0.0f, 0.0f, 0.0f) - spotlightPos1), 0.0f)))));
        }
	}

    if (pressedKeys[GLFW_KEY_Q]) {
        angle -= 1.0f;
        // update model matrix for teapot
        model = glm::rotate(glm::mat4(1.0f), glm::radians(angle), glm::vec3(0, 1, 0));
        // update normal matrix for teapot
        normalMatrix = glm::mat3(glm::inverseTranspose(view*model));
    }

    if (pressedKeys[GLFW_KEY_E]) {
        angle += 1.0f;
        // update model matrix for teapot
        model = glm::rotate(glm::mat4(1.0f), glm::radians(angle), glm::vec3(0, 1, 0));
        // update normal matrix for teapot
        normalMatrix = glm::mat3(glm::inverseTranspose(view*model));
    }

    if (pressedKeys[GLFW_KEY_J]) {
        if (lightAngle >= -45.0f) {
            lightAngle -= 1.0f;
        }
        // update model matrix for teapot
        model = glm::rotate(glm::mat4(1.0f), glm::radians(angle), glm::vec3(1, 0, 0));
        // update normal matrix for teapot
        normalMatrix = glm::mat3(glm::inverseTranspose(view * model));
    }

    if (pressedKeys[GLFW_KEY_L]) {
        if (lightAngle <= 100) {
            lightAngle += 1.0f;
        }
        // update model matrix for teapot
        model = glm::rotate(glm::mat4(1.0f), glm::radians(angle), glm::vec3(1, 0, 0));
        // update normal matrix for teapot
        normalMatrix = glm::mat3(glm::inverseTranspose(view * model));
    }
}

void initOpenGLWindow() {
    myWindow.Create(1024, 768, "OpenGL Project Core");
}

void setWindowCallbacks() {
	glfwSetWindowSizeCallback(myWindow.getWindow(), windowResizeCallback);
    glfwSetKeyCallback(myWindow.getWindow(), keyboardCallback);
    glfwSetCursorPosCallback(myWindow.getWindow(), mouseCallback);
}

void initOpenGLState() {
	glClearColor(0.7f, 0.7f, 0.7f, 1.0f);
	glViewport(0, 0, myWindow.getWindowDimensions().width, myWindow.getWindowDimensions().height);
    glEnable(GL_FRAMEBUFFER_SRGB);
	glEnable(GL_DEPTH_TEST); // enable depth-testing
	glDepthFunc(GL_LESS); // depth-testing interprets a smaller value as "closer"
	glEnable(GL_CULL_FACE); // cull face
	glCullFace(GL_BACK); // cull back face
	glFrontFace(GL_CCW); // GL_CCW for counter clock-wise
}

void initModels() {
    ground.LoadModel("models/ground/ground.obj");
    stage.LoadModel("models/stage/stage.obj");
    casualMan.LoadModel("models/casualMan/casualMan.obj");
    lightCube.LoadModel("models/cube/cube.obj");
    screenQuad.LoadModel("models/quad/quad.obj");
    streetLamp.LoadModel("models/streetLamp/streetLamp.obj");
    sun.LoadModel("models/sun/sun.obj");
}

void initShaders() {
	myBasicShader.loadShader(
        "shaders/basic.vert",
        "shaders/basic.frag");
    lightShader.loadShader("shaders/lightCube.vert", "shaders/lightCube.frag");
    depthMapShader.loadShader("shaders/depthMapShader.vert", "shaders/depthMapShader.frag");
    skyboxShader.loadShader("shaders/skyboxShader.vert", "shaders/skyboxShader.frag");
    screenQuadShader.loadShader("shaders/screenQuad.vert", "shaders/screenQuad.frag");
}

void initUniforms() {
	myBasicShader.useShaderProgram();

    // create model matrix
    model = glm::rotate(glm::mat4(1.0f), glm::radians(angle), glm::vec3(0.0f, 1.0f, 0.0f));
	modelLoc = glGetUniformLocation(myBasicShader.shaderProgram, "model");

	// get view matrix for current camera
	view = myCamera.getViewMatrix();
	viewLoc = glGetUniformLocation(myBasicShader.shaderProgram, "view");
	// send view matrix to shader
    glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));

    // compute normal matrix
    normalMatrix = glm::mat3(glm::inverseTranspose(view*model));
	normalMatrixLoc = glGetUniformLocation(myBasicShader.shaderProgram, "normalMatrix");

	// create projection matrix
	projection = glm::perspective(glm::radians(45.0f),
                               (float)myWindow.getWindowDimensions().width / (float)myWindow.getWindowDimensions().height,
                               0.1f, 20.0f);
	projectionLoc = glGetUniformLocation(myBasicShader.shaderProgram, "projection");
	// send projection matrix to shader
	glUniformMatrix4fv(projectionLoc, 1, GL_FALSE, glm::value_ptr(projection));	

	//set the light direction (direction towards the light)
	lightDir = glm::vec3(0.0f, 6.0f, 1.0f);
    lightRotation = glm::rotate(glm::mat4(1.0f), glm::radians(lightAngle), glm::vec3(1.0f, 0.0f, 0.0f));
	lightDirLoc = glGetUniformLocation(myBasicShader.shaderProgram, "lightDir");
	// send light dir to shader
	glUniform3fv(lightDirLoc, 1, glm::value_ptr(lightDir));

	//set light color
	lightColor = glm::vec3(1.0f, 1.0f, 1.0f); //white light
	lightColorLoc = glGetUniformLocation(myBasicShader.shaderProgram, "lightColor");
	// send light color to shader
	glUniform3fv(lightColorLoc, 1, glm::value_ptr(lightColor));

    lightPosEye = glm::vec3(0.0f, 1.0f, 1.0f);
    lightPosEyeLoc = glGetUniformLocation(myBasicShader.shaderProgram, "lightPosEye");
    glUniform3fv(lightPosEyeLoc, 1, glm::value_ptr(glm::vec3(view * glm::vec4(lightPosEye, 1.0f))));

    // point light
    lightPosEye1 = glm::vec3(7.0f, 4.0f, 1.0f);
    lightPosEye1Loc = glGetUniformLocation(myBasicShader.shaderProgram, "lightPosEye1");
    glUniform3fv(lightPosEye1Loc, 1, glm::value_ptr(glm::vec3(view * glm::vec4(lightPosEye1, 1.0f))));

    lightPosEye2 = glm::vec3(-7.0f, 4.0f, 1.0f);
    lightPosEye2Loc = glGetUniformLocation(myBasicShader.shaderProgram, "lightPosEye2");
    glUniform3fv(lightPosEye2Loc, 1, glm::value_ptr(glm::vec3(view * glm::vec4(lightPosEye2, 1.0f))));

    // spotlight
    spotlightPos1 = glm::vec3(-7.0f, 4.0f, 1.0f);
    spotlightPos1Loc = glGetUniformLocation(myBasicShader.shaderProgram, "spotlightPos1");
    glUniform3fv(spotlightPos1Loc, 1, glm::value_ptr(glm::vec3(view * glm::vec4(spotlightPos1, 1.0f))));

    spotlightDir1 = glm::normalize(glm::vec3(0.0f, -2.0f, 0.0f) - spotlightPos1);
    spotlightDir1Loc = glGetUniformLocation(myBasicShader.shaderProgram, "spotlightDir1");
    glUniform3fv(spotlightDir1Loc, 1, glm::value_ptr(glm::normalize(glm::vec3(view * glm::vec4(glm::normalize(glm::vec3(0.0f, 0.0f, 0.0f) - spotlightPos1), 0.0f)))));

    spotlightPos2 = glm::vec3(-7.0f, 4.0f, 1.0f);
    spotlightPos2Loc = glGetUniformLocation(myBasicShader.shaderProgram, "spotlightPos2");
    glUniform3fv(spotlightPos2Loc, 1, glm::value_ptr(glm::vec3(view * glm::vec4(spotlightPos2, 1.0f))));

    spotlightDir2 = glm::normalize(glm::vec3(0.0f, -2.0f, 0.0f) - spotlightPos2);
    spotlightDir2Loc = glGetUniformLocation(myBasicShader.shaderProgram, "spotlightDir2");
    glUniform3fv(spotlightDir2Loc, 1, glm::value_ptr(spotlightDir2));

    spotlightCutOff = glm::cos(glm::radians(20.0f));
    spotlightCutOffLoc = glGetUniformLocation(myBasicShader.shaderProgram, "spotlightCutOff");
    glUniform1f(spotlightCutOffLoc, spotlightCutOff);

    nightLoc = glGetUniformLocation(myBasicShader.shaderProgram, "night");
    glUniform1f(nightLoc, night);

    fogLoc = glGetUniformLocation(myBasicShader.shaderProgram, "fog");
    glUniform1f(fogLoc, fog);


    lightShader.useShaderProgram();
    glUniformMatrix4fv(glGetUniformLocation(lightShader.shaderProgram, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
}

void initFBO() {
    //generate FBO ID
    glGenFramebuffers(1, &shadowMapFBO);

    //create depth texture for FBO
    glGenTextures(1, &depthMapTexture);
    glBindTexture(GL_TEXTURE_2D, depthMapTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT,
        SHADOW_WIDTH, SHADOW_HEIGHT, 0, GL_DEPTH_COMPONENT, GL_FLOAT, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    float borderColor[] = { 1.0f, 1.0f, 1.0f, 1.0f };
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);


    //attach texture to FBO
    glBindFramebuffer(GL_FRAMEBUFFER, shadowMapFBO);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depthMapTexture, 0);

    glDrawBuffer(GL_NONE);
    glReadBuffer(GL_NONE);

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

glm::mat4 computeLightSpaceTrMatrix() {
    //return the light-space transformation matrix
    glm::vec3 rotatedLightDir = glm::inverseTranspose(glm::mat3(lightRotation)) * lightDir; /////////////////////////////////////////////
    glm::mat4 lightView = glm::lookAt(rotatedLightDir, glm::vec3(0.0f), glm::vec3(0.0f, 1.0f, 0.0f));
    const GLfloat near_plane = 0.1f, far_plane = 6.0f;
    glm::mat4 lightProjection = glm::ortho(-1.0f, 1.0f, -1.0f, 1.0f, near_plane, far_plane);
    glm::mat4 lightSpaceTrMatrix = lightProjection * lightView;

    return lightSpaceTrMatrix;
}

void renderGround(gps::Shader shader) {
    // select active shader program
    shader.useShaderProgram();

    glm::mat4 groundModel = model;

    groundModel = glm::translate(groundModel, glm::vec3(0.0f, -0.6f, -4.5f));

    glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(groundModel));

    glm::mat3 groundNormalMatrix = glm::mat3(glm::inverseTranspose(view * groundModel));
    //glUniformMatrix3fv(normalMatrixLoc, 1, GL_FALSE, glm::value_ptr(normalMatrix));

    // draw
    ground.Draw(shader);
}

void renderStreetLamp(gps::Shader shader) {
    // select active shader program
    shader.useShaderProgram();

    for (int i = -1; i < 2; i+=2) {

        glm::mat4 streetLampModel = model;

        streetLampModel = glm::translate(streetLampModel, glm::vec3(i * 7.0f, -0.5f, 1.0f));
        streetLampModel = glm::scale(streetLampModel, glm::vec3(0.3f, 0.3f, 0.3f));
        glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(streetLampModel));

        glm::mat3 streetLampNormalMatrix = glm::mat3(glm::inverseTranspose(view * streetLampModel));
        //glUniformMatrix3fv(normalMatrixLoc, 1, GL_FALSE, glm::value_ptr(normalMatrix));

        // draw
        streetLamp.Draw(shader);
    }
}

void renderStage(gps::Shader shader) {
    // select active shader program
    shader.useShaderProgram();

    glm::mat4 stageModel = model;

    stageModel = glm::translate(stageModel, glm::vec3(0.0f, 0.0f, -1.5f));

    glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(stageModel));

    //glUniformMatrix3fv(normalMatrixLoc, 1, GL_FALSE, glm::value_ptr(normalMatrix));

    // draw
    stage.Draw(shader);
}

void renderCasualMan(gps::Shader shader, float x, float z, float jump) {
    // select active shader program
    shader.useShaderProgram();

    glm::mat4 casualManModel = model;

    casualManModel = glm::translate(casualManModel, glm::vec3(x, -0.3f + jump, z));

    glUniformMatrix4fv(modelLoc, 1, GL_FALSE, glm::value_ptr(casualManModel));

    glm::mat3 casualManNormalMatrix = glm::mat3(glm::inverseTranspose(view * casualManModel));
    //glUniformMatrix3fv(normalMatrixLoc, 1, GL_FALSE, glm::value_ptr(normalMatrix));

    // draw
    casualMan.Draw(shader);
}

void renderCrowd(gps::Shader shader, float time) {
    float frequency = 12.0f;  
    float amplitude = 0.1f;

    for (float z = -2.5f; z <= 3.0f; z += 0.75f) {
        for (float x = -5.0f; x <= 5.0f; x += 0.65f) {

            float phase = randomOffset(3.14f);
            float jump = amplitude * sin(frequency * time + (x + z));

            renderCasualMan(shader, x, z, jump);
        }
    }
}

void drawObjects(gps::Shader shader, bool depthPass) {
    shader.useShaderProgram();

    /////////////////////////////////////////////////////////////////////////////////////// 
    //model = glm::rotate(glm::mat4(1.0f), glm::radians(angleY), glm::vec3(0.0f, 1.0f, 0.0f));
    //glUniformMatrix4fv(glGetUniformLocation(shader.shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));

    
    // do not send the normal matrix if we are rendering in the depth map
    if (!depthPass) {
        normalMatrix = glm::mat3(glm::inverseTranspose(view * model));
        glUniformMatrix3fv(normalMatrixLoc, 1, GL_FALSE, glm::value_ptr(normalMatrix));
    }

    glDisable(GL_CULL_FACE);
    renderStage(shader);
    glEnable(GL_CULL_FACE);
    renderStreetLamp(shader);

    float currentTime = glfwGetTime();
    renderCrowd(shader, currentTime);


    /////////////////////////////////////////////////////////////////////////////////////// 
    //model = glm::translate(glm::mat4(1.0f), glm::vec3(0.0f, -1.0f, 0.0f));
    //model = glm::scale(model, glm::vec3(0.5f));
    //glUniformMatrix4fv(glGetUniformLocation(shader.shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));

    // do not send the normal matrix if we are rendering in the depth map
    if (!depthPass) {
        normalMatrix = glm::mat3(glm::inverseTranspose(view * model));
        glUniformMatrix3fv(normalMatrixLoc, 1, GL_FALSE, glm::value_ptr(normalMatrix));
    }

    renderGround(shader);

}

void renderScene() {

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    depthMapShader.useShaderProgram();

    glUniformMatrix4fv(glGetUniformLocation(depthMapShader.shaderProgram, "lightSpaceTrMatrix"),
        1,
        GL_FALSE,
        glm::value_ptr(computeLightSpaceTrMatrix()));

    glViewport(0, 0, SHADOW_WIDTH, SHADOW_HEIGHT);
    glBindFramebuffer(GL_FRAMEBUFFER, shadowMapFBO);
    glClear(GL_DEPTH_BUFFER_BIT);

    drawObjects(depthMapShader, true);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    // render depth map on screen - toggled with the M key

    if (showDepthMap) {

        glViewport(0, 0, myWindow.getWindowDimensions().width, myWindow.getWindowDimensions().height);

        glClear(GL_COLOR_BUFFER_BIT);

        screenQuadShader.useShaderProgram();

        //bind the depth map
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, depthMapTexture);
        glUniform1i(glGetUniformLocation(screenQuadShader.shaderProgram, "depthMap"), 0);

        glDisable(GL_DEPTH_TEST);
        screenQuad.Draw(screenQuadShader);
        glEnable(GL_DEPTH_TEST);
    }
    else {

        //render the scene

        glfwSetInputMode(myWindow.getWindow(), GLFW_CURSOR, GLFW_CURSOR_DISABLED);
        glViewport(0, 0, myWindow.getWindowDimensions().width, myWindow.getWindowDimensions().height);

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        myBasicShader.useShaderProgram();

        view = myCamera.getViewMatrix();
        glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(view));

        lightRotation = glm::rotate(glm::mat4(1.0f), glm::radians(lightAngle), glm::vec3(1.0f, 0.0f, 0.0f));
        glUniform3fv(lightDirLoc, 1, glm::value_ptr(glm::inverseTranspose(glm::mat3(view * lightRotation)) * lightDir));

        //bind the shadow map
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, depthMapTexture);
        glUniform1i(glGetUniformLocation(myBasicShader.shaderProgram, "shadowMap"), 3);

        glUniformMatrix4fv(glGetUniformLocation(myBasicShader.shaderProgram, "lightSpaceTrMatrix"),
            1,
            GL_FALSE,
            glm::value_ptr(computeLightSpaceTrMatrix()));

        drawObjects(myBasicShader, false);
        //draw the sun cube around the light

        if (night == 0.0f || fog == 0.0f) {
            lightShader.useShaderProgram();

            glUniformMatrix4fv(glGetUniformLocation(lightShader.shaderProgram, "view"), 1, GL_FALSE, glm::value_ptr(view));

            glm::mat4 lightModel = lightRotation;
            lightModel = glm::translate(lightModel, 1.0f * lightDir);
            lightModel = glm::scale(lightModel, glm::vec3(0.2f, 0.2f, 0.2f));
            glUniformMatrix4fv(glGetUniformLocation(lightShader.shaderProgram, "model"), 1, GL_FALSE, glm::value_ptr(lightModel));

            sun.Draw(lightShader);
        }
        mySkyBox.Draw(skyboxShader, view, projection);
    }
}

void runPresentationAnimation(float startTime) {

    float currentTime = glfwGetTime();
    float time = currentTime - startTime;

    std::cout << currentTime << std::endl;
    std::cout << startTime << std::endl;
    std::cout << time << std::endl;

    float animationDuration = 30.0f;  // cate secunde dureaza animatia
    float moveSpeed = 0.005f;
    float stepHeight = 0.2f;
    float stepWidth = 1.0f;
    float danceAmplitude = 0.1f;
    float danceFrequency = 2.0f;

    // merg aproape de scena
    if (time < animationDuration * 0.20f) { 
        float moveProgress = time / (animationDuration * 0.20f); 
        glm::vec3 cameraPosition = myCamera.getPosition();
        glm::vec3 startPosition = glm::vec3(12.0f, 0.5f, 4.0f);
        glm::vec3 intermediatePosition = glm::vec3(-8.0f, 0.5f, 4.0f); 

        cameraPosition = startPosition + moveProgress * (intermediatePosition - startPosition);

        myCamera.setPosition(cameraPosition);
        myCamera.setTarget(glm::vec3(0.0f, 0.5f, -8.0f));
    }
    else if (time < animationDuration * 0.40f) { 
        float moveProgress = (time - animationDuration * 0.20f) / (animationDuration * 0.20f); 
        glm::vec3 cameraPosition = myCamera.getPosition();
        glm::vec3 intermediatePosition = glm::vec3(-8.0f, 0.5f, 4.0f);
        glm::vec3 endPosition = glm::vec3(-8.0f, 0.5f, -8.0f); 

        cameraPosition = intermediatePosition + moveProgress * (endPosition - intermediatePosition);

        myCamera.setPosition(cameraPosition);
        myCamera.setTarget(glm::vec3(0.0f, 0.5f, -8.0f));
    }
    // urc scarile de la scena
    else if (time < animationDuration * 0.60f) {
        float moveProgress = (time - animationDuration * 0.40f) / (animationDuration * 0.20f);

        glm::vec3 startPosition = glm::vec3(-8.0f, 0.5f, -8.0f);
        glm::vec3 endPosition = glm::vec3(-2.0f, 1.5f, -8.0f);

        glm::vec3 startTarget = glm::vec3(0.0f, 0.5f, -8.0f);
        glm::vec3 endTarget = glm::vec3(0.0f, 1.5f, 5.0f);

        glm::vec3 cameraPosition = startPosition + moveProgress * (endPosition - startPosition);

        glm::vec3 cameraTarget = startTarget + moveProgress * (endTarget - startTarget);

        myCamera.setPosition(cameraPosition);
        myCamera.setTarget(cameraTarget);
    }
    // dansez pe scena
    else {
        float moveProgress = (time - animationDuration * 0.60f) / (animationDuration * 0.40f);
        glm::vec3 cameraPosition = myCamera.getPosition();
        glm::vec3 cameraTarget = myCamera.getTarget();

        float danceFrequency = 1.5f;  
        
        float minX = -3.0f;  
        float maxX = 3.0f;   

        cameraPosition.x = minX + (maxX - minX) * 0.5f * (1.0f + sin(danceFrequency * time));

        glm::vec3 startTarget = glm::vec3(7.0f, 1.5f, 5.0f);
        glm::vec3 endTarget = glm::vec3(-7.0f, 1.5f, 3.0f);

        cameraTarget = startTarget + moveProgress * (endTarget - startTarget);

        myCamera.setPosition(cameraPosition);
        myCamera.setTarget(cameraTarget);
    }

    glm::mat4 viewMatrix = myCamera.getViewMatrix();
    glUniformMatrix4fv(viewLoc, 1, GL_FALSE, glm::value_ptr(viewMatrix));

    glm::mat3 normalMatrix = glm::mat3(glm::inverseTranspose(viewMatrix * model));
    glUniformMatrix3fv(normalMatrixLoc, 1, GL_FALSE, glm::value_ptr(normalMatrix));

    renderGround(myBasicShader);
    renderStreetLamp(myBasicShader);
    renderStage(myBasicShader);
    renderCrowd(myBasicShader, time);
}

void cleanup() {
    myWindow.Delete();
    //cleanup code for your own data
}

int main(int argc, const char * argv[]) {

    try {
        initOpenGLWindow();
    } catch (const std::exception& e) {
        std::cerr << e.what() << std::endl;
        return EXIT_FAILURE;
    }


    initOpenGLState();
	initModels();
	initShaders();
	initUniforms();
    initFBO();
    initSkyBox();
    setWindowCallbacks();

	glCheckError();
	// application loop
	while (!glfwWindowShouldClose(myWindow.getWindow())) {

        if (runAnimation) {
            runPresentationAnimation(startTime);
        }

        processMovement();

	    renderScene();

		glfwPollEvents();
		glfwSwapBuffers(myWindow.getWindow());

		glCheckError();
	}

	cleanup();

    return EXIT_SUCCESS;
}
