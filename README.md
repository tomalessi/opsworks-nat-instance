# nat-instance Cookbook

The purpose of this cookbook is to build and maintain two NAT instances in an Amazon AWS multi-availability zone environment.


## Assumptions

- This cookbook is meant to work within an AWS OpsWorks environment.  Your mileage may vary in other environments.
- You have a VPC with two availability zones within a single AWS region, each with its own NAT instance.
- Within each AZ, you have an Internet connected subnet, and a non Internet connected (or private) subnet.


## Requirements

- Amazon Linux (tested on 2015.03)
- Chef (tested on 11.10)
- Berkshelf (tested on 3.2.0)


## Usage

- Create a NAT instance AMI using an Amazon Linux AMI from the Amazon marketplace (these instances always include the string amzn-ami-vpc-nat).
- Setup the following custom JSON in the OpsWorks stack that controls your NAT instances:
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
- nat-instance-2a and nat-instance-2b are the hostnames of the two NAT instances (in this case, one in availability zone 2a and one in availability zone 2b) but you may substitute any names here as long as they match your NAT instance names.
- Populate the partner_id, partner_route and my_route for each NAT instance in the stack custom JSON.
- Create a layer within the OpsWorks stack that will be responsible for your NAT instances.  This is the best approach, but is not required - you could provision the NAT instances as part of an existing stack/layer.
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
- Include this recipe as part of the `setup` or `configure` lifecycle event in the NAT instance layer.
- Provision two NAT instances from the OpsWorks console using the AMI you created earlier within the NAT instance stack/layer, one in each AZ in the Internet accessible subnet.
```


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
