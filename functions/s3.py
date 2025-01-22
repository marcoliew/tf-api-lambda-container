import boto3


def lambda_handler(event, context):
    # Create an S3 client
    s3_client = boto3.client("s3")

    # List all buckets
    response = s3_client.list_buckets()

    # Extract bucket names
    buckets = [bucket["Name"] for bucket in response["Buckets"]]

    # Log or return the list of bucket names
    print("S3 Buckets:", buckets)
    return {"statusCode": 200, "body": {"buckets": buckets}}
