# Check if a file name argument is passed
if ($args.Length -eq 0) {
  Write-Host "Please provide a file name as an argument."
  Write-Host "Usage: .\docker_test.ps1 file_name"
  exit 1
}

# Get the file name from the argument
$FileName = $args[0]

# Define the container name with a timestamp
$ContainerName = "$FileName-container"

# Check if the container exists and stop it if it does
$existingContainer = docker ps -aq --filter "name=$ContainerName"
if ($existingContainer) {
  Write-Host "Stopping and removing existing container: $ContainerName"
  docker stop $existingContainer
  docker rm $existingContainer
}

# Path to AWS SSO cache
$cacheDir = "$env:USERPROFILE\.aws\sso\cache"

# Get the most recent JSON file in the cache
$latestFile = Get-ChildItem -Path $cacheDir -Filter "*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $latestFile) {
    Write-Host "No SSO cache file found. Please login using 'aws sso login' first."
    exit
}

# Read the content of the latest JSON file
$jsonContent = Get-Content $latestFile.FullName | ConvertFrom-Json

# Extract the access token
$accessToken = $jsonContent.accessToken
if ($null -eq $accessToken) {
    Write-Host "No access token found in the cache file."
    exit
}

Write-Host "Access Token retrieved successfully."

# Retrieve AWS session credentials (Access Key ID, Secret Access Key, and Session Token)
$awsAccessKey = (aws sts get-session-token --query 'Credentials.AccessKeyId' --output text)
$awsSecretKey = (aws sts get-session-token --query 'Credentials.SecretAccessKey' --output text)
$awsSessionToken = (aws sts get-session-token --query 'Credentials.SessionToken' --output text)

# Ensure we have the credentials before continuing
if ($awsAccessKey -eq "" -or $awsSecretKey -eq "" -or $awsSessionToken -eq "") {
    Write-Host "AWS credentials could not be retrieved. Make sure you are logged in with AWS SSO."
    exit
}

Write-Host "AWS Credentials retrieved successfully."


# Now, let's build the Docker image
$dockerImageName = "$FileName-lambda-function"
$dockerfilePath = ".\Dockerfile"
$lambdaFileName = $FileName  # Update this dynamically if needed

# Build the Docker image
Write-Host "Building Docker image..."
docker build -t $dockerImageName -f $dockerfilePath --build-arg FILE_NAME=$lambdaFileName .

# Run the Docker container and inject the environment variables for AWS credentials and access token
Write-Host "Running Docker container with AWS credentials..."
docker run -d -p 9000:8080 `
  -e AWS_ACCESS_KEY_ID=$awsAccessKey `
  -e AWS_SECRET_ACCESS_KEY=$awsSecretKey `
  -e AWS_SESSION_TOKEN=$awsSessionToken `
  -e AWS_SSO_ACCESS_TOKEN=$accessToken `
  --name $ContainerName $dockerImageName

# Test the Lambda function using Invoke-RestMethod
Invoke-RestMethod -Method Post -Uri "http://localhost:9000/2015-03-31/functions/function/invocations" -Headers @{ "Content-Type" = "application/json" } -Body "{}"

# Output container logs for debugging
docker logs $ContainerName
