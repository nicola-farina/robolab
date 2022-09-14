#!/bin/bash

IMAGE="nicolafarina/robolab"
CONTAINER_NAME="robolab"
FORCE=false

usage() { 
    echo "USAGE: $0 [-f] <path>"
    echo "[OPTIONAL] -f: forces container to stop if already running"
    echo "<path>: absolute path of the directory which will map to home inside the docker container"
    exit 1
} 

run_container() {
    docker run -dit --rm \
    -v /etc/passwd:/etc/passwd:ro \
    -v $VOLUME_PATH:$HOME \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -u $UID:users \
    -w $HOME \
    -e DISPLAY=:0.0 \
    -e QT_X11_NO_MITSHM=1 \
    -e NVIDIA_VISIBLE_DEVICES=all \
    --device=/dev/dri:/dev/dri \
    --name $CONTAINER_NAME \
    --hostname $CONTAINER_NAME \
    $IMAGE > /dev/null
}

#Check that there are 1 or 2 arguments
if [ $# -eq 0 ] || [ $# -gt 2 ]; then
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

#If two arguments, first -f then volume directory
if [ $# -eq 2 ]; then
    if [ "$1" == "-f" ] && [ -d $2 ]; then
        FORCE=true
        VOLUME_PATH=$2
    else
        usage
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
        run_container
    else
        echo "Container $CONTAINER_NAME already running, attaching..."
    fi
else
    run_container
fi

echo "Connected to container $CONTAINER_NAME"
docker exec -it $CONTAINER_NAME bash