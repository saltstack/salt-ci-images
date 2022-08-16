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


source "vagrant" "ubuntu-amd64" {
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

source "vagrant" "ubuntu-arm64" {
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
    "source.vagrant.ubuntu-amd64",
    "source.vagrant.ubuntu-arm64",
  ]

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "echo -n ''|tee /etc/apt/apt.conf.d/20auto-upgrades",
      "sleep 30",
      "while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do",
      "    echo Waiting for other software managers to finish... ",
      "    sleep 10",
      "done",
      "if test -b /dev/nvme0n1; then debconf-set-selections <<< 'grub-pc grub-pc/install_devices multiselect /dev/nvme0n1'; fi",
      "debconf-set-selections <<< 'libc6 libraries/restart-without-asking boolean true'",
      "apt-get update -y && apt-get upgrade -yq",
      "apt-get dist-upgrade -yq",
      "apt-get install -y bash git vim openssh-server curl sudo lsb-release locales tar",
      "locale-gen en_US.UTF-8",
      "update-locale LANG=en_US.UTF-8",
      "apt-get update -yq"
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
    only = ["vagrant.ubuntu-amd64"]
    environment_vars = [
      "SALT_VERSION=${var.salt_provision_version}",
      "SALT_PROVISION_TYPE=${var.salt_provision_type}"
    ]
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/files/install-salt-onedir.sh"
  }

  provisioner "shell" {
    only = ["vagrant.ubuntu-arm64"]
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command  = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    inline           = [
      # Install Pyenv Dependencies
      "apt-get install -y --no-install-recommends ${var.salt_provision_pyenv_deps}",
      # Install PyEnv
      "curl https://pyenv.run | bash"
    ]
    inline_shebang   = "/bin/bash -ex"
  }

  provisioner "shell" {
    only = ["vagrant.ubuntu-arm64"]
    environment_vars = [
      "SALT_VERSION=${var.salt_provision_version}",
      "SALT_PY_VERSION=${var.salt_provision_python_version}",
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
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
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}",
      "SALT_STATE=${var.state_name}"
    ]
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    pause_after     = "5s"
    script          = "os-images/files/provision-system.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "rm -rf /var/lib/apt/lists/* && apt-get clean"
    ]
    inline_shebang = "/bin/bash -ex"
  }

  provisioner "shell" {
    only = ["vagrant.ubuntu-amd64"]
    environment_vars = [
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
    ]
    execute_command = "sudo bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/files/cleanup-salt-onedir.sh"
  }

  provisioner "shell" {
    only = ["vagrant.ubuntu-arm64"]
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
