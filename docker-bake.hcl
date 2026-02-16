variable "REGISTRY" {
    default = "docker.io"
}

variable "REGISTRY_USER" {
    default = "ashleykza"
}
variable "APP" {
    default = "instantid"
}

variable "RELEASE" {
    default = "2.6.0"
}

variable "RELEASE_SUFFIX" {
    default = ""
}

variable "CU_VERSION" {
    default = "124"
}

variable "BASE_IMAGE_REPOSITORY" {
    default = "ashleykza/runpod-base"
}

variable "BASE_IMAGE_VERSION" {
    default = "2.4.14"
}

variable "CUDA_VERSION" {
    default = "12.4.1"
}

variable "TORCH_VERSION" {
    default = "2.6.0"
}

variable "PYTHON_VERSION" {
    default = "3.10"
}

variable "INDEX_URL" {
    default = "https://download.pytorch.org/whl/cu${CU_VERSION}"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}/${REGISTRY_USER}/${APP}:${RELEASE}${RELEASE_SUFFIX}"]
    args = {
        RELEASE = "${RELEASE}"
        BASE_IMAGE = "${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_VERSION}-python${PYTHON_VERSION}-cuda${CUDA_VERSION}-torch${TORCH_VERSION}"
        INDEX_URL = "${INDEX_URL}"
        TORCH_VERSION = "${TORCH_VERSION}+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.29.post3"
        INSTANTID_COMMIT = "ff8e8ed4c82c35a0170518ab1fb2eae89baf5b5b"
    }
}
