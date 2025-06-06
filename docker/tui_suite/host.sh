#!/bin/bash
set -e

show_help() {
    echo "Usage: ./host.sh [COMMAND]"
    echo
    echo "Commands:"
    echo "  start        Create and mount filesystem, start containers"
    echo "  stop         Stop containers and unmount filesystem"
    echo "  restart      Restart containers and remount filesystem"
    echo "  clean        Stop containers, unmount and remove filesystem"
    echo "  status       Display current status of containers and filesystem"
    echo "  help         Display this help message"
    echo
    echo "If no command is specified, 'help' will be executed."
}

setup_filesystem() {
    echo "Setting up filesystem..."
    # This is to prevent users from creating very large files
    dd if=/dev/zero of=./runtimefs_disk.img bs=1M count=20
    sudo mkfs.ext4 ./runtimefs_disk.img
    mkdir -p /tmp/tui_suite_runtimefs
    sudo mount ./runtimefs_disk.img /tmp/tui_suite_runtimefs
    if [ -d ./.runtimefs ]; then
        sudo cp -r ./.runtimefs/* /tmp/tui_suite_runtimefs/ || true
    fi
    sudo umount /tmp/tui_suite_runtimefs
    rmdir /tmp/tui_suite_runtimefs
    sudo mount ./runtimefs_disk.img ./.runtimefs
    echo "Filesystem setup complete."
}

start_containers() {
    echo "Starting containers..."
    docker compose up -d
    echo "Containers started."
}

stop_containers() {
    echo "Stopping containers..."
    docker compose down
    echo "Containers stopped."
}

unmount_filesystem() {
    echo "Unmounting filesystem..."
    sudo umount ./.runtimefs 2>/dev/null || true
    echo "Filesystem unmounted."
}

clean_filesystem() {
    echo "Removing filesystem image..."
    rm -f ./runtimefs_disk.img
    echo "Filesystem image removed."
}

show_status() {
    echo "Container status:"
    docker compose ps
    echo
    echo "Filesystem status:"
    if mount | grep -q "./.runtimefs"; then
        echo "Filesystem is mounted"
        df -h ./.runtimefs
    else
        echo "Filesystem is not mounted"
    fi
}

case "${1:-help}" in
    start)
        if [ -f ./runtimefs_disk.img ] && mount | grep -q "./.runtimefs"; then
            echo "Filesystem already mounted."
        else
            setup_filesystem
        fi
        start_containers
        ;;
    stop)
        stop_containers
        unmount_filesystem
        ;;
    restart)
        stop_containers
        unmount_filesystem
        setup_filesystem
        start_containers
        ;;
    clean)
        stop_containers
        unmount_filesystem
        clean_filesystem
        ;;
    status)
        show_status
        ;;
    help|*)
        show_help
        ;;
esac
