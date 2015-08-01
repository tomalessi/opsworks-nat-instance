# nat-instance Cookbook

The purpose of this cookbook is to build and maintain two NAT instances in an Amazon AWS multi-availability zone environment.


## Assumptions

- This cookbook is meant to work within an AWS OpsWorks environment.  Your mileage may vary in other environments.
- You have a VPC with two availability zones within a single AWS region (each will have its own NAT instance).
- Within each AZ, you have an Internet connected subnet, and one or more non Internet connected (or private) subnets.  Any instances in the Internet connected subnet will require a public IP address and any instances in the private subnets will use the NAT instances for Internet connectivity.
- You have setup three route tables: (1) Main route table, (2) a route table for AZ1 and (3) a route table for AZ2.  The main route table should send 0.0.0.0/0 to the IGW with the other two route tables sending 0.0.0.0/0 to their respective NAT instances.


## Requirements

- Amazon Linux (tested on 2015.03)
- Chef (tested on 11.10)
- Berkshelf (tested on 3.2.0)


## Usage

NOTE: You will not be able to create functional route tables, nor populate the stack custom JSON until the two NAT instances are actually provisioned (because you need their instance IDs).  Once the NAT instances are provisioned, you will use this recipe to keep them properly running and configured.

- Create a NAT instance AMI using an Amazon Linux AMI from the Amazon marketplace (these instances always include the string amzn-ami-vpc-nat).
- Setup the following custom JSON in the OpsWorks stack that controls your NAT instances.  The names `nat-instance-2a` and `nat-instance-2b` are the hostnames of the two NAT instances (in this case, one in availability zone 2a and one in availability zone 2b) but you may substitute any names here as long as they match your NAT instance hostnames.  The `ec2-url` must match the region within which you are provisioning the nat instances:
```json
{
  "private_settings": {
    "nat": {
      "nat-instance-2a": {
        "partner_id": "i-xxxxxxxx",
        "partner_route": "rtb-xxxxxxxx",
        "my_route": "rtb-yyyyyyyy"
      },
      "nat-instance-2b": {
        "partner_id": "i-yyyyyyyy",
        "partner_route": "rtb-yyyyyyyy",
        "my_route": "rtb-xxxxxxxx"
      },
      "ec2_url": "https://ec2.us-west-2.amazonaws.com"
    }
}
```
- Create a layer within the OpsWorks stack that will be responsible for your NAT instances.  Configure the layer to provide an elastic IP to each provisioned instance.
- Include the following policy in the OpsWorks stack instance profile associated with the NAT instance stack/layer so that NAT instances can manage routes:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:CreateRoute",
        "ec2:ReplaceRoute",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```
- Include this recipe as part of the `setup` lifecycle event in the NAT instance layer.  You will need to reference this recipe in your Berksfile:
```text
cookbook 'opsworks-nat-instance', git: 'git://github.com/tomalessi/opsworks-nat-instance.git'
```
- Provision two NAT instances from the OpsWorks console using the AMI you created earlier within the NAT instance stack/layer, one in each AZ in the Internet accessible subnet.
- After the instances are provisioned, disable source/destination checks.
- Populate the partner_id, partner_route and my_route for each NAT instance in the stack custom JSON and run the `setup` lifecycle event on the instances.


## To Do

- Disable source/destionation checks on NAT instances using the AWS SDK as part of the recipe.


## License and Authors

- Author: Tom Alessi (tom.alessi@gmail.com)
- Author: Unknown author created the AWS nat_instance.sh monitor script

```text
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
