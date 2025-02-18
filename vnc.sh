#!/bin/bash

install() {
    echo "Installing LXQt, TigerVNC, and noVNC..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y lxqt tigervnc-standalone-server tigervnc-common \
        novnc websockify x11-xserver-utils

    echo "Configuring VNC..."
    mkdir -p ~/.vnc
    echo -e "#!/bin/bash\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nstartlxqt &" > ~/.vnc/xstartup
    chmod +x ~/.vnc/xstartup

    echo "Setting VNC password:"
    vncpasswd

    echo "LXQt and VNC configuration complete."

    # Prompt to install Firefox
    read -p "Do you want to install Firefox (y/n)? " install_firefox
    if [[ "$install_firefox" == "y" || "$install_firefox" == "Y" ]]; then
        echo "Installing Firefox..."
        sudo apt install -y firefox
        echo "Firefox installation complete!"
    else
        echo "Firefox installation skipped."
    fi

    echo "Installation complete! Use './vnc_with_lxqt.sh --start' to start the server."
}

start() {
    echo "Starting VNC server..."
    vncserver :1

    echo "Starting noVNC WebSocket proxy..."
    websockify --web=/usr/share/novnc 6080 localhost:5901 &
    echo "Access noVNC at http://localhost:6080/vnc.html"
}

stop() {
    echo "Stopping all VNC sessions..."
    vncserver -kill :1
    pkill websockify
    echo "All VNC sessions stopped."
}

case "$1" in
    --install)
        install
        ;;
    --start)
        start
        ;;
    --stop)
        stop
        ;;
    *)
        echo "Usage: $0 --install | --start | --stop"
        ;;
esac
