# Chapter 3: X Window System - Summary

## 3.1 Introduction

The X Window system is the primary GUI server for Linux systems, providing a network-oriented graphical interface using the WIMP (Windows, Icons, Menus, and Pointers) paradigm.

**Key Concepts:**
- Linux GUIs are optional and add overhead
- X Window uses open source components allowing extensive customization
- Network-oriented design allows remote display capabilities
- Multiple desktop environments available (GNOME, KDE, etc.)

## 3.2 X Window Components

### 3.2.1 Hardware Drivers
- **Graphics Adapters**: AMD, Intel, Nvidia, etc.
- **Input Devices**: Mouse, keyboard, touchpad drivers
- **Vendor-specific and generic drivers available**

### 3.2.2 X Server
- **Function**: Manages GUI using server-client model
- **Main executable**: `X`
- **Responsibilities**: Display updates, keyboard/mouse input handling
- **Network capability**: Supports remote X clients

### 3.2.3 X Client
- **Definition**: Applications that communicate with X server
- **Examples**: Terminal applications, graphical programs
- **Location**: Can run locally or remotely

### 3.2.4 Window Manager
- **Purpose**: Manages window placement and appearance
- **Special privilege**: Can manage other X clients
- **Requirements**: May need accelerated graphics support
- **Note**: X Window defines protocol only, not appearance

### 3.2.5 Display Manager
**Function**: Provides graphical login interface using XDMCP protocol

**Common Display Managers:**
- `xdm` - X Display Manager (basic)
- `gdm` - GNOME Display Manager
- `kdm` - KDE Display Manager  
- `lightdm` - Ubuntu's display manager

**Configuration Locations:**
- `gdm`: `/etc/gdm/` and `/etc/gdm/custom.conf`
- `kdm`: `/etc/kdm/`
- `xdm`: `/etc/X11/xdm/`

#### Display Manager Control

**Runlevel Dependencies:**
- **Debian-derived**: Display manager starts in runlevels 2-5
- **Red Hat-derived**: Display manager starts only in runlevel 5

**Configuration Files:**
- Debian: `/etc/inittab` - `id:2:initdefault:`
- Red Hat: `/etc/inittab` - `id:5:initdefault:`

#### Switching Display Managers
- **Debian**: `sudo dpkg-reconfigure kdm`
- **Red Hat**: Edit `/etc/sysconfig/desktop`

```bash
# Red Hat - GNOME setup
DESKTOP="GNOME"
DISPLAYMANAGER="GNOME"

# Red Hat - KDE setup  
DESKTOP="KDE"
DISPLAYMANAGER="KDE"
```

#### Display Manager Customization

**GDM Banner Configuration:**
```bash
init 3
su -s /bin/sh gdm
gconftool-2 --direct --config-source=xml:readwrite:$HOME/.gconf --type bool --set /apps/gdm/simple-greeter/banner_message_enable true
gconftool-2 --direct --config-source=xml:readwrite:$HOME/.gconf --type string --set /apps/gdm/simple-greeter/banner_message_text "Custom Message"
exit
init 5
```

**KDM Banner Configuration:**
Edit `/etc/kde/kdm/kdmrc`:
```
UseTheme=false
GreetString=Custom Message
```

**Color Depth Configuration:**
Edit `/etc/X11/xorg.conf`:
```
Section "Screen"
    Identifier    "Default Screen"
    Monitor       "Monitor"
    Device        "Video Card"
    DefaultDepth  16
    Modes         "1024x768"
EndSection
```

### 3.2.6 Widget/Toolkit Libraries
- **Motif**: Old, once proprietary (UNIX CDE)
- **Qt**: Modern C++ toolkit (KDE)
- **Gtk+**: GIMP toolkit for C development (GNOME)

## 3.3 Desktop Environments

**Popular Options:**
- **GNOME**: Uses GTK+ toolkit
- **KDE**: Uses Qt toolkit

**Benefits:**
- Consistent appearance across applications
- Efficient resource usage
- Bundled applications (file manager, text editor, browsers, etc.)

**Future Considerations:**
- **Wayland**: Promising X11 replacement
- **Weston**: Reference Wayland implementation
- **Compatibility**: X servers can run under Wayland

## 3.4 Configuring X Windows

### 3.4.1 Hardware Considerations
**Critical Components:**
- Video cards (most critical)
- Display monitors  
- Keyboards and mice
- Pointing devices

**Laptop Considerations:**
- Verify component compatibility before purchase
- Video card issues harder to resolve (not easily replaceable)

### 3.4.2 System Boot Configuration

