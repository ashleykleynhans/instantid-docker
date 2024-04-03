variable "USERNAME" {
    default = "ashleykza"
}

variable "APP" {
    default = "instantid"
}

variable "RELEASE" {
    default = "2.0.3"
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
        TORCH_VERSION = "2.2.2+cu${CU_VERSION}"
        XFORMERS_VERSION = "0.0.25.post1+cu${CU_VERSION}"
        INSTANTID_COMMIT = "748cc597244acc54835e5ca2f3a71f92dafc1314"
        RUNPODCTL_VERSION = "v1.14.2"
        VENV_PATH = "/workspace/venvs/${APP}"
    }
}
