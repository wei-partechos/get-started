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