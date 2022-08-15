# CLI Variables
variable "distro_slug" { type = string }
variable "os_version" { type = string }
variable "output_box_name" { type = string }
variable "output_box_version" { type = string }
variable "src_box_name" { type = string }
variable "vagrantcloud_user" { type = string }
variable "os_name" { type = string }
variable "salt_pr" {
  type = string
  default = ""
}

# Common variables with their defaults
variable "src_box_version" {
  type = string
  default = ""
}
variable "os_arch" {
  type = string
  default = "amd64"
}
variable "salt_provision_root_dir" {
  type = string
  default = "/tmp/salt-provision"
}
variable "salt_provision_type" {
  type = string
  default = "stable"
}
variable "salt_provision_version" {
  type = string
  default = "3004.2-1"
}
variable "salt_provision_pyenv_deps" {
  type = string
  default = null
}
variable "salt_provision_python_version" {
  type = string
  default = null
}
variable "state_name" {
  type = string
  default = "provision"
}
variable "build_type" {
  type = string
  default = "ci"
}


packer {
  required_plugins {
    vagrant = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}


source "vagrant" "fedora-amd64" {
  provider = "virtualbox"
  communicator = "ssh"

  source_path = "${var.src_box_name}"
  box_version = "${var.src_box_version}"
  box_name = "${var.output_box_name}-test"
  teardown_method = "destroy"

  output_dir = "target"
  add_force = false
  skip_add = true
}

build {
  sources = [
    "source.vagrant.fedora-amd64",
  ]

  provisioner "shell" {
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "systemctl mask tmp.mount",
      "dnf update -y",
      "dnf install -y git vim sudo openssh-server dbus curl tar"
    ]
    inline_shebang = "/bin/bash -ex"
  }

  provisioner "shell-local" {
    environment_vars = [
      "SALT_PR=${var.salt_pr}",
      "DISTRO_SLUG=${var.distro_slug}",
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
    ]
    script = "os-images/AWS/files/prep-linux.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "SALT_VERSION=${var.salt_provision_version}",
      "SALT_PROVISION_TYPE=${var.salt_provision_type}"
    ]
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/files/install-salt-onedir.sh"
  }

  provisioner "file" {
    destination = "${var.salt_provision_root_dir}/"
    direction   = "upload"
    generated   = true
    source      = ".tmp/${var.distro_slug}"
  }

  provisioner "shell" {
    environment_vars = [
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}",
      "SALT_STATE=${var.state_name}"
    ]
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    pause_after     = "5s"
    script          = "os-images/files/provision-system.sh"
  }

  provisioner "shell" {
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "dnf clean all",
      "rm -rf /var/cache/yum"
    ]
    inline_shebang = "/bin/bash -ex"
  }

  provisioner "shell" {
    environment_vars = [
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
    ]
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/files/cleanup-salt-onedir.sh"
  }

  provisioner "shell" {
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/AWS/files/cleanup-linux.sh"
    pause_after     = "3s"
  }
}
