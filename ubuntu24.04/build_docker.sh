#!/bin/bash

docker build --build-arg UID=$(id -u) --build-arg USERNAME=user -t build_docker_2404 .

