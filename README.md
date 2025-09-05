# X Window System Lab Environment

This repository contains a comprehensive lab environment for learning X Window system configuration and troubleshooting as covered in Chapter 3 of Linux system administration.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Environment Setup](#environment-setup)
- [Lab Structure](#lab-structure)
- [Getting Started](#getting-started)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

## Prerequisites

### Software Requirements
- **VirtualBox** 6.1+ or **VMware Workstation**
- **Vagrant** 2.2+
- **Git** (for cloning this repository)
- **Host System**: Windows 10+, macOS 10.14+, or Linux with virtualization support

### Hardware Requirements
- **RAM**: 8GB minimum (4GB allocated to VM)
- **Storage**: 20GB free space
- **CPU**: Virtualization support (Intel VT-x or AMD-V)
- **Display**: 1920x1080 minimum resolution recommended

### Host System Configuration
1. **Enable Virtualization** in BIOS/UEFI
2. **Install VirtualBox** with Extension Pack
3. **Install Vagrant** from official website
4. **Verify installations**:
   ```bash
   VBoxManage --version
   vagrant --version
   ```

## Environment Setup

### 1. Clone Repository
```bash
git clone https://github.com/yourusername/x-window-labs.git
cd x-window-labs
```

### 2. Start Lab Environment
```bash
# Launch the VM
vagrant up

# This will:
# - Download Ubuntu 20.04 base box (~1.5GB)
# - Configure VM with 4GB RAM, 2 CPUs
# - Install X Window components
# - Install multiple desktop environments
# - Configure lab materials
```

### 3. Access the Environment
```bash
# SSH access (recommended for most labs)
vagrant ssh

# GUI access
# The VM will have GUI enabled - reboot to start graphical interface
vagrant reload
```

### 4. Verify Installation
```bash
# Inside the VM
vagrant@xwindow-lab:~$ ls lab-materials/
README.md  lab1/  lab2/  lab3/  lab4/

# Check X Window system
vagrant@xwindow-lab:~$ which X
/usr/bin/X

# Verify display managers
vagrant@xwindow-lab:~$ ls /usr/sbin/*dm
/usr/sbin/gdm3  /usr/sbin/lightdm  /usr/sbin/sddm  /usr/sbin/xdm
```

## Lab Structure

### Lab Overview
| Lab | Topic | Duration | Difficulty |
|-----|-------|----------|------------|
| Lab 1 | X Window Components & Basic Configuration | 60 min | Beginner |
| Lab 2 | Display Manager Configuration | 45 min | Intermediate |
| Lab 3 | X Server Troubleshooting | 90 min | Advanced |
| Lab 4 | Font Management & Advanced Configuration | 75 min | Intermediate |

### File Structure
```
x-window-labs/
├── Vagrantfile                 # VM configuration
├── README.md                   # This file
├── chapter3-summary.md         # Chapter 3 summary
├── lab-materials/              # Synced to VM
│   ├── lab1/
│   │   ├── lab1-instructions.md
│   │   ├── configs/
│   │   └── scripts/
│   ├── lab2/
│   │   ├── lab2-instructions.md
│   │   ├── configs/
│   │   └── scripts/
│   ├── lab3/
│   │   ├── lab3-instructions.md
│   │   ├── configs/
│   │   └── scripts/
│   └── lab4/
│       ├── lab4-instructions.md
│       ├── configs/
│       └── scripts/
└── docs/                       # Additional documentation
    ├── reference-commands.md
    └── troubleshooting-guide.md
```

## Getting Started

### Quick Start Guide

1. **Complete Environment Setup** (above)

2. **Access Lab Materials**:
   ```bash
   vagrant ssh
   cd lab-materials
   ```

3. **Start with Lab 1**:
   ```bash
   cd lab1
   cat lab1-instructions.md
   ```

4. **Lab Progression**:
   - Complete labs in order (1→2→3→4)
   - Each lab builds on previous knowledge
   - Check off objectives as you complete them

### Lab Access Methods

#### Method 1: SSH (Recommended for most tasks)
```bash
vagrant ssh
# Advantages: Full terminal access, copy/paste, fast
# Use for: Configuration editing, command-line tasks
```

#### Method 2: GUI Desktop
```bash
vagrant up
# Access VM console through VirtualBox GUI
# Advantages: Visual desktop environment
# Use for: Testing graphical applications, display managers
```

#### Method 3: X11 Forwarding (Advanced)
```bash
vagrant ssh -- -X
# Test with: xterm, xclock, gedit
# Advantages: Run GUI apps on host display
# Use for: Remote X testing, specific GUI debugging
```

### User Accounts

| Username | Password | Purpose |
|----------|----------|---------|
| `vagrant` | `vagrant` | Main lab user (sudo access) |
| `labuser` | `password` | Test user for multi-user scenarios |
| `root` | N/A | Use `sudo` for root access |

## Lab Instructions

### Before Starting Each Lab

1. **Read the full lab instructions**
2. **Understand the objectives**
3. **Check prerequisites**
4. **Have backup plan ready**

### During Labs

1. **Document your changes**:
   ```bash
   # Example: Before modifying configuration
   sudo cp /etc/X11/xorg.conf /home/vagrant/config-backups/xorg.conf.backup.$(date +%Y%m%d_%H%M%S)
   ```

2. **Test changes carefully**:
   ```bash
   # Test X configuration before reboot
   sudo X -config /path/to/test.conf
   ```

3. **Track progress**:
   ```bash
   # Mark lab completion
   echo "Lab X completed: $(date)" >> /home/vagrant/lab-progress/completed.log
   ```

### After Each Lab

1. **Reset environment if needed**:
   ```bash
   # Restore from backup
   sudo cp /home/vagrant/config-backups/xorg.conf.backup.TIMESTAMP /etc/X11/xorg.conf
   ```

2. **Document learning outcomes**
3. **Prepare for next lab**

## Environment Commands

### VM Management
```bash
# Start VM
vagrant up

# SSH into VM
vagrant ssh

# Restart VM
vagrant reload

# Stop VM
vagrant halt

# Destroy VM (delete all data)
vagrant destroy

# View VM status
vagrant status
```

### X Window Management
```bash
# Start X manually
startx

# Stop X server
sudo pkill X

# Check X server status
ps aux | grep X

# View X logs
sudo tail -f /var/log/Xorg.0.log

# Test X configuration
sudo X -configure
```

### Display Manager Management
```bash
# Check current display manager
cat /etc/X11/default-display-manager

# Switch display managers (Ubuntu)
sudo dpkg-reconfigure lightdm

# Control display manager service
sudo systemctl status display-manager
sudo systemctl restart display-manager
sudo systemctl stop display-manager
```

## Troubleshooting

### Common Issues

#### 1. VM Won't Start
```bash
# Check VirtualBox
VBoxManage list vms

# Check virtualization
grep -E "(vmx|svm)" /proc/cpuinfo

# Restart VirtualBox service
sudo systemctl restart vboxdrv
```

#### 2. X Server Won't Start
```bash
# Check logs
sudo tail -50 /var/log/Xorg.0.log | grep -E "(EE|WW)"

# Test with VESA driver
sudo X -configure
# Edit generated config to use "vesa" driver
```

#### 3. GUI Performance Issues
```bash
# Increase video memory in Vagrantfile
vb.customize ["modifyvm", :id, "--vram", "256"]

# Rebuild VM
vagrant destroy
vagrant up
```

#### 4. SSH Connection Issues
```bash
# Reset SSH
vagrant reload

# Alternative access
vagrant ssh -- -o StrictHostKeyChecking=no
```

### Getting Help

1. **Check lab instructions** for specific guidance
2. **Review log files** for error details
3. **Use VM snapshots** before major changes
4. **Reset environment** if needed: `vagrant destroy && vagrant up`

### Best Practices

1. **Always backup configurations** before changes
2. **Test in single-user mode** when possible
3. **Read log files carefully** for troubleshooting
4. **Document your solutions** for reference
5. **Reset to known good state** between labs if needed

## Performance Optimization

### Host System
- Close unnecessary applications
- Ensure adequate free disk space
- Use SSD storage for better performance

### VM Configuration
- Adjust memory allocation based on host capacity
- Enable hardware acceleration
- Use appropriate video memory settings

## Additional Resources

### Documentation
- [X.Org Documentation](https://www.x.org/wiki/)
- [Ubuntu X Window Guide](https://help.ubuntu.com/community/X)
- [Arch Linux X11 Wiki](https://wiki.archlinux.org/title/Xorg)

### Configuration References
- [xorg.conf Manual](https://www.x.org/releases/current/doc/man/man5/xorg.conf.5.xhtml)
- [Display Manager Comparison](https://wiki.archlinux.org/title/Display_manager)

### Troubleshooting Resources
- [X.Org Error Messages](http://www.x.org/wiki/FAQErrorMessages)
- [Common X Problems](https://wiki.ubuntu.com/X/Troubleshooting)

## Lab Completion

Upon completing all labs, you should be able to:

✅ **Understand X Window architecture and components**
✅ **Configure X server settings manually**
✅ **Manage multiple display managers**
✅ **Troubleshoot common X Window issues**
✅ **Configure fonts and advanced X settings**
✅ **Implement security and remote access controls**

## Support

For technical issues with the lab environment:

1. Check this README and troubleshooting sections
2. Review individual lab instructions
3. Examine log files for specific errors
4. Reset environment and try again
5. Create an issue in the repository with detailed error information

## Contributing

Contributions to improve the lab environment are welcome:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with improvements

---

**Happy Learning!** 🐧🖥️