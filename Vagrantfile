# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'yaml'
CONFSBOX = YAML.load(File.open(File.join(File.dirname(__FILE__), "Scotchbox.yaml"), File::RDONLY).read)
ENV['VAGRANT_DEFAULT_PROVIDER'] = CONFSBOX["provider"] ||= "virtualbox"
FALIASES = File.join(File.dirname(__FILE__), "aliases")

name = "scotchbox35"

Vagrant.configure("2") do |config|
    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"

    if File.exists? FALIASES then
        config.vm.provision "file", source: FALIASES, destination: "~/.bash_aliases"
    end

    config.hostmanager.enabled = true
    config.hostmanager.aliases = Array.new
    config.hostmanager.aliases.push "scotch.box"

    config.vm.box_check_update = false
    config.vm.synced_folder ".", "/vagrant", disabled: true

    config.vm.provider :virtualbox do |vbox|
	    vbox.name = name
        # Set server memory in MegaBytes and CPU core count
        vbox.customize ["modifyvm", :id, "--memory", CONFSBOX['memory'], "--cpus", CONFSBOX['cpus']]
        # Set the timesync threshold to 100 seconds, instead of the default 20 minutes.
        # If the clock gets more than 15 minutes out of sync (due to your laptop going
        # to sleep for instance, then some 3rd party services will reject requests.
        vbox.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 100000]
        # Prevent VMs running on Ubuntu to lose internet connection
        vbox.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vbox.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

    config.vm.box = "scotch/box"
    config.vm.network "private_network", ip: CONFSBOX['ip'] ||= "192.168.33.10"
    config.vm.hostname = "scotchbox"
    config.vm.synced_folder ".", "/var/www", :mount_options => ["dmode=777", "fmode=666"]
    # Optional NFS. Make sure to remove other synced_folder line too
    #config.vm.synced_folder ".", "/var/www", :nfs => { :mount_options => ["dmode=777","fmode=666"] }
    if CONFSBOX.include? 'projects'
      CONFSBOX["projects"].each do |project|
        mount_opts = ["dmode=777", "fmode=666"]
        if (project["mount"] == "nfs")
            mount_opts = project["mount_options"] ? project["mount_options"] : ['actimeo=1']
        end
        # For b/w compatibility keep separate 'mount_opts', but merge with options
        mount_options = ({}).merge({ mount_options: mount_opts })
        config.vm.synced_folder project["map"], project["to"], type: project["mount"] ||= nil, **mount_options

        config.hostmanager.aliases.push project['site']

        config.vm.provision project["site"], type: "shell" do |sh|
            sh.path = "a2site.sh"
            sh.args = [ project["site"] , project["to"] +"/"+ project["root"] ]
            sh.privileged = true
            sh.keep_color = true
        end

        if project.has_key?("db")
            config.vm.provision project["db"], type: "shell" do |sh|
                sh.path = "mydb.sh"
                sh.args = project["db"]
                if project.has_key?("sql")
                    sh.args += " "+ project["to"] +"/"+ project["sql"]
                end
                sh.privileged = true
                sh.keep_color = true
            end
        end
      end
    end
    config.vm.provision "shell", privileged: false, path: "./provision.sh"

    config.hostmanager.manage_host = true
    config.hostmanager.ignore_private_ip = false
    config.hostmanager.include_offline = true
end
