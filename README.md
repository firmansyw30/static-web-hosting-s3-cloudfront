# 🌟 Static Website Hosting on AWS using Terraform 🌟
This project provides a comprehensive solution for hosting a static website on Amazon Web Services (AWS) using Terraform. The project utilizes Terraform to define and manage the infrastructure resources, including S3 buckets, CloudFront distributions, and IAM policies. The solution is designed to be scalable, secure, and easy to manage.

## 🚀 Features
* **Static Website Hosting**: Host a static website on S3 with a public access block to restrict access.
* **CloudFront Distribution**: Create a CloudFront distribution to serve the static website with a custom domain name.
* **IAM Policy Management**: Define an IAM policy to allow CloudFront to access the S3 bucket.
* **Terraform Configuration**: Use Terraform to define and manage the infrastructure resources.
* **Customizable**: Allow users to customize the configuration and infrastructure resources using input variables.

## 🛠️ Tech Stack
* **Terraform**: Used to define and manage the infrastructure resources.
* **AWS**: Used to host the static website and provide CloudFront distribution.
* **S3**: Used to store the static website content.
* **CloudFront**: Used to serve the static website with a custom domain name.
* **IAM**: Used to manage access to the S3 bucket and CloudFront distribution.

## 📦 Installation
### Prerequisites
* **Terraform**: Install Terraform on your machine.
* **AWS CLI**: Install the AWS CLI on your machine and configure your AWS credentials.
* **Git**: Install Git on your machine to clone the repository.

### Setup Instructions
1. Clone the repository using Git: `git clone https://github.com/your-repo/your-project.git`
2. Navigate to the project directory: `cd your-project`
3. Initialize Terraform: `terraform init`
4. Update the required variables field in var.tfvars
5. Apply the Terraform configuration: `terraform apply -var 'var.tfvars'`
6. Access your static website using the custom domain name.

## 📂 Project Structure
```
.
├── main.tf
├── output.tf
├── provider.tf
├── variables.tf
├── index.html
├── README.md
└── .gitignore
```

## 🤝 Contributing
Contributions are welcome! Please submit a pull request with your changes and a brief description of what you've added or fixed.

## 📬 Contact
For any questions or concerns, please contact us at [firmansyahwicaksono30@gmail.com](mailto:firmansyahwicaksono30@gmail.com).

## 💖 Thanks Message
Thanks for visit my project! I hope you find it helpful.
