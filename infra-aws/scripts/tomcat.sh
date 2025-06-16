#!/bin/bash -xe
exec &> >(tee /var/log/user-data.log)
yum update -y
yum install -y tar wget shadow-utils coreutils
CORRETTO_RPM="amazon-corretto-17-x64-linux-jdk.rpm"
curl -sSL -o "/tmp/${CORRETTO_RPM}" "https://corretto.aws/downloads/latest/${CORRETTO_RPM}"
yum localinstall -y "/tmp/${CORRETTO_RPM}"
export JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
echo "→ JAVA_HOME=${JAVA_HOME}"
groupadd -r tomcat || true
useradd -r -g tomcat -d /opt/tomcat -s /sbin/nologin tomcat || true
TOMCAT_VERSION="11.0.7"
BASE="https://dlcdn.apache.org/tomcat/tomcat-11/v${TOMCAT_VERSION}/bin"
cd /tmp
for F in apache-tomcat-${TOMCAT_VERSION}.tar.gz{,.sha512}; do
  [ -f "${F}" ] || wget -q "${BASE}/${F}"
done
sha512sum -c "apache-tomcat-${TOMCAT_VERSION}.tar.gz.sha512" || echo "⚠️ Checksum mismatch—continuing anyway"
mkdir -p /opt/tomcat
tar xzf "apache-tomcat-${TOMCAT_VERSION}.tar.gz" --strip-components=1 -C /opt/tomcat
chown -R tomcat:tomcat /opt/tomcat
find /opt/tomcat -type d -exec chmod 750 {} +
find /opt/tomcat -type f -exec chmod 640 {} +
chmod +x /opt/tomcat/bin/*.sh
usermod -aG tomcat ec2-user
find /opt/tomcat -type d -exec chmod g+rx {} +
cat > /etc/systemd/system/tomcat.service <<'EOF'
[Unit]
Description=Apache Tomcat 11
After=network.target
[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
ExecStart=/opt/tomcat/bin/catalina.sh start
ExecStop=/opt/tomcat/bin/catalina.sh stop
Restart=on-failure
RestartSec=10
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now tomcat
echo "✅ Tomcat ${TOMCAT_VERSION} deployed in /opt/tomcat"
echo "👉 Check: systemctl status tomcat"
echo "🔓 Don’t forget to open port 8080 in your Security Group!"
