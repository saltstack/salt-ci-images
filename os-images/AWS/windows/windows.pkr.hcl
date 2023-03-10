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
  default = "c5a.xlarge"
}
variable "ssh_username" {
  type    = string
  default = "Administrator"
}

# Remaining variables
variable "build_type" {
  type    = string
  default = "ci"
}
variable "ami_owner" {
  type    = string
  default = "801119661308"
}

variable "distro_name" {
  type    = string
  default = "Windows"
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
  default = "3005.1+2103.gc1fc63d39a"
}

variable "salt_provision_root_dir" {
  type    = string
  default = "c:\\salt-provision"
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
  source_ami = data.amazon-ami.image.id

  communicator   = "winrm"
  winrm_port     = 5986
  winrm_insecure = true
  winrm_use_ssl  = true
  winrm_username = "Administrator"
  winrm_password = "Really-SuperS3cr3t!!!!"

  user_data_file = "${path.root}/scripts/SetUpWinRM.ps1"

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

  provisioner "powershell" {
    script = "${path.root}/scripts/Install-Git.ps1"
  }

  provisioner "powershell" {
    elevated_password = ""
    elevated_user     = "SYSTEM"
    script            = "${path.root}/scripts/InstallAndConfigureOpenSSH.ps1"
  }

  provisioner "powershell" {
    elevated_password = ""
    elevated_user     = "SYSTEM"
    script            = "${path.root}/scripts/Install-CloudWatchAgent.ps1"
  }

  provisioner "powershell" {
    elevated_password = ""
    elevated_user     = "SYSTEM"
    script            = "${path.root}/scripts/Install-AwsSsmAgent.ps1"
  }

  provisioner "shell-local" {
    environment_vars = [
      "DISTRO_SLUG=${local.distro_slug}",
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}",
      "INSTALL_GITHUB_ACTIONS_RUNNER=${var.install_github_actions_runner ? "yes" : "no"}",
      "INSTALL_GITHUB_ACTIONS_RUNNER_DEPENDENCIES=false",
      "GITHUB_ACTIONS_RUNNER_TARBALL_URL=https://github.com/actions/runner/releases/download/v${var.runner_version}/actions-runner-win-${var.distro_arch == "x86_64" ? "x64" : "arm64"}-${var.runner_version}.zip"
    ]
    script = abspath("${path.root}/../files/prep-windows.sh")
  }

  provisioner "powershell" {
    script = "${path.root}/scripts/update-git-path.ps1"
  }

  provisioner "powershell" {
    elevated_password = ""
    elevated_user     = "SYSTEM"
    environment_vars = [
      "OS_ARCH=${var.distro_arch == "x86_64" ? "amd64" : var.distro_arch}",
      "SALT_VERSION=${var.salt_provision_version}",
    ]
    script = "${path.root}/scripts/Provision-Salt.ps1"
  }

  provisioner "powershell" {
    elevated_password = ""
    elevated_user     = "SYSTEM"
    inline = [
      "Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force",
      "Install-Module -Name DockerMsftProvider -Repository PSGallery -Force",
      "Install-Package -Name docker -ProviderName DockerMsftProvider -Force",
      "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart"
    ]
    pause_before = "5s"
  }

  provisioner "file" {
    destination = "${var.salt_provision_root_dir}"
    direction   = "upload"
    generated   = true
    source      = ".tmp/${local.distro_slug}/"
  }

  provisioner "powershell" {
    elevated_password = ""
    elevated_user     = "SYSTEM"
    environment_vars = [
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}",
      "SALT_STATE=${var.state_name}",
      "PYTHONUTF8=1",
    ]
    script = "${path.root}/scripts/Provision-System.ps1"
  }

  provisioner "powershell" {
    elevated_password = ""
    elevated_user     = "SYSTEM"
    environment_vars = [
      "SALT_ROOT_DIR=${var.salt_provision_root_dir}"
    ]
    inline = [
      "Remove-Item $Env:SALT_ROOT_DIR -Recurse -Force",
      "Remove-Item $Env:TMP\\salt -Recurse -Force"
    ]
    pause_before = "5s"
  }

  provisioner "powershell" {
    elevated_password = ""
    elevated_user     = "SYSTEM"
    inline = [
      "Set-ItemProperty -Path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced' -Name 'Hidden' -Value 1",
      "Set-Itemproperty -path 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced' -Name 'HideFileExt' -value 0"
    ]
  }

  provisioner "powershell" {
    script = "${path.root}/scripts/SysPrep.ps1"
  }

  provisioner "shell-local" {
    command      = "echo Done"
    pause_before = "5s"
  }

  post-processor "manifest" {
    custom_data = {
      arch                       = var.distro_arch
      ami_name                   = local.ami_name
      ami_description            = local.ami_description
      ssh_username               = var.ssh_username
      instance_type              = var.instance_type
      is_windows                 = true
      cloudwatch-agent-available = true
      slug                       = "${lower(var.distro_name)}-${var.distro_version}${var.distro_arch == "arm64" ? "-${var.distro_arch}" : ""}"
    }
    output     = "manifest.json"
    strip_path = true
  }
}
