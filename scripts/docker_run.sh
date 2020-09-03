##
## This script creates or starts or connects to the mlab_ros container.
##
## Copy this file to ~/bin (you may need to add ~/bin to path), change its name
## and access,
##      chmod +x mlab_docker_run.sh
##
##

# Paths. Modify them for your system.
# See README.md for more details.
CONTAINER_NAME=mlab_ros
DOCKER_IMAGE=yifan/ros-gpu:melodic-nvidia # the image name in build.sh
GIT_PATH=~/Git # this path on the host machine will be mounted to /workspace/Git
CATKIN_WS_PATH=~/Dockers/mlab/catkin_ws # this path on the host machine will be
                                        # mounted to /workspace/catkin_ws

##
## The following code check if the container is create/stopped/running before
## trying to create/start/attach to it. This avoids duplicating containers.
##
set -euo pipefail
if [ "$(docker ps -q -f name="$CONTAINER_NAME")" ]; then
    # the container is already running.
    echo "The container is already running. Now connect to it."
    docker exec -it "$CONTAINER_NAME" bash
    exit
else
    # the container is not running
    if [ "$(docker ps -aq -f status=exited -f name="$CONTAINER_NAME")" ]; then
        # the container exists. start and connect to it
        echo "The container exists. Now start and connect to it."
        docker start "$CONTAINER_NAME"
        docker exec -it "$CONTAINER_NAME" bash
        exit
    fi
fi

echo "The container does not exist. Creating it:"

# Which GPUs to use; see https://github.com/NVIDIA/nvidia-docker
GPUS="all"

XSOCK=/tmp/.X11-unix

XAUTH=`pwd`/.tmp/docker.xauth
XAUTH_DOCKER=/tmp/.docker.xauth

if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo "$xauth_list" | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

docker run -it \
    --name "$CONTAINER_NAME" \
    --gpus "$GPUS" \
    --env="DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --env="XAUTHORITY=$XAUTH_DOCKER" \
    --volume="$XSOCK:$XSOCK:rw" \
    --volume="$XAUTH:$XAUTH_DOCKER:rw" \
    -v "$GIT_PATH:/workspace/Git" \
    -v "$CATKIN_WS_PATH:/workspace/catkin_ws" \
    $DOCKER_IMAGE \
    bash