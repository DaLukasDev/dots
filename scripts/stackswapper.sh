#!/bin/bash
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

check_container() {
    local container_name=$1
    docker ps --filter "name=${container_name}" --filter "status=running" -q
}

get_docker_command() {
    local action=$1
    if [ "$action" == "up" ]; then
        echo "docker compose up -d"
    elif [ "$action" == "down" ]; then
        echo "docker compose down -v"
    else
        echo "Invalid action"
        exit 1
    fi
}

startstop_lokalhost() {
    local action=$1
    local docker_command

    docker_command=$(get_docker_command "$action")

    cd $HOME/lokal.host/basic-infra/traefik
    $docker_command >/dev/null 2>&1
    cd $HOME/lokal.host/basic-infra/logs
    $docker_command >/dev/null 2>&1
}

startstop_rqc() {
    local action=$1
    local docker_command

    docker_command=$(get_docker_command "$action")

    cd $HOME/rqc.icu/basic-infra/traefik
    $docker_command >/dev/null 2>&1
    cd $HOME/rqc.icu/basic-infra/dozzle
    $docker_command >/dev/null 2>&1
}

zzzproxy_status=$(check_container "zzzproxy")
proxy_status=$(check_container "proxy")

# Handle the results accordingly
if [ -n "$zzzproxy_status" ]; then
    clear
    echo "------------------stopping RQC.ICU------------------"
    startstop_rqc "down"
    echo "------------------starting lokal.host------------------"
    startstop_lokalhost "up"
    echo "All done ✅️"
    exit 0

fi

if [ -n "$proxy_status" ]; then
    clear
    echo "------------------stopping lokalhost------------------"
    startstop_lokalhost "down"
    echo "------------------starting RQC.ICU------------------"
    startstop_rqc "up"
    echo "All done ✅️"
    exit 0
fi

# Prompt the user if neither container is running
if [ -z "$zzzproxy_status" ] && [ -z "$proxy_status" ]; then
    echo "Neither container is running."
    read -p "Which container would you like to start? (L for lokal.host, R for rqc.icu): " choice
    case "$choice" in
    R | r)
        echo "Starting container rqc..."
        startstop_rqc "up"
        ;;
    L | l)
        echo "Starting container lokalhost..."
        startstop_lokalhost "up"
        ;;
    *)
        echo "Invalid choice. No container will be started."
        ;;
    esac
    exit 0
fi
