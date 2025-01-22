FROM public.ecr.aws/lambda/python:3.9


ARG FILE_NAME

# Add function code
COPY ./functions/${FILE_NAME}.py .

# Set the CMD to your handler
CMD ["${FILE_NAME}.lambda_handler"]
