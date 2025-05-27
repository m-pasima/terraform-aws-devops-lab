#!/usr/bin/env bash
set -euo pipefail
NEXUS_VERSION="3.75.1-01"
INSTALL_DIR="/opt"
NEXUS_USER="nexus"
NEXUS_GROUP="nexus"
DOWNLOAD_URL="https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz"
TMP_TARBALL="/tmp/nexus-${NEXUS_VERSION}.tar.gz"
DATA_DIR="/opt/sonatype-work"
echo ">>> [1/8] Installing Java 17 (Amazon Corretto OpenJDK)..."
if ! java -version 2>&1 | grep '17.'; then
  if command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y java-17-amazon-corretto-devel
  else
    sudo yum install -y java-17-amazon-corretto-devel
  fi
fi
echo ">>> [2/8] Creating nexus user & group..."
getent group "${NEXUS_GROUP}" >/dev/null || groupadd --system "${NEXUS_GROUP}"
id -u "${NEXUS_USER}" >/dev/null 2>&1 ||   useradd --system -g "${NEXUS_GROUP}"           -d "${INSTALL_DIR}/nexus-${NEXUS_VERSION}"           -s /sbin/nologin "${NEXUS_USER}"
echo ">>> [3/8] Downloading Nexus ${NEXUS_VERSION}..."
curl -fSL "${DOWNLOAD_URL}" -o "${TMP_TARBALL}"
echo ">>> [4/8] Extracting Nexus to ${INSTALL_DIR}..."
tar -xzf "${TMP_TARBALL}" -C "${INSTALL_DIR}"
echo ">>> [5/8] Setting up directories & permissions..."
mkdir -p "${DATA_DIR}"
chown -R "${NEXUS_USER}:${NEXUS_GROUP}"     "${INSTALL_DIR}/nexus-${NEXUS_VERSION}"     "${DATA_DIR}"
echo ">>> [6/8] Creating stable symlink: /opt/nexus → nexus-${NEXUS_VERSION}"
ln -sfn "${INSTALL_DIR}/nexus-${NEXUS_VERSION}" "${INSTALL_DIR}/nexus"
echo ">>> [7/8] Configuring Nexus to run as ${NEXUS_USER}..."
sed -i   -e "s|#run_as_user=.*|run_as_user="${NEXUS_USER}"|"   "${INSTALL_DIR}/nexus/bin/nexus.rc"
echo ">>> [8/8] Creating & enabling systemd service..."
cat > /etc/systemd/system/nexus.service <<EOF
[Unit]
Description=Sonatype Nexus Repository Manager
After=network.target
[Service]
Type=forking
LimitNOFILE=65536
ExecStart=${INSTALL_DIR}/nexus/bin/nexus start
ExecStop=${INSTALL_DIR}/nexus/bin/nexus stop
User=${NEXUS_USER}
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus
echo
echo "✅ Nexus Repository OSS ${NEXUS_VERSION} is now running!"
echo "👉 Access the UI at: http://<YOUR-SERVER-IP>:8081"
echo
echo "📖 Next steps:"
echo "   • Make sure port 8081 is allowed in your AWS Security Group."
echo "   • View logs: tail -f /opt/sonatype-work/log/*.log"
