#!/bin/bash -xe
exec &> >(tee /var/log/user-data.log)
yum update -y
yum install -y fontconfig java-17-openjdk wget firewalld
systemctl enable --now firewalld
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum upgrade -y
yum install -y jenkins
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins
if systemctl is-active firewalld >/dev/null 2>&1; then
    firewall-cmd --permanent --new-service=jenkins || true
    firewall-cmd --permanent --service=jenkins --set-short="Jenkins ports"
    firewall-cmd --permanent --service=jenkins --set-description="Jenkins port exceptions"
    firewall-cmd --permanent --service=jenkins --add-port=8080/tcp
    firewall-cmd --permanent --add-service=jenkins
    firewall-cmd --reload
fi
sleep 15
echo "Jenkins initial admin password:" | tee /var/log/jenkins-init.log
cat /var/lib/jenkins/secrets/initialAdminPassword | tee -a /var/log/jenkins-init.log
echo "Jenkins installation and setup completed!"
