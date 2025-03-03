#include "Camera.hpp"
#include <iostream>

namespace gps {
    //Camera constructor
    Camera::Camera(glm::vec3 cameraPosition, glm::vec3 cameraTarget, glm::vec3 cameraUp) {
        //TODO
        this->cameraPosition = cameraPosition;
        this->cameraTarget = cameraTarget;
        this->cameraUpDirection = cameraUp;
        cameraFrontDirection = -glm::normalize(cameraPosition - cameraTarget);
        cameraRightDirection = glm::normalize(glm::cross(cameraFrontDirection, cameraUp));
        cameraUpDirection = glm::normalize(glm::cross(cameraRightDirection, cameraFrontDirection));
    }

    //return the view matrix, using the glm::lookAt() function
    glm::mat4 Camera::getViewMatrix() {
        //TODO
        return glm::lookAt(cameraPosition, cameraTarget, cameraUpDirection);
    }

    glm::vec3 Camera::getPosition() const {
        return cameraPosition;
    }

    glm::vec3 Camera::getTarget() const {
        return cameraTarget;
    }

    glm::vec3 Camera::getFrontDirection() const {
        return cameraFrontDirection;
    }

    glm::vec3 Camera::getRightDirection() const {
        return cameraRightDirection;
    }

    void Camera::setPosition(const glm::vec3& position) {
        this->cameraPosition = position;

        cameraFrontDirection = -glm::normalize(cameraPosition - cameraTarget);
        cameraRightDirection = glm::normalize(glm::cross(cameraFrontDirection, cameraUpDirection));
        cameraUpDirection = glm::normalize(glm::cross(cameraRightDirection, cameraFrontDirection));

        cameraTarget = cameraPosition + cameraFrontDirection;
    }

    void Camera::setTarget(const glm::vec3& target) {
        this->cameraTarget = target;

        cameraFrontDirection = glm::normalize(cameraTarget - cameraPosition);
        cameraRightDirection = glm::normalize(glm::cross(cameraFrontDirection, glm::vec3(0.0f, 1.0f, 0.0f)));
        cameraUpDirection = glm::normalize(glm::cross(cameraRightDirection, cameraFrontDirection));
    }

    //update the camera internal parameters following a camera move event
    void Camera::move(MOVE_DIRECTION direction, float speed) {
        //TODO
        if (direction == MOVE_FORWARD) {
            cameraPosition += speed * cameraFrontDirection;
        }
        if (direction == MOVE_BACKWARD) {
            cameraPosition -= speed * cameraFrontDirection;
        }
        if (direction == MOVE_LEFT) {
            cameraPosition -= speed * cameraRightDirection;
        }
        if (direction == MOVE_RIGHT) {
            cameraPosition += speed * cameraRightDirection;
        }

        cameraTarget = cameraPosition + cameraFrontDirection;
    }

    //update the camera internal parameters following a camera rotate event
    //yaw - camera rotation around the y axis
    //pitch - camera rotation around the x axis
    void Camera::rotate(float pitch, float yaw) {
        //TODO
        glm::vec3 direction;

        glm::mat4 euler = glm::yawPitchRoll(glm::radians(yaw), glm::radians(pitch), 0.0f);
        direction = glm::vec3(euler * glm::vec4(0.0f, 0.0f, -1.0f, 0.0f));
        cameraFrontDirection= glm::normalize(direction);
        cameraRightDirection = glm::normalize(glm::cross(cameraFrontDirection, glm::vec3(0.0f, 1.0f, 0.0f)));
        cameraUpDirection = glm::normalize(glm::cross(cameraRightDirection, cameraFrontDirection));

        cameraTarget = cameraPosition + cameraFrontDirection;

    }

}