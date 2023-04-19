# CLI Variables
variable "ci_build" { type = bool }
variable "aws_region" { type = string }
variable "ssh_keypair_name" { type = string }
variable "ssh_private_key_file" { type = string }
variable "distro_arch" { type = string }
variable "distro_version" { type = string }
variable "skip_create_ami" {
  type    = bool
  default = false
}
variable "runner_version" {
  description = "The version (no v prefix) of the GitHub Actions Runner software to install https://github.com/actions/runner/releases"
  type        = string
  default     = "2.300.2"
}
variable "install_github_actions_runner" {
  description = "Create a user to run the GitHub Actions Runner under."
  type        = bool
  default     = false
}

# Variables set by pkrvars file
variable "instance_type" {
  type    = string
  default = "c5a.large"
}
variable "ssh_username" {
  type    = string
  default = "ec2-user"
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
  default = "CentOSStream"
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
  default = "3006.0"
}

variable "salt_provision_root_dir" {
  type    = string
  default = "/tmp/salt-provision"
}

locals {
  build_timestamp = timestamp()
  ami_name        = "${var.ami_name_prefix}/${var.build_type}/${lower(var.distro_name)}/${var.distro_version}/${var.distro_arch}/${formatdate("YYYYMMDD.hhmm", local.build_timestamp)}"
  ami_description = "${upper(var.build_type)} Image of ${var.distro_name} ${var.distro_version} ${var.distro_arch}"
  distro_slug     = "${lower(var.distro_name)}-${var.distro_version}-${var.distro_arch}"
}

data "amazon-ami" "image" {
  filters = {
    name                = var.ami_filter
    root-device-type    = "ebs"
    state               = "available"
    virtualization-type = "hvm"
    architecture        = var.distro_arch
  }
  most_recent = true
  owners = [
    var.ami_owner
  ]
  region = var.aws_region
}

source "amazon-ebs" "image" {
  ami_description = local.ami_description
  ami_name        = local.ami_name
  instance_type   = var.instance_type

  ebs_optimized     = true
  shutdown_behavior = "terminate"

  skip_create_ami = var.skip_create_ami

  ami_users = [
    "178480506716",
    "540082622920"
  ]

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
    Name                     = "Packer {{ upper `${var.build_type}` }} ${var.distro_name} ${var.distro_version} ${var.distro_arch} Builder"
    Owner                    = "SRE"
    Salt-Golden-Image        = true
    create-salt-golden-image = true
    created-by               = "packer"
  }
  security_group_filter {
    filters = {
      group-name = "*-prod-*-golden-images-provision-${var.ci_build ? "private" : "public"}-*"
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
      "tag:Name" = "*-prod-vpc-${var.ci_build ? "private" : "public"}-*"
    }
    most_free = true
    random    = false
  }
  tags = {
    Build-Date                = "${local.build_timestamp}"
    Build-Type                = var.build_type
    Name                      = "Salt Project // ${upper(var.build_type)} // ${var.distro_name} ${var.distro_version} ${var.distro_arch}"
    OS-Arch                   = "${var.distro_arch}"
    OS-Name                   = "${var.distro_name}"
    OS-Version                = "${var.distro_version}"
    Owner                     = "SRE"
    Provision-State-Name      = "${var.state_name}"
    Salt-Golden-Image         = true
    created-by                = "packer"
    no-delete                 = false
    ssh-username              = var.ssh_username
    "spb:start-github-runner" = false
  }
}

build {
  sources = [
    "source.amazon-ebs.image"
  ]

  provisioner "shell" {
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "yum install -y dnf || true",
      "dnf install -y centos-gpg-keys centos-stream-release centos-stream-repos",
      "dnf update -y",
      "dnf install -y git vim sudo openssh-server dbus curl tar unzip"
    ]
    inline_shebang = "/bin/sh -ex"
  }

  provisioner "shell" {
    # The above 'dnf update' call will upgrade cloud-init which defines a new
    # username as the default user for the image.
    # Make sure that user exists while running the remaining steps.
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "cloud-init single --name cc_users_groups"
    ]
    inline_shebang = "/bin/sh -ex"
  }

  provisioner "shell" {
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "curl -f https://s3.amazonaws.com/amazoncloudwatch-agent/assets/amazon-cloudwatch-agent.gpg -o /tmp/amazon-cloudwatch-agent.gpg",
      "gpg --import /tmp/amazon-cloudwatch-agent.gpg",
      "curl -f https://s3.amazonaws.com/amazoncloudwatch-agent/${var.distro_arch == "x86_64" ? "centos" : "redhat"}/${var.distro_arch == "x86_64" ? "amd64" : "arm64"}/latest/amazon-cloudwatch-agent.rpm -o /tmp/amazon-cloudwatch-agent.rpm",
      "curl -f https://s3.amazonaws.com/amazoncloudwatch-agent/${var.distro_arch == "x86_64" ? "centos" : "redhat"}/${var.distro_arch == "x86_64" ? "amd64" : "arm64"}/latest/amazon-cloudwatch-agent.rpm.sig -o /tmp/amazon-cloudwatch-agent.rpm.sig",
      "gpg --verify /tmp/amazon-cloudwatch-agent.rpm.sig /tmp/amazon-cloudwatch-agent.rpm",
      "rpm -U /tmp/amazon-cloudwatch-agent.rpm",
      "systemctl restart amazon-cloudwatch-agent",
    ]
    inline_shebang = "/bin/sh -ex"
  }

  provisioner "shell" {
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "curl -f https://awscli.amazonaws.com/awscli-exe-linux-${var.distro_arch == "x86_64" ? "x86_64" : "aarch64"}.zip -o /tmp/awscliv2.zip",
      "cd /tmp; unzip awscliv2.zip",
      "cd /tmp; ./aws/install",
    ]
    inline_shebang = "/bin/sh -ex"
  }

  provisioner "shell-local" {
    environment_vars = [
      "DISTRO_SLUG=${local.distro_slug}",
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}",
      "INSTALL_GITHUB_ACTIONS_RUNNER=${var.install_github_actions_runner ? "yes" : "no"}",
      "INSTALL_GITHUB_ACTIONS_RUNNER_DEPENDENCIES=true",
      "GITHUB_ACTIONS_RUNNER_TARBALL_URL=https://github.com/actions/runner/releases/download/v${var.runner_version}/actions-runner-linux-${var.distro_arch == "x86_64" ? "x64" : "arm64"}-${var.runner_version}.tar.gz"
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
    environment_vars = [
      "SSH_USERNAME=${var.ssh_username}"
    ]
    execute_command = "sudo -E -H bash -c '{{ .Vars }} {{ .Path }}'"
    script          = "os-images/AWS/files/cleanup-linux.sh"
  }

  post-processor "manifest" {
    custom_data = {
      arch                       = var.distro_arch
      ami_name                   = local.ami_name
      ami_description            = local.ami_description
      ssh_username               = var.ssh_username
      instance_type              = var.instance_type
      is_windows                 = false
      cloudwatch-agent-available = true
      slug                       = "${lower(var.distro_name)}-${var.distro_version}${var.distro_arch == "arm64" ? "-${var.distro_arch}" : ""}"
    }
    output     = "manifest.json"
    strip_path = true
  }
}
