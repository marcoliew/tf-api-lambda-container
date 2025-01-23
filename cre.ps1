# Define the SSO cache directory path
$cacheDir = "$env:USERPROFILE\.aws\sso\cache"

# Get the most recent .json token file in the directory
$tokenFile = Get-ChildItem -Path $cacheDir -Filter "*.json" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($null -eq $tokenFile) {
    Write-Host "No SSO token file found."
    exit
}

# Debug: Output the content of the token file to inspect its structure
$tokenFileContent = Get-Content $tokenFile.FullName | ConvertFrom-Json
Write-Host "Token file content:"
$tokenFileContent | Format-List

# Extract the access token (adjust based on actual file structure)
$accessToken = $tokenFileContent.accessToken

if ($null -eq $accessToken) {
    Write-Host "Access token not found in the token file."
    exit
}

Write-Host "Using access token: $accessToken"

# Step 2: Get role credentials using the access token
$roleName = "SSO_AdministratorAccess"
$accountId = "058264095432"

$roleCredentials = aws sso get-role-credentials --role-name $roleName --account-id $accountId --access-token $accessToken --query "roleCredentials" --output json

# Step 3: Extract credentials
$accessKeyId = $roleCredentials.roleCredentials.accessKeyId
$secretAccessKey = $roleCredentials.roleCredentials.secretAccessKey
$sessionToken = $roleCredentials.roleCredentials.sessionToken

# Step 4: Set environment variables for Docker
$env:AWS_ACCESS_KEY_ID = $accessKeyId
$env:AWS_SECRET_ACCESS_KEY = $secretAccessKey
$env:AWS_SESSION_TOKEN = $sessionToken
#env:AWS_REGION = "us-west-2"