**Single-User Mode Access:**
- Press key at GRUB menu
- Edit kernel parameters
- Add: `1`, `s`, `S`, or `single`

**Example kernel line:**
```
kernel /boot/vmlinuz-3.1.25 root=/dev/sda2 ro 1
```

**Alternative Console Access:**
- Press `Ctrl+Alt+F2` (try F1-F6)
- Login via command line
- Switch to runlevel 1: `telinit 1`
- Start X manually: `startx`

### 3.4.3 Display Configuration
- **Primary display**: Identifier 0
- **Additional displays**: Numbered incrementally (1, 2, etc.)
- **Log files**: `/var/log/Xorg.0.log`, `/var/log/Xorg.1.log`, etc.

## 3.5 X Server Configuration File

### 3.5.1 /etc/X11/xorg.conf Structure

**Main Configuration:**
- Primary file: `/etc/X11/xorg.conf`
- Additional configs: `/etc/X11/xorg.conf.d/*.conf`
- Modern X servers can auto-configure without xorg.conf

**Configuration Sections:**

| Section | Purpose |
|---------|---------|
| `Files` | Font and module file paths |
| `ServerFlags` | Global server options |
| `Module` | Dynamic module loading |
| `Extensions` | X11 protocol extensions |
| `InputDevice` | Keyboard and pointer devices |
| `InputClass` | Input device classes |
| `Device` | Video card configuration |
| `VideoAdaptor` | Xv video adaptor settings |
| `Monitor` | Monitor specifications |
| `Modes` | Video mode definitions |
| `Screen` | Screen configuration |
| `ServerLayout` | Overall layout combining sections |
| `DRI` | Direct Rendering Infrastructure |
| `Vendor` | Vendor-specific settings |

## 3.6 Troubleshooting X Server

### 3.6.1 Log File Analysis

**Log Locations:** `/var/log/Xorg.0.log`

**Log Entry Types:**
- `II` = Informational
- `WW` = Warning  
- `EE` = Error
- `**` = From configuration file
- `++` = From command line
- `--` = Probed
- `NI` = Not implemented
- `??` = Unknown

### 3.6.2 Common Issues and Solutions

#### Missing Configuration File
```bash
# Generate new configuration
X -configure

# Backup and test
cp /etc/X11/xorg.conf /etc/X11/xorg.conf.backup
mv xorg.conf.new /etc/X11/xorg.conf
startx
```

#### No Video Card Detected
**Error:** `No devices detected`

**Solutions:**
1. Use proprietary drivers (Nvidia/AMD)
2. Use generic VESA driver:

```
Section "Device"
    Identifier  "Card0"
    Driver      "vesa"
EndSection
```

#### No Display Monitor Detected  
**Error:** `Screen(s) found, but none have a usable configuration`

**Compatibility Factors:**
- Horizontal sync rate
- Vertical refresh rate  
- Color depth
- Resolution

#### Font Issues
**Error:** `font named "fixed" cannot be found`

**Modern Font Configuration:**
```
Section "Files"
    ModulePath   "/usr/lib/xorg/modules"
    FontPath     "catalogue:/etc/X11/fontpath.d"
    FontPath     "built-ins"
EndSection
```

**Font Installation:**
```bash
# System-wide fonts
cp fonts/* /usr/share/fonts/local/
fc-cache /usr/share/fonts/local

# User fonts  
cp fonts/* ~/.fonts/
fc-cache ~/.fonts
```

### 3.6.3 Application Error Logging
**File:** `~/.xsession-errors`
- Contains STDERR output from X applications
- Useful for troubleshooting GUI application issues
- Generated by desktop environments like GNOME

## Key Commands Summary

| Command | Purpose |
|---------|---------|
| `startx` | Start X server manually |
| `telinit 1` | Switch to single-user mode |
| `X -configure` | Generate X configuration file |
| `dpkg-reconfigure kdm` | Switch display manager (Debian) |
| `gconftool-2` | Configure GDM settings |
| `fc-cache` | Update font cache |
| `Ctrl+Alt+F2` | Switch to alternative console |

## Important Files and Directories

| Path | Purpose |
|------|---------|
| `/etc/X11/xorg.conf` | Main X configuration |
| `/etc/X11/xorg.conf.d/` | Additional X configurations |
| `/var/log/Xorg.0.log` | X server log file |
| `/etc/inittab` | Default runlevel configuration |
| `/etc/sysconfig/desktop` | Red Hat display manager config |
| `/etc/gdm/custom.conf` | GDM configuration |
| `/usr/share/fonts/` | System font directory |
| `~/.fonts/` | User font directory |
| `~/.xsession-errors` | X application error log |