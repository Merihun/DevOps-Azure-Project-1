# Udacity-DevOps-Azure-Project-1

## Deploy a scalable IaaS web server in Azure using Azure CLi, Packer & Terraform

****

### Project Overview

***

- This project will acomplish creating infrastructure as code in the form of a Terraform template to deploy a website with a load balancer.
- It contains infrastructure to host a web application on Microsoft Azure.
- It uses Terraform to manage resources, Packer to build an
image to be used for the virtual machine and creates the necessary network resources to route traffic.
- The user will be promted for the amount of instances to be created within the Availability set.
- The virtual machine instance count is spread across the Availability set and load is distributed with the use of a Load Balancer.
- Block external internet traffic with the use of Network Security Groups by default.

### Project Scenario

***
Your company's development team has created an application that they need deployed to Azure. The application is self-contained, but they need the infrastructure to deploy it in a customizable way based on specifications provided at build time, with an eye toward scaling the application for use in a CI/CD pipeline.

Although we’d like to use Azure App Service, management has told us that the cost is too high for a PaaS like that and wants us to deploy it as pure IaaS so we can control cost. Since they expect this to be a popular service, it should be deployed across multiple virtual machines.

To support this need and minimize future work, the project should use Packer to create a server image, and Terraform to create a template for deploying a scalable cluster of servers—with a load balancer to manage the incoming traffic. We’ll also need to adhere to security practices and ensure that our infrastructure is secure.

### Follow the below main steps to create the infrastructure

- Create a Resource Group.

- Create a Virtual network and a subnet on that virtual network.

- Create a Network Security Group. Ensure that you explicitly allow access to other VMs on the subnet and deny direct access from the internet.

- Create a Network Interface.

- Create a Public IP.

- Create a Load Balancer. Your load balancer will need a backend address pool and address pool association for the network interface and the load balancer.

- Create a virtual machine availability set.

- Create virtual machines. Make sure you use the image you deployed using Packer!

- Create managed disks for your virtual machines.

- Ensure a variables file allows for customers to configure the number of virtual machines and the deployment at a minimum.

** All commands are run through Azure CLI (see Dependencies section)

### Dependencies

****

