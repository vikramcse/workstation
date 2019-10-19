provider "digitalocean" {}

variable "region" {
  default = "blr1"
}

resource "digitalocean_droplet" "godev" {
  name               = "godev"
  image              = "ubuntu-18-04-x64"
  size               = "s-1vcpu-1gb"
  region             = "${var.region}"
  ssh_keys           = [25590642]                        # doctl compute ssh-key list

  provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("~/.ssh/ipad_rsa")}"
      timeout     = "2m"
      host = "${digitalocean_droplet.godev.ipv4_address}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "/tmp/bootstrap.sh initialize",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file("~/.ssh/ipad_rsa")}"
      timeout     = "2m"
      host = "${digitalocean_droplet.godev.ipv4_address}"
    }
  }
}

resource "digitalocean_firewall" "godev" {
  name = "godev"

  droplet_ids = ["${digitalocean_droplet.godev.id}"]

  inbound_rule {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = ["0.0.0.0/0", "::/0"]
	}

  inbound_rule {
      protocol         = "udp"
      port_range       = "60000-60010"
      source_addresses = ["0.0.0.0/0", "::/0"]
	}

  outbound_rule  {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
	}

  outbound_rule  {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0", "::/0"]
	}

  outbound_rule  {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0", "::/0"]
	}
}

output "public_ip" {
  value = "${digitalocean_droplet.godev.ipv4_address}"
}
