# cfn-aws-client-vpn

Deploy [AWS Client VPN](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/what-is.html)
with [access to the Internet](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/scenario-internet.html)
in a couple of minutes with these helper scripts.

Make it kind of standing-by and stop AWS billing your with one simple command.
Resume it at any moment in seconds.

## Prerequisites

Before to start you need to have server and client certificates and keys uploaded to AWS ACM.
You can refer to [Step 1: Generate Server and Client Certificates and Keys](
https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/cvpn-getting-started.html#cvpn-getting-started-certs)
of "Getting Started with Client VPN" documentation.

## How to deploy

Run ```deploy.sh``` script. The script leverages AWS CLoudFormation.

The following is an example of parameters you provide.

```
Client certificate ARN: <Enter>
Server certificate ARN: <Enter>
AWS region: us-east-1<Enter>
CloudFormation stack name: MyClientVPN<Enter>
VPC CIDR block, default 10.0.0.0/16: <Enter>
VPC subnet CIDR block, default 10.0.0.0/24: <Enter>
Client subnet CIDR block, block size between /16 and /22, not overlapping with VPC CIDR, default 10.1.0.0/16: <Enter>
```

## How to send your Client VPN endpoint to send-by mode

Run ```disable.sh``` script.

## How to resume your Client VPN endpoint

Run ```enable.sh``` script.

## Contribute
Feel free to contribute to the scripts on GitHub at [MaksimAniskov/cfn-aws-client-vpn](https://github.com/MaksimAniskov/cfn-aws-client-vpn)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
