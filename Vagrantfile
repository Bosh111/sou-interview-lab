Vagrant.configure("2") do |config|
  config.vm.define "Ping" do |node1|
    node1.vm.box = "ubuntu/bionic64"
    node1.vm.network "private_network", type: "dhcp"
    node1.vm.provision "docker"
  end

  config.vm.define "Pong" do |node2|
    node2.vm.box = "ubuntu/bionic64"
    node2.vm.network "private_network", type: "dhcp"
    node2.vm.provision "docker"
  end
end

