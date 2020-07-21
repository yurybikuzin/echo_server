#!/usr/bin/env bash
sudo kill -HUP $(ps aux | grep nginx | grep master | awk '{print $2}')

