# CLI Variables
variable "distro_slug" { type = string }
variable "os_version" { type = string }
variable "output_box_name" { type = string }
variable "output_box_version" { type = string }
variable "vagrantcloud_user" { type = string }
variable "os_name" { type = string }
variable "salt_pr" {
  type = string
  default = ""
}

# Common variables with their defaults
variable "src_box_name" { type = string }
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


source "vagrant" "freebsd-amd64" {
  provider = "virtualbox"
  communicator = "ssh"

  source_path = "${var.src_box_name}"
  box_version = "${var.src_box_version}"
  box_name = "${var.output_box_name}-build"

  output_dir = "target"
  add_force = false
  skip_add = true
}


build {
  sources = [
    "source.vagrant.freebsd-amd64",
  ]

  provisioner "shell" {
    execute_command = "sudo -E -H sh -ec '{{ .Vars }} {{ .Path }}'"
    inline_shebang = "/bin/sh"
    environment_vars = [
      "ASSUME_ALWAYS_YES=yes",
      "DEFAULT_ALWAYS_YES=yes",
    ]
    inline = [
      "freebsd-update --not-running-from-cron fetch install",
      "pkg update",
      "pkg upgrade",
      "pkg install -y bash git vim",
    ]
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
    execute_command  = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    inline           = [
      "pkg install -y ${var.salt_provision_pyenv_deps}",
      # Install PyEnv
      "curl https://pyenv.run | bash"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "SALT_VERSION=${var.salt_provision_version}",
      "SALT_PY_VERSION=${var.salt_provision_python_version}",
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}",
      "USE_STATIC_REQUIREMENTS=1"
    ]
    execute_command  = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    script           = "os-images/files/install-salt.sh"
  }

  provisioner "file" {
    destination = "${var.salt_provision_root_dir}/"
    direction   = "upload"
    generated   = true
    source      = ".tmp/${var.distro_slug}"
  }

  provisioner "shell" {
    environment_vars = [
      "SALT_PY_VERSION=${var.salt_provision_python_version}",
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}",
      "SALT_STATE=${var.state_name}"
    ]
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    pause_after     = "5s"
    script          = "os-images/files/provision-system.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
    ]
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/files/cleanup-salt.sh"
  }

  provisioner "shell" {
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/AWS/files/cleanup-linux.sh"
    pause_after     = "3s"
  }
}
