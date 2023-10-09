#!/usr/bin/env bash

# delcare variables

fileName=$1"/settings.py"
searchString1="from pathlib import Path"
replaceString1="from pathlib import Path \nimport os"
searchString2="ALLOWED_HOSTS = \[\]"
replaceString2="ALLOWED_HOSTS = ['0.0.0.0']"
searchString3="'ENGINE': 'django.db.backends.sqlite3',"
replaceString3="'ENGINE': 'django.db.backends.postgresql',"
searchString4="'NAME': BASE_DIR \/ 'db.sqlite3',"
replaceString4="'NAME': os.environ.get('POSTGRES_NAME'),\n\t\t'USER': os.environ.get('POSTGRES_USER'),\n\t\t'PASSWORD': os.environ.get('POSTGRES_PASSWORD'),\n\t\t'HOST': 'db',\n\t\t'PORT': 5432,"


# 1. create the django project
docker-compose run web django-admin startproject $1 .

# 2. change settings.py file 

# check if the settings.py file exists 
if [ -e $fileName ]
then
    echo "OK, settings.py has been created"
    echo "Let's move on to the next step"
    # add import os to settings.py
    sed -i '' "s/$searchString1/$replaceString1/" $fileName
    # replace ALLOWED_HOSTS 
    sed -i '' "s/$searchString2/$replaceString2/" $fileName
    # replace DATABASES connections  
    sed -i '' "s/$searchString3/$replaceString3/" $fileName
    sed -i '' "s/$searchString4/$replaceString4/" $fileName
    echo "settings.py has been updated!"
else
    echo "settings.py hasn't been created yet"
fi

# 3. run docker compose 
docker-compose up -d