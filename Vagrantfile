# -*- mode: ruby -*-

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

CLOUD_CONFIG_PATH = File.join(File.dirname(__FILE__), "cloud-config.yaml")

# automatically refresh the discovery token on 'vagrant up'
if File.exists?('cloud-config.yaml') && ARGV[0].eql?('up')
  require 'open-uri'
  require 'yaml'

  token = open('https://discovery.etcd.io/new').read

  data = YAML.load(IO.readlines('cloud-config.yaml')[1..-1].join)
  data['coreos']['etcd']['discovery'] = token

  lines = YAML.dump(data).split("\n")
  lines[0] = '#cloud-config'

  open('cloud-config.yaml', 'r+') do |f|
    f.puts(lines.join("\n"))
  end
end

# options
$num_instances = 4
$update_channel = "alpha"
$vb_gui = false
$vb_memory = 1024
$vb_cpus = 1

# $expose_docker_tcp=2375
$expose_fleet_tcp=8080
$expose_extempore_tcp=7099

Vagrant.configure("2") do |config|
  config.vm.box = "yungsang/coreos-" + $update_channel
  config.vm.box_check_update
  
  (1..$num_instances).each do |i|
    config.vm.define vm_name = "core-%02d" % i do |config|
      config.vm.hostname = vm_name

      if $expose_docker_tcp
        config.vm.network "forwarded_port", guest: 2375, host: ($expose_docker_tcp + i - 1), auto_correct: true
      end

      config.vm.provider :parallels do |vb|
        vb.memory = $vb_memory
        vb.cpus = $vb_cpus
      end

      config.vm.provider :virtualbox do |vb|
        vb.gui = $vb_gui
      end

      # don't need to have an ip for the box
      # ip = "192.168.59.#{i+100}"
      # config.vm.network :private_network, ip: ip

      if $expose_fleet_tcp
        config.vm.network "forwarded_port", guest: 8080, host: ($expose_fleet_tcp + i - 1), auto_correct: true
      end

      if $expose_extempore_tcp
        # extempore primary process (count up from port 7099 on host)
        config.vm.network "forwarded_port", guest: 7099, host: ($expose_extempore_tcp + i - 1), auto_correct: true
      end

      # logstash/elasticsearch/kibana - just go through the static IP address instead
      # config.vm.network "forwarded_port", guest: 9200, host: (9200 + i - 1), auto_correct: true
      # config.vm.network "forwarded_port", guest: 9292, host: (9292 + i - 1), auto_correct: true

      # Uncomment below to enable NFS for sharing the host machine into the coreos-vagrant VM.
      #config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true, :mount_options => ['nolock,vers=3,udp']

      # copy cloud-config file in provisioning step
      if File.exist?(CLOUD_CONFIG_PATH)
        config.vm.provision :file, :source => "#{CLOUD_CONFIG_PATH}", :destination => "/tmp/vagrantfile-user-data"
        config.vm.provision :shell, :inline => "mv /tmp/vagrantfile-user-data /var/lib/coreos-vagrant/", :privileged => true
      end

    end
  end
end
