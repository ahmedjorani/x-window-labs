# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Base box - Ubuntu 20.04 LTS with desktop support
  config.vm.box = "ubuntu/focal64"
  config.vm.box_version = "20240821.0.0"

  # VM Configuration
  config.vm.hostname = "xwindow-lab"

  # Network configuration
  config.vm.network "private_network", ip: "192.168.56.10"
  config.vm.network "forwarded_port", guest: 22, host: 2222, id: "ssh"

  # VirtualBox specific configuration
  config.vm.provider "virtualbox" do |vb|
    vb.name = "X-Window-Lab"
    vb.memory = "4096"
    vb.cpus = 2

    # Enable GUI for testing X Window
    vb.gui = true

    # Video memory for better graphics support
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["modifyvm", :id, "--draganddrop", "bidirectional"]
  end

  # Shared folder for lab materials
  config.vm.synced_folder "./lab-materials", "/home/vagrant/lab-materials",
    create: true, mount_options: ["dmode=755,fmode=644"]

  # Provisioning script
  config.vm.provision "shell", inline: <<-SHELL
    # Update system
    apt-get update

    # Install X Window System components
    apt-get install -y xorg
    apt-get install -y xserver-xorg-video-all
    apt-get install -y xserver-xorg-input-all

    # Install multiple desktop environments for testing
    apt-get install -y ubuntu-desktop-minimal
    apt-get install -y gnome-session
    apt-get install -y kde-plasma-desktop
    apt-get install -y xfce4
    apt-get install -y lxde

    # Install multiple display managers
    apt-get install -y gdm3
    apt-get install -y lightdm
    apt-get install -y sddm
    apt-get install -y xdm

    # Install additional window managers
    apt-get install -y openbox
    apt-get install -y fluxbox
    apt-get install -y i3

    # Install development and debugging tools
    apt-get install -y vim
    apt-get install -y nano
    apt-get install -y tree
    apt-get install -y htop
    apt-get install -y xinit
    apt-get install -y xauth
    apt-get install -y xterm
    apt-get install -y x11-utils
    apt-get install -y x11-xserver-utils
    apt-get install -y mesa-utils

    # Install font packages
    apt-get install -y fonts-liberation
    apt-get install -y fonts-dejavu
    apt-get install -y fonts-noto
    apt-get install -y fontconfig

    # Install text editors and utilities
    apt-get install -y gedit
    apt-get install -y kate
    apt-get install -y mousepad

    # Install network tools for remote X testing
    apt-get install -y openssh-server
    apt-get install -y net-tools

    # Create lab user
    useradd -m -s /bin/bash labuser
    echo "labuser:password" | chpasswd
    usermod -aG sudo labuser

    # Set up X11 directories and permissions
    mkdir -p /etc/X11/xorg.conf.d
    chmod 755 /etc/X11/xorg.conf.d

    # Create backup directory for configurations
    mkdir -p /home/vagrant/config-backups
    chown vagrant:vagrant /home/vagrant/config-backups

    # Generate initial xorg.conf for labs
    if [ ! -f /etc/X11/xorg.conf ]; then
        # Create a basic xorg.conf template
        cat > /etc/X11/xorg.conf.template << 'EOF'
# Basic X Window Configuration Template
Section "Files"
    ModulePath   "/usr/lib/xorg/modules"
    FontPath     "catalogue:/etc/X11/fontpath.d"
    FontPath     "built-ins"
EndSection

Section "Module"
    Load "glx"
    Load "dri2"
EndSection

Section "Device"
    Identifier  "Card0"
    Driver      "auto"
EndSection

Section "Monitor"
    Identifier   "Monitor0"
    ModelName    "Generic Monitor"
EndSection

Section "Screen"
    Identifier    "Screen0"
    Device        "Card0"
    Monitor       "Monitor0"
    DefaultDepth  24
    SubSection "Display"
        Depth     24
        Modes     "1024x768" "800x600"
    EndSubSection
EndSection

Section "ServerLayout"
    Identifier     "Layout0"
    Screen      0  "Screen0" 0 0
    InputDevice    "Keyboard0" "CoreKeyboard"
    InputDevice    "Mouse0" "CorePointer"
EndSection

Section "InputDevice"
    Identifier  "Keyboard0"
    Driver      "kbd"
EndSection

Section "InputDevice"
    Identifier  "Mouse0"
    Driver      "mouse"
    Option      "Protocol" "auto"
    Option      "Device" "/dev/input/mice"
EndSection
EOF
    fi

    # Set default display manager to lightdm for easier management
    echo "/usr/sbin/lightdm" > /etc/X11/default-display-manager
    systemctl set-default graphical.target

    # Configure SSH for X11 forwarding
    sed -i 's/#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
    sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/' /etc/ssh/sshd_config
    sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/' /etc/ssh/sshd_config
    systemctl restart ssh

    # Create sample problematic configs for troubleshooting labs
    mkdir -p /home/vagrant/lab-configs

    # Broken xorg.conf for troubleshooting
    cat > /home/vagrant/lab-configs/broken-xorg.conf << 'EOF'
# Intentionally broken configuration for Lab 3
Section "Device"
    Identifier  "Card0"
    Driver      "nonexistent-driver"
EndSection

Section "Monitor"
    Identifier   "Monitor0"
    HorizSync    999999-999999
    VertRefresh  999999-999999
EndSection

Section "Screen"
    Identifier    "Screen0"
    Device        "Card0"
    Monitor       "Monitor0"
    DefaultDepth  128
EndSection
EOF

    # Create font test files
    mkdir -p /home/vagrant/test-fonts

    # Set ownership
    chown -R vagrant:vagrant /home/vagrant/lab-configs
    chown -R vagrant:vagrant /home/vagrant/test-fonts

    # Install additional debugging packages
    apt-get install -y strace
    apt-get install -y lsof
    apt-get install -y psmisc

    # Clean up
    apt-get autoremove -y
    apt-get autoclean

    # Create lab completion tracking
    mkdir -p /home/vagrant/lab-progress
    chown vagrant:vagrant /home/vagrant/lab-progress

    echo "X Window Lab Environment Setup Complete!"
    echo "Access the VM with: vagrant ssh"
    echo "Lab materials will be in /home/vagrant/lab-materials"
    echo "Use 'startx' to start X Window system or reboot for automatic GUI"
  SHELL

  # Post-provision message
  config.vm.post_up_message = <<-MSG
    X Window Lab Environment is ready!

    VM Details:
    - IP Address: 192.168.56.10
    - SSH: vagrant ssh
    - GUI: Enabled (reboot to start graphical interface)

    Available Desktop Environments:
    - GNOME (default)
    - KDE Plasma
    - XFCE
    - LXDE

    Available Display Managers:
    - LightDM (default)
    - GDM3
    - SDDM
    - XDM

    Lab Materials: /home/vagrant/lab-materials

    To start the labs:
    1. vagrant ssh
    2. cd lab-materials
    3. Follow the README.md instructions
  MSG
end
