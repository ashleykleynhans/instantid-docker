variable "USERNAME" {
    default = "ashleykza"
}

variable "APP" {
    default = "instantid"
}

variable "RELEASE" {
    default = "2.0.2"
}

variable "CU_VERSION" {
    default = "118"
}

target "default" {
    dockerfile = "Dockerfile"
    tags = ["${USERNAME}/${APP}:${RELEASE}"]
    args = {
        RELEASE = "${RELEASE}"
        INDEX_URL = "https://download.pytorch.org/whl/cu${CU_VERSION}"
        TORCH_VERSION = "2.2.0+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.24+cu${CU_VERSION}"
        INSTANTID_COMMIT = "218183c899a8b5489a46e2c487d3e186a73c8b92"
        RUNPODCTL_VERSION = "v1.14.2"
        VENV_PATH = "/workspace/venvs/${APP}"
    }
}
