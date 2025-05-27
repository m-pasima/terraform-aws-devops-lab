# AWS DevOps Infra Automation with Terraform & GitHub Actions

This repository provisions four AWS EC2 instances—**Jenkins, SonarQube, Nexus, Tomcat**—using reusable Terraform modules, user data scripts, and GitHub Actions CI/CD.

---

## 📦 Structure

<pre> ```text infra-aws/ ├── modules/ │ └── ec2/ # Reusable EC2 Terraform module ├── env/ │ └── main.tf # Environment configuration (root module) ├── scripts/ # User data scripts for each server ├── .github/ │ └── workflows/ # GitHub Actions for apply/destroy ``` </pre>


---

## 🚀 Getting Started

1. **Clone the repo and unzip contents**
2. Update variables as needed (e.g., `ami` for your region)
3. **Store AWS credentials** in GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
4. Push changes to your main branch
5. GitHub Actions will run `terraform apply` automatically. Trigger `terraform destroy` manually via Actions tab.

---

## 🛠️ Components

- **EC2 Instances**: Jenkins, SonarQube, Nexus, Tomcat
- **Terraform**: Reusable EC2 module for all servers
- **GitHub Actions**: Automated CI/CD for apply/destroy
- **User Data Scripts**: Installs and configures each app on instance boot

---

## 🔒 Security Group

Ports open:  
- **8080** (Tomcat, Jenkins)
- **9000** (SonarQube)
- **8081** (Nexus)
- **22** (SSH)

---

## 🖼️ Architecture Diagram 

![alt text](image.png)

## 🧑‍💻 Author

DevOps automation by **Passy (Pasima)** — [ Contact ](https://www.linkedin.com/in/your-link-here)
