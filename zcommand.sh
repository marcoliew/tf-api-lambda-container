python.exe -m pip install --upgrade pip
pip freeze > requirements.txt
python -m venv venv
pip install boto3