#! /bin/sh
AWS_DEFAULT_REGION=$(cat settings/region)
ClientVpnEndpointId=$(cat settings/client-vpn-endpoint-id)
SubnetId=$(cat settings/subnet-id)

echo Region $AWS_DEFAULT_REGION
echo ClientVpnEndpointId $ClientVpnEndpointId
echo SubnetId $SubnetId
echo "Enabling..."

aws ec2 associate-client-vpn-target-network --client-vpn-endpoint-id $ClientVpnEndpointId --subnet-id $SubnetId
aws ec2 create-client-vpn-route --client-vpn-endpoint-id $ClientVpnEndpointId --destination-cidr-block '0.0.0.0/0' --target-vpc-subnet-id $SubnetId
