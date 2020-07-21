#!/usr/bin/env bash
set -e
docker-compose up -d
docker exec -it echo-proj cargo build --release
cp target/release/echo prod/proj/copy/

