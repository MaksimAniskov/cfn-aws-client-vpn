#!/bin/sh
set -e

echo "Before to start you need to generate client and server certificates and upload them to AWS ACM. See https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-certs"
read -p 'Client certificate ARN: ' ClientCertificateArn
read -p 'Server certificate ARN: ' ServerCertificateArn
read -p 'AWS region: ' AWS_DEFAULT_REGION
read -p 'CloudFormation stack name: ' StackName
read -p 'VPC CIDR block, default 10.0.0.0/16: ' VpcCidrBlock
read -p 'VPC subnet CIDR block, default 10.0.0.0/24: ' VpcSubnetCidrBlock
read -p 'Client subnet CIDR block, block size between /16 and /22, not overlapping with VPC CIDR, default 10.1.0.0/16: ' ClientCidrBlock

if [ "$ClientCidrBlock" = "" ]; then ClientCidrBlock=10.1.0.0/16; fi
if [ "$VpcCidrBlock" = "" ]; then VpcCidrBlock=10.0.0.0/16; fi
if [ "$VpcSubnetCidrBlock" = "" ]; then VpcSubnetCidrBlock=10.0.0.0/24; fi

echo "Creating VPC..."
aws cloudformation deploy \
  --template-file cfn-template.yaml \
  --stack-name "$StackName" \
  --parameter-overrides VpcCidrBlock=$VpcCidrBlock VpcSubnetCidrBlock=$VpcSubnetCidrBlock
echo "VPC created."

echo "Creating Client VPN endpoint..."
ClientVpnEndpointId=$(aws ec2 create-client-vpn-endpoint \
  --client-cidr-block $ClientCidrBlock \
  --server-certificate-arn $ServerCertificateArn \
  --authentication-options Type=certificate-authentication,MutualAuthentication={ClientRootCertificateChainArn=$ClientCertificateArn} \
  --connection-log-options Enabled=false \
  --query 'ClientVpnEndpointId' --output text)
echo "Client VPN endpoint created, id $ClientVpnEndpointId."

echo "Configuring Client VPN endpoint..."
aws ec2 create-tags --resources $ClientVpnEndpointId --tags "Key=Name,Value=$StackName"
VpcSubnetId=$(aws cloudformation describe-stacks --stack-name VPN --query 'Stacks[0].Outputs[?OutputKey==`SubnetId`].OutputValue' --output text)

aws ec2 associate-client-vpn-target-network \
  --client-vpn-endpoint-id $ClientVpnEndpointId \
  --subnet-id $VpcSubnetId

aws ec2  authorize-client-vpn-ingress \
  --client-vpn-endpoint-id $ClientVpnEndpointId \
  --target-network-cidr 0.0.0.0/0 \
  --authorize-all-groups

aws ec2 create-client-vpn-route \
  --client-vpn-endpoint-id $ClientVpnEndpointId \
  --destination-cidr-block '0.0.0.0/0' \
  --target-vpc-subnet-id $VpcSubnetId

echo "cert /PATH_CHANGE_ME/client1.domain.tld.crt" >client-config.ovpn
echo "key /PATH_CHANGE_ME/client1.domain.tld.key" >>client-config.ovpn
aws ec2 export-client-vpn-client-configuration \
  --client-vpn-endpoint-id $ClientVpnEndpointId \
  --output text \
  >> client-config.ovpn

echo "Find client-config.ovpn file I've created in this folder. Edit it to change path to cert and key"

mkdir settings
echo $AWS_DEFAULT_REGION >settings/region
echo $VpcSubnetId >settings/subnet-id
echo $ClientVpnEndpointId >settings/client-vpn-endpoint-id
echo "Find saved VPN endpoint settings in settings folder. The settings are required by following script."

echo "To stop AWS charging you, temporarely disassociate Client VPN endpoint using disable.sh script"
echo "Use enable.sh to enable it back"
