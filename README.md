# Infrastructure blueprint for Netcentric puppet task

Spin up small infrastracture made of a puppet agent and a puppet server based on Ubuntu precise64 

This infrastructure is generate with Vagrant and the agent instance is provisioned with Puppet.
Once that the infrastrucutre is up and running you can connect to the 2 instances and check the nginx logs for the pupept-agent

Create/extend an existing puppet module for Nginx including the following functionalities:
```
Create a proxy to redirect requests for http://domain.com to 10.10.10.10 and redirect requests for http://domain.com/resource to 20.20.20.20.
Create a forward proxy to log HTTP requests going from the internal network to the Internet including: request protocol, remote IP and time take to serve the request.
```

## Tech

For this tasks I used the following softwares

* [Vagrant](https://www.vagrantup.com/) building and maintaining portable virtual software development environments
* [Puppet](https://www.puppet.com/) software that automates software provisioning, configuration management, and application deployment
* [Virtualbox](https://www.virtualbox.org) open-source hosted hypervisor for x86 computers

Software versions used for deploy this infrastrcture 

* Vagrant 2.1.4
* Puppet 2.8.1
* Virtualbox 5.2.18

## Building Vagrantfile

To create the infrastructure you need to run this command and you will see the list of machines that will be deployed

```
$ vagrant up
Bringing machine 'puppet_server' up with 'virtualbox' provider...
Bringing machine 'puppetagent' up with 'virtualbox' provider...
```

During the building phase of each instance, Vagrant will call the puppet commands defined in the Vagrantfile.<br>
Also the module and the site.pp file are copied from ther /vagrant folder to the puppet dir on the master.<br>
On the puppet server Vagrant will install the nginx and apt puppet modules.<br>
On the puppet agent, puppet will make a call to the master.
On the master the module assigned to the agent is called *netcentric_puppet*.
This module will be sure to install nginx with type of logs

```
log_format => {
      main => 'Request protocol: $scheme | Remote IP: $upstream_addr | Request time: $request_time',
    }
```

## How does it works

Once the machines are provisioned, you can connect to each of them doing

```
vagrant ssh puppetagent
vagrant ssh puppet_agent
```

On the puppet agent machine, you can try to connect to the localhost on port 8000 and then check the logs

```
vagrant@puppetagent:~$ sudo curl localhost:8000
vagrant@puppetagent:~$ sudo sudo tail -f /var/log/nginx/localhost.access.log
Request protocol: http | Remote IP: - | Request time: 0.013
```

If you connect from the puppet master to the nginx on the agent like that
```
vagrant@puppetmaster:~$ curl 192.168.10.22:8000
```

You will see the logs with the ip of the master the type of protocol and time taken like in this case

```
vagrant@puppetagent:~$ sudo tail -f /var/log/nginx/localhost.access.log
Request protocol: http | Remote IP: 192.168.10.22:80 | Request time: 0.001
Request protocol: http | Remote IP: 192.168.10.22:8000 | Request time: 0.001
```