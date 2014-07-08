# -*- mode: ruby -*-
# # vi: set ft=ruby :

Vagrant.require_version ">= 1.6.3"

Vagrant.configure("2") do |config|
  config.ssh.shell = "sh"
  config.ssh.username = "docker"

  # Forward the Docker port
  config.vm.network :forwarded_port, guest: 2375, host: 2375

  # Disable synced folder by default
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Attach the b2d ISO so that it can boot
  config.vm.provider :virtualbox do |v|
    v.check_guest_additions = false
    v.functional_vboxsf = false
    v.customize "pre-boot", [
      "storageattach", :id,
      "--storagectl", "IDE Controller",
      "--port", "0",
      "--device", "1",
      "--type", "dvddrive",
      "--medium", File.expand_path("../boot2docker.iso", __FILE__),
    ]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.provider :parallels do |p|
    p.check_guest_tools = false
    p.functional_psf = false
    p.customize "pre-boot", [
      "set", :id,
      "--device-set", "cdrom0",
      "--image", File.expand_path("../boot2docker.iso", __FILE__),
      "--enable", "--connect"
    ]
    p.customize "pre-boot", [
      "set", :id,
      "--device-bootorder", "cdrom0 hdd0"
    ]
  end

  config.vm.provider "vmware_fusion" do |v|
    v.vmx["bios.bootorder"]    = "CDROM,hdd"
    v.vmx["ide1:0.present"]    = "TRUE"
    v.vmx["ide1:0.filename"]   = File.expand_path("../boot2docker.iso", __FILE__)
    v.vmx["ide1:0.devicetype"] = "cdrom-image"
    v.vmx["ide1:0.autodetect"] = "TRUE"
    v.vmx["ide1:0.startConnected"] = "TRUE"
  end
end
