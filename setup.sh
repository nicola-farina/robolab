#!/bin/bash

IMAGE="nicolafarina/robolab"
CONTAINER_NAME="robolab"
FORCE=false
NVIDIA=false

usage() { 
    echo "USAGE: $0 [-f] <path>"
    echo "[OPTIONAL] -f: forces container to stop if already running"
    echo "[OPTIONAL] -n: use if you have an NVIDIA GPU"
    echo "<path>: absolute path of the directory which will map to home inside the docker container"
    exit 1
} 

run_container() {
    docker run -dit --rm \
    -v /etc/passwd:/etc/passwd:ro \
    -v $VOLUME_PATH:$HOME \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v $HOME/.ssh:/$HOME/.ssh:ro \
    -v $SSH_AUTH_SOCK:/ssh-agent:ro \
    -u $UID:users \
    -w $HOME \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -e DOCKER=1 \
    -e SSH_AUTH_SOCK=/ssh-agent \
    --device=/dev/dri:/dev/dri \
    --name $CONTAINER_NAME \
    --hostname $CONTAINER_NAME \
    $IMAGE > /dev/null
}

run_container_nvidia() {
    docker run -dit --rm \
    -v /etc/passwd:/etc/passwd:ro \
    -v $VOLUME_PATH:$HOME \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -u $UID:users \
    -w $HOME \
    -e DISPLAY=$DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -e DOCKER=1 \
    -e NVIDIA_VISIBLE_DEVICES=all \
    -e NVIDIA_DRIVER_CAPABILITIES=all \
    --device=/dev/dri:/dev/dri \
    --name $CONTAINER_NAME \
    --hostname $CONTAINER_NAME \
    --runtime=nvidia \
    $IMAGE > /dev/null
}


#Check that there are 1, 2 or 3 arguments
if [ $# -eq 0 ] || [ $# -gt 3 ]; then
    usage
fi

#If only one argument, it must be the volume directory
if [ $# -eq 1 ]; then
    if [ -d $1 ]; then
        VOLUME_PATH=$1
    else
        usage
    fi
fi  

#If two arguments, first -f then volume directory; or first -n then volume directory
if [ $# -eq 2 ]; then
    if [ "$1" == "-f" ] && [ -d $2 ]; then
        FORCE=true
        VOLUME_PATH=$2
    else
        if [ "$1" == "-n" ] && [ -d $2 ]; then
            NVIDIA=true
            VOLUME_PATH=$2
        else
            usage
        fi
    fi
fi

#If three arguments, first -f and -n, then volume directory
if [ $# -eq 3 ]; then
    if [ "$1" == "-f" ] && [ "$2" == "-n"] && [ -d $3 ]; then
        FORCE=true
        NVIDIA=true
        VOLUME_PATH=$3
    else
        if [ "$1" == "-n" ] && [ "$2" == "-f"] && [ -d $3 ]; then
            FORCE=true
            NVIDIA=true
            VOLUME_PATH=$3
        else
            usage
        fi
    fi
fi

#Create code base folders if not present
CODEBASE_PATH_OUTSIDE="$VOLUME_PATH/src"
if [ ! -d $CODEBASE_PATH_OUTSIDE ]; then
    mkdir -p $CODEBASE_PATH_OUTSIDE
fi

#Setup .bashrc
CODEBASE_PATH_INSIDE="$HOME/src"
if [ ! -f "$VOLUME_PATH/.bashrc" ]; then
    cp /etc/skel/.bashrc $VOLUME_PATH
    printf "\n\
export PATH=/opt/openrobots/bin:\$PATH \n\
export PKG_CONFIG_PATH=/opt/openrobots/lib/pkgconfig:\$PKG_CONFIG_PATH \n\
export LD_LIBRARY_PATH=/opt/openrobots/lib:\$LD_LIBRARY_PATH \n\
export ROS_PACKAGE_PATH=/opt/openrobots/share \n\
export PYTHONPATH=\$PYTHONPATH:/opt/openrobots/lib/python3.8/site-packages \n\
export PYTHONPATH=\$PYTHONPATH:$CODEBASE_PATH_INSIDE\n" >> $VOLUME_PATH/.bashrc
fi

#Check if container is already running
if [ "$( docker container inspect -f '{{.State.Status}}' $CONTAINER_NAME 2>/dev/null)" == "running" ]; then
    #Stop if -f flag is set
    if [ $FORCE = true ]; then
        echo "Stopping container $CONTAINER_NAME..."
        docker container stop $CONTAINER_NAME > /dev/null
        if [ $NVIDIA = true ]; then
            run_container_nvidia
        else
            run_container
        fi
    else
        echo "Container $CONTAINER_NAME already running, attaching..."
    fi
else
    if [ $NVIDIA = true ]; then
        run_container_nvidia
    else
        run_container
    fi
fi

docker exec -it $CONTAINER_NAME bash