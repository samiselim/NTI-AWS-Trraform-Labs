import boto3

AMI = 'ami-00c71bd4d220aa22a' 
INSTANCE_TYPE = 't2.micro'
KEY_NAME = 'ntikey'
REGION = 'eu-west-3'


ec2 = boto3.client('ec2', region_name=REGION)


def lambda_handler(event, context):

    instance = ec2.run_instances(
        ImageId=AMI,
        InstanceType=INSTANCE_TYPE,
        KeyName=KEY_NAME,
        MaxCount=1,
        MinCount=1
    )
    
    print ("New instance created:")
    instance_id = instance['Instances'][0]['InstanceId']
    print (instance_id)

    return instance_id