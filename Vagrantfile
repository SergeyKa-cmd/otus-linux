# -*- mode: ruby -*-
# vim: set ft=ruby :
# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
:inetRouter => {
        :box_name => "centos/6",
        :net => [
                   {ip: '192.168.255.1', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
                ]
  },
 :centralRouter => {
       :box_name => "centos/7",
        :net => [
                   {ip: '192.168.255.2', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "router-net"},
                   {ip: '192.168.0.1', adapter: 3, netmask: "255.255.255.240", virtualbox__intnet: "dir-net"},
                   {ip: '192.168.0.33', adapter: 4, netmask: "255.255.255.240", virtualbox__intnet: "hw-net"},
                   {ip: '192.168.0.65', adapter: 5, netmask: "255.255.255.192", virtualbox__intnet: "mgt-net"},
                   {ip: '192.168.0.17', adapter: 6, netmask: "255.255.255.252", virtualbox__intnet: "office1Router"},
                   {ip: '192.168.0.21', adapter: 7, netmask: "255.255.255.252", virtualbox__intnet: "office2Router"},
                ]
  },

  :office1Router => {
       :box_name => "centos/7",
        :net => [
                   {ip: '192.168.0.18', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "office1Router"},
                   {ip: '192.168.2.193', adapter: 3, netmask: "255.255.255.192", virtualbox__intnet: "office1-net"},
                ]
  },
  
  :office2Router => {
       :box_name => "centos/7",
        :net => [
                   {ip: '192.168.0.22', adapter: 2, netmask: "255.255.255.252", virtualbox__intnet: "office2Router"},
                   {ip: '192.168.1.193', adapter: 3, netmask: "255.255.255.192", virtualbox__intnet: "office2-net"},
                ]
  },

  :centralServer => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.0.2', adapter: 2, netmask: "255.255.255.240", virtualbox__intnet: "dir-net"},
                   {adapter: 3, auto_config: false, virtualbox__intnet: true},
                   {adapter: 4, auto_config: false, virtualbox__intnet: true},
                ]
  },
  
  :office1Server => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.2.194', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "office1-net"},
                   {adapter: 3, auto_config: false, virtualbox__intnet: true},
                   {adapter: 4, auto_config: false, virtualbox__intnet: true},
                ]
  },

  :office2Server => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.1.194', adapter: 2, netmask: "255.255.255.192", virtualbox__intnet: "office2-net"},
                   {adapter: 3, auto_config: false, virtualbox__intnet: true},
                   {adapter: 4, auto_config: false, virtualbox__intnet: true},
                ]
  },
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

    config.vm.define boxname do |box|

        box.vm.box = boxconfig[:box_name]
        box.vm.host_name = boxname.to_s

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end
        
        if boxconfig.key?(:public)
          box.vm.network "public_network", boxconfig[:public]
        end

        box.vm.provision "shell", inline: <<-SHELL
          mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
          yum -y install tcpdump
        SHELL
        
        case boxname.to_s
        when "inetRouter"
          box.vm.hostname = 'inetRouter'
          box.vm.provision "shell", run: "always", inline: <<-SHELL
            echo 1 > /proc/sys/net/ipv4/ip_forward
            sed -i "s%net.ipv4.ip_forward = 0%net.ipv4.ip_forward = 1%g"  /etc/sysctl.conf
            sysctl -p /etc/sysctl.conf
            iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o eth0 -j MASQUERADE
            service iptables save
            
            touch /etc/sysconfig/network-scripts/route-eth1
            echo "192.168.0.0/28 via 192.168.255.2 dev eth1" >> /etc/sysconfig/network-scripts/route-eth1
            echo "192.168.0.32/28 via 192.168.255.2 dev eth1" >> /etc/sysconfig/network-scripts/route-eth1
            echo "192.168.0.64/26 via 192.168.255.2 dev eth1" >> /etc/sysconfig/network-scripts/route-eth1
            echo "192.168.0.16/30 via 192.168.255.2 dev eth1" >> /etc/sysconfig/network-scripts/route-eth1
            echo "192.168.0.20/30 via 192.168.255.2 dev eth1" >> /etc/sysconfig/network-scripts/route-eth1
            echo "192.168.2.192/26 via 192.168.255.2 dev eth1" >> /etc/sysconfig/network-scripts/route-eth1
            echo "192.168.1.192/26 via 192.168.255.2 dev eth1" >> /etc/sysconfig/network-scripts/route-eth1
            service network restart
            SHELL

           when "centralRouter"
             box.vm.hostname = 'centralRouter'
             box.vm.provision "shell", run: "always", inline: <<-SHELL
               sysctl -w net.ipv4.ip_forward=1
               echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
               echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
               echo "GATEWAY=192.168.255.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
               echo "192.168.2.192/26 via 192.168.0.18 dev eth5" >> /etc/sysconfig/network-scripts/route-eth5
               echo "192.168.1.192/26 via 192.168.0.22 dev eth6" >> /etc/sysconfig/network-scripts/route-eth6
               systemctl restart network
               SHELL
          
            when "office1Router"
              box.vm.hostname = 'office1Router'
              box.vm.provision "shell", run: "always", inline: <<-SHELL
                sysctl -w net.ipv4.ip_forward=1
                echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
                echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
                echo "GATEWAY=192.168.0.17" >> /etc/sysconfig/network-scripts/ifcfg-eth1
                systemctl restart network
                SHELL

            when "office2Router"
              box.vm.hostname = 'office2Router'
              box.vm.provision "shell", run: "always", inline: <<-SHELL
                sysctl -w net.ipv4.ip_forward=1
                echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
                echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
                echo "GATEWAY=192.168.0.21" >> /etc/sysconfig/network-scripts/ifcfg-eth1
                echo "default via 192.168.0.21 dev eth1" >> /etc/sysconfig/network-scripts/route-eth1
                systemctl restart network
                SHELL

            when "centralServer"
              box.vm.hostname = 'centralServer'
              box.vm.provision "shell", run: "always", inline: <<-SHELL
                echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
                echo "GATEWAY=192.168.0.1" >> /etc/sysconfig/network-scripts/ifcfg-eth1
                systemctl restart network
                SHELL

            when "office1Server"
              box.vm.hostname = 'office1Server'
              box.vm.provision "shell", run: "always", inline: <<-SHELL
                echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
                echo "GATEWAY=192.168.2.193" >> /etc/sysconfig/network-scripts/ifcfg-eth1
                systemctl restart network
                SHELL
          
            when "office2Server"
              box.vm.hostname = 'office2Server'
              box.vm.provision "shell", run: "always", inline: <<-SHELL
                echo "DEFROUTE=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0 
                echo "GATEWAY=192.168.1.193" >> /etc/sysconfig/network-scripts/ifcfg-eth1
                systemctl restart network
                SHELL
                
        end

      end

  end
  
  
end