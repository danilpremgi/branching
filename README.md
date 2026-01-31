# branching

This repository provisions Azure infrastructure in UK South with a hub-and-spoke topology, two Windows Server 2022 VMs split across availability zones, two additional Windows Server 2022 VMs on a separate subnet without availability zones, and a third virtual network hosting a single Windows 11 VM.

## Prerequisites
- Terraform >= 1.5
- Azure credentials configured for the `azurerm` provider

## Usage
```bash
terraform init
terraform plan \
  -var "subscription_id=00000000-0000-0000-0000-000000000000"
terraform apply \
  -var "subscription_id=00000000-0000-0000-0000-000000000000"
```

## Notes
- An Azure Firewall in the hub virtual network handles outbound access via UDRs.
- Azure Bastion is deployed in the hub virtual network for secure access to the VMs.
- VMs are deployed into availability zones 1 and 2 for the primary subnet; secondary subnet VMs are not zonal.
- The Windows 11 VM is deployed in a separate virtual network and subnet.