1. Create an [Azure Account](https://portal.azure.com)
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Getting Started

****

1. Clone this repository
2. Setting the Azure Policy
3. Create environment variables
4. Modify the packer file
5. Modify terraform variable files

### Instructions

****

#### 1. Clone this repository

git clone

Login to Azure CLI
    az login

#### 2. Deploy a Policy

- Write a policy definition to deny the creation of resources that do not have tags
- Apply the policy definition to the subscription with the name "tagging-policy"
- Use ``` az policy assignment list ```.

Create tagging policy definition as defined in ```tagging_policy.rules.json``` and assign this to the subscription by running the bash script ``` tagging-policy-create.sh ```
First make the script executable:

```bash
chmod +x tagging-policy-create.sh
```

Execute the script:

```bash
./Policy/tagging-policy-create.sh
```

Or use the below steps as alternetive to script.

a. Create the Policy Definition

```azure
az policy definition create --name tagging-policy  --rules Policy\tagging_policy.rules.json \
   --param Policy/tagging_policy.params.json
```

b. Show the Policy definition

```azure
az policy definition show --name tagging-policy
```

c. Assign the Policy ( naming "tagging-policy") to the global Scope ( subscription scope in this case)

```azure cli
az policy assignment create --name tagging-policy --policy tagging-policy --param Policy/tagging_assignment.params.json
```

d. Check the policy was assigned:

```azure cli
az policy assignment show --name tagging-policy
```

or

```azure cli
az policy assignment list
```

#### 2. Create service principal for Terraform and Packer [Create service Principal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#creating-a-service-principal-using-the-azure-cli)

****
  Steps

  a. Login to the Azure CLI using:
      $ az login
  b. list the Subscriptions associated with the account via:
      $ az account list --output table
  c. Create Service Principal using the following command:
      $ az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
  d. Test these values work as expected by first logging in:
      $ az login --service-principal -u CLIENT_ID -p CLIENT_SECRET --tenant TENANT_ID

#### 3. Set ARM environment variables

Packer

  a. Create a resource group for your image. It will be used as a variable with default value into packer file "server.json" ( example: udacity-packerimage-rg), also will be used in terraform

```azure cli

az group create -l eastus -n udacity-packerimage-rg

```

Verify the resource group created

```azure
az group exists -n udacity-packerimage-rg
```

  b. Modify the variable sections into packer file server.json so the image builds in your preferred region, and use the resource group name created above
  c. Create a RBAC ( Service principal) account , using the following command:

  ```azure
  az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
  ```

  and check your subscription id.

  ```azure
  az account show --query "{ subscription_id: id }"
  ```

It is best to add these variables to your ./bashrc file to persist if the terminal is closed
d. Export ( set) the following variables that will be used in server.json

```bash
export CLIENT_ID="<rbac account client_id value from above command>"
export CLIENT_SECRET="<rbac account client_secret value from above command>"
export TENANT_ID="<rbac  account tenant_id value from above command>"
export SUBSCRIPTION_ID="<subscription_id value from above command> "

Note: check with echo $CLIENT_ID ( for example)
```

Once you have exported and config the environment variable, use printenv to check whether they are configured properly.

  printenv
Note: check with echo $ARM_CLIENT_ID ( for example)

#### 5. Build packer image

Use Packer to create a server image, ensuring that the provided application is included in the template.

- Use an Ubuntu 18.04-LTS SKU as your base image
- Ensure the following in your provisioners:

  ```bash
  "inline": ["echo 'Hello, World!' > index.html", "nohup busybox httpd -f -p 80 &" ],
  "inline_shebang": "/bin/sh -x", 
  "type": "shell"
  ```

- Ensure that the resource group you specify in Packer for the image is the same image specified in Terraform
    packer build server.json
Run the following command to build your server image. This may take a while ( approx 10 minutes) so grab a cup of coffee.

```azure
packer build Packer/server.json
```

#### 6. Get Image ID

Get the ID for the image you just created, to be used in the Terraform template

  az image show packer-image

#### 7. Edit Terraform variables

| File        | Description |
| ----------- | ----------- |
| locals.tf      | Security Rules block for our Net Security Group Rules |
| terraform.tfvars   | to provide default variable values        |
| vars.tf  | Variables |
| maint.tf  | Provider and resources |

- Use the terraform.tfvars to add yor variables ( location , client_id, client_secret, tenant_id, subscription_id; some network settings, some vm settings
- Use the same values , for example, of the commands that you executed already in packer
  
```azure cli
az account show --query "{ subscription_id: id }"
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```

- Edit variables in the 'variables.tf' to reflect your information.
The following items should be updated:

  - prefix
  - username
  - password
  - location (should match image resource group location)
  - image_id

```hcl
variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "YOUR PREFIX"
}

variable "username" {
  description = "Enter username to associate with the machine"
  default     = "YOUR USER NAME"

}

variable "password" {
  description = "Enter password to use to access the machine"
  default     = "YOUR PASSWORD"

}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "YOUR LOCATION"
}

variable "image_id" {
  description = "Enter the ID for the image which will be used for creating the Virtual Machines"
  default     = "YOUR IMAGE ID HERE"
}

...

```

Instance count will be prompted on creation of the resources.

#### 7. Run Terraform

***
Go to Terraform directory and Run terraform init to prepare your directory for terraform

```
    cd Terraform
    terraform init
    terraform validate
    terraform plan -out solution.plan
    terraform apply "solution.plan"
```

### Output

***
Following the Terraform service principal authentication guidelines creates the following resources:

- Azure Service Principal

Running the Packer commands creates the following resources:

- Image resource group
- Managed virtual machine image

The following resources are created with the Terraform template:

- Resource Group
- Virtual Network
- Subnet
- Network Security Group
- Security group rules
- Public IP
- Load Balancer
- Backend Address pools
- Availability Set
- Network Interface Card(s)
- Virtual Machine(s)
- Azure Managed Disk(s)

Go to Terraform directory and Run terraform init to prepare your directory for terraform

```
cd Terraform

pwd

terraform init
```

b. validate the files

terraform validate

c. to create an execution plan named "solution.plan"

``` terraform plan -out solution.plan ```

d. Create the Infrastructure ( wait some minutes) :

    terraform apply solution.plan

e. You can get as an output result , the URL of the Load balancer Example:

Outputs:

lb_url = "http://20.163.224.135/"

f. You can check your IaaC is working with curl command or going to that URL in your browser

curl <http://20.163.224.135/>

result:
Hello World!!!

### Destroying the Resources

delete the Terraform resources first

```
pwd
terraform plan -destroy -out solution.destroy.plan
terraform apply solution.destroy.plan
```

delete the packer image

```
az image delete --name udacity-server-image  --resource-group udacity-packerimage-rg
```

delete the Resource Group used in Packer

```
az group delete -n udacity-packerimage-rg
```

delete the Policy Assignment

```
az policy assignment delete --name tagging-policy
```

delete the Policy Definition

```
az policy definition delete --name tagging-policy
```

Delete all the Resource

az group delete --name packerResourceGroup --yes
az group delete --name NetwrokWatcherRG --yes
