# CLI Variables
variable "ci_build" { type = bool }
variable "distro_arch" { type = string }
variable "aws_region" { type = string }
variable "ssh_keypair_name" { type = string }
variable "ssh_private_key_file" { type = string }
variable "distro_version" {
  type = string
}
variable "skip_create_ami" {
  type    = bool
  default = false
}

# Variables set by pkrvars file
variable "instance_type" {
  type    = string
  default = "m5.large"
}
variable "ssh_username" {
  type    = string
  default = "fedora"
}

# Remaining variables
variable "build_type" {
  type    = string
  default = "ci"
}
variable "ami_owner" {
  type    = string
  default = "125523088429"
}

variable "distro_name" {
  type    = string
  default = "Fedora"
}

variable "ami_filter" {
  type = string
}

variable "ami_name_prefix" {
  type    = string
  default = "salt-project"
}

variable "state_name" {
  type    = string
  default = "provision"
}

variable "salt_provision_type" {
  type    = string
  default = "stable"
}

variable "salt_provision_version" {
  type    = string
  default = "3005.1"
}

variable "salt_provision_root_dir" {
  type    = string
  default = "/tmp/salt-provision"
}

locals {
  build_timestamp = timestamp()
  ami_name        = "${var.ami_name_prefix}/${var.build_type}/${lower(var.distro_name)}/${var.distro_version}/${var.distro_arch}/${formatdate("YYYYMMDD.hhmm", local.build_timestamp)}"
  distro_slug     = "${lower(var.distro_name)}-${var.distro_version}-${var.distro_arch}"
}

data "amazon-ami" "image" {
  filters = {
    name                = var.ami_filter
    root-device-type    = "ebs"
    state               = "available"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners = [
    var.ami_owner
  ]
  region = var.aws_region
}

source "amazon-ebs" "image" {
  ami_description = "${upper(var.build_type)} Image of ${var.distro_name} ${var.distro_version} ${var.distro_arch}"
  ami_name        = local.ami_name
  instance_type   = var.instance_type

  ebs_optimized     = true
  shutdown_behavior = "terminate"

  skip_create_ami = var.skip_create_ami

  #  ami_groups = [
  #    "all"
  #  ]

  launch_block_device_mappings {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    volume_size           = 40
    volume_type           = "gp3"
  }

  region = var.aws_region

  run_tags = {
    Name              = "Packer {{ upper `${var.build_type}` }} ${var.distro_name} ${var.distro_version} ${var.distro_arch} Builder"
    Owner             = "SRE"
    Salt-Golden-Image = true
    created-by        = "packer"
  }
  security_group_filter {
    filters = {
      group-name = "*-golden-images-provision-${var.ci_build ? "private" : "public"}-*"
    }
  }
  source_ami                  = data.amazon-ami.image.id
  ssh_interface               = "${var.ci_build ? "private" : "public"}_ip"
  ssh_keypair_name            = var.ssh_keypair_name
  ssh_private_key_file        = var.ssh_private_key_file
  ssh_username                = var.ssh_username
  associate_public_ip_address = var.ci_build == false
  subnet_filter {
    filters = {
      "tag:Name" = "*-${var.ci_build ? "private" : "public"}-*"
    }
    most_free = true
    random    = false
  }
  tags = {
    Build-Date           = "${local.build_timestamp}"
    Build-Type           = var.build_type
    Name                 = "Salt Project // ${upper(var.build_type)} // ${var.distro_name} ${var.distro_version} ${var.distro_arch}"
    OS-Arch              = "${var.distro_arch}"
    OS-Name              = "${var.distro_name}"
    OS-Version           = "${var.distro_version}"
    Owner                = "SRE"
    Provision-State-Name = "${var.state_name}"
    Salt-Golden-Image    = true
    created-by           = "packer"
    no-delete            = false
  }
}

build {
  sources = [
    "source.amazon-ebs.image"
  ]

  provisioner "shell" {
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "systemctl mask tmp.mount",
      "dnf update -y",
      "dnf install -y git vim sudo openssh-server dbus curl tar"
    ]
    inline_shebang = "/bin/sh -ex"
  }

  provisioner "shell-local" {
    environment_vars = [
      "DISTRO_SLUG=${local.distro_slug}",
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
    ]
    script = "os-images/AWS/files/prep-linux.sh"
  }

  provisioner "shell" {
    environment_vars = [
      "OS_ARCH=${var.distro_arch == "arm64" ? "aarch64" : "x86_64"}",
      "SALT_VERSION=${var.salt_provision_version}",
      "SALT_PROVISION_TYPE=${var.salt_provision_type}"
    ]
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/files/provision-salt.sh"
  }

  provisioner "file" {
    destination = "${var.salt_provision_root_dir}/"
    direction   = "upload"
    generated   = true
    source      = ".tmp/${local.distro_slug}"
  }

  provisioner "shell" {
    environment_vars = [
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}",
      "SALT_STATE=${var.state_name}"
    ]
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    pause_after     = "5s"
    script          = "os-images/files/provision-system.sh"
  }

  provisioner "shell" {
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    inline_shebang  = "/bin/sh -ex"
    inline = [
      "dnf clean all",
      "rm -rf /var/cache/yum"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
    ]
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/files/cleanup-salt.sh"
  }

  provisioner "shell" {
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/AWS/files/cleanup-linux.sh"
  }

  post-processor "manifest" {
    custom_data = {
      ami_name = local.ami_name
    }
    output     = "manifest.json"
    strip_path = true
  }
}
