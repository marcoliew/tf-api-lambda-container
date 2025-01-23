FROM public.ecr.aws/lambda/python:3.8

# Set environment variables (for passing the file name dynamically)
ARG FILE_NAME
ENV HANDLER="${FILE_NAME}.lambda_handler"

# Copy your lambda function code to the container
COPY functions/${FILE_NAME}.py ${FILE_NAME}.py

# Set the CMD to invoke the handler as the first argument to the Lambda runtime
CMD ["s3.lambda_handler"]
