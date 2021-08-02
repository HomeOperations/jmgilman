variable "admin_pass" {
    type = string
    default = env("LINUX_ADMIN_PASS")
    description = "Password for admin user"
    sensitive = true
}

variable "ssh_pub_key" {
    type = string
    default = env("RPI_SSH_PUB_KEY")
    description = "Default SSH public key to add to authorized keys"
    sensitive = true
}

variable "config" {
    type = string
    default = env("MACHINE_CONFIG")
    description = "Configuration for the Tinkerbell machine"
}

variable "dns" {
    type = string
    default = env("DNS")
    description = "DNS configuration"
}

source "arm-image" "vault-seal" {
  iso_url           = "https://cdimage.ubuntu.com/releases/21.04/release/ubuntu-21.04-preinstalled-server-arm64+raspi.img.xz"
  iso_checksum      = "sha256:3df85b93b66ccd2d370c844568b37888de66c362eebae5204bf017f6f5875207"
  image_type = "raspberrypi"
  image_mounts = ["/boot/firmware","/"]
  chroot_mounts = [
        ["proc", "proc", "/proc"],
        ["sysfs", "sysfs", "/sys"],
        ["bind", "/dev", "/dev"],
        ["devpts", "devpts", "/dev/pts"],
        ["binfmt_misc", "binfmt_misc", "/proc/sys/fs/binfmt_misc"],
    ]
  additional_chroot_mounts = [["bind", "/run/systemd", "/run/systemd"]]
  target_image_size = 5368709120
}

build {
  sources = ["source.arm-image.vault-seal"]

  provisioner "shell" {
      inline = [
          "apt-get -y update",
          "apt-get install -y ansible"
      ]
  }

  provisioner "ansible-local" {
    playbook_file = "./tinker.yml"
    extra_arguments = [
        "--extra-vars \"LINUX_ADMIN_PASSWORD='${var.admin_pass}' RPI_SSH_PUB_KEY='${var.ssh_pub_key}' MACHINE_CONFIG='${var.config}' DNS='${var.dns}'\""
    ]
  }
}