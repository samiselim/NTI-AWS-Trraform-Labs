import boto3
import time
region = 'eu-west-3'
instances = ['i-04c3a12397e09e907', 'i-0762b4d188ec2e979' , 'i-095bd7bce747a9dbf']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.stop_instances(InstanceIds=instances)
    print('stopped your instances: ' + str(instances))
    time.sleep(300)
    ec2.start_instances(InstanceIds=instances)
    print('started your instances: ' + str(instances))
    time.sleep(300)