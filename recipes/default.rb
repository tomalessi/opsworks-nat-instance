#
# Cookbook Name:: nat-instance
# Recipe:: default
#
# Copyright 2015, Tom Alessi
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


# Copy root crontab into place
cookbook_file "root_crontab" do
  path "/var/spool/cron/root"
  action :create
  owner "root"
  group "root"
  mode "0600"
end


# Create the NAT monitor script
template "/etc/nat_monitor.sh" do
  action :create
  source "nat_monitor.sh.erb"
  variables({
    :partner_id => node[:private_settings][:nat][node['hostname']][:partner_id],
    :partner_route => node[:private_settings][:nat][node['hostname']][:partner_route],
    :my_route => node[:private_settings][:nat][node['hostname']][:my_route],
    :ec2_url => node[:private_settings][:nat][:ec2_url]
  })
  owner "root"
  group "root"
  mode "0700"
end


# Create the NAT monitor log directory
directory "/var/log/nat_monitor" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end


# Kill the NAT monitor script
execute "Kill NAT Monitor Script" do
  command "pkill -f nat_monitor"
  returns [0, 1]
end


# Start the NAT monitor script
execute "Start NAT Monitor Script" do
  command "/etc/nat_monitor.sh >>/var/log/nat_monitor/nat_monitor.log &"
end
