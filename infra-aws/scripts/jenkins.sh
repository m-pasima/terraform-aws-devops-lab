#!/bin/bash -xe
exec &> >(tee /var/log/user-data.log)

# Update system and install prerequisites
yum update -y
yum install -y wget firewalld fontconfig

# Install Amazon Corretto JDK 17
CORRETTO_RPM="amazon-corretto-17-x64-linux-jdk.rpm"
curl -sSL -o "/tmp/${CORRETTO_RPM}" "https://corretto.aws/downloads/latest/${CORRETTO_RPM}"
yum localinstall -y "/tmp/${CORRETTO_RPM}"
export JAVA_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"

# Enable and start firewall
systemctl enable --now firewalld

# Configure Jenkins repository and install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum upgrade -y
yum install -y jenkins

# Enable and start Jenkins service
systemctl daemon-reload
systemctl enable --now jenkins

# Open Jenkins port if firewall is running
if systemctl is-active firewalld >/dev/null 2>&1; then
    firewall-cmd --permanent --new-service=jenkins || true
    firewall-cmd --permanent --service=jenkins --set-short="Jenkins ports"
    firewall-cmd --permanent --service=jenkins --set-description="Jenkins port exceptions"
    firewall-cmd --permanent --service=jenkins --add-port=8080/tcp
    firewall-cmd --permanent --add-service=jenkins
    firewall-cmd --reload
fi

# Output initial admin password for convenience
sleep 15
echo "Jenkins initial admin password:" | tee /var/log/jenkins-init.log
cat /var/lib/jenkins/secrets/initialAdminPassword | tee -a /var/log/jenkins-init.log

echo "Jenkins installation and setup completed!"
