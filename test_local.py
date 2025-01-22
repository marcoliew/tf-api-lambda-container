# local_test.py

import json
from functions.s3 import (
    lambda_handler,
)  # Assuming your Lambda code is in lambda_function.py

# Mocking an AWS Lambda event (e.g., an API Gateway event)
# comment this part, as will load json event from mock_event.json instead
# mock_event = {
#     "version": "0",
#     "id": "12345678-1234-5678-abcd-1234567890ab",
#     "detail-type": "CloudWatch Alarm State Change",
#     "source": "aws.cloudwatch",
#     "account": "123456789012",
#     "time": "2024-10-07T12:00:00Z",
#     "region": "us-east-1",
#     "resources": ["arn:aws:cloudwatch:us-east-1:123456789012:alarm:HighCPUAlarm"],
#     "detail": {
#         "alarmName": "HighCPUAlarm",
#         "state": {"value": "ALARM"},
#         "configuration": {
#             "metrics": [
#                 {
#                     "metricStat": {
#                         "metric": {
#                             "namespace": "AWS/EC2",
#                             "metricName": "CPUUtilization",
#                             "dimensions": {"InstanceId": "i-03096ae760f3930c4"},
#                         }
#                     }
#                 }
#             ]
#         },
#     },
# }


# Mocking the AWS Lambda context
class MockContext:
    def __init__(self):
        self.function_name = "test-lambda"
        self.memory_limit_in_mb = "128"
        self.invoked_function_arn = (
            "arn:aws:lambda:ap-southeast-2:058264095432:function:test-lambda"
        )
        self.aws_request_id = "test-request-id"


context = MockContext()

# load and print event info:

with open("mock_event.json") as f:
    msg = str()
    msg = json.load(f)
    print(msg["id"])

# Call your Lambda function locally
response = lambda_handler(msg, context)
print(json.dumps(response, indent=4))
