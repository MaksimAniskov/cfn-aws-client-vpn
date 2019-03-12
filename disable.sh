#! /bin/sh
AWS_DEFAULT_REGION=$(cat settings/region)
ClientVpnEndpointId=$(cat settings/client-vpn-endpoint-id)
AssociationId=$(aws ec2 describe-client-vpn-target-networks --client-vpn-endpoint-id $ClientVpnEndpointId --query 'ClientVpnTargetNetworks[0].AssociationId' --output text)

echo Region $AWS_DEFAULT_REGION
echo ClientVpnEndpointId $ClientVpnEndpointId
echo AssociationId $AssociationId
echo "Disabling..."

aws ec2 disassociate-client-vpn-target-network --client-vpn-endpoint-id $ClientVpnEndpointId --association-id $AssociationId
