#!/bin/bash
set -e

echo "Starting OpenVPN and Superset initialization..."

# Function to check if OpenVPN is connected
check_vpn_connection() {
    # Check if tun0 interface exists and has an IP
    if ip addr show tun0 &> /dev/null; then
        echo "VPN connection established"
        return 0
    fi
    return 1
}

# Start OpenVPN if .ovpn config file exists
if [ -f "/etc/secrets/client.ovpn" ]; then
    echo "OpenVPN configuration file detected, starting VPN connection..."
    
    # Start OpenVPN in the background using the secret file directly
    openvpn --config /etc/secrets/client.ovpn --daemon --log /var/log/openvpn.log
    
    # Wait for VPN connection to establish (max 30 seconds)
    echo "Waiting for VPN connection..."
    for i in {1..30}; do
        if check_vpn_connection; then
            echo "VPN connected successfully!"
            break
        fi
        if [ $i -eq 30 ]; then
            echo "WARNING: VPN connection timeout. Check /var/log/openvpn.log for details"
            cat /var/log/openvpn.log || true
        fi
        sleep 1
    done
else
    echo "No OpenVPN configuration provided, skipping VPN setup"
fi

# Switch to superset user for database operations
echo "Running database migrations..."
su -s /bin/bash -c "superset db upgrade" superset

# Create admin if not exists
echo "Creating admin user..."
su -s /bin/bash -c "superset fab create-admin \
  --username \"${SUPERSET_ADMIN_USERNAME}\" \
  --firstname \"${SUPERSET_ADMIN_FIRSTNAME}\" \
  --lastname \"${SUPERSET_ADMIN_LASTNAME}\" \
  --email \"${SUPERSET_ADMIN_EMAIL}\" \
  --password \"${SUPERSET_ADMIN_PASSWORD}\"" superset || true

# Initialize Superset
echo "Initializing Superset..."
su -s /bin/bash -c "superset init" superset

# Start the web server as superset user (main PID)
echo "Starting Superset web server..."
exec su -s /bin/bash -c "superset run -h 0.0.0.0 -p 8088" superset