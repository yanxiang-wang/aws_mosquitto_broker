AWS Mosquitto Broker
--------------------------------

Docker Image for AWS IOT connected Mosquitto broker

![enter image description here](https://s3.amazonaws.com/aws-iot-blog-assets/how-to-bridge-mosquitto-mqtt-broker-to-aws-iot/1-overview.png)


## Step 1: Setup AWS Account

Go to [AWS](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html#cli-signup) and setup the account


Result: Acces Key + Access Secret

## Step 2: Install and Setup AWS CLI

Install AWS CLI from [here](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)

Then run AWS Configure and put your Region, your Access Key and Acces Secret

	aws configure
	AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
	AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
	Default region name [None]: us-west-2
	Default output format [None]: json


## Step 3: Create an IAM policy for the bridge

```
aws iot create-policy --policy-name bridgeMQTT --policy-document '{"Version": "2012-10-17","Statement": [{"Effect": "Allow","Action": "iot:*","Resource": "*"}]}'
```




## Step 4: Create Certificates

Place yourself in ./config/certs directory and create certificates and keys, note the certificate ARN

	cd ./config/certs

	sudo aws iot create-keys-and-certificate --set-as-active \ 
	--certificate-pem-outfile cert.crt --private-key-outfile private.key \ 
	--public-key-outfile public.key --region us-east-1




List the certificate and copy the ARN in the form of arn:aws:iot:eu-central-1:0123456789:cert/xyzxyz

	aws iot list-certificates


Attach the policy to your certificate

	aws iot attach-principal-policy --policy-name bridge --principal REPLACE_ARN_CERT


Add read permissions to private key and client cert

	sudo chmod 644 ./config/certs/private.key
	sudo chmod 644 ./config/certs/cert.crt


Download root CA certificate

	# in cert folder
	sudo wget https://www.amazontrust.com/repository/AmazonRootCA1.pem -O rootCA.pem


## Step 5: Edit mosquitto custom config file

Rename awsbridge.conf.sample to awsbridge.conf

	mv ./config/conf.d/awsbridge.conf.sample ./config/conf.d/awsbridge.conf

Edit ./config/conf.d/awsbridge.conf and follow the awsbridge.conf instructions

	nano ./config/conf.d/awsbridge.conf



## Step 6:  Build Docker File

	docker build -t aws_mqtt_broker .


## Step 7: Run Docker Image

	docker run -ti -p 1883:1883 -p 9001:9001 --name mqtt aws_mqtt_broker



Console / Log output:

```
1638882142: mosquitto version 1.4.15 (build date 2018-03-04 15:19:39+0000) starting
1638882142: Config loaded from /mosquitto/config/mosquitto.conf.
1638882142: Opening ipv4 listen socket on port 1883.
1638882142: Opening ipv6 listen socket on port 1883.
1638882142: Bridge local.bridgeawsiot doing local SUBSCRIBE on topic localgateway_to_awsiot
1638882142: Bridge local.bridgeawsiot doing local SUBSCRIBE on topic both_directions
1638882142: Connecting bridge awsiot (XXXXXXXXXXX.amazonaws.com:8883)
1638882142: Bridge bridgeawsiot sending CONNECT
1638882143: Received CONNACK on connection local.bridgeawsiot.
1638882143: Bridge local.bridgeawsiot sending SUBSCRIBE (Mid: 1, Topic: awsiot_to_localgateway, QoS: 1)
1638882143: Bridge local.bridgeawsiot sending UNSUBSCRIBE (Mid: 2, Topic: localgateway_to_awsiot)
1638882143: Bridge local.bridgeawsiot sending SUBSCRIBE (Mid: 3, Topic: both_directions, QoS: 1)
1638882143: Received UNSUBACK from local.bridgeawsiot
1638882143: Received SUBACK from local.bridgeawsiot
1638882143: Received SUBACK from local.bridgeawsiot
```


## Step 8: Test


### Publish from aws iot console

1.- From AWS Management Console go to AWS IOT Services -> Test

2.- Subscribe to topics mentioned in our config file
	- awsiot_to_localgateway
	- localgateway_to_awsiot
	- both_directions

3.- Publish to awsiot_to_localgateway topic (hello world)

4.- Review log or console output in our local broker for something like this:

`1493564128: Received PUBLISH from local.bridgeawsiot (d0, q0, r0, m0, 'awsiot_to_localgateway', ... (45 bytes)) `



### Publish from host

Flow: hostpc -> dockergateway -> aws

`mosquitto_pub -h localhost -p 1883 -q 1 -d -t localgateway_to_awsiot  -i clientid1 -m "{\"key\": \"helloFromLocalGateway\"}"`

### Publish from arduino UNO / Mega with Ethernet Shield

[Arduino Client](https://github.com/dnavarrom/aws_mqtt_arduino_uno)

## References:

[AWS Mosquitto Guide](https://aws.amazon.com/es/blogs/iot/how-to-bridge-mosquitto-mqtt-broker-to-aws-iot/)

[Docker Mosquitto Image](https://github.com/toke/docker-mosquitto)
