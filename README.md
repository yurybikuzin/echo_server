# Echo-server (Rust/Rocket) 
<!-- vim-markdown-toc Redcarpet -->

* [About](#about)
* [Development](#development)
    * [Prerequisites](#prerequisites)
        * [Git](#git)
        * [Docker](#docker)
        * [Docker-Compose](#docker-compose)
    * [Prepare workplace](#prepare-workplace)
        * [Available commands](#available-commands)
            * [cargo](#cargo)
    * [Do not forget to stop docker containers after work is over](#do-not-forget-to-stop-docker-containers-after-work-is-over)
* [Release](#release)
    * [Check](#check)
    * [Make](#make)
    * [Run](#run)
* [Files](#files)

<!-- vim-markdown-toc -->

## About

simple echo-server for proxy-checker

## Development

### Prerequisites

#### Git

https://git-scm.com/downloads

#### Docker

https://docs.docker.com/install

Pay attention to [Post-installation steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/)

#### Docker-Compose

https://docs.docker.com/compose/install

### Prepare workplace

- clone repo: 

```
git clone git@github.com:yurybikuzin/echo_server.git
```

- up dev container: 

```
docker-compose up -d 
```

#### Available commands

##### cargo

```
docker exec -it echo-proj cargo
docker exec -it -e RUST_LOG=info echo-proj cargo test -p echo
docker exec -it echo-proj cargo run
```

### Do not forget to stop docker containers after work is over

```
docker-compose down
```

## Release

### Check

Before release check `.env` and `prod/version.yml`:
BW_PROD_VERSION at `.env` must be bigger than version in `prod/version.yml`

### Make

To make a release:
```
prod/docker-image.sh
```

### Run

To run a release:
```
docker run -p 42101:8000 bazawinner/prod-echo-proj:0.1.0
```

## Files

- `README.md` - this is it
- `LICENSE.md` - license
- `.gitignore` - see https://git-scm.com/docs/gitignore
- `docker-compose.yml` - required for `docker-compose up -d`
- `.env` - required for `docker-compose up -d`
- `dev/` - folder for docker-container definitions for development
    - `dev/docker-image.sh` - tool for rebuilding docker container for service from `docker-compose.yml` (`proj` by default)
    - `dev/proj/Dockerfile` - Dockerfile for service `proj`, mentioned in `docker-compose.yml`
    - `dev/proj/sh/*` - helper sh-scripts used in `echo-proj` docker container
- `prod/` - folder for docker-container definitions for production
    - `prod/proj/Dockerfile` - Dockerfile for service `proj` (main and only service) in production
- `Cargo.toml`, `Cargo.lock` - [cargo](https://doc.rust-lang.org/cargo/) files
- `echo/` - folder for source code (Rust) of echo server



