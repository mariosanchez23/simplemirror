#!/bin/bash
docker-compose -f docker-compose-single-ni.yml down
sudo rm -fR irisA/* irisB/*
