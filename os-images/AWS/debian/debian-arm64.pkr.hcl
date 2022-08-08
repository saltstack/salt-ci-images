# CLI Variables
variable "distro_slug" { type = string }
variable "os_version" { type = string }
variable "salt_pr" {
  type = string
  default = ""
}

# OS Version Variables
variable "ami_filter" { type = string }
variable "ami_name_suffix" { type = string }

# Old PyEnv Poovisioning Dependencies
variable "salt_provision_pyenv_deps" { type = string }
variable "salt_provision_python_version" { type = string }

# Common variables with their defaults
variable "os_name" {
  type = string
  default = "Debian"
}
variable "ami_name_prefix" {
  type = string
  default = "saltstack"
}
variable "ami_owner" {
  type = string
  default = "903794441882"
}
variable "aws_region" {
  type = string
  default = "us-west-2"
}
variable "device_name" {
  type = string
  default = "/dev/xvda"
}
variable "instance_type" {
  type = string
  default = "m5.large"
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
variable "ssh_username" {
  type = string
  default = "admin"
}
variable "state_name" {
  type = string
  default = "provision"
}
variable "build_type" {
  type = string
  default = "ci"
}

data "amazon-ami" "debian" {
  filters = {
    name                = "${var.ami_filter}"
    root-device-type    = "ebs"
    state               = "available"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = [
    "${var.ami_owner}"
  ]
  region      = "${var.aws_region}"
}

source "amazon-ebs" "debian" {
  ami_description = "${upper(var.build_type)} Image of ${var.os_name} ${var.os_version} ${var.os_arch}"
  ami_groups      = ["all"]
  ami_name        = "${var.ami_name_prefix}/${var.build_type}/${var.ami_name_suffix}/${formatdate("2006-01-02-15-04-05")}"
  instance_type   = "${var.instance_type}"
  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "${var.device_name}"
    volume_size           = 40
    volume_type           = "gp3"
  }
  region = "${var.aws_region}"
  run_tags = {
    Name       = "Packer ${upper(var.build_type)} ${var.os_name} ${var.os_version} ${var.os_arch} Builder"
    Owner      = "SRE"
    created-by = "packer"
  }
  security_group_filter {
    filters = {
      group-name = "kitchen-slave-auto-delete-test"
    }
  }
  source_ami           = "${data.amazon-ami.debian.id}"
  ssh_interface        = "private_ip"
  ssh_keypair_name     = "kitchen"
  ssh_private_key_file = "~/.ssh/kitchen.pem"
  ssh_username         = "${var.ssh_username}"
  subnet_filter {
    filters = {
      "tag:Name" = "*-public-*"
    }
    most_free = true
    random    = false
  }
  tags = {
    Build-Date           = "${timestamp()}"
    Build-Type           = "${upper(var.build_type)}"
    Name                 = "${upper(var.build_type)} // ${var.os_name} ${var.os_version} ${var.os_arch}"
    OS-Arch              = "${var.os_arch}"
    OS-Name              = "${var.os_name}"
    OS-Version           = "${var.os_version}"
    Owner                = "SRE"
    Promoted             = false
    Provision-State-Name = "${var.state_name}"
    created-by           = "packer"
  }
  vpc_filter {
    filters = {
      "tag:Name" = "test"
    }
  }
}

build {
  sources = ["source.amazon-ebs.debian"]

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command  = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    inline           = [
      "rm -rf /etc/apt/apt.conf.d/20auto-upgrades",
      "apt-get update -y && apt-get upgrade -yq",
      "apt-get install -y bash git vim openssh-server curl "
    ]
    inline_shebang   = "/bin/bash -ex"
  }

  provisioner "shell-local" {
    environment_vars = [
      "SALT_PR=${var.salt_pr}",
      "DISTRO_SLUG=${var.distro_slug}",
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
    ]
    script           = "os-images/AWS/files/prep-linux.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command  = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    inline           = [
      # Install Pyenv Dependencies
      "apt-get install -y --no-install-recommends ${var.salt_provision_pyenv_deps}",
      # Install PyEnv
      "curl https://pyenv.run | bash"
    ]
    inline_shebang   = "/bin/bash -ex"
  }

  provisioner "shell" {
    environment_vars = [
      "SALT_VERSION=${var.salt_provision_version}",
      "SALT_PY_VERSION=${var.salt_provision_python_version}",
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
    ]
    execute_command  = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    script           = "os-images/files/install-salt.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command  = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    inline           = [
      # Un-Install Pyenv Dependencies
      "apt-get purge -y ${var.salt_provision_pyenv_deps}",
      "apt-get autoremove --purge -y"
    ]
    inline_shebang   = "/bin/bash -ex"
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
    execute_command  = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    pause_after      = "5s"
    script           = "os-images/files/provision-system.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    execute_command  = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    inline           = [
      "rm -rf /var/lib/apt/lists/* && apt-get clean"
    ]
    inline_shebang   = "/bin/bash -ex"
  }

  provisioner "shell" {
    environment_vars = [
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
    ]
    execute_command  = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    script           = "os-images/files/cleanup-salt.sh"
  }

  provisioner "shell" {
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/AWS/files/cleanup-linux.sh"
  }

  post-processor "manifest" {
    custom_data = {
      ami_name = "${var.ami_name_prefix}/${var.build_type}/${var.ami_name_suffix}"
    }
    output     = "manifest.json"
    strip_path = true
  }
}
