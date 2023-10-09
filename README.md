<meta charset="utf-8">

# **Objective**: Build a simple docker instance to run a web app

## **_Tech Stack_**
- [bash][bashSite] & [git][gitSite]
- [docker][dockerSite] & [python][pythonSite] & [django][djangoSite]
- [postgres][postgresSite] & [redis][redisSite]
- [typescript][typescriptSite] & [vue][vueSite]
- [tailwind][tailwindSite] & [fontawesome][fontawesomeSite]

## **_Build_**

```sh
bash build.sh xyz
```

## **_Build Steps_**

### Step 1: Create a clean Dockerfile with latest Python3, Django and PostgreSQL [link]

Use a clean image that offers the bear minimum setup to run the docker successfully.

```Dockerfile
# syntax=docker/dockerfile:1

# Starts with a Python3 parent image
FROM python:3

# Setting env configs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Creates a working directory. (Note: This is the directory created inside of the build image)
WORKDIR /code

# Saves dependencies to a single file. Similar to package.json or composer
COPY requirements.txt /code/

# Upgrade pip to the latest version (sometimes latest version of python doesn't have the latest version of pip)
RUN pip install --upgrade pip

# Install dependencies during the build with a clean installation
RUN pip install --no-cache-dir -r requirements.txt

# Copy everything from current dir to container's code dir
COPY . /code/
```

### Step 2: Create a file called docker-compose.yml in the root directory

The docker-compose.yml file describes the services in the app. To make it simple, only a web server and a database are added. It describes
- Which docker images these services use
- How they are wired together
- How many volumes that need to be mounted inside the containers
- Which ports these services are exposed to

```yml
version: "3.8" # lastest version as of now

services:
  web:
    build: . # build from root Dockerfile
    command: python manage.py runserver 0.0.0.0:8000 # django local server port
    volumes:
      - .:/code # mount current dir to /code in the container
    ports:
      - "8000:8000" # connect local port 8000 with container's 8000
    environment: # connect web app with db using same credentials.
      - POSTGRES_NAME=xyz-main
      - POSTGRES_USER=xyzAdmin
      - POSTGRES_PASSWORD=gDmuZQPg!Einps2mqPCy
    depends_on:
      - db
  db:
    image: postgres # lastest postgres
    volumes:
      - ./data/db:/var/lib/postgresql/data # local db volumne mount
    environment: # sample credentials
      - POSTGRES_DB=xyz-main
      - POSTGRES_USER=xyzAdmin
      - POSTGRES_PASSWORD=gDmuZQPg!Einps2mqPCy
```

### Step 3: Create a Django Project

Create a Django starter project by building the image from the build context defined in the previous procedures.

1. Change to the root of your project directory.
2. Create the Django project by running the docker-compose run command as follows.

```sh
docker-compose run web django-admin startproject xyz .
```

This allows docker-compose to run django-admin startproject XYZ (the project name) in a container, using the web service’s image and configuration. Because the web image doesn’t exist yet, Compose builds it from the current directory, as specified by the build: . line in docker-compose.yml.

Once the web service image is built, Compose runs it and executes the django-admin startproject command in the container. This command instructs Django to create a set of files and directories representing xyz, a Django project.

### Step 4: Connect to the database

In The project directory, edit the xyz/settings.py file.
Add import os.
Add ALLOWED_HOSTS
Replace the DATABASES = ... with postgres settings

```py
# add import os
import os  

[...]

#add ALLOWED_HOSTS
ALLOWED_HOSTS = ['0.0.0.0'] 

#third place
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('POSTGRES_NAME'),
        'USER': os.environ.get('POSTGRES_USER'),
        'PASSWORD': os.environ.get('POSTGRES_PASSWORD'),
        'HOST': 'db',
        'PORT': 5432,
    }
}
```

These settings are determined by the postgres Docker image specified in docker-compose.yml.

### Step 5: Run the docker-compose up command

```sh
docker-compose up
```

### Testing

remove all the existing containers in the docker env

```sh
docker rm -f $(docker ps -aq)
```

proune the entire docker system

```sh
docker system prune -a
```

### issues

ERROR: Invalid HTTP_HOST header: '0.0.0.0:8000'.
You may need to add '0.0.0.0' to ALLOWED_HOSTS

Just add the ip in ALLOWED_HOSTS property in the file <your_app_path>/settings.py.

ERROR: THESE PACKAGES DO NOT MATCH THE HASHES FROM THE REQUIREMENTS FILE

Even if --no-cache-dir is enforce in the dockfile, sometimes it would ignore it and report hashes issues. Just have to rerun docker-compose up.

ERROR: open /Users/abc/.docker/buildx/current: permission denied

```sh
sudo chown -R $(whoami) ~/.docker
```

## Tests

SSH into the web container

```sh
docker exec -it get-started-web-1 /bin/bash
```

Run in the entire test suite.

```sh
docker-compose run web python3 manage.py test
```

Run individual test

```sh
./manage.py test xyz.Source --pattern="test_abc*.py"
```

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen.)
[bashSite]: <https://www.gnu.org/software/bash/manual/bash.html>
[gitSite]: <https://git-scm.com/docs>
[dockerSite]: <https://www.docker.com/>
[djangoSite]: <https://www.djangoproject.com>
[pythonSite]: <https://www.python.org/>
[postgresSite]: <https://www.postgresql.org/>
[redisSite]: <https://redis.com/>
[typescriptSite]: <https://www.typescriptlang.org/>
[vueSite]: <https://vuejs.org/>
[tailwindSite]: <https://tailwindcss.com/>
[fontawesomeSite]: <https://fontawesome.com/>

[link]: <https://github.com/docker/awesome-compose/tree/master/official-documentation-samples/django/>
