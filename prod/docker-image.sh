#!/usr/bin/env bash
set -e

# Version 0.1.1, 2020-06-30

target=prod

cmdname=${0##*/}

echoerr() { 
    echo "ERR: $@" 1>&2 
}

usage()
{
    cat << USAGE >&2
Description:
    build image of service (Dockerfile in subfolder at $target/) and push to Docker Hub
Usage:
    $cmdname [--help | [SERVICE] [-b] ]
params:
    SERVICE   from docker-compose.yml, and self-titled subfolder at $target/, 'proj' by default
options:
    -b        build only, no push
    --help    this help
USAGE
    exit 1
}

build_only=
service=
opts=()

# process arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        -b)
            build_only=1
            shift 1
        ;;

        --help)
            usage
        ;;

        --no-cache )
            opts+=($1)
            shift 1
        ;;

        -* )
            echoerr "Unknown option: $1"
            usage
        ;;

        *)
            if [[ $service == "" ]]; then
                service=$1
            else 
                echoerr "SERVICE must be specified only once, but two found: '$service' and '$1'"
                usage
            fi
            shift 1
        ;;
    esac
done

if [[ ! $service ]]; then
    service=proj
fi


if [[ $service == proj ]]; then
    docker-compose up -d
    docker exec -it echo-$service cargo build --release
    cp target/release/echo prod/proj/copy/
    # ls target/release/echo
    # echo TODO
else 
    echoerr "SERVICE other than 'proj is not supported"
fi

bw_proj_name=$(env $(cat .env | grep -v '#' | xargs) bash -c 'echo $BW_PROJ_NAME')
if [[ ! $bw_proj_name ]]; then
    echoerr "BW_PROJ_NAME value must be specified in file'.env'"
    exit 1
fi

bw_version=$(env $(cat .env | grep -v '#' | xargs) bash -c 'echo $BW_PROD_VERSION')
if [[ ! $bw_version ]]; then
    echoerr "BW_PROD_VERSION value must be specified in file'.env'"
    exit 1
fi

version_fspec="$target/version.yml"
did_version=$(cat "$version_fspec" | sed -nr "s/^$service:[[:space:]]*([^[:space:]])/\1/p;")
if [[ ! $did_version ]]; then
    echoerr "$service: VERSION not found in file'$version_fspec'"
    exit 1
fi

if [[ ! $build_only && $bw_version == $did_version ]]; then
    echoerr "BW_PROD_VERSION ($bw_version) in file'.env' must differ (be bigger) than version ($did_version) in file'$version_fspec' in line: image: bazawinner/$target-${bw_proj_name}-$service:$did_version"
    exit 1
fi

env $(cat .env | grep -v '#' | xargs) bash -c '\
    tag=bazawinner/'$target'-$BW_PROJ_NAME-'$service':$BW_PROD_VERSION
    echo Building $tag . . .
    docker build '${opts[@]}' \
        $(\
            src='$target'/'$service'/Dockerfile; 
            cat $src | \
            sed -nr "s/^[[:space:]]*ARG[[:space:]]+([[:alnum:]_]+)/--build-arg=\1/p"\
        ) \
        -t $tag \
        '$target'/'$service' && \
    echo OK: Built $tag && \
    if [[ ! "'$build_only'" ]] 
    then
        echo Pushing $tag . . .
        docker push $tag
        echo OK: Pushed $tag
    fi
'

