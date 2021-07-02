# -*- mode: ruby -*-
# vi: set ft=ruby :
synced_folder  = ENV[     'SYNCED_FOLDER'      ]  || "/home/vagrant/#{File.basename(Dir.pwd)}"
memory         = ENV[           'MEMORY'       ]  || 4096
cpus           = ENV[           'CPUS'         ]  || 4
vm_name        = ENV[           'VM_NAME'      ]  || File.basename(Dir.pwd)
forwarded_ports= []
provisioners   = [
  "node",
  "python",
  "ansible",
  "spacevim",
  "ripgrep",
  "docker",
  "lxd",
  "rust-core-utils",
  "kube-util",
]
utility_scripts= [
 "disable-ssh-password-login",
 "lxd-debian",
 "ngrok-init"
]
INSTALLER_SCRIPTS_BASE      = "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/installer"
UTIL_SCRIPTS_BASE           = "https://raw.githubusercontent.com/da-moon/provisioner-scripts/master/bash/util"
Vagrant.configure("2") do |config|
  config.vm.define "#{vm_name}"
  config.vm.hostname = "#{vm_name}"
  config.vm.synced_folder ".","#{synced_folder}",auto_correct:true, owner: "vagrant",group: "vagrant",disabled:true
  config.vagrant.plugins = [ "vagrant-vbguest" ]
  config.vm.provider "virtualbox" do |vb, override|
    override.vm.box="generic/debian10"
    vb.memory = "#{memory}"
    vb.cpus   = "#{cpus}"
    # => enable nested virtualization
    vb.customize ["modifyvm",:id,"--nested-hw-virt", "on"]
    override.vm.synced_folder ".", "#{synced_folder}",disabled: false,
      auto_correct:true, owner: "vagrant",group: "vagrant",type: "virtualbox"
  end
  config.vm.provider "hyperv" do |h,override|
    override.vm.box="generic/debian10"
    h.enable_virtualization_extensions = true
    h.linked_clone = true
    h.cpus   = "#{cpus}"
    h.memory = "#{memory}"
    h.maxmemory = "#{memory}"
    override.vm.network "public_network"
    override.vm.synced_folder ".", "#{synced_folder}",disabled: false,auto_correct:true, type: "smb",
    owner: "vagrant",group: "vagrant"
  end
  config.vm.provider "libvirt" do |libvirt,override|
    override.vm.box="generic/debian10"
    libvirt.memory = "#{memory}"
    libvirt.cpus = "#{cpus}"
    libvirt.nested = true
    libvirt.cpu_mode = "host-passthrough"
    libvirt.driver = "kvm"
    override.vm.synced_folder ".", "#{synced_folder}",
      disabled: false,auto_correct:true, owner: "1000", group: "1000",
      type: "9p",accessmode: "passthrough"
    override.vm.provision "shell",
      privileged:true,
      name:"p9-kernel-support",
      inline: <<-SCRIPT
      [ ! -L /usr/local/bin/modprobe ] && sudo ln -s /sbin/modprobe /usr/local/bin/modprobe
      SCRIPT
  end if Vagrant.has_plugin?('vagrant-libvirt')
  forwarded_ports.each do |port|
    config.vm.network "forwarded_port",
      guest: port,
      host: port,
      auto_correct: true
  end
  config.vm.provision "shell",
    privileged:false,
    name:"cleanup",
    path: "#{UTIL_SCRIPTS_BASE}/clean-pkgs"
  config.vm.provision "shell",
    privileged:false,
    name:"init",
    path: "#{INSTALLER_SCRIPTS_BASE}/init"
  # [ NOTE ] => downloading helper executable scripts
  utility_scripts.each do |utility|
    config.vm.provision "shell",
      privileged:false,
      name:"#{utility}-utility-script",
      inline: <<-SCRIPT
    [ -r /usr/local/bin/#{utility} ] || \
      sudo curl -s \
      -o /usr/local/bin/#{utility} \
      #{UTIL_SCRIPTS_BASE}/#{utility} && \
      sudo chmod +x /usr/local/bin/#{utility}
    SCRIPT
  end
  # [ NOTE ] => provisioning
  provisioners.each do |provisioner|
    config.vm.provision "shell",
      privileged:false,
      name:"#{provisioner}",
      path: "#{INSTALLER_SCRIPTS_BASE}/#{provisioner}"
  end
  config.vm.provision "shell",
    privileged:false,
    name:"hashicorp",
    path:"#{INSTALLER_SCRIPTS_BASE}/hashicorp",
    args:[
      "--skip","otto",
      "--skip", "serf",
      "--skip", "terraform",
      "--skip", "boundary",
      "--skip", "waypoint",
    ]
  config.vm.provision "shell",
    privileged:false,
    name:"tfenv",
    path:"#{INSTALLER_SCRIPTS_BASE}/tfenv"
  config.vm.provision "shell",
      privileged:false,
      name:"extra-tools",
      inline: <<-SCRIPT
      sudo python3 -m pip install asciinema yq
      sudo apt-get install -y upx
      sudo snap install diagon
    SCRIPT
  config.trigger.after [:provision] do |t|
    t.info = "cleaning up after provisioning"
    t.run_remote = {path: "#{UTIL_SCRIPTS_BASE}/clean-pkgs" }
  end
end
